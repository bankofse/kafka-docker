#!/bin/bash

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop| cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
    echo ${temp##*|}
}
 
json=`curl -s -X GET $CONSUL_URL/v1/catalog/service/zookeeper-2181`
prop='ServicePort'
port=`jsonval`

json=`curl -s -X GET $CONSUL_URL/v1/catalog/service/zookeeper-2181`
prop='Address'
address=`jsonval`

 
echo ${address}:${port%?}
