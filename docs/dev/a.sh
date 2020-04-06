#!/bin/sh
while read -r ln;
do
find /Users/alton/Documents/project/docs  -name $ln -exec rm {} \;
done < a.log
