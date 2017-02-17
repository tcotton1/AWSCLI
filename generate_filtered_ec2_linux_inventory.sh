#!/bin/bash
#Output IP #name for each non windows server found
#create group headings for each profile
#Sort each group by IP address
#Filters out known appliances and a few others
# f5,dsm,qualsys etc.

outputlocation="./EC2-Filtered-Linux-inv"
profiles=("dev" "prod" "pci" "uat" "mgmt" "util")

if [ -f $outputlocation ] ; then
    rm $outputlocation
fi

for profile in "${profiles[@]}"
do
echo [$profile] >> "$outputlocation"
aws ec2 describe-instances --query "Reservations[].Instances[].[PrivateIpAddress,Tags[?Key== 'Name' ]|[0].Value,Platform]" --output text --profile $profile | sed -e 's/\t/ #/' -e 's/\tNone//' -e '/\twindows/d' -e '/\(f5\|dsm\|qualys\|kickstart\)/d' | awk '{print $0| "sort -t . -k 2,2n -k 3,3n -k 4,4n"}'  >> "$outputlocation"
done

