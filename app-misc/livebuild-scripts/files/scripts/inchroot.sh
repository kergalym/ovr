#!/bin/bash
TIMECOUNTRY="Asia/Almaty"
NEWLOCALE="ru_RU.UTF-8 UTF-8"

if [ -f  /etc/localtime ]; then
    echo "Localtime is configured already"; 
else    
    cp /usr/share/zoneinfo/$TIMECOUNTRY /etc/localtime >/dev/null &
fi
if grep -q $TIMECOUNTRY /etc/timezone; then
    echo "Localtime is configured already"; 
else 
    echo $TIMECOUNTRY > /etc/timezone >/dev/null & 
fi
if grep -q gentoo /etc/conf.d/hostname; then
    echo "Hostname is configured already";  
else
    sed -i 's/localhost/gentoo/g' /etc/conf.d/hostname >/dev/null &
fi
if grep -q 'dns_domain_lo="workgroup"' /etc/conf.d/net; then
    echo "dns_doman_lo is configured already"; 
else
    echo 'dns_domain_lo="workgroup"' >> /etc/conf.d/net >/dev/null &
fi
if grep -q 'config_eth0="dhcp"' /etc/conf.d/net; then
    echo "dhcp is configured already"; 
else  
    echo 'config_eth0="dhcp"' >> /etc/conf.d/net >/dev/null &
fi
if [ -f /etc/udev/rules.d/80-net-name-slot.rules ]; then
    echo ""; 
else
    touch /etc/udev/rules.d/80-net-name-slot.rules  >/dev/null &
fi
if [ -f /etc/init.d/net.eth0 ]; then
    echo "Network Interface is configured already"; 
else
    ln -s /etc/init.d/net.lo /etc/init.d/net.eth0 >/dev/null &
    rc-update add net.eth0 default >/dev/null &
fi
if grep -q UniCyr_8x16 /etc/conf.d/consolefont; then
    echo "Consolefont is configured already"; 
else
    sed -i 's/default8x16/ UniCyr_8x16/g' /etc/conf.d/consolefont >/dev/null &
fi
if grep -q en /etc/conf.d/keymaps; then
    echo "Keymaps:en is configured already"; 
else
    echo  keymaps="en" >> /etc/conf.d/keymaps >/dev/null &
fi
if grep -q 'clock="local"' /etc/conf.d/hwclock; then
    echo "Hardware clock is configured already"; 
else
    sed -i 's/clock="UTC"/clock="local"/g' /etc/conf.d/hwclock >/dev/null &
fi
if grep -q "$NEWLOCALE" /etc/locale.gen; then
    echo "Locale is configured already"; 
else
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
    echo "$NEWLOCALE" >> /etc/locale.gen
    locale-gen
fi
if grep -q  'LANG="$NEWLOCALE"' /etc/env.d/02locale; then
    echo "02locale is configured already"; 
else
    echo 'LANG="$NEWLOCALE"' >> /etc/env.d/02locale >/dev/null &
fi
if grep -q 'LC_COLLATE="C"' /etc/env.d/02locale; then
    echo "02locale is configured already"; 
else
    echo 'LC_COLLATE="C"' >> /etc/env.d/02locale >/dev/null &
    env-update && source /etc/profile
fi

