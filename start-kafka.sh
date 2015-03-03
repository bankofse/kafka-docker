#!/bin/bash

if [[ -z "$KAFKA_ADVERTISED_PORT" ]]; then
    export KAFKA_ADVERTISED_PORT=$(docker port kafka 9092 | sed -r "s/.*:(.*)/\1/g")
fi
if [[ -z "$KAFKA_BROKER_ID" ]]; then
    export KAFKA_BROKER_ID=$KAFKA_ADVERTISED_PORT
fi
if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    export KAFKA_LOG_DIRS="/kafka/kafka-logs-$KAFKA_BROKER_ID"
fi
if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then

    address=`dig @$CONSUL_URL zookeeper-2181.service.nyc.consul +short`
    port=`dig @$CONSUL_URL zookeeper-2181.service.nyc.consul SRV +short | awk '{print $3}'`

    export KAFKA_ZOOKEEPER_CONNECT=$(echo ${address}:${port}) 
    echo $KAFKA_ZOOKEEPER_CONNECT

fi

if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i "s/^(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
    unset KAFKA_HEAP_OPTS
fi

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$kafka_name=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties #note that no config values may contain an '@' char
    else
        echo "$kafka_name=${!env_var}" >> $KAFKA_HOME/config/server.properties
    fi
  fi
done

$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
