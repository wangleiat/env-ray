#!/bin/bash
# 

# mock debug mode
#DEBUG="-v"

#-----------------------------------------------------------
# Env for rpmrc
DIST="fc21.loongson"
ARCH="mips64el"
TARGET_ARCH="mipsn32el"
VENDOR="Loongson"
PACKAGER="Loongson"
HOSTNAME="loongson3a-builder.loongnix.org"
RELEASEVER="21"
ISA_NAME="mips"
ISA_BITS="n32"
# yum repo url
BASEURL="http://ftp.loongnix.org/os/loongnix/1.0/os/"
#-----------------------------------------------------------

# check mock utils
if ! which mock > /dev/null 2>&1 ; then
    echo "Please install mock utils first!"
    echo -e "\t:sudo yum install mock"
    exit
fi

# check user
if [ ${UID} -eq 0 ]; then
    echo "mock is not intended to be run directly as root!"
    exit
fi
if ! groups | grep '\<mock\>' ; then
    echo "Please add ${USER} to mock group!"
    echo -e "\t:sudo usermod -a -G mock ${USER}"
    exit
fi

#
# Env for some directory
#

if [ -w ${PWD} ]; then
    MOCKDIR="${PWD}/$(dirname ${0})/mock-build"
else 
    MOCKDIR="${HOME}/mock-build"
fi
# check MOCKDIR
if [ ! -d ${MOCKDIR} ]; then
    rm -f ${MOCKDIR} 2>/dev/null
    mkdir -m 2775 -p ${MOCKDIR}
    chgrp mock ${MOCKDIR}
fi

# mock basedir
BASE_DIR="${MOCKDIR}/build"

# cache dir
CACHE_DIR="${MOCKDIR}/cache"
# root cache dir
ROOT_CACHE_DIR="${CACHE_DIR}/${DIST}-${ARCH}/root_cache"
# c cache dir
C_CACHE_DIR="${CACHE_DIR}/${DIST}-${ARCH}/ccache"
# yum cache dir
YUM_CACHE_DIR="${CACHE_DIR}/${DIST}-${ARCH}/yum_cache"

# config files dir
CONFIGDIR="${MOCKDIR}/mock-conf"
# check conf dir
if [ ! -d ${CONFIGDIR} ]; then
    rm -f ${CONFIGDIR} 2>/dev/null
    mkdir -p ${CONFIGDIR}
fi
RESULT_DIR="${MOCKDIR}/mock-result-${DIST}"
# check result dir
if [ ! -d ${RESULT_DIR} ]; then
    mkdir -p ${RESULT_DIR}/{all-ok,all-err,srpms,debug,rpms}
fi
RESULT_ALL="${RESULT_DIR}/all-ok"  # build ok result
RESULT_ERR="${RESULT_DIR}/all-err"  # build error result

# check default config files
if [ ! -e ${CONFIGDIR}/site-defaults.cfg ]; then
    touch ${CONFIGDIR}/site-defaults.cfg
fi
if [ ! -e ${CONFIGDIR}/logging.ini ]; then
cat > ${CONFIGDIR}/logging.ini << EOF
[formatters]
keys: detailed,simple,unadorned,state

[handlers]
keys: simple_console,detailed_console,unadorned_console,simple_console_warnings_only

[loggers]
keys: root,build,state,mockbuild

[formatter_state]
format: %(asctime)s - %(message)s

[formatter_unadorned]
format: %(message)s

[formatter_simple]
format: %(levelname)s: %(message)s

;useful for debugging:
[formatter_detailed]
format: %(levelname)s %(filename)s:%(lineno)d:  %(message)s

[handler_unadorned_console]
class: StreamHandler
args: []
formatter: unadorned
level: INFO

[handler_simple_console]
class: StreamHandler
args: []
formatter: simple
level: INFO

[handler_simple_console_warnings_only]
class: StreamHandler
args: []
formatter: simple
level: WARNING

[handler_detailed_console]
class: StreamHandler
args: []
formatter: detailed
level: WARNING

; usually dont want to set a level for loggers
; this way all handlers get all messages, and messages can be filtered
; at the handler level
;
; all these loggers default to a console output handler
;
[logger_root]
level: NOTSET
handlers: simple_console

; mockbuild logger normally has no output
;  catches stuff like mockbuild.trace_decorator and mockbuild.util
;  dont normally want to propagate to root logger, either
[logger_mockbuild]
level: NOTSET
handlers:
qualname: mockbuild
propagate: 1

[logger_state]
level: NOTSET
; unadorned_console only outputs INFO or above
handlers: unadorned_console
qualname: mockbuild.Root.state
propagate: 0

[logger_build]
level: NOTSET
handlers: simple_console_warnings_only
qualname: mockbuild.Root.build
propagate: 0

; the following is a list mock logger qualnames used within the code:
;
;  qualname: mockbuild.util
;  qualname: mockbuild.uid
;  qualname: mockbuild.trace_decorator

EOF
fi
if [ ! -e ${RESULT_DIR}/link.sh ]; then
cat > ${RESULT_DIR}/link.sh << EOF
#!/bin/bash
for BUILD in all-ok/*
do
  for RPM in \$BUILD/*.rpm
  do
    case \$RPM in
      *.src.rpm)
        echo SRC \$RPM
        ln -f \$RPM srpms
      ;;
      *-debuginfo*)
        echo DBG \$RPM
        ln -f \$RPM debug
      ;;
      *)
        echo BIN \$RPM
        ln -f \$RPM rpms 
      ;;
    esac
  done
done
EOF
    chmod +x ${RESULT_DIR}/link.sh
fi

OPTIONS=""
if [ $# -eq 0 ]; then
    echo "Please input the source rpm!"
    echo -e "\t$0 <file.src.rpm> [mock options...]"
    exit
else
    SRC_RPM=$1
    while [ $# -ne 0 ]; do
        OPTIONS="${OPTIONS} $2"
        shift
    done
fi

# rpm name
NAME=$(rpm -qpi ${SRC_RPM} | grep "^Name" | awk '{print $3}')
VERSION=$(rpm -qpi ${SRC_RPM} | grep "^Version" | awk '{print $3}')
RELEASE=$(rpm -qpi ${SRC_RPM} | grep "^Release" | awk '{print $3}')
CONF_NAME="${NAME}-${VERSION}-${RELEASE}"

# mock Build config file
cat > ${CONFIGDIR}/${CONF_NAME}.cfg << EOF
config_opts['environment']['HOSTNAME'] = '${HOSTNAME}'
config_opts['chroothome'] = '/builddir'                                                                                 
config_opts['use_host_resolv'] = False
config_opts['basedir'] = '${BASE_DIR}'
#config_opts['rpmbuild_timeout'] = 86400
config_opts['root'] = '${CONF_NAME}'
config_opts['target_arch'] = '${TARGET_ARCH}'
config_opts['chroot_setup_cmd'] = 'install @buildsys-build'
config_opts['dist'] = '${DIST}'  # only useful for --resultdir variable subst
config_opts['releasever'] = '${RELEASEVER}'

config_opts['plugin_conf']['package_state_enable'] = False
config_opts['plugin_conf']['root_cache_enable'] = True
config_opts['plugin_conf']['root_cache_opts']['age_check'] = True
config_opts['plugin_conf']['root_cache_opts']['max_age_days'] = 15
config_opts['plugin_conf']['root_cache_opts']['dir'] = '${ROOT_CACHE_DIR}'
config_opts['plugin_conf']['ccache_enable'] = True
config_opts['plugin_conf']['ccache_opts']['max_cache_size'] = '4G'
config_opts['plugin_conf']['ccache_opts']['dir'] = '${C_CACHE_DIR}'
config_opts['plugin_conf']['yum_cache_enable'] = True
config_opts['plugin_conf']['yum_cache_opts']['max_age_days'] = 30
config_opts['plugin_conf']['yum_cache_opts']['dir'] = '${YUM_CACHE_DIR}'

config_opts['macros']['%_host'] = '${ARCH}-redhat-linux'
config_opts['macros']['%_host_cpu'] = '${ARCH}'
config_opts['macros']['%vendor'] = '${VENDOR}'
config_opts['macros']['%_topdir'] = '/builddir/build'
config_opts['macros']['%_rpmfilename'] = '%%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm'
config_opts['macros']['%packager'] = '${PACKAGER}'
config_opts['macros']['%dist'] = '.${DIST}'
config_opts['macros']['%__isa_name'] = '${ISA_NAME}'
config_opts['macros']['%__isa_bits'] = '${ISA_BITS}'
config_opts['macros']['%__perl'] = '/usr/bin/perl'
config_opts['macros']['%__python'] = '/usr/bin/python'

config_opts['yum.conf'] = """
[main]
cachedir=/var/cache/yum
debuglevel=1
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
syslog_ident=mock
syslog_device=

# repos

[fedora]
name=fedora
enable=1
gpgcheck=0
baseurl=${BASEURL}

[local]
name=local
baseurl=file://${RESULT_DIR}/rpms/
cost=2000
enabled=0
"""                                                                                                                     
EOF

# cache file must be newer than config file
touch ${ROOT_CACHE_DIR}/* > /dev/null 2>&1

# mock build
if [ -z ${OPTIONS} ] || [[ "${OPTIONS}" =~ "--no-clean" ]]; then
    mock ${DEBUG} ${OPTIONS} --configdir=${CONFIGDIR} -r ${CONF_NAME} ${SRC_RPM}
    RET=$?
    TIME_STR=$(date +"%F %T")
    PKG_NAME=$(basename ${SRC_RPM})
else
    mock ${DEBUG} ${OPTIONS} --configdir=${CONFIGDIR} -r ${CONF_NAME}
    exit
fi

# result 
# ok: move rpms to dist dirs and delete build environment.
# err: nothing to do.
if [ ${RET} -eq 0 ] ; then
    rm -rf ${RESULT_ALL}/${CONF_NAME} 2>/dev/null
    rm -rf ${RESULT_ERR}/${CONF_NAME} 2>/dev/null
    set -e
    set -x
    /bin/cp -a ${BASE_DIR}/${CONF_NAME}/result ${RESULT_ALL}/${CONF_NAME} 2>/dev/null
    set +x
    set +e
    mock --configdir=${CONFIGDIR} -r ${CONF_NAME} --clean
    echo "------------------------------------------------------------"
    echo "OK:  ${TIME_STR}: ${PKG_NAME}"
    echo "TOPDIR=${MOCKDIR}"
    echo "BUILD_ROOT=${BASE_DIR}"
    echo "CACHE_DIR=${CACHE_DIR}"
    echo "CONFIG_DIR=${CONFIGDIR}"
    echo "RESULT_LOG_DIR=${RESULT_DIR}"
    echo ""
    echo "for use new package build:"
    echo "   # cd ${RESULT_DIR}"
    echo "   # ./link.sh"
    echo "   # createrepo/createrepo_c rpms"
    echo "------------------------------------------------------------"
else
    rm -rf ${RESULT_ERR}/${CONF_NAME} 2>/dev/null
    /bin/cp -a ${BASE_DIR}/${CONF_NAME}/result ${RESULT_ERR}/${CONF_NAME} 2>/dev/null
    #mock --configdir=${CONFIGDIR} -r ${CONF_NAME} --clean
    echo "------------------------------------------------------------"
    echo "ERROR:  ${TIME_STR}: ${PKG_NAME}"
    echo "------------------------------------------------------------"
fi

