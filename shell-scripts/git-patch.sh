#!/bin/bash

# format one patch
git checkout -b dev
git reset --hard commit-num
git merge master --squash
git commit -m "message"
git format-patch HEAD^

# Apply all patches
git init
git config user.name "RayWang"
git config user.email "wanglei@loongson.cn"
git add .
git commit -a -q -m "3.10.0-14.12.05 baseline."
git am %{patches} < /dev/null
