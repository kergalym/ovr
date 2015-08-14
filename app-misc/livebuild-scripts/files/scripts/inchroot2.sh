#!/bin/bash
USER="user"

cat  /etc/bash/bashrc
# /etc/bash/bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
        # Shell is non-interactive.  Be done now!
        return
fi

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# Change the window title of X terminals 
case ${TERM} in
        xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix)
                PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
                ;;
        screen*)
                PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"'
                ;;
esac

use_color=false

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
        && type -P dircolors >/dev/null \
        && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
        # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
        if type -P dircolors >/dev/null ; then
                if [[ -f ~/.dir_colors ]] ; then
                        eval $(dircolors -b ~/.dir_colors)
                elif [[ -f /etc/DIR_COLORS ]] ; then
                        eval $(dircolors -b /etc/DIR_COLORS)
                fi
        fi

        if [[ ${EUID} == 0 ]] ; then
                PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
        else
                PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
        fi

        alias ls='ls --color=auto'
        alias grep='grep --colour=auto'
        alias egrep='egrep --colour=auto'
        alias fgrep='fgrep --colour=auto'
else
        if [[ ${EUID} == 0 ]] ; then
                # show root@ when we don't have colors
                PS1='\u@\h \W \$ '
        else
                PS1='\u@\h \w \$ '
        fi
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs

#linux_logo -L gentoo-alt
alias krnlbb='genkernel all --no-clean --oldconfig --menuconfig --unionfs --all-ramdisk-modules --splash --splash=livecd-12.0 --splash-res=1024x768 --makeopts=-j2 && emerge @module-rebuild'
alias update-grub='grub2-mkconfig -o /boot/grub/grub.cfg'
alias upd='emerge -vauDN world'
alias upsi='eix-sync && emerge --metadata'
alias binarygrp='qlist -IC|xargs quickpkg --include-config=y'
alias perlfix='emerge --deselect --ask $(qlist -IC 'perl-core/*'); emerge -uD1a $(qlist -IC 'virtual/perl-*'); perl-cleaner --reallyall'
alias portcachefix='rm -r /var/cache/edb/dep; emerge --metadata'
complete -cf sudo gksu kdesu 
alias initrdbb='genkernel initramfs --all-ramdisk-modules --splash --splash=livecd-12.0 --splash-res=1024x768'

# IBus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

export PS1="\[\e[00;36m\]\d\[\e[0m\]\[\e[00;33m\]_\[\e[0m\]\[\e[00;31m\]\@\[\e[0m\]\[\e[00;33m\]\\$\[\e[0m\]"
EOF

if grep -q layman /var/lib/portage/world; then
	echo "layman is installed";
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



