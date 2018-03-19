#!/usr/bin/env sh
# 
# Safe and semi automatic way to remove old kernels
#

INSTALLED_LIST=/tmp/kernel_installed.list

REMOVE_KERNEL_VER=$1

# Get installed kernel versions
sudo dpkg --get-selections | egrep "linux-headers-|linux-headers-|linux-image-|linux-image-extra-|linux-signed-image-" | egrep '[0-9]+' > ${INSTALLED_LIST}


CURRENT_KERNEL_VER=`uname -r | sed 's/-generic//g'`

echo "CURRENT_KERNEL_VER=${CURRENT_KERNEL_VER}"


#cat ${INSTALLED_LIST}

echo "INSTALLED:"
HEADER_LIST="`cat ${INSTALLED_LIST} | grep "^linux-headers-" | grep -v '\-generic' | cut -d'-' -f3-4 | awk '{print $1}' | sort -u`"
echo " * HEADER VERs         : `echo ${HEADER_LIST}`"

GENERIC_HEADER_LIST="`cat ${INSTALLED_LIST} | grep "^linux-headers-" | grep '\-generic' | cut -d'-' -f3-4 | awk '{print $1}' | sort -u`"
echo " * GENERIG HEADER VERs : `echo ${GENERIC_HEADER_LIST}`"

IMAGE_LIST=`cat ${INSTALLED_LIST} | grep "^linux-image-" | grep -v "^linux-image-extra-" | cut -d'-' -f3-4 | sort -u`
echo " * IMAGE VERs          : `echo ${IMAGE_LIST}`"

IMAGE_EXTRA_LIST=`cat ${INSTALLED_LIST} | grep "^linux-image-extra-" | cut -d'-' -f4-5 | sort -u`
echo " * IMAGE EXTRA VERs    : `echo ${IMAGE_EXTRA_LIST}`"

SIGNED_IMAGE_LIST=`cat ${INSTALLED_LIST} | grep "^linux-signed-image-" | cut -d'-' -f4-5 | sort -u`
echo " * SIGNED IMAGE VERs   : `echo ${SIGNED_IMAGE_LIST}`"


echo "CLEANUP:"
if [ -z "${REMOVE_KERNEL_VER}" ]; then
   echo " * Script can suggest you correct command to remove outdated kernel version. Pass it version as argument"
   echo " * Example: $0 \"4.4.0-XX\""
elif [ "${CURRENT_KERNEL_VER}" = "${REMOVE_KERNEL_VER}" ]; then
    echo " * Kernel version (${REMOVE_KERNEL_VER}) is currently used. DO NOT REMOVE THAT!"
else

    # Prepare default kernek components to purge
    PURGE_HEADERS="linux-headers-${REMOVE_KERNEL_VER}"
    PURGE_GENERIC_HEADERS="linux-headers-${REMOVE_KERNEL_VER}-generic"
    PURGE_IMAGE="linux-image-${REMOVE_KERNEL_VER}-generic"
    PURGE_IMAGE_EXTRA="linux-image-extra-${REMOVE_KERNEL_VER}-generic"
    PURGE_SIGNED_IMAGE="linux-signed-image-${REMOVE_KERNEL_VER}-generic"

    # Check if kernel versions components installed
    [ -z "`echo ${HEADER_LIST}         | grep -w ${REMOVE_KERNEL_VER}`" ] && PURGE_HEADERS=""         && echo "No any (linux-headers-${REMOVE_KERNEL_VER}) found!"
    [ -z "`echo ${GENERIC_HEADER_LIST} | grep -w ${REMOVE_KERNEL_VER}`" ] && PURGE_GENERIC_HEADERS="" && echo "No any (linux-headers-${REMOVE_KERNEL_VER}-generic) found!"
    [ -z "`echo ${IMAGE_LIST}          | grep -w ${REMOVE_KERNEL_VER}`" ] && PURGE_IMAGE=""           && echo "No any (linux-image-${REMOVE_KERNEL_VER}-generic) found!"
    [ -z "`echo ${IMAGE_EXTRA_LIST}    | grep -w ${REMOVE_KERNEL_VER}`" ] && PURGE_IMAGE_EXTRA=""     && echo "No any (linux-image-extra-${REMOVE_KERNEL_VER}-generic) found!"
    [ -z "`echo ${SIGNED_IMAGE_LIST}   | grep -w ${REMOVE_KERNEL_VER}`" ] && PURGE_SIGNED_IMAGE=""    && echo "No any (linux-signed-image-${REMOVE_KERNEL_VER}-generic) found!"

    echo " * Use this command to purge selected kernel version:"
    echo "   sudo apt purge ${PURGE_HEADERS} ${PURGE_GENERIC_HEADERS} ${PURGE_IMAGE} ${PURGE_IMAGE_EXTRA} ${PURGE_SIGNED_IMAGE}"

fi








