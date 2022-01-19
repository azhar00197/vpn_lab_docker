FROM ubuntu:focal
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
RUN apt update
RUN apt-get install nano vim -y
RUN apt-get install openssh-server gnupg git -y
RUN apt-get install iputils-ping traceroute iproute2 curl iptables   -y