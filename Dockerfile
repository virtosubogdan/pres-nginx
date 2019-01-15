FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install apt-utils net-tools vim nginx tcpdump python3 curl lsof -y --assume-yes
RUN apt-get clean