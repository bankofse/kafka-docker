FROM ubuntu:trusty

MAINTAINER Wurstmeister 

RUN apt-get update; apt-get install -y unzip  openjdk-6-jdk wget git docker.io

RUN wget -q http://mirrors.ibiblio.org/apache/kafka/0.8.2.0/kafka-0.8.2.0-src.tgz -O /tmp/kafka_2.10-0.8.2.0.tgz
RUN tar xfz /tmp/kafka_2.10-0.8.2.0.tgz -C /opt

RUN apt-get install -y curl

VOLUME ["/kafka"]

ADD ./config /opt/kafka_2.10-0.8.2.0/config

ENV KAFKA_HOME /opt/kafka_2.10-0.8.2.0
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh

CMD start-kafka.sh
