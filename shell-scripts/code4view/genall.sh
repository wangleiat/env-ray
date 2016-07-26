#!/bin/sh
#-------------
# ctags file
#-------------

#ctags for c,c++
ctags --extra=+q --fields=+Saim --c++-kinds=+lpx --c-kinds=+lpx -R .

#ctags for java
#ctags --java-kinds=+l -R .

#nomal
#ctags -R .

#-------------
# cscope file
#-------------

#cscope -Rkbq for kernel source
cscope -Rbq

#-------------
# lookup tags file
# generate tag file for vim lookupfile plugin
#-------------

echo -e '!_TAG_FILE_SORTED\t2\t/2=foldcase/'> filenametags
find . -not -regex '.*\.\(png\|gif\)' ! \( -path "*.svn*" -o -path "*.git*" \) -type f -printf "%f\t%p\t1\n" | sort -f>> filenametags
