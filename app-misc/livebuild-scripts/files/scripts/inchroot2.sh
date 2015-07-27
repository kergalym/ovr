#!/bin/bash
USER="user"

sed -i s'/#source/source/'g /etc/portage/make.conf

if grep -q layman /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge layman eix 
	layman -f -o https://raw.githubusercontent.com/kergalym/ovr/master/repositories.xml -a ovr
	eix-update
fi
if grep -q eix /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge  eix 
	eix-update
fi
if grep -q genkernel /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge genkernel 
fi
if grep -q  aufs-sources /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge aufs-sources 
fi
if grep -q livedvd-configs /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge app-misc/livedvd-configs
	genkernel all --clean --oldconfig --menuconfig --unionfs --all-ramdisk-modules --splash --splash=livecd-12.0 --splash-res=1024x768 --kernel-config=/etc/kernels/.config --makeopts=-j2 && emerge @module-rebuild
fi
if grep -q acpid /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge acpid
	rc-update add acpid default
fi
if grep -q syslog-ng /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge syslog-ng
	rc-update add syslog-ng default
fi
if grep -q vixie-cron /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge vixie-cron
	rc-update add vixie-cron default
fi
if grep -q dhcpcd /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge dhcpcd
	rc-update add dhcpcd default
fi
if grep -q xfce /var/lib/portage/world; then
	echo "Nothing to do";
else    
	emerge -avuDN world
	rc-update add alsasound boot
	rc-update add xdm default
	rc-update add sshd default
	rc-update add dbus default
	rc-update add consolefont default
	rc-update add cpufrequtils default
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
	echo "Nothing to do"
else
	echo 'options snd-hda-intel index=0' >> /etc/modprobe.d/alsa.conf
fi
if grep -q snd-usb-audio /etc/modprobe.d/alsa.conf; then
	echo "Nothing to do"
else
	echo 'options snd-usb-audio index=2' >> /etc/modprobe.d/alsa.conf
fi

if grep -q snd-hda-intel /etc/modprobe.d/alsa.conf; then
	echo "Nothing to do"
else
	echo 'options snd-hda-intel index=0' >> /etc/modprobe.d/alsa.conf
fi
if grep -q snd-usb-audio /etc/modprobe.d/alsa.conf; then
	echo "Nothing to do"
else
	echo 'options snd-usb-audio index=2' >> /etc/modprobe.d/alsa.conf
fi

# emerge mlocate eix gentoolkit xfce4-meta thunar deadfeef media-video/gnome-mplayer firefox libreoffice-bin samba net-wireless/wpa_supplicant
# emerge media-fonts/infinality-ultimate-meta
# tar xpf stage3.configs.tar -C /


if grep -q $USER; then
	echo "$USER exist"
else
	useradd -m -G users,wheel,audio,video,usb,plugdev,polkitd,lp,lpadmin -s /bin/bash $USER
	passwd $USER
fi


if grep -q root; then
	echo "root exist"
else
	passwd root
fi

