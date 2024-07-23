#!/usr/bin/env bash

cd ./charts 

for file in $(find \( -path './edge*' -o -path './mod*' -a ! -path './*keycloak' \) -type f -name 'Chart.yaml' | sort); 
do 
version=$(grep ^version: $file | awk -F ': ' '{print $2}')
new_version=$(echo $version | awk -F. '{printf "%d.%d.%d", $1, $2, $3+1}')

sed -i "/^version:/s/: .*/: $new_version/" $file
done
