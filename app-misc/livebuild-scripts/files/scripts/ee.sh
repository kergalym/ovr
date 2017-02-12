#!/bin/sh
#
# Version 0.1, created 2012/11/26
#
# Version 0.2, created 2013/07/30
#
# Version 0.3, created 2013/11/8:
# USE flag "python3_3" and "pypy2_0" unmasked
# 
# Version 0.4, created 2014/27/9:
NO_ARGS=0
if [ $# -eq "$NO_ARGS" ]
 then
 echo "Выбран недопустимый ключ. Для вызова помощи используйте ключ '-h'"
fi
while getopts ":hsSlpuQqUdcDCrRBWHPKE" Option
 do
 case $Option in
 h ) echo "Версия 0.3"
 echo "Использование: ee.sh [ОПЦИИ]"
 echo "Запуск скрипта без опций выполняет emerge --sync и layman -S, обновляет базу пакетов eix (eix-update) и отображает список пакетов,"
 echo "доступных для обновления или требующих пересборки с учетом новых примененных USE флагов и зависимостей (--deep --newuse world)"
 echo " -h Показывает это меню"
 echo " -s Выполняет emerge --sync, синхронизирует сторонние оверлеи и обновляет базу пакетов eix"
 echo " -S Аналогично -s, БЕЗ синхронизации сторонних оверлеев"
 echo " -l Синхронизирует сторонние оверлеи и обновляет пакетную базу eix"
 echo " -p Отображает доступные для обновления пакеты с учетом новых примененных USE флагов и зависимостей"
 echo " -u Обновляет мир с учетом новых примененных USE флагов и зависимостей"
 echo " -Q Активирует операцию динамического связывания библиотек (необходимо установить пакет sys-devel/prelink)"
 echo " -q Отменяеет операцию динамического связывания библиотек"
 echo " -U Собирает мир с учетом новых примененных USE флагов и зависимостей без браузеров и офисных пакетов"
 echo " -d Отображает список пакетов, которые не являются зависимостями, и не записаны в system или world (-pv --depclean)"
 echo " -c Выполняет то же самое, что и -d (-pvc)"
 echo " -D Удаляет пакеты, которые не являются зависимостями и не записаны в system или world (--depclean)"
 echo " -C Выполняет то же, что и -D (-c)"
 echo " -r Продолжает сборку пакетов с момента, когда компиляция была прервана, с пересборкой 'плохого' пакета"
 echo " -R То же, что и -r, БЕЗ пересборки 'плохого' пакета (актуально для сборщиков firefox и libreoffice:-))"
 echo " -B Создает набор бинарных пакетов используемой системы с текущими настройками"
 echo " -W Обновляет Perl'овые пакеты"
 echo " -H Обновляет Haskell'евые пакеты"
 echo " -P Пересоздает кеш Portage для предотвращения замедления"
 echo " -K Сборка ядра с помощью Genkernel и загрузочным оформлением"
 echo " -E Редактирование конфигурационных файлов Portage";;
 s ) emerge-webrsync && layman -S && eix-update;;
 S ) emerge-webrsync && eix-update;;
 l ) layman -S && eix-update;;
 p ) emerge -pv --update --newuse --deep --with-bdeps=y @world;;
 u ) emerge --update --newuse --deep --with-bdeps=y @world;;
 Q ) prelink -afmR;;
 q ) prelink -ua;;
 U ) emerge --ask --update --newuse --deep --with-bdeps=y @world --exclude=app-office/libreoffice --exclude=www-client/firefox --exclude=www-client/chromium;;
 d ) emerge -pv --depclean;;
 c ) emerge -pv -c;;
 D ) emerge --depclean;;
 C ) emerge -c;;
 r ) emerge --resume;;
 R ) FEATURES="keeptemp keepwork" emerge --resume;;
 B ) qlist -IC|xargs quickpkg --include-config=y;;
 W ) emerge --deselect --ask $(qlist -IC 'perl-core/*'); emerge -uD1a $(qlist -IC 'virtual/perl-*'); perl-cleaner --reallyall;;
 H ) haskell-updater;;
 P ) emerge --regen && rm -r /var/cache/edb/dep; emerge --metadata;;
 K ) genkernel all --clean --menuconfig --splash --splash=livecd-12.0 --splash-res=1024x768  --makeopts=-j2 && emerge @module-rebuild;;
 E ) nano /etc/portage/make.conf /etc/portage/package.use /etc/portage/package.keywords /etc/portage/package.mask /etc/portage/package.unmask;;
 * ) echo "Выбран недопустимый ключ. Для вызова помощи используйте ключ '-h'";;
 esac
 done
exit 0
