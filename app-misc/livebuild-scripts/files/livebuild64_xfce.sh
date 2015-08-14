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

configfile="/etc/livebuild-scripts/livebuild64.conf"
source "$configfile"

if [ "$EUID" -ne 0 ]
   then echo "Please run as root"
     exit
fi

if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    echo "Starting build 64-bit system on 64-bit host system"
    sleep 1
elif  [ ${MACHINE_TYPE} == 'i686' ]; then
    echo "You cannot build 64-bit system on 32-bit host system"
    sleep 1
fi

if grep -q sys-fs/e2fsprogs /var/lib/portage/world ; then
      echo "'sys-fs/e2fsprogs' has been installed"
else
      echo -e "You'll need installed 'sys-fs/e2fsprogs' to continue \n"
      emerge sys-fs/e2fsprogs
fi 
if grep -q app-cdr/cdrtools /var/lib/portage/world ; then
      echo "'app-cdr/cdrtools' has been installed"
else
      echo -e "You'll need installed 'app-cdr/cdrtools' to continue \n"
      emerge app-cdr/cdrtools
fi
if grep -q sys-fs/squashfs-tools /var/lib/portage/world ; then
      echo "'sys-fs/squashfs-tools' has been installed"
else
      echo -e "You'll need installed 'sys-fs/squashfs-tools' to continue \n"
      emerge sys-fs/squashfs-tools
fi 
if grep -q sys-boot/syslinux /var/lib/portage/world ; then
      echo "'sys-boot/syslinux' has been installed"
else
      echo -e "You'll need installed 'sys-boot/syslinux' to continue \n"
      emerge sys-boot/syslinux
fi
if grep -q sys-devel/gcc /var/lib/portage/world ; then
      echo "'sys-devel/gcc' has been installed"
else
      echo -e "You'll need installed 'sys-devel/gcc' to continue \n"
      emerge sys-devel/gcc
fi 
if [ -d "$BUILDDATA" ]; then
      echo "Build directory exist. Updating..."
      rm -rf $BUILDDATA/i386*
      rm -rf $BUILDDATA/amd64*
      rm -rf $BUILDDATA/scripts*
      cp -r /usr/share/livebuild-scripts/i386* "$BUILDDATA"
      cp -r /usr/share/livebuild-scripts/amd64* "$BUILDDATA"
      cp -r /usr/share/livebuild-scripts/scripts* "$BUILDDATA"
elif [ ! -d "$BUILDDATA" ]; then
      echo "Build directory doesn't exist. Copying..."
      mkdir -p "$BUILDDATA"
      cp -r /usr/share/livebuild-scripts/i386* "$BUILDDATA"
      cp -r /usr/share/livebuild-scripts/amd64* "$BUILDDATA"
      cp -r /usr/share/livebuild-scripts/scripts* "$BUILDDATA"
fi
sleep 1

start() {

   echo "Mounting chroot"
   mount $LOOP_IMAGE $BUILDROOT
   cp $BUILDDATA/scripts/initrd.defaults $BUILDDATA/scripts/initrd.scripts $BUILDDATA/scripts/linuxrc $BUILDROOT/usr/share/genkernel/defaults/
   cp -L /etc/resolv.conf $BUILDROOT/etc/
   cp $BUILDDATA/scripts/*x86* $BUILDROOT/etc/kernels/
   cp $BUILDDATA/scripts/*x86_64* $BUILDROOT/etc/kernels/
   cp $BUILDDATA/scripts/inchroot* $BUILDROOT/
   rm -rf $BUILDROOT/root/.config $BUILDROOT/etc/skel/.config $BUILDROOT/home/user/.config
   tar xpf $BUILDDATA/scripts/xfce.config.tar -C $BUILDROOT/root
   tar xpf $BUILDDATA/scripts/xfce.config.tar -C $BUILDROOT/home/user 
   tar xpf $BUILDDATA/scripts/xfce.config.tar -C $BUILDROOT/etc/skel 
   cp $BUILDDATA/scripts/installation-helper64.sh $BUILDROOT/usr/local/sbin/installation-helper.sh
   rm $BUILDROOT/usr/sbin/installation-helper
   chroot ${BUILDROOT} /bin/bash -c 'ln -s /usr/local/sbin/installation-helper.sh /usr/sbin/installation-helper'
   chmod +x $BUILDROOT/usr/local/sbin/installation-helper.sh
   mount -t proc none $BUILDROOT/proc >/dev/null &
   mount --make-rprivate --rbind /sys $BUILDROOT/sys >/dev/null &
   mount --make-rprivate --rbind /dev $BUILDROOT/dev >/dev/null &
   if [ ${MACHINE_TYPE} == 'i686' ]; then
          rm $BUILDROOT/etc/portage/make.conf
          linux32 chroot ${BUILDROOT} /bin/bash -c 'ln -s /etc/portage/make32.conf /etc/portage/make.conf'
	  linux32 chroot ${BUILDROOT} /bin/bash -c "/inchroot.sh && touch /.stage1done  && /inchroot2.sh && rm /inchroot*"
	  linux32 chroot ${BUILDROOT} /bin/bash
	  cp $BUILDROOT/etc/kernels/*x86* $BUILDDATA/scripts/
   elif  [ ${MACHINE_TYPE} == 'x86_64' ]; then
          rm $BUILDROOT/etc/portage/make.conf
          chroot ${BUILDROOT} /bin/bash -c 'ln -s /etc/portage/make64.conf /etc/portage/make.conf'
	  chroot ${BUILDROOT} /bin/bash -c "/inchroot.sh && touch /.stage1done  && /inchroot2.sh && rm /inchroot*"
	  chroot ${BUILDROOT} /bin/bash
	  cp $BUILDROOT/etc/kernels/*x86_64* $BUILDDATA/scripts/
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

if  [ -e $BUILDDATA/.work.session ] ; [ -a $LOOP_IMAGE ] ; then
    echo -e "Tarballs exists. \n"
    echo "Session exist"
    exit 1
elif [ ! -e $BUILDDATA/stage3-amd64.tar.bz2 ] ; [ ! -a $BUILDDATA/portage-latest.tar.xz ] ; then
    echo -e "Downloading Stage3"
    sleep 1
    wget -c -O $BUILDDATA/stage3-amd64.tar.bz2 $STAGE3
    echo -e "Downloading Portage"
    sleep 1
    wget -c -O $BUILDDATA/portage-latest.tar.xz $PORTS
    echo -e "Create block device \n"
    sleep 1
    dd if=/dev/zero of=$LOOP_IMAGE bs=1024K count=20000  || die() { echo "$@" 1>&2 ; exit 1; }
    echo -e "Make Ext4fs on block device \n"
    mkfs.ext4 $LOOP_IMAGE
    echo "Mounting chroot"
    mount $LOOP_IMAGE $BUILDROOT
    echo -e "Unpacking Stage3 \n"
    sleep 1
    tar xpf $BUILDDATA/stage3*amd64*.tar.bz2 -C $BUILDROOT 2> $BUILDROOT/build.log
    cp -L /etc/resolv.conf $BUILDROOT/etc/
    echo -e "Unpacking Portage \n"
    sleep 1
    tar xpf $BUILDDATA/portage*.tar.xz -C $BUILDROOT/usr 2> $BUILDROOT/buildport.log
    touch $BUILDDATA/.work.session
    echo -e "Stage3 & Portage Unpacked \n" 
    sleep 1
    cp -r $BUILDDATA/{etc,var} $BUILDROOT/
fi

}

iso() {

    rm $BUILDDATA/$ARCH/livedvd/$LIVE_IMAGE > /dev/null
    mount $LOOP_IMAGE $BUILDROOT
    cp $BUILDROOT/boot/kernel-genkernel* $BUILDDATA/$ARCH/livedvd/boot/vmlinuz 
    cp $BUILDROOT/boot/initramfs-genkernel* $BUILDDATA/$ARCH/livedvd/boot/initrd 
    mksquashfs $BUILDROOT $BUILDDATA/$ARCH/livedvd/$LIVE_IMAGE -comp xz -e $BUILDROOT/usr/portage/distfiles -e $BUILDROOT/usr/portage/packages  || die() { echo "$@" 1>&2 ; exit 1; }
    umount $LOOP_IMAGE $BUILDROOT 

if [ -a "$BUILDDATA"/"$ISO_NAME" ]; then
    echo -e "$ISO_NAME exists! \n"
    sleep 1
    rm $BUILDDATA/$ISO_NAME
    echo -e "Create ISO image"
    sleep 1
    echo -e "Gentoo" > $BUILDDATA/$ARCH/livedvd/livecd
    mkisofs -R -J -o $BUILDDATA/$ISO_NAME -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -iso-level 4 -boot-info-table $BUILDDATA/$ARCH/livedvd/  || die() { echo "$@" 1>&2 ; exit 1; }
else
    echo -e "Create ISO image \n"
    sleep 1
    echo -e "Gentoo" > $BUILDDATA/$ARCH/livedvd/livecd
    mkisofs -R -J -o $BUILDDATA/$ISO_NAME -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -iso-level 4 -boot-info-table $BUILDDATA/$ARCH/livedvd/  || die() { echo "$@" 1>&2 ; exit 1; }
    isohybrid $BUILDDATA/$ISO_NAME || die() { echo "$@" 1>&2 ; exit 1; }
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
