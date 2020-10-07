#===-------------------- llvm centos8 ockerfile -------------------------===//
#
#                     The LLVM Compiler Infrastructure
#
# This file is distributed under the University of Illinois Open Source
# License. See LICENSE.TXT for details.
#
#===----------------------------------------------------------------------===//

FROM centos:latest
LABEL maintainer "Ray Wang"

# Install build dependencies of llvm.
RUN dnf update -y && \
      rpmdb --rebuilddb 
RUN dnf install 'dnf-command(config-manager)' -y && \
      dnf config-manager --set-enabled PowerTools && \
      dnf install ninja-build cmake gcc-c++ libffi-devel python3 -y && \
      dnf clean all
