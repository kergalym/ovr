#!/bin/bash
### 32- and 64-bit system buildscript
### Author:  Galym Kerimbekov
### E-mail: kerimbekov.galym@yandex.ru

### Copyright (C) 2015 Galym Kerimbekov 

### This program is free software; you can redistribute it and/or
### modify it under the terms of the GNU General Public License
### as published by the Free Software Foundation; either version 2
### of the License, or (at your option) any later version.

### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
### GNU General Public License for more details.

### You should have received a copy of the GNU General Public License
### along with this program; if not, write to the Free Software
### Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

MACHINE_TYPE=`uname -m`
BUILDDATA="/usr/share/livebuild-scripts"
BUILDROOT="/mnt/gentoo64"
ARCH="amd64_xfce"
LOOP_IMAGE="/media/WDGR/live64_xfce.img"
ISO_NAME="Gentoo_Linux_XFCE_amd64.iso"
LIVE_IMAGE="livecd.squashfs"
STAGE3="http://mirror.neolabs.kz/gentoo/pub/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20150709.tar.bz2"
PORTS="http://distfiles.gentoo.org/snapshots/portage-20140823.tar.bz2"
REQS="'sys-fs/e2fsprogs app-cdr/cdrtools sys-fs/squashfs-tools sys-boot/syslinux sys-devel/gcc'"
CHROOTPARM="chroot"
FILES="portage*.tar.bz2 stage3*.tar.bz2"

function set_root
{
  if [[ $(id -u) -ne 0 ]]; then
    sudo bash -c "exit" 2> /dev/null
    if [[ $? -ne 0 ]]; then
      echo "Unable to start, need root privileges"
      return 1
    fi
    sudo bash ${@:1}
    exit $?
  fi
  return 0
}

if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    echo "Starting build 64-bit system on 64-bit host system"
    sleep 1
elif  [ ${MACHINE_TYPE} == 'i686' ]; then
    echo "Starting build 32-bit system on 32-bit host system"
    sleep 1
fi

if grep -q sys-fs/e2fsprogs /var/lib/portage/world ; then
      echo "Required packages has been installed"
else
      echo -e "You'll need installed $REQS to continue \n"
      emerge sys-fs/e2fsprogs
fi 
if grep -q app-cdr/cdrtools /var/lib/portage/world ; then
      echo "Required packages has been installed"
else
      echo -e "You'll need installed $REQS to continue \n"
      emerge app-cdr/cdrtools
fi
if grep -q sys-fs/squashfs-tools /var/lib/portage/world ; then
      echo "Required packages has been installed"
else
      echo -e "You'll need installed $REQS to continue \n"
      emerge sys-fs/squashfs-tools
fi 
if grep -q sys-boot/syslinux /var/lib/portage/world ; then
      echo "Required packages has been installed"
else
      echo -e "You'll need installed $REQS to continue \n"
      emerge sys-boot/syslinux
fi
if grep -q sys-devel/gcc /var/lib/portage/world ; then
      echo "Required packages has been installed"
else
      echo -e "You'll need installed $REQS to continue \n"
      emerge sys-devel/gcc
fi      
sleep 1

start() {

   echo "Mounting chroot"
   
   mount $LOOP_IMAGE $BUILDROOT
   cp -L /etc/resolv.conf $BUILDROOT/etc/
   cp $BUILDDATA/scripts/kernel-config $BUILDROOT/usr/src/linux/.config
   cp $BUILDDATA/scripts/inchroot* $BUILDROOT/
   cp $BUILDDATA/scripts/installation-helper64.sh $BUILDROOT/usr/local/sbin/installation-helper.sh
   cp $BUILDDATA/scripts/stage3.configs.tar  $BUILDROOT/
   cp $BUILDDATA/scripts/initrd.defaults $BUILDDATA/scripts/initrd.scripts $BUILDDATA/scripts/linuxrc $BUILDROOT/usr/share/genkernel/defaults/
   tar xpf $BUILDDATA/scripts/xfce.config.tar -C $BUILDROOT/{home/user,root} 
   chmod +x $BUILDROOT/usr/bin/installer
   mount -t proc none $BUILDROOT/proc >/dev/null &
   mount --make-rprivate --rbind /sys $BUILDROOT/sys >/dev/null &
   mount --make-rprivate --rbind /dev $BUILDROOT/dev >/dev/null &
   if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  linux32 chroot ${BUILDROOT} /bin/bash -c "/inchroot.sh && touch /.stage1done"
	  sed -i 's/#source/source"/g' $BUILDROOT/etc/portage/make32.conf >/dev/null 
	  rm $BUILDROOT/etc/portage/make.conf
	  ln -s $BUILDROOT/etc/portage/make32.conf $BUILDROOT/etc/portage/make.conf
   elif  [ ${MACHINE_TYPE} == 'i686' ]; then
	  chroot ${BUILDROOT} /bin/bash -c "/inchroot.sh && touch /.stage1done"
	  sed -i 's/#source/source"/g' $BUILDROOT/etc/portage/make64.conf >/dev/null 
	  rm $BUILDROOT/etc/portage/make.conf
	  ln -s $BUILDROOT/etc/portage/make64.conf $BUILDROOT/etc/portage/make.conf
  fi

}

stop() {

   echo "Unmounting chroot"

   umount $BUILDROOT/proc
   umount $BUILDROOT/sys 
   umount -l $BUILDROOT/dev{/shm,/pts,} 
   umount $LOOP_IMAGE $BUILDROOT 
}

buildroot() {

if  [ -e $HOME/.work.session ] ; [ -a $LOOP_IMAGE ] ; then
    echo -e "Tarballs exists. \n"
    echo "Session exist"
else 
    echo -e "Downloading Stage3"
    sleep 1
    wget -c -O $HOME/stage3-amd64.tar.bz2 $STAGE3
    echo -e "Downloading Portage"
    sleep 1
    wget -c -O $HOME/portage-latest.tar.bz2 $PORTS
    echo -e "Create block device \n"
    sleep 1
    dd if=/dev/zero of=$LOOP_IMAGE bs=1024K count=20000  || die() { echo "$@" 1>&2 ; exit 1; }
    echo -e "Make Ext4fs on block device \n"
    mkfs.ext4 $LOOP_IMAGE
    echo "Mounting chroot"
    mount $LOOP_IMAGE $BUILDROOT
    echo -e "Unpacking Stage3 \n"
    sleep 1
    tar xpf $HOME/stage3*amd64*.tar.bz2 -C $BUILDROOT 2> $BUILDROOT/build.log
    cp -L /etc/resolv.conf $BUILDROOT/etc/
    echo -e "Unpacking Portage \n"
    sleep 1
    tar xpf $HOME/portage*.tar.bz2 -C $BUILDROOT/usr 2> $BUILDROOT/buildport.log
    touch $HOME/.work.session
    echo -e "Stage3 & Portage Unpacked \n" 
    sleep 1
fi

}

iso() {

    rm $BUILDDATA/$ARCH/livedvd/$LIVE_IMAGE > /dev/null
    mount $LOOP_IMAGE $BUILDROOT
    cp $BUILDROOT/boot/kernel-genkernel* $BUILDDATA/$ARCH/livedvd/boot/vmlinuz 
    cp $BUILDROOT/boot/initramfs-genkernel* $BUILDDATA/$ARCH/livedvd/boot/initrd 
    mksquashfs $BUILDROOT $BUILDDATA/$ARCH/livedvd/$LIVE_IMAGE -comp xz -e $BUILDROOT/usr/portage/distfiles -e $BUILDROOT/usr/portage/packages  || die() { echo "$@" 1>&2 ; exit 1; }
    umount $LOOP_IMAGE $BUILDROOT 

if [ -a "$ISO_NAME" ]; then
    echo -e "$ISO_NAME exists! \n"
    sleep 1
    rm $ISO_NAME
    echo -e "Create ISO image"
    sleep 1
    echo -e "Gentoo" > $BUILDDATA/$ARCH/livedvd/livecd
    mkisofs -R -J -o $ISO_NAME -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -iso-level 4 -boot-info-table $BUILDDATA/$ARCH/livedvd/  || die() { echo "$@" 1>&2 ; exit 1; }
else
    echo -e "Create ISO image \n"
    sleep 1
    echo -e "Gentoo" > $BUILDDATA/$ARCH/livedvd/livecd
    mkisofs -R -J -o $ISO_NAME -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -iso-level 4 -boot-info-table $BUILDDATA/$ARCH/livedvd/  || die() { echo "$@" 1>&2 ; exit 1; }
    isohybrid $ISO_NAME || die() { echo "$@" 1>&2 ; exit 1; }
fi

}

usage() {
   echo "$0 [start|stop|iso|buildroot]"
}

if [ "$1" == "start" ]
then
   start
   stop
elif [ "$1" == "stop" ]
then
   stop
else
   usage
fi

if [ "$1" == "iso" ]
then
   iso
fi

if [ "$1" == "buildroot" ]
then
   buildroot
   stop
   start
   stop
fi
