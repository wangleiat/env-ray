#!/bin/sh
#ctags --list-kinds

#ctags for c,c++
ctags --extra=+q --fields=+Saim --c++-kinds=+lpx --c-kinds=+lpx -R .

#ctags for java
#ctags --java-kinds=+l -R .

#nomal
#ctags -R .
