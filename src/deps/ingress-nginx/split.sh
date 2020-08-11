#!/usr/bin/env bash

set -euxo pipefail

if [ -z "$1" ]; then
  echo "Please provide an output directory"
  exit 1
fi

awk -v out="$1" -F": " '
   $0~/^# Source: / {
       file=out"/"$2;
       if (!(file in filemap)) {
           filemap[file] = 1
           print "Creating "file;
           system ("mkdir -p $(dirname "file"); echo -n "" > "file);
       }
   }
   $0!~/^#/ {
       if (file) {
           print $0 >> file;
       }
   }' <./deploy/yaml
