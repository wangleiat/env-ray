#!/bin/sh
# generate tag file for vim lookupfile plugin
echo -e '!_TAG_FILE_SORTED\t2\t/2=foldcase/'> filenametags
find . -not -regex '.*\.\(png\|gif\)' ! \( -path "*.svn*" -o -path "*.git*" \) -type f -printf "%f\t%p\t1\n" | sort -f>> filenametags
