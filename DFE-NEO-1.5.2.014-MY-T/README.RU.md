#
#
#
#
#
#

XDA - https://forum.xda-developers.com/t/a-b-script-universal-disable-force-encryption-for-a-b-dynamic-partitions-virtual-a-b-devices-neo-beta-0-9-0.4454017/


Donate me : 
monthly donations: PayPal, visa, MasterCard
https://www.donationalerts.com/r/leegarchat
https://boosty.to/leegar/about
Crypto: Bitcoin, litecoin, Ethereum
https://telegra.ph/Donation-list-crypto-05-29


Telgram https://t.me/PocoF3DFE , https://t.me/mfpupdate

Как пользоваться DFE-NEO или как упростить процесс прошивки/обновления
Начнем с аргументов и как их редактировать. Открываем архив DFE-NEO через программу архиватор и запускаем arguments.txt

https://t.me/PocoF3DFE/57039
Тут мы можем увидеть на скриншоте параметры работы DFE

Спойлер: Режимы работы этих параметров:

У данных параметров есть два режима: 
• true (да, правда),
• false (нет, не правда)

Исключения для конкретных параметров:
• DFE method (метод DFE)
=neo (новый метод)
=legacy (старый метод)

• Flash slot
=both (патчинг разделов boot_a и boot_b, также относится к установке magisk, twrp)
=in-current (патчинг раздела boot_x, там где x - текущий слот, также относится к установке magisk, twrp)
=un-current (патчинг раздела boot_x, там где x - противоположенный слот)

• Reboot after installing (Перезагрузка после установки)
=none(нет, то есть перезагрузки не будет)
=system(перезапустить в систему, простая перезагрузка)
=bootloader(перезагрузка в режим fastboot)
=recovery(перезагрузка в режим recovery)


Итак с режимами работы всех параметров разобрались. Теперь, что значит, каждый из них.
Спойлер: Значения этих параметров
Тут описываются функции параметров в режиме true, для исключений в зависимости от режима работы параметра

• DFE method - метод прошивки DFE
• Flash slot - патчинг раздела boot
• Reboot after installing - перезагрузка после установки
• DISABLE DINAMIC REFRESHRATE - отключение динамической герцовки экрана, ТОЛЬКО ДЛЯ MIUI
• Flash DFE - прошивка DFE
• Hide not encrypted - ПЗУ будет думать, что шифрование включено
• Skip warning - в конце будет показываться мини гайд по правильному использованию dfe после прошивки
• Reflash recovery for ota - перепрошивка recovery после ota обновлений, по режиму параметра Flash slot=
• Reflash current Recovery for Recovery - прошить текущий recovery, по режиму параметра Flash slot=
• Wipe DATA - удаление содержимого раздела /data без форматирования внутренней памяти (там где находятся папки Android, Downloads, Music и т.д) Если в первый раз шьёте DFE, то все равно делаем format data
• Remove PIN - удаление пароля
• Disable AVB - отключается проверка целостности системы (или как это назвать, можно поставить false если будете прошивать magisk)
• Disable QUOTA - (честно говоря так и не понял, что это, но можно оставить true)
• Flash Magisk - установка Magisk, по режиму параметра Flash slot=

Спойлер: как правильно использовать DFE-NEO
1. Если вы удалите магиск через менеджер или uninstall.zip, то DFE перестанет работать. В таком случае вы должный прошить DFE снова
2. Если DFE был установлен с Magisk, то вы можете повышать и понижать версию Magisk без перепрошивки DFE
3. Если DFE был установлен без Magisk, то вы можете прошить Magisk позже, и следовать правилам 1,2.
4. Если вы установили TWRP или другое кастомное recovery, то DFE перестанет работать, нужно будет ещё раз прошить
5. Если вы будете устанавливать/обновлять прошивку, то
необходимо прошить DFE снова, по аналогии с магиском

Спойлер: А также можно настроить свой временный arguments.txt

В DFE-NEO помимо использования arguments.txt в .zip архиве, можно ещё настроить свой временный. После установки прошивки запускаем архив dfe-neo и выбираем Configure Arguments now (громкость + >> громкость -) 
И нам предлагают настроить параметры.
Громкость + обозначает изменить
Громкость - обозначает выбрать
Вот тут можно посмотреть как это работает - https://youtu.be/jHTE1dzkoHc

Спойлер: Что выбрать DFE method= neo или legacy?
• Neo метод - патчит раздел boot, оставляем neo если системные разделы только для чтения, также подойдёт если системные разделы доступны для редактирования
• Legacy метод - патчит fstab.qcom в разделе /vendor/etc/, такой метод нельзя использовать если системные разделы только для чтения.