#===------------ llvm docker debian10 Dockerfile -------------------------===//
#
#                     The LLVM Compiler Infrastructure
#
# This file is distributed under the University of Illinois Open Source
# License. See LICENSE.TXT for details.
#
#===----------------------------------------------------------------------===//
# Stage 1. Check out LLVM source code and run the build.
FROM debian:latest
LABEL maintainer "Ray Wang"
# Install build dependencies of llvm.
# First, Update the apt's source list and include the sources of the packages.
RUN echo "deb http://mirrors.huaweicloud.com/debian buster main" > /etc/apt/sources.list
# Install compiler, python and subversion.
RUN while true; do apt update && break ; done ; \
    apt install -y --no-install-recommends ca-certificates gnupg \
           build-essential python cmake ninja-build libffi-dev && \
    rm -rf /var/lib/apt/lists/*
