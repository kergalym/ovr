
#!/bin/bash
#
# installation-helper for GentooLive
# 09.08.2015
#
# Shell script for installation of GentooLive to harddisk
# Author:             Galym Kerimbekov <kegalym2@mail.ru>
#
# written by Thomas Schoenhuetl 22.05.2007
# modified for GentooLive by Galym Kerimbekov 09.08.2015
# It contains parts of the official Slackware installer
#

mkdir /tmp/GentooLive/ 2>/dev/null
mkdir /tmp/tmp 2>/dev/null
TMP=/tmp/tmp 2>/dev/null

kbd_interrupt(){
        dialog --title "ПОМОЩНИК УСТАНОВКИ" --yesno "Хотите прервать установку?" 7 60
# Get exit status
# 0 means user hit [yes] button.
# 1 means user hit [no] button.
# 255 means user hit [Esc] key.
	response=$?
	case $response in
		0) rm -R $TMP;;
		1) echo "Продолжаем...";;
		255) echo "Нажата клавиша [ESC]";;
	esac
}

# trap keyboard interrupt (control-c)
trap kbd_interrupt SIGINT
trap kbd_interrupt SIGTSTP

# main() loop
#while true; do read x; done

# umount harddisk for running cfdisk
umount  /mnt/gentoo/*/{proc,sys,dev}  2>/dev/null
umount  /mnt/gentoo/* 2>/dev/null
#
# run cfdisk to partition the harddrive
dialog --clear --title "РАЗБИЕНИЕ ЖЕСТКОГО ДИСКА" --msgbox "Помощник установки GentooLive запустит 'cfdisk', \
чтобы вы смогли создать новые разделы для системы.\n\n Рекомендуется создать два раздела. 1 под систему (не менее 15 ГБ) \
и  2 для раздела подкачки.\n\n Проследуйте дальше и выполните необходимые операции, а затем примените их и выйдите из \
программы 'cfdisk'\n\n ВАЖНО!: внимательно прочтите инструкции и вывод cfdisk. В некоторых случаях необходимо перезагрузить \
компьютер, чтобы обновить таблицу разделов! Выйдите из cfdisk если разделы уже существуют" 20 70
if [ $? = 1 ] ; then
exit
fi

# Create partitions using fdisk or cfdisk.

fdisk -l | sed -n 's/^Disk \(\/dev\/[^:]*\): \([^,]*\).*$/"\1" "\2" \\/p' >> $TMP/drivelist

while [ 0 ]; do
echo dialog --ok-label Select \
--cancel-label Continue \
--title \"PARTITIONING\" \
--menu \"Select drive to partition:\" 11 40 4 \\\
> $TMP/tmpscript
cat $TMP/drivelist >> $TMP/tmpscript
echo "2> $TMP/tmpanswer" >> $TMP/tmpscript
. $TMP/tmpscript
[ $? != 0 ] && break
PARTITION=`cat $TMP/tmpanswer`

if [ ! -f /etc/expert-mode ]; then
cfdisk $PARTITION
else
echo dialog --title \"PARTITIONING $PARTITION\" \
--menu \"Select which fdisk program you want to use. cfdisk is \
strongly recommended for newbies while advanced users may prefer fdisk.\" \
11 50 2 \
cfdisk \"Curses based partitioning program\" \
fdisk \"Traditional fdisk\" \
"2> $TMP/tmpanswer" > $TMP/tmpscript
. $TMP/tmpscript
[ $? != 0 ] && continue
FDISKPROGRAM=`cat $TMP/tmpanswer`
clear
if [ "$FDISKPROGRAM" = "cfdisk" ]; then
cfdisk $PARTITION
elif [ "$FDISKPROGRAM" = "fdisk" ]; then
fdisk $PARTITION
fi
fi
done

rm -f $TMP/drivelist $TMP/tmpscript $TMP/tmpanswer

TMP=/tmp/tmp
if [ ! -d $TMP ]; then
mkdir -p $TMP
fi
REDIR=/dev/tty4
NDIR=/dev/null
crunch() {
read STRING;
echo $STRING;
}
rm -f $TMP/SeTswap $TMP/SeTswapskip
SWAPLIST="`fdisk -l | fgrep "Linux swap" | sort 2> $NDIR`"
if [ "$SWAPLIST" = "" ]; then
dialog --title "РАЗДЕЛ ПОДКАЧКИ НЕ ОБНАРУЖЕН" --yesno "Вы не создали раздел подкачки Linux с помощью fdisk. \
Хотите продолжить установку без него? " 6 60
if [ "$?" = "1" ]; then
dialog --title "ПРЕКРАЩЕНИЕ УСТАНОВКИ" --msgbox "Создайте раздел подкачки Linux с помощью fdisk и попробуйте снова." 6 40
exit 1
else
exit 0
fi
else # there is at least one swap partition:
echo > $TMP/swapmsg
if [ "`echo "$SWAPLIST" | sed -n '2 p'`" = "" ]; then
echo "Помощник установки GentooLive обнаружил раздел подкачки:\n\n" >> $TMP/swapmsg
echo >> $TMP/swapmsg
echo " Device Boot Start End Blocks Id System\\n" >> $TMP/swapmsg
echo "`echo "$SWAPLIST" | sed -n '1 p'`\\n\n" >> $TMP/swapmsg
echo >> $TMP/swapmsg
echo "Хотите создать этот раздел в качестве раздела подкачки?" >> $TMP/swapmsg
dialog --title "РАЗДЕЛ ПОДКАЧКИ ОБНАРУЖЕН" --cr-wrap --yesno "`cat $TMP/swapmsg`" 12 72
REPLY=$?
else
echo "Помощник установки GentooLive обнаружил следующие разделы подкачки:" >> $TMP/swapmsg
echo >> $TMP/swapmsg
echo " Device Boot Start End Blocks Id System\\n" >> $TMP/swapmsg
echo "$SWAPLIST\\n\n" >> $TMP/swapmsg
echo >> $TMP/swapmsg
echo "Хотите создать эти разделы в качестве разделов подкачки? " >> $TMP/swapmsg
dialog --title "РАЗДЕЛЫ ПОДКАЧКИ ОБНАРУЖЕНЫ" --cr-wrap --yesno "`cat $TMP/swapmsg`" 13 72
REPLY=$?
fi
rm -f $TMP/swapmsg
if [ $REPLY = 0 ]; then # yes
if grep "SwapTotal: * 0 kB" /proc/meminfo 1> $NDIR 2> $NDIR ; then
USE_SWAP=0 # swap is not currently mounted
else # warn of possible problems:
# This 10231808 below is the size of a swapfile pre-supplied by install.zip that we'd like to ignore.
if grep 10231808 /proc/meminfo 1> $NDIR 2> $NDIR ; then
USE_SWAP=0
else
cat $TMP/swapmsg
IMPORTANT NOTE: If you have already made any of your swap
partitions active "(using the swapon command)", then you
should not allow Setup to use mkswap on your swap partitions,
because it may corrupt memory pages that are currently
swapped out. Instead, you will have to make sure that your
swap partitions have been prepared "(with mkswap)" before they
will work. You might want to do this to any inactive swap
partitions before you reboot.
EOF
dialog --title "MKSWAP WARNING" --msgbox "`cat $TMP/swapmsg`" 12 67
rm -f $TMP/swapmsg
dialog --title "ИСПОЛЬЗОВАТЬ MKSWAP?" --yesno "Вы хотите применить mkswap к пространству подкачки?" \
5 65
USE_SWAP=$?
fi
fi
CURRENT_SWAP="1"
while [ ! "`echo "$SWAPLIST" | sed -n "$CURRENT_SWAP p"`" = "" ]; do
SWAP_PART=`fdisk -l | fgrep "Linux swap" | sed -n "$CURRENT_SWAP p" | crunch | cut -f 1 -d ' '`
if [ $USE_SWAP = 0 ]; then
dialog --title "ФОРМАТИРОВАНИЕ РАЗДЕЛА ПОДКАЧКИ" --infobox "Форматирование \
$SWAP_PART в раздел подкачки Linux (и проверка на наличие битых секторов)..." 4 55
mkswap -c $SWAP_PART 1> $REDIR 2> $REDIR
fi
echo "Активация раздела подкачки $SWAP_PART:"
echo "swapon $SWAP_PART"
swapon $SWAP_PART 1> $REDIR 2> $REDIR
#SWAP_IN_USE="`echo "$SWAP_PART swap swap defaults 0 0"`"
#echo "$SWAP_IN_USE" >> $TMP/SeTswap
printf "%-11s %-11s %-11s %-27s %-2s %s\n" "$SWAP_PART" "swap" "swap" "defaults" "0" "0" >> $TMP/SeTswap
CURRENT_SWAP="`expr $CURRENT_SWAP + 1`"
sleep 1
done
echo "пространство подкачки настроено. Эти сведения будут внесены" > $TMP/swapmsg
echo "в  /etc/fstab:" >> $TMP/swapmsg
echo >> $TMP/swapmsg
cat $TMP/SeTswap >> $TMP/swapmsg
dialog --title "ПРОСТРАНСТВО ПОДКАЧКИ НАСТРОЕНО" --exit-label OK --textbox $TMP/swapmsg 10 72
cat $TMP/SeTswap > $TMP/SeTfstab
rm -f $TMP/swapmsg $TMP/SeTswap
fi
fi

# format root partition
fdisk -l | grep Linux | sed -e '/swap/d' | cut -b 1-10 > $TMP/pout 2>/dev/null

dialog --clear --title "ОБНАРУЖЕН КОРНЕВОЙ РАЗДЕЛ" --exit-label OK --msgbox "Помощник установки GentooLive обнаружил \n\n `cat /tmp/tmp/pout` \n\n в качестве Linux-совместимого \
раздела(ов).\n\n Далее можно выбрать файловую систему  для корневого раздела из нескольких, если таковые имеются!" 20 70
if [ $? = 1 ] ; then
exit
fi

# choose root partition
dialog --clear --title "ВЫБЕРИТЕ КОРНЕВОЙ РАЗДЕЛ" --inputbox "Укажите предпочитаемый раздел:\n\n введите /dev/sdaX --- где X - номер раздела, \
например 1 для /dev/sda1!" 10 70 2> $TMP/pout

dialog --clear --title "ОТФОРМАТИРУЙТЕ КОРНЕВОЙ РАЗДЕЛ" --radiolist "Теперь можно выбрать файловую систему для корневого раздела; имейте ввиду, \
что раздел будет отформатирован после выбора файловой системы." 10 70 0 \
"1" "ext2" off \
"2" "ext3" off \
"3" "ext4" on \
"4" "reiserfs" off \
"5" "btrfs" off \
2> $TMP/part
if [ $? = 1 ] ; then
exit
fi

if [ `cat $TMP/part` = "1" ] ; then
mkfs.ext2 `cat $TMP/pout`
dialog --clear --title "ОТФОРМАТИРУЙТЕ КОРНЕВОЙ РАЗДЕЛ" --msgbox "Теперь раздел будет отформатирован в файловую систему ext2." 10 70
echo "`cat $TMP/pout` / ext2 defaults,noatime 1 1" >> $TMP/SeTfstab2
# mount the root partition to copy the system
mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`
mount -t ext2 /dev/`cat $TMP/pout | cut -b 6-10` /mnt//gentoo/`cat $TMP/pout | cut -b 6-10`
fi

if [ `cat $TMP/part` = "2" ] ; then
mkfs.ext3 `cat $TMP/pout`
dialog --clear --title "ОТФОРМАТИРУЙТЕ КОРНЕВОЙ РАЗДЕЛ" --msgbox "Теперь раздел будет отформатирован в файловую систему ext3." 10 70
echo "`cat $TMP/pout` / ext3 defaults,noatime 1 1" >> $TMP/SeTfstab2
# mount the root partition to copy the system
mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`
mount -t ext3 /dev/`cat $TMP/pout | cut -b 6-10` /mnt//gentoo/`cat $TMP/pout | cut -b 6-10`
fi

if [ `cat $TMP/part` = "3" ] ; then
mkfs.ext4 `cat $TMP/pout`
dialog --clear --title "ОТФОРМАТИРУЙТЕ КОРНЕВОЙ РАЗДЕЛ" --msgbox "Теперь раздел будет отформатирован в файловую систему ext4." 10 70
echo "`cat $TMP/pout` / ext4 defaults,noatime 1 1" >> $TMP/SeTfstab2
# mount the root partition to copy the system
mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`
mount -t ext4 /dev/`cat $TMP/pout | cut -b 6-10` /mnt//gentoo/`cat $TMP/pout | cut -b 6-10`
fi

if [ `cat $TMP/part` = "4" ] ; then
mkfs.reiserfs -f `cat $TMP/pout`
dialog --clear --title "ОТФОРМАТИРУЙТЕ КОРНЕВОЙ РАЗДЕЛ" --msgbox "Теперь раздел будет отформатирован в файловую систему reiserfs." 10 70
echo "`cat $TMP/pout` / reiserfs defaults,noatime 1 1" >> $TMP/SeTfstab2
# mount the root partition to copy the system
mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`
mount -t reiserfs /dev/`cat $TMP/pout | cut -b 6-10` /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`
fi

if [ `cat $TMP/part` = "5" ] ; then
mkfs.btrfs -f `cat $TMP/pout`
dialog --clear --title "ОТФОРМАТИРУЙТЕ КОРНЕВОЙ РАЗДЕЛ" --msgbox "Теперь раздел будет отформатирован в файловую систему btrfs." 10 70
echo "`cat $TMP/pout` / btrfs defaults,noatime 1 1" >> $TMP/SeTfstab2
# mount the root partition to copy the system
mkdir /mnt/gentoo/gentoo/`cat $TMP/pout | cut -b 6-10`
mount -t btrfs /dev/`cat $TMP/pout | cut -b 6-10` /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`
fi
# copy the system
dialog --clear --title "КОПИРОВАНИЕ ФАЙЛОВ СИСТЕМЫ" --msgbox "Помощник установки GentooLive начнет копирование файлов системы на жесткий диск.\n\n Нажмите OK \
чтобы начать ..." 10 70
if [ $? = 1 ] ; then
exit
fi

dialog --title "ПРОЦЕСС КОПИРОВАНИЯ" --infobox "Помощник установки GentooLive копирует файлы системы на жесткий диск.\n\n Пожалуйста подождите ... это может занять \
до 10 минут в зависимости от вашей системы!" 10 70

cp -arpx /mnt/livecd/{boot,bin,dev,home,etc,lib,media,mnt,opt,proc,root,run,sbin,sys,var,usr,tmp} /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/ 2>/dev/null

mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/mnt 2>/dev/null
mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/media 2>/dev/null
mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/proc 2>/dev/null
mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/sys 2>/dev/null
mkdir /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/tmp 2>/dev/null

dialog --clear --title "ОПЕРАЦИЯ ЗАВЕРШЕНА" --msgbox "Помощник установки GentooLive завершил операцию копирования." 10 70
if [ $? = 1 ] ; then
exit
fi

# create new fstab
echo `cat $TMP/SeTfstab` > /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/etc/fstab 2>/dev/null
echo `cat $TMP/SeTfstab2` >> /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/etc/fstab 2>/dev/null

dialog --title "НАСТРОЙКА ВРЕМЕННЫХ ЗОН" --menu "Выберите один из следующих временных зон:" 21 50 13 \
"US/Alaska" " " \
"US/Aleutian" " " \
"US/Arizona" " " \
"US/Central" " " \
"US/East-Indiana" " " \
"US/Eastern" " " \
"US/Hawaii" " " \
"US/Indiana-Starke" " " \
"US/Michigan" " " \
"US/Mountain" " " \
"US/Pacific" " " \
"US/Pacific-New" " " \
"US/Samoa" " " \
"Africa/Abidjan" " " \
"Africa/Accra" " " \
"Africa/Addis_Ababa" " " \
"Africa/Algiers" " " \
"Africa/Asmara" " " \
"Africa/Asmera" " " \
"Africa/Bamako" " " \
"Africa/Bangui" " " \
"Africa/Banjul" " " \
"Africa/Bissau" " " \
"Africa/Blantyre" " " \
"Africa/Brazzaville" " " \
"Africa/Bujumbura" " " \
"Africa/Cairo" " " \
"Africa/Casablanca" " " \
"Africa/Ceuta" " " \
"Africa/Conakry" " " \
"Africa/Dakar" " " \
"Africa/Dar_es_Salaam" " " \
"Africa/Djibouti" " " \
"Africa/Douala" " " \
"Africa/El_Aaiun" " " \
"Africa/Freetown" " " \
"Africa/Gaborone" " " \
"Africa/Harare" " " \
"Africa/Johannesburg" " " \
"Africa/Juba" " " \
"Africa/Kampala" " " \
"Africa/Khartoum" " " \
"Africa/Kigali" " " \
"Africa/Kinshasa" " " \
"Africa/Lagos" " " \
"Africa/Libreville" " " \
"Africa/Lome" " " \
"Africa/Luanda" " " \
"Africa/Lubumbashi" " " \
"Africa/Lusaka" " " \
"Africa/Malabo" " " \
"Africa/Maputo" " " \
"Africa/Maseru" " " \
"Africa/Mbabane" " " \
"Africa/Mogadishu" " " \
"Africa/Monrovia" " " \
"Africa/Nairobi" " " \
"Africa/Ndjamena" " " \
"Africa/Niamey" " " \
"Africa/Nouakchott" " " \
"Africa/Ouagadougou" " " \
"Africa/Porto-Novo" " " \
"Africa/Sao_Tome" " " \
"Africa/Timbuktu" " " \
"Africa/Tripoli" " " \
"Africa/Tunis" " " \
"Africa/Windhoek" " " \
"America/Adak" " " \
"America/Anchorage" " " \
"America/Anguilla" " " \
"America/Antigua" " " \
"America/Araguaina" " " \
"America/Argentina/Buenos_Aires" " " \
"America/Argentina/Catamarca" " " \
"America/Argentina/ComodRivadavia" " " \
"America/Argentina/Cordoba" " " \
"America/Argentina/Jujuy" " " \
"America/Argentina/La_Rioja" " " \
"America/Argentina/Mendoza" " " \
"America/Argentina/Rio_Gallegos" " " \
"America/Argentina/Salta" " " \
"America/Argentina/San_Juan" " " \
"America/Argentina/San_Luis" " " \
"America/Argentina/Tucuman" " " \
"America/Argentina/Ushuaia" " " \
"America/Aruba" " " \
"America/Asuncion" " " \
"America/Atikokan" " " \
"America/Atka" " " \
"America/Bahia" " " \
"America/Bahia_Banderas" " " \
"America/Barbados" " " \
"America/Belem" " " \
"America/Belize" " " \
"America/Blanc-Sablon" " " \
"America/Boa_Vista" " " \
"America/Bogota" " " \
"America/Boise" " " \
"America/Buenos_Aires" " " \
"America/Cambridge_Bay" " " \
"America/Campo_Grande" " " \
"America/Cancun" " " \
"America/Caracas" " " \
"America/Catamarca" " " \
"America/Cayenne" " " \
"America/Cayman" " " \
"America/Chicago" " " \
"America/Chihuahua" " " \
"America/Coral_Harbour" " " \
"America/Cordoba" " " \
"America/Costa_Rica" " " \
"America/Creston" " " \
"America/Cuiaba" " " \
"America/Curacao" " " \
"America/Danmarkshavn" " " \
"America/Dawson" " " \
"America/Dawson_Creek" " " \
"America/Denver" " " \
"America/Detroit" " " \
"America/Dominica" " " \
"America/Edmonton" " " \
"America/Eirunepe" " " \
"America/El_Salvador" " " \
"America/Ensenada" " " \
"America/Fort_Wayne" " " \
"America/Fortaleza" " " \
"America/Glace_Bay" " " \
"America/Godthab" " " \
"America/Goose_Bay" " " \
"America/Grand_Turk" " " \
"America/Grenada" " " \
"America/Guadeloupe" " " \
"America/Guatemala" " " \
"America/Guayaquil" " " \
"America/Guyana" " " \
"America/Halifax" " " \
"America/Havana" " " \
"America/Hermosillo" " " \
"America/Indiana/Indianapolis" " " \
"America/Indiana/Knox" " " \
"America/Indiana/Marengo" " " \
"America/Indiana/Petersburg" " " \
"America/Indiana/Tell_City" " " \
"America/Indiana/Vevay" " " \
"America/Indiana/Vincennes" " " \
"America/Indiana/Winamac" " " \
"America/Indianapolis" " " \
"America/Inuvik" " " \
"America/Iqaluit" " " \
"America/Jamaica" " " \
"America/Jujuy" " " \
"America/Juneau" " " \
"America/Kentucky/Louisville" " " \
"America/Kentucky/Monticello" " " \
"America/Knox_IN" " " \
"America/Kralendijk" " " \
"America/La_Paz" " " \
"America/Lima" " " \
"America/Los_Angeles" " " \
"America/Louisville" " " \
"America/Lower_Princes" " " \
"America/Maceio" " " \
"America/Managua" " " \
"America/Manaus" " " \
"America/Marigot" " " \
"America/Martinique" " " \
"America/Matamoros" " " \
"America/Mazatlan" " " \
"America/Mendoza" " " \
"America/Menominee" " " \
"America/Merida" " " \
"America/Metlakatla" " " \
"America/Mexico_City" " " \
"America/Miquelon" " " \
"America/Moncton" " " \
"America/Monterrey" " " \
"America/Montevideo" " " \
"America/Montreal" " " \
"America/Montserrat" " " \
"America/Nassau" " " \
"America/New_York" " " \
"America/Nipigon" " " \
"America/Nome" " " \
"America/Noronha" " " \
"America/North_Dakota/Beulah" " " \
"America/North_Dakota/Center" " " \
"America/North_Dakota/New_Salem" " " \
"America/Ojinaga" " " \
"America/Panama" " " \
"America/Pangnirtung" " " \
"America/Paramaribo" " " \
"America/Phoenix" " " \
"America/Port-au-Prince" " " \
"America/Port_of_Spain" " " \
"America/Porto_Acre" " " \
"America/Porto_Velho" " " \
"America/Puerto_Rico" " " \
"America/Rainy_River" " " \
"America/Rankin_Inlet" " " \
"America/Recife" " " \
"America/Regina" " " \
"America/Resolute" " " \
"America/Rio_Branco" " " \
"America/Rosario" " " \
"America/Santa_Isabel" " " \
"America/Santarem" " " \
"America/Santiago" " " \
"America/Santo_Domingo" " " \
"America/Sao_Paulo" " " \
"America/Scoresbysund" " " \
"America/Shiprock" " " \
"America/Sitka" " " \
"America/St_Barthelemy" " " \
"America/St_Johns" " " \
"America/St_Kitts" " " \
"America/St_Lucia" " " \
"America/St_Thomas" " " \
"America/St_Vincent" " " \
"America/Swift_Current" " " \
"America/Tegucigalpa" " " \
"America/Thule" " " \
"America/Thunder_Bay" " " \
"America/Tijuana" " " \
"America/Toronto" " " \
"America/Tortola" " " \
"America/Vancouver" " " \
"America/Virgin" " " \
"America/Whitehorse" " " \
"America/Winnipeg" " " \
"America/Yakutat" " " \
"America/Yellowknife" " " \
"Antarctica/Casey" " " \
"Antarctica/Davis" " " \
"Antarctica/DumontDUrville" " " \
"Antarctica/Macquarie" " " \
"Antarctica/Mawson" " " \
"Antarctica/McMurdo" " " \
"Antarctica/Palmer" " " \
"Antarctica/Rothera" " " \
"Antarctica/South_Pole" " " \
"Antarctica/Syowa" " " \
"Antarctica/Troll" " " \
"Antarctica/Vostok" " " \
"Arctic/Longyearbyen" " " \
"Asia/Aden" " " \
"Asia/Almaty" " " \
"Asia/Amman" " " \
"Asia/Anadyr" " " \
"Asia/Aqtau" " " \
"Asia/Aqtobe" " " \
"Asia/Ashgabat" " " \
"Asia/Ashkhabad" " " \
"Asia/Baghdad" " " \
"Asia/Bahrain" " " \
"Asia/Baku" " " \
"Asia/Bangkok" " " \
"Asia/Beirut" " " \
"Asia/Bishkek" " " \
"Asia/Brunei" " " \
"Asia/Calcutta" " " \
"Asia/Chita" " " \
"Asia/Choibalsan" " " \
"Asia/Chongqing" " " \
"Asia/Chungking" " " \
"Asia/Colombo" " " \
"Asia/Dacca" " " \
"Asia/Damascus" " " \
"Asia/Dhaka" " " \
"Asia/Dili" " " \
"Asia/Dubai" " " \
"Asia/Dushanbe" " " \
"Asia/Gaza" " " \
"Asia/Harbin" " " \
"Asia/Hebron" " " \
"Asia/Ho_Chi_Minh" " " \
"Asia/Hong_Kong" " " \
"Asia/Hovd" " " \
"Asia/Irkutsk" " " \
"Asia/Istanbul" " " \
"Asia/Jakarta" " " \
"Asia/Jayapura" " " \
"Asia/Jerusalem" " " \
"Asia/Kabul" " " \
"Asia/Kamchatka" " " \
"Asia/Karachi" " " \
"Asia/Kashgar" " " \
"Asia/Kathmandu" " " \
"Asia/Katmandu" " " \
"Asia/Khandyga" " " \
"Asia/Kolkata" " " \
"Asia/Krasnoyarsk" " " \
"Asia/Kuala_Lumpur" " " \
"Asia/Kuching" " " \
"Asia/Kuwait" " " \
"Asia/Macao" " " \
"Asia/Macau" " " \
"Asia/Magadan" " " \
"Asia/Makassar" " " \
"Asia/Manila" " " \
"Asia/Muscat" " " \
"Asia/Nicosia" " " \
"Asia/Novokuznetsk" " " \
"Asia/Novosibirsk" " " \
"Asia/Omsk" " " \
"Asia/Oral" " " \
"Asia/Phnom_Penh" " " \
"Asia/Pontianak" " " \
"Asia/Pyongyang" " " \
"Asia/Qatar" " " \
"Asia/Qyzylorda" " " \
"Asia/Rangoon" " " \
"Asia/Riyadh" " " \
"Asia/Saigon" " " \
"Asia/Sakhalin" " " \
"Asia/Samarkand" " " \
"Asia/Seoul" " " \
"Asia/Shanghai" " " \
"Asia/Singapore" " " \
"Asia/Srednekolymsk" " " \
"Asia/Taipei" " " \
"Asia/Tashkent" " " \
"Asia/Tbilisi" " " \
"Asia/Tehran" " " \
"Asia/Tel_Aviv" " " \
"Asia/Thimbu" " " \
"Asia/Thimphu" " " \
"Asia/Tokyo" " " \
"Asia/Ujung_Pandang" " " \
"Asia/Ulaanbaatar" " " \
"Asia/Ulan_Bator" " " \
"Asia/Urumqi" " " \
"Asia/Ust-Nera" " " \
"Asia/Vientiane" " " \
"Asia/Vladivostok" " " \
"Asia/Yakutsk" " " \
"Asia/Yekaterinburg" " " \
"Asia/Yerevan" " " \
"Atlantic/Azores" " " \
"Atlantic/Bermuda" " " \
"Atlantic/Canary" " " \
"Atlantic/Cape_Verde" " " \
"Atlantic/Faeroe" " " \
"Atlantic/Faroe" " " \
"Atlantic/Jan_Mayen" " " \
"Atlantic/Madeira" " " \
"Atlantic/Reykjavik" " " \
"Atlantic/South_Georgia" " " \
"Atlantic/St_Helena" " " \
"Atlantic/Stanley" " " \
"Australia/ACT" " " \
"Australia/Adelaide" " " \
"Australia/Brisbane" " " \
"Australia/Broken_Hill" " " \
"Australia/Canberra" " " \
"Australia/Currie" " " \
"Australia/Darwin" " " \
"Australia/Eucla" " " \
"Australia/Hobart" " " \
"Australia/LHI" " " \
"Australia/Lindeman" " " \
"Australia/Lord_Howe" " " \
"Australia/Melbourne" " " \
"Australia/NSW" " " \
"Australia/North" " " \
"Australia/Perth" " " \
"Australia/Queensland" " " \
"Australia/South" " " \
"Australia/Sydney" " " \
"Australia/Tasmania" " " \
"Australia/Victoria" " " \
"Australia/West" " " \
"Australia/Yancowinna" " " \
"Brazil/Acre" " " \
"Brazil/DeNoronha" " " \
"Brazil/East" " " \
"Brazil/West" " " \
"CET" " " \
"CST6CDT" " " \
"Canada/Atlantic" " " \
"Canada/Central" " " \
"Canada/East-Saskatchewan" " " \
"Canada/Eastern" " " \
"Canada/Mountain" " " \
"Canada/Newfoundland" " " \
"Canada/Pacific" " " \
"Canada/Saskatchewan" " " \
"Canada/Yukon" " " \
"Chile/Continental" " " \
"Chile/EasterIsland" " " \
"Cuba" " " \
"EET" " " \
"EST" " " \
"EST5EDT" " " \
"Egypt" " " \
"Eire" " " \
"Etc/GMT" " " \
"Etc/GMT+0" " " \
"Etc/GMT+1" " " \
"Etc/GMT+10" " " \
"Etc/GMT+11" " " \
"Etc/GMT+12" " " \
"Etc/GMT+2" " " \
"Etc/GMT+3" " " \
"Etc/GMT+4" " " \
"Etc/GMT+5" " " \
"Etc/GMT+6" " " \
"Etc/GMT+7" " " \
"Etc/GMT+8" " " \
"Etc/GMT+9" " " \
"Etc/GMT-0" " " \
"Etc/GMT-1" " " \
"Etc/GMT-10" " " \
"Etc/GMT-11" " " \
"Etc/GMT-12" " " \
"Etc/GMT-13" " " \
"Etc/GMT-14" " " \
"Etc/GMT-2" " " \
"Etc/GMT-3" " " \
"Etc/GMT-4" " " \
"Etc/GMT-5" " " \
"Etc/GMT-6" " " \
"Etc/GMT-7" " " \
"Etc/GMT-8" " " \
"Etc/GMT-9" " " \
"Etc/GMT0" " " \
"Etc/Greenwich" " " \
"Etc/UCT" " " \
"Etc/UTC" " " \
"Etc/Universal" " " \
"Etc/Zulu" " " \
"Europe/Amsterdam" " " \
"Europe/Andorra" " " \
"Europe/Athens" " " \
"Europe/Belfast" " " \
"Europe/Belgrade" " " \
"Europe/Berlin" " " \
"Europe/Bratislava" " " \
"Europe/Brussels" " " \
"Europe/Bucharest" " " \
"Europe/Budapest" " " \
"Europe/Busingen" " " \
"Europe/Chisinau" " " \
"Europe/Copenhagen" " " \
"Europe/Dublin" " " \
"Europe/Gibraltar" " " \
"Europe/Guernsey" " " \
"Europe/Helsinki" " " \
"Europe/Isle_of_Man" " " \
"Europe/Istanbul" " " \
"Europe/Jersey" " " \
"Europe/Kaliningrad" " " \
"Europe/Kiev" " " \
"Europe/Lisbon" " " \
"Europe/Ljubljana" " " \
"Europe/London" " " \
"Europe/Luxembourg" " " \
"Europe/Madrid" " " \
"Europe/Malta" " " \
"Europe/Mariehamn" " " \
"Europe/Minsk" " " \
"Europe/Monaco" " " \
"Europe/Moscow" " " \
"Europe/Nicosia" " " \
"Europe/Oslo" " " \
"Europe/Paris" " " \
"Europe/Podgorica" " " \
"Europe/Prague" " " \
"Europe/Riga" " " \
"Europe/Rome" " " \
"Europe/Samara" " " \
"Europe/San_Marino" " " \
"Europe/Sarajevo" " " \
"Europe/Simferopol" " " \
"Europe/Skopje" " " \
"Europe/Sofia" " " \
"Europe/Stockholm" " " \
"Europe/Tallinn" " " \
"Europe/Tirane" " " \
"Europe/Tiraspol" " " \
"Europe/Uzhgorod" " " \
"Europe/Vaduz" " " \
"Europe/Vatican" " " \
"Europe/Vienna" " " \
"Europe/Vilnius" " " \
"Europe/Volgograd" " " \
"Europe/Warsaw" " " \
"Europe/Zagreb" " " \
"Europe/Zaporozhye" " " \
"Europe/Zurich" " " \
"Factory" " " \
"GB" " " \
"GB-Eire" " " \
"GMT" " " \
"GMT+0" " " \
"GMT-0" " " \
"GMT0" " " \
"Greenwich" " " \
"HST" " " \
"Hongkong" " " \
"Iceland" " " \
"Indian/Antananarivo" " " \
"Indian/Chagos" " " \
"Indian/Christmas" " " \
"Indian/Cocos" " " \
"Indian/Comoro" " " \
"Indian/Kerguelen" " " \
"Indian/Mahe" " " \
"Indian/Maldives" " " \
"Indian/Mauritius" " " \
"Indian/Mayotte" " " \
"Indian/Reunion" " " \
"Iran" " " \
"Israel" " " \
"Jamaica" " " \
"Japan" " " \
"Kwajalein" " " \
"Libya" " " \
"MET" " " \
"MST" " " \
"MST7MDT" " " \
"Mexico/BajaNorte" " " \
"Mexico/BajaSur" " " \
"Mexico/General" " " \
"NZ" " " \
"NZ-CHAT" " " \
"Navajo" " " \
"PRC" " " \
"PST8PDT" " " \
"Pacific/Apia" " " \
"Pacific/Auckland" " " \
"Pacific/Bougainville" " " \
"Pacific/Chatham" " " \
"Pacific/Chuuk" " " \
"Pacific/Easter" " " \
"Pacific/Efate" " " \
"Pacific/Enderbury" " " \
"Pacific/Fakaofo" " " \
"Pacific/Fiji" " " \
"Pacific/Funafuti" " " \
"Pacific/Galapagos" " " \
"Pacific/Gambier" " " \
"Pacific/Guadalcanal" " " \
"Pacific/Guam" " " \
"Pacific/Honolulu" " " \
"Pacific/Johnston" " " \
"Pacific/Kiritimati" " " \
"Pacific/Kosrae" " " \
"Pacific/Kwajalein" " " \
"Pacific/Majuro" " " \
"Pacific/Marquesas" " " \
"Pacific/Midway" " " \
"Pacific/Nauru" " " \
"Pacific/Niue" " " \
"Pacific/Norfolk" " " \
"Pacific/Noumea" " " \
"Pacific/Pago_Pago" " " \
"Pacific/Palau" " " \
"Pacific/Pitcairn" " " \
"Pacific/Pohnpei" " " \
"Pacific/Ponape" " " \
"Pacific/Port_Moresby" " " \
"Pacific/Rarotonga" " " \
"Pacific/Saipan" " " \
"Pacific/Samoa" " " \
"Pacific/Tahiti" " " \
"Pacific/Tarawa" " " \
"Pacific/Tongatapu" " " \
"Pacific/Truk" " " \
"Pacific/Wake" " " \
"Pacific/Wallis" " " \
"Pacific/Yap" " " \
"Poland" " " \
"Portugal" " " \
"ROC" " " \
"ROK" " " \
"Singapore" " " \
"Turkey" " " \
"UCT" " " \
"UTC" " " \
"Universal" " " \
"W-SU" " " \
"WET" " " \
"Zulu" " " \
   2> $TMP/tz

TIMEZONE="`cat $TMP/tz`"

if [ -f /mnt//gentoo/`cat $TMP/pout | cut -b 6-10`/usr/share/zoneinfo/$TIMEZONE ]; then
     echo "Копируем $TIMEZONE в /etc..."
     cp /mnt//gentoo/`cat $TMP/pout | cut -b 6-10`/usr/share/zoneinfo/$TIMEZONE /mnt//gentoo/`cat $TMP/pout | cut -b 6-10`/etc/localtime
else
     echo "Временная зона $TIMEZONE не найдена. Возможно, вы ввели что-то неправильно."
fi

# prepare installation of Grub2
mount --bind /dev /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/dev
mount -t proc /proc /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/proc


dialog --clear --title "ОБЩАЯ ИНФОРМАЦИЯ" --msgbox "Помощник установки GentooLive выполнит установку вашей системы \
на жесткий диск.\n\n Вы можете создавать разделы, форматировать их и установить систему, включая загрузчик.\n\n Будьте \
внимательны при разбиении жесткого диска на разделы, предварительно сохранив перед этим важные данные в надежном месте!" 20 70
if [ $? = 1 ] ; then
exit
fi

dialog --title "УКАЖИТЕ ПАРОЛЬ ROOT" --yesno "Укажите пароль для суперпользователя:" 10 70
if [ $? = 0 ] ; then
    echo
    echo
    echo
    chroot  /mnt/gentoo/`cat $TMP/pout | cut -b 6-10` /bin/bash -c '/usr/bin/passwd root' 
    echo
    echo -n "Нажмите [enter] чтобы продолжить:"
    echo
else
    break;
fi

dialog --clear --title "СОЗДАЙТЕ ПОЛЬЗОВАТЕЛЯ" --inputbox "Укажите имя нового пользователя:" 10 70 2> /tmp/user
cp /tmp/user  /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/tmp/user
chroot  /mnt/gentoo/`cat $TMP/pout | cut -b 6-10` /bin/bash -c '/usr/sbin/useradd -m -G users,wheel,audio,video,usb,plugdev,polkitd,lp,lpadmin -s /bin/bash `cat /tmp/user`' 

dialog --title "УКАЖИТЕ ПАРОЛЬ ПОЛЬЗОВАТЕЛЯ" --yesno "Укажите пароль для нового пользователя:" 10 70
if [ $? = 0 ] ; then
    echo
    echo
    echo
    chroot  /mnt/gentoo/`cat $TMP/pout | cut -b 6-10` /bin/bash -c '/usr/bin/passwd `cat /tmp/user`'
    echo
    echo -n "Нажмите [enter] чтобы продолжить:"
    echo
else
    break;
fi

# install Grub2 with or without Windows
dialog --clear --title "УСТАНОВКА СИСТЕМНОГО ЗАГРУЗЧИКА" --radiolist "Выберите раздел для установки системного загрузчика." 10 70 0 \
"1" "GRUB2 Loader" on \
2> $TMP/part
if [ $? = 1 ] ; then
exit
fi

if [ `cat $TMP/part` = "1" ] ; then
#mkdir -p /mnt/gentoo/`cat $TMP
#cat $TMP/pout >  /mnt/gentoo/`cat $TMP/pout
/usr/sbin/grub2-install --root-directory=/mnt/gentoo/`cat $TMP/pout | cut -b 6-10`  `cat $TMP/pout | cut -b 1-8` 2>/dev/null
chroot /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`  /bin/bash -c '/usr/sbin/grub2-mkconfig -o /boot/grub/grub.cfg' 2>/dev/null

dialog --clear --title "УСТАНОВКА ЗАВЕРШЕНА" --msgbox "Помощник установки GentooLive завершил установку.\n\n Перезагрузите компьютер." 10 70
if [ $? = 1 ] ; then
exit
fi
fi

umount  /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/{proc,sys,dev}  2>/dev/null
umount  /mnt/gentoo/`cat $TMP/pout | cut -b 6-10`/ 2>/dev/null


rm -R $TMP

exit
