#!/bin/bash
USER="user"

cat <<EOF >  /root/.bashrc
alias krnlbb='genkernel all --no-clean --oldconfig --menuconfig --unionfs --all-ramdisk-modules --splash --splash=livecd-12.0 --splash-res=1024x768 --makeopts=-j2 && emerge @module-rebuild'
alias update-grub='grub2-mkconfig -o /boot/grub/grub.cfg'
alias upd='emerge -vauDN world'
alias upsi='eix-sync && emerge --metadata'
alias binarygrp='qlist -IC|xargs quickpkg --include-config=y'
alias portcachefix='rm -r /var/cache/edb/dep; emerge --metadata'
complete -cf sudo gksu kdesu 
alias initrdbb='genkernel initramfs --all-ramdisk-modules --splash --splash=livecd-12.0 --splash-res=1024x768'

# IBus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

export PS1="\[\e[00;36m\]\d\[\e[0m\]\[\e[00;33m\]_\[\e[0m\]\[\e[00;31m\]\@\[\e[0m\]\[\e[00;33m\]\\$\[\e[0m\]"
EOF

source /etc/bash/bashrc

if grep -q layman /var/lib/portage/world; then
	echo "layman is installed";
	sed -i s'/#source/source/'g /etc/portage/make.conf
else    
	emerge layman  
	layman -f -o https://raw.githubusercontent.com/kergalym/ovr/master/repositories.xml -a ovr
	sed -i s'/#source/source/'g /etc/portage/make.conf
	eix-update
fi
if grep -q eix /var/lib/portage/world; then
	echo "eix is installed";
else    
	emerge  eix 
	eix-update
fi
if grep -q genkernel /var/lib/portage/world; then
	echo "genkernel is installed";
else    
	emerge genkernel 
fi
if grep -q  aufs-sources /var/lib/portage/world; then
	echo "aufs-sources is installed";
else    
	emerge aufs-sources 
fi
if grep -q livedvd-configs /var/lib/portage/world; then
	echo "livedvd-configs is installed";
else 
	echo "=app-misc/livedvd-configs-1.0" >> /etc/portage/package.keywords
	emerge app-misc/livedvd-configs
	genkernel all --no-clean --oldconfig --menuconfig --unionfs --all-ramdisk-modules --splash --splash=livecd-12.0 --splash-res=1024x768 --makeopts=-j2 && emerge @module-rebuild
fi
if grep -q acpid /var/lib/portage/world; then
	echo "acpid is installed";
else    
	emerge acpid
	rc-update add acpid default
fi
if grep -q syslog-ng /var/lib/portage/world; then
	echo "syslog-ng is installed";
else    
	emerge syslog-ng
	rc-update add syslog-ng default
fi
if grep -q vixie-cron /var/lib/portage/world; then
	echo "vixie-cron is installed";
else    
	emerge vixie-cron
	rc-update add vixie-cron default
fi
if grep -q dhcpcd /var/lib/portage/world; then
	echo "dhcpcd is installed";
else    
	emerge dhcpcd
	rc-update add dhcpcd default
fi
if grep -q xfce /var/lib/portage/world; then
	echo "xfce is installed";
	emerge -avuDN world
else    
	emerge -avuDN world
	rc-update add alsasound boot
	rc-update add xdm boot
	rc-update add sshd default
	rc-update add dbus default
	rc-update add consolefont default
	rc-update add consolekit default
	eselect infinality set 2
	eselect lcdfilter set 3
	eselect fontconfig enable 2
	eselect fontconfig enable 9
	eselect fontconfig enable 17
	eselect fontconfig enable 19
	eselect fontconfig enable 20
	eselect fontconfig enable 23
	eselect fontconfig enable 24
	eselect fontconfig enable 25
	eselect fontconfig enable 26
	eselect fontconfig enable 27
	eselect fontconfig enable 28
	eselect fontconfig enable 29
	eselect fontconfig enable 36
	eselect fontconfig enable 40
	eselect fontconfig enable 42
fi

if grep -q snd-hda-intel /etc/modprobe.d/alsa.conf; then
	echo "snd-hda-intel priority is configured already"
else
	echo "Setting snd-hda-intel priority to 0"
	echo 'options snd-hda-intel index=0' >> /etc/modprobe.d/alsa.conf
fi
if grep -q snd-usb-audio /etc/modprobe.d/alsa.conf; then
	echo "snd-usb-audio priority is configured already"
else
	echo "Setting snd-usb-audio priority to 2"
	echo 'options snd-usb-audio index=2' >> /etc/modprobe.d/alsa.conf
fi

# emerge mlocate eix gentoolkit xfce4-meta thunar deadfeef media-video/gnome-mplayer firefox libreoffice-bin samba net-wireless/wpa_supplicant
# emerge media-fonts/infinality-ultimate-meta



