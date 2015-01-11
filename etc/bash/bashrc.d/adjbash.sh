#!/bin/bash

#linux_logo -L gentoo-alt
alias krnlbb='genkernel all --no-clean --menuconfig --splash --splash=livecd-12.0 --splash-res=1024x768  --makeopts=-j2 && emerge @module-rebuild'
alias update-grub='grub2-mkconfig -o /boot/grub/grub.cfg'
alias upd='emerge -vauDN world'
alias upsi='eix-sync && emerge --metadata'
alias binarygrp='qlist -IC|xargs quickpkg --include-config=y'
alias perlfix='emerge --deselect --ask $(qlist -IC 'perl-core/*'); emerge -uD1a $(qlist -IC 'virtual/perl-*'); perl-cleaner --reallyall'
alias portcachefix='rm -r /var/cache/edb/dep; emerge --metadata'
complete -cf sudo gksu kdesu 
alias initrdbb='genkernel initramfs --all-ramdisk-modules --splash --splash=livecd-12.0 --splash-res=1024x768 --kernel-config=/usr/src/linux/.config'

# IBus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

export LFS=/mnt/lfs

export PS1="\[\e[00;36m\]\d\[\e[0m\]\[\e[00;33m\]_\[\e[0m\]\[\e[00;31m\]\@\[\e[0m\]\[\e[00;33m\]\\$\[\e[0m\]"

alias freeswap='swapoff -a && swapon -a && sync && echo 3 > /proc/sys/vm/drop_caches'

