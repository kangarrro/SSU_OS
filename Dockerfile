FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y build-essential qemu gcc-multilib qemu-system-x86