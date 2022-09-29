#!/sbin/sh
text1="Код ошибки"
text2="Вы можете продолжить на свой страх и риск"
text3="ПРОДОЛЖИТЬ"
text4="ЗАВЕРШИТЬ"
text5="Громкость вверх (+) для переключения по списку"
text6="Громкость вниз (-) для выбора"
text7="Выбрано"
text8="Устройство"
text9="Модель"
text10="Архитектура CPU"
text11="Добро пожаловать в DFE-NEO"
text12="Разработчик TG/XDA - LeeGarChat"
text13="Группа TG @PocoF3DFE"
text14="Благодарность команде MAGISK"
text15="Обнаружен активный загрузочный слот:"
text16="Использовать заполненный arguments.txt внутри архива dfe-neo.zop?"
text17="Громкость вверх (+) для переключения по списку"
text18="Громкость вниз (-) для выбора"
text19="Использовать готовый arguments.txt" 
text104="Настроить аргументы сейчас"
text20="Режим для установки DFE"
text21="Будет пропатчен загрузочный раздел, зачастую это boot_a/b. Права на чтение и запись (RW) не нужны. Работоспособность 100% если следовать правилам"
text22="Будут пропатчены и модифицированны системные разделы напрямую, зачастую это раздел /vendor. Нужны права на чтения и запись (RW)"
text23="Хотите настроить дополнительные функции DFE. Для QUOTA и AVB?"
text24="ДА"
text25="ПО УМОЛЧАНИЮ"
text26="Выключить параметр quota?"
text27="ВЫКЛЮЧИТЬ QUOTA"
text28="ОСТАВИТЬ ПАРАМЕТР QUOTA КАК ЗАДУМАНО РАЗРАБОТЧИКОМ"
text29="Выключить параметр avb?"
text30="ВЫКЛЮЧИТЬ AVB"
text31="ОСТАВИТЬ ПАРАМЕТР AVB КАК ЗАДУМАНО РАЗРАБОТЧИКОМ"
text32="Переустановить кастомное рекавари после OTA?"
text33="НЕТ"
text34="Установить текущее запущенное кастомное рекавари? Функция работает только для устройств, в которых РЕКАВАРИ расположен в RAMDISK на разделе BOOT"
text35="Установить встроенный в dfe-neo.zip MAGISK v"
text36="Включить опцию скрытия отключенного шифрования устройства? Например в настройках будет отображаться что ваше устройство ЗАШИФРОВАНО, но на самом деле оно НЕ ЗАШИФРОВАНО"
text37="СИСТЕМА БУДЕТ ДУМАТЬ ЧТО ДАННЫЕ ЗАШИФРОВАНЫ"
text38="СИСТЕМА БУДЕТ ОТОБРАЖАТЬ ЧТО ДАННЫЕ ЖНЕ ЗАШИФРОВАНЫ"
text39="ДА ВКЛЮЧИТЬ"
text40="НЕ НУЖНО"
text41="ХОТИТЕ НАСТРОИТЬ ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ?"
text42="Пропустить мини туториал по использованию DFE?"
text43="ПРОПУСТИТЬ"
text44="НЕ ПРОПУСКАТЬ"
text45="Удалить данные экрана блокировки? Удаляет пароль блокировки"
text46="УДАЛИТЬ"
text47="НЕ ТРОГАТЬ"
text48="Очистить раздел /data после успешной установки? НЕ FORMAT DATA А  WIPE DATA"
text49="WIPE DATA"
text50="НЕ ТРОГАТЬ!"
text51="Если ваше устройство уже без шифрования и вы МЕНЯЕТЕ прошивку на другую"
text52="Если ваше устройство уже без шифрования и вы ОБНОВЛЯЕТЕ прошивку"
text53="Перезагрузить устройство после завершения установки?"
text54="Не перезагружать"
text55="В систему"
text56="В рекавари"
text57="В бутлоадер/фастбут"
text58="Отключить адаптивную герцовку? Только для MIUI"
text59="ВЫКЛЮЧИТЬ ДИНАМИЧЕСКОЕ ОЬНОВЛЕНИЕ ДИСПЛЕЯ"
text60="НЕ ТРОГАТЬ"
text61="Старт установки со следующими параметрами:"
text62=">>> DFE-NEO"
text63=">>> DFE LEGACY"
text64=">>> Установка Magisk"
text65=">>> Скрытие отключённого шифрования"
text66=">>> Переустановка рекавари после OTA"
text67=">>> Установка текущего рекавари"
text68=">>> Удаление экрана блокировки"
text69=">>> Очиста DATA"
text70=">>> Отключение quota"
text71=">>> Отключение avb"
text72=">>> Перезагрузка после установки:"
text73=">>> Отключение динамической герцовки"
text74="Обнаруженна активное OTA обнолвение. DFE метод Legacy не работает после ota, пожалуйста используйте DFE метод neo"
text75="Не удается смонтировать системные разделы, попробуйте перезапустить рекавари или используйте NEO метод"
text76="Файлы рамдиска были изменены, не возможно подготовить рамдиск для записи, попробуйте перезапустить тврп при помощи команды fastboot boot twrp.img либо перезагрузить рекавари"
text77="Установка Magisk v"
text78="Для слота"
text79="Распаковка загрузочного раздела"
text80="Загрузочный раздел с Magisk обнаружен"
text81="Патчинг boot образа"
text82="Стоковый загрузочный раздел обнаружен, без magisk"
text83="Частичная установка Magisk-init для работы DFE-NEO"
text84="без полной интеграции Magisk загрузка устройства будет занимать на 40-50 секунд дольше при каждом запуске на моменте с лого брэнда устройства"
text85="Патчинг загрузочного раздела"
text86="Удаление локскрина"
text87="Общее время работы скрипта:"
text88="секунд"
text89="Реальное время работы скрипта после чтения/настройки аргументов:"
text90="**** Установка завершена! ****"
text91="**** Специальное предупреждение !!! ****"
text92="Ваши данные расшифрованы, format data делать не нужно"
text93="Ваши данные зашифрованы, нужно сделать форматировение данных (format data)"
text94="Если ваши данные зашифрованы, вам нужно сделать форматирование данных (format data)"
text95="1) Если вы удалите magisk через приложение либо через magisk uninstaller, то DFE-NEO перестанет работать, в этом случае нужно будет переустановить DFE-NEO"
text96="2) Если вы установили DFE-NEO вместе с magisk, то вы можете обновить либо понизить версию magisk позже"
text97="3) Если DFE-NEO был установлен без magisk, то вы можете установить magisk позже, а так же следуйте пунктам 1 и 2"
text98="4) Если вы замените кастомное рекавари на другое, в случае если рекавари расположено в загрузочном разделе boot_a/b, то DFE-NEO перестанет работать, по аналогии с magisk"
text99="5) Если вы обновите/установите прошивку, то DFE-NEO перестанет работать, по аналогии с magisk"
text100="1) Если вы обновите/установите прошивку, то DFE-LEGACY перестанет работать"
text101="-  Перезагрузка в"
text102="через 7 секунд"
text103="DFE-NEO предназначен только для A/B устройств"
text105="Выбрать Русский язык, автор перевода @LeeGarChat"
text106="У вашей системы статус RO, пожалуйста, используйте MakeRW или SystemRW или используйте метод neo"
text107="Открыть termux для дальнейшей установки?"
text108="ОТКРЫТЬ TERMUX"
text109="ПРОДОЛЖИТЬ В MAGISK-APP"
text110="Больше стабильности ui в TERMUX"
text111="Меньше стабильности ui в MAGISK"
text112="Переустановка текущего рекавари"
text113="Перепаковка загрузочного раздела"
text114="Прошивка нового загрузочного раздела"
text115="Включить встроенный в dfe-neo Safetynet fix?"
text116="ВКЛЮЧИТЬ"
text117="ВЫКЛЮЧИТЬ"
text118=">>> Safetynet fix"
text119='Клавиша громкости не обноружена, ВЫХОД'
text120='Клаыиша громкости не обноружена, попробуйте снова'
text121='Параметры которые записаны в arguments.txt:'
text122='>>> Принудительный режим zygisk'
text123='>>> Добавить приложения в denylist автоматически'
text124='Добавить кастомные пакеты/приложения автоматически в denylist после загрузки системы? Нужен обязательно включенный режим zygisk. Пакетов в denylist.txt:'
text125='Принудительно включать режим zygisk для magisk при старте системы? После установки DFE-NEO, режим zygisk для magisk будет постоянно включен, что бы выключить, нужно будет перепрошить DFE-NEO без этого режима'
text126='(ПО-УМОЛЧАНИЮ)'