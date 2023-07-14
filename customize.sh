#!/system/bin/sh

timer_start1=$(date +%s%N)
LNGarg="$5"
#exit 1
DFENV="1.5.3.015 BETA"
#SKIPUHNZIP=1
calc() { awk 'BEGIN{ print int('"$1"') }'; }
calcF() { awk 'BEGIN{ print '"$1"' }'; }
#(mountpoint -q /data/) && tmp="/data/local/tmp-dfe-neo" ||
tmp="/dev/dfe-neo"
sysboot=$(getprop sys.boot_completed)
CPU=$(getprop ro.product.cpu.abi)
rem_lock=false
# TWRP or Magisk check

[ -f /data/adb/modules_update/DFENEO/customize.sh ] && rm -rf /data/adb/modules_update/DFENEO
[ -f /data/adb/modules/DFENEO/customize.sh ] && rm -rf /data/adb/modules/DFENEO
if [ "$sysboot" = 1 ]; then
    if [ $4 = termux ]; then
        arg3="$3"
        clear
    else
        arg3="$(find "$(dirname "$0")"/ -name "*.zip")"
    fi
    arg1=1
    arg2=2
    my_magisk_installer=true
    type flash_image &>$(dirname $arg3)/log.txt || flash_image() { dd if="$1" of="$2"; }
    . /data/adb/magisk/util_functions.sh

else
    arg1="$1"
    arg2="$2"
    arg3="$3"
    my_magisk_installer=false
    type flash_image || flash_image() { dd if="$1" of="$2"; }
    ui_print() { echo -e "ui_print "$1"\nui_print" >>"/proc/self/fd/$arg2"; }
fi

wipe_data=false
rebootafter=false

my_print() {
    in_text="$1"
    skipG="* "
    tick=1
    listT=0
    all_char=$(echo $in_text | wc -m)
    all_words=$(
        for word in $in_text; do listT=$((listT + 1)); done
        echo $listT
    )
    all_words2=$((all_words + 2))
    ! [[ -z "$2" ]] && [[ "$2" == "selected" ]] && first_line=false || first_line=true
    if [[ $all_char -gt 50 ]]; then
        while true; do
            num=$(echo ${in_text%${in_text#$skipG}*} | wc -m)
            if [[ $num -ge 45 ]]; then
                [[ $num -gt 55 ]] && skipG="${skipG%\**}"
                $first_line && ui_print "- ${in_text%${in_text#$skipG}*}" ||
                    ui_print "  ${in_text%${in_text#$skipG}*}"
                in_text="${in_text#$skipG}"
                skipG="* "
                first_line=false
            else
                skipG="${skipG}* "
            fi
            tick=$((tick + 1))
            if [[ $tick -ge $all_words2 ]]; then
                if [[ -z ${in_text} ]] || [[ ${in_text} == " " ]]; then
                    ui_print " " && break
                else
                    $first_line && ui_print "- ${in_text}" ||
                        ui_print "  ${in_text}"
                fi
                break
            fi
        done
    else
        if [[ -z ${in_text} ]] || [[ ${in_text} == " " ]]; then
            ui_print " "
        else
            $first_line && ui_print "- ${in_text}" ||
                ui_print "  ${in_text}"
        fi
    fi
}

my_abort() {
    error_code="$1"
    error_text="$2"

    if ! [[ -z $error_text ]]; then
        ui_print "*******************************"
        ui_print "*******************************"
        ui_print " "
        my_print "$2"
        ui_print " "
        ui_print "*******************************"
        ui_print "*******************************"
    fi
    my_print "$text1 $error_code"
    exit $error_code
}
A_only=false
MYSELECT4() {
    my_print "> [$1]" "selected"
    my_print "> [$2]" "selected"
    my_print "> [$3]" "selected"
    my_print "> [$4]" "selected"
    my_print "> [$text4] " "selected"
    ui_print " "
    A=1
    while true; do
        case $A in
        1)
            TEXT="$1"
            outselect=1
            ;;
        2)
            TEXT="$2"
            outselect=2
            ;;
        3)
            TEXT="$3"
            outselect=3
            ;;
        4)
            TEXT="$4"
            outselect=4
            ;;
        5)
            TEXT="$text4"
            outselect=5
            ;;
            #4 ) TEXT="EXIT" ; outselect=4 ;;
        esac

        my_print " > $TEXT <" "selected"
        if chooseport 60; then
            A=$((A + 1))
        else
            break
        fi
        if [ $A -gt 5 ]; then
            A=1
        fi
    done
    if [ $outselect = 5 ]; then
        my_abort "1"
    fi

    my_print " >[$TEXT]<" "selected"
    ui_print " "
    ui_print "****==================================*****"
    return $outselect
}
rw_part_check() {
    mnt="$1"
    echo "test test test TEST TESTR TEST" &>$mnt/test.txt
    if [[ $(stat -c%s $mnt/test.txt) -ge 6 ]]; then
        rm -f $mnt/test.txt
        return 0
    else
        [[ -f $mnt/test.txt ]] && rm -f $mnt/test.txt
        return 1
    fi
}

mount_part() {
    for mnt in vendor $($my_magisk_installer && echo system || echo system_root) odm system_ext product; do
        case "$1" in
        --mount)
            if ! $my_magisk_installer; then
                umount /$mnt
                e2fsck -f /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                blockdev --setrw /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                e2fsck -E unshare_blocks -y -f /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                resize2fs /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                mount /$mnt
            fi
            mount -o rw,remount /$mnt
            $my_magisk_installer && mount -o rw,remount /
            ;;
        --umount)
            (mountpoint -q /$mnt) && umount /$mnt
            ;;
        esac
    done
}
tabul="
"
DFE() {

    fstabp=$1
    g=$(
        echo "fileencryption="
        echo "forcefdeorfbe="
        echo "encryptable="
        echo "forceencrypt="
        echo "metadata_encryption="
        echo "keydirectory="
        $AVB_STAY && echo "avb="
        $AVB_STAY && echo "avb_keys="
    )
    g2=$(
        $AVB_STAY && echo "avb"
        $QUOTA_STAY && echo "quota"
        echo "inlinecrypt"
        echo "wrappedkey"
    )
    while ($(
        for i in $g; do
            grep -q "$i" $fstabp && return 0
        done
        return 1
    )); do
        fstabp_now=$(cat "$fstabp")
        for remove in $g; do
            grep -q "$remove" "$fstabp" &&
                remove_now="${fstabp_now#*"$remove"}" &&
                remove_now="${remove_now%%,*}" &&
                remove_now="${remove}${remove_now%%"$tabul"*}" ||
                continue
            grep -q ",$remove_now" "$fstabp" &&
                sed -i 's|,'$remove_now'||' $fstabp
            grep -q "$remove_now" "$fstabp" &&
                sed -i 's|'$remove_now'||' $fstabp
        done
    done
    if ($(
        for i in $g2; do
            grep -q "$i" $fstabp && return 0
        done
        return 1
    )); then
        for remove in $g2; do
            grep -q ",$remove" $fstabp && sed -i 's|,'$remove'||g' $fstabp
            grep -q "$remove," $fstabp && sed -i 's|'$remove',||g' $fstabp
            grep -q "$remove" $fstabp && sed -i 's|'$remove'||g' $fstabp
        done
    fi
}

for_all() {
    all_fstabs=""
    mkdir -pv $tmp/dfe_tmp_fstab/
    tmpF=$tmp/dfe_tmp_fstab
    for fstab in $(find /system /system_ext /odm /product /vendor -name "*fstab*"); do
        if (grep "/userdata" $fstab) &&
            (grep "/metadata" $fstab); then
            mkdir -pv $tmpF$(dirname $fstab)
            cp $fstab $tmpF$fstab
            DFE "$tmpF$fstab"
            echo '#DFE-NEO 0.14.0' &>$tmpF$fstab
            cp $tmpF$fstab $tmpF$fstab.qcom
            chmod 777 ${tmpF}${fstab}*
            mount ${tmpF}${fstab} ${fstab}

        fi
    done
}

mygrep_prop() {

    echo $(grep "$1" "$2" | sed 's|'"$1"'=||')

}

chooseport_legacy() {
    # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
    # Calling it first time detects previous input. Calling it second time will do what we want
    [ "$1" ] && local delay=$1 || local delay=3
    local error=false
    while true; do
        timeout 0 $tmp/$cpukey/keycheck
        timeout $delay $tmp/$cpukey/keycheck
        local sel=$?
        if [ $sel -eq 42 ]; then
            return 0
        elif [ $sel -eq 41 ]; then
            return 1
        elif $error; then
            abort "No version selected, please restart installation"
            #  abort "  installation cannot continue"
        else
            error=true
            #         echo "Try again!"
        fi
    done
}

chooseport() {
    # Original idea by chainfire and ianmacd @xda-developers
    [ "$1" ] && local delay=$1 || local delay=3
    local error=false
    while true; do
        local count=0
        while true; do
            timeout 0.5 /system/bin/getevent -lqc 1 2>&1 >$tmp/events &
            sleep 0.1
            count=$((count + 1))
            if (grep -q 'KEY_VOLUMEUP *DOWN' $tmp/events); then
                return 0
            elif (grep -q 'KEY_VOLUMEDOWN *DOWN' $tmp/events); then
                return 1
            fi
            [ $count -gt 100 ] && break
        done
        if $error; then
            ui_print "$text119"
            exit 90
        else
            error=true
            ui_print " "
            ui_print "$text120"
        fi
    done
}

MYSELECT() {
    my_print "> [$1]" "selected"
    ! [[ -z "$3" ]] && my_print "$3"
    my_print "> [$2]" "selected"
    ! [[ -z "$4" ]] && my_print "$4"
    my_print "> [$text4]" "selected"
    ui_print " "
    A=1
    while true; do
        case $A in
        1)
            TEXT="$1"
            outselect=1
            ;;
        2)
            TEXT="$2"
            outselect=2
            ;;
        3)
            TEXT="$text4"
            outselect=3
            ;;
            #4 ) TEXT="EXIT" ; outselect=4 ;;
        esac

        my_print " > $TEXT <" "selected"
        if chooseport 60; then
            A=$((A + 1))
        else
            break
        fi
        if [ $A -gt 3 ]; then
            A=1
        fi
    done
    if [ $outselect = 3 ]; then
        my_abort "1"
    fi

    my_print " >[$TEXT]<" "selected"
    ui_print " "
    ui_print "****==================================*****"
    return $outselect
}

# Create tmp folder

rm -rf $tmp
mkdir -pv $tmp &>$(dirname $arg3)/log.txt

# CPU and slot check

[ -z "$CPU" ] && my_abort 77
case $CPU in
arm*) cpukey=arm ;;
x86*) cpukey=x86 ;;
esac
#sleep 1

my_print "Unpacking tools"

# Magisk unpack

unzip -o "$arg3" "arguments.txt" \
    "tools/magisklite.zip" \
    "tools/init.rc" \
    "tools/magisk.db" \
    "denylist.txt" \
    "tools/init.sh" \
    "tools/sql" \
    -j -d $tmp/ &>$(dirname $arg3)/log.txt || my_abort "44" "Cant unzip $arg3"
mkdir $tmp/arm
mkdir $tmp/x86
unzip -o "$arg3" "tools/arm/keycheck" \
    -j -d $tmp/arm/ &>$(dirname $arg3)/log.txt || my_abort "44" "Cant unzip $arg3"
unzip -o "$arg3" "tools/x86/keycheck" \
    -j -d $tmp/x86/ &>$(dirname $arg3)/log.txt || my_abort "44" "Cant unzip $arg3"
# Magiskbin and busybox unpack
mkdir $tmp/LNG
unzip -o "$arg3" "languages/*.sh" \
    -j -d $tmp/LNG/ &>$(dirname $arg3)/log.txt || my_abort "44" "Cant unzip $arg3"
mkdir -pv $tmp/bin &>$(dirname $arg3)/log.txt
[[ -f "$tmp/magisklite.zip" ]] || my_abort "4"
unzip -o "$tmp/magisklite.zip" \
    "lib/$CPU/libmagiskboot.so" \
    "lib/$CPU/libbusybox.so" \
    "assets/bootctl" -j -d $tmp/bin/ &>$(dirname $arg3)/log.txt
cd $tmp/bin/ || my_abort "3"
for file in lib*.so; do mv "$file" "${file:3:${#file}-6}"; done
PATH=$tmp/bin:$PATH
cd $tmp || my_abort "3"
[[ -f $tmp/bin/busybox ]] || my_abort 63
chmod 777 $tmp/bin/*
BB="$tmp/bin/busybox"
chmod 777 $tmp/bin/*
cd $tmp || my_abort "3"
slot_num=$(bootctl get-current-slot)
slot_ab=$(bootctl get-suffix $slot_num)
if ! [ "$(getprop ro.virtual_ab.enabled)" = "true" ]; then
    A_only=true
fi
if $A_only; then
    sleep 0.1
elif [[ $slot_ab == "_a" ]]; then
    not_slot_ab="_b"
elif [[ $slot_ab == "_b" ]]; then
    not_slot_ab="_a"
else
    slot_ab=""
    not_slot_ab=""
    #my_abort "64" "WTF???"
fi

# Magisk unzip
TMPDIR=$tmp/magiskinst
rm -rf $TMPDIR
mkdir -p $TMPDIR
export BBBIN="$BB"
for arch in "x86_64" "x86" "arm64-v8a" "armeabi-v7a"; do
    $BB unzip -o "$tmp/magisklite.zip" "lib/$arch/libbusybox.so" -d $TMPDIR &>$(dirname $arg3)/log.txt
    libpath="$TMPDIR/lib/$arch/libbusybox.so"
    chmod 755 $libpath
    if [ -x $libpath ] && $libpath &>$(dirname $arg3)/log.txt; then
        mv -f $libpath $BBBIN
        break
    fi
done
$BBBIN rm -rf $TMPDIR/lib
export INSTALLER=$TMPDIR/install
$BBBIN mkdir -p $INSTALLER
$BBBIN unzip -o "$tmp/magisklite.zip" "assets/*" "lib/*" "META-INF/com/google/*" -x "lib/*/libbusybox.so" -d $INSTALLER &>$(dirname $arg3)/log.txt
export ASH_STANDALONE=1

umask 022
OUTFD=$2
APK="$tmp/magisklite.zip"
COMMONDIR=$INSTALLER/assets
CHROMEDIR=$INSTALLER/assets/chromeos
if [ ! -f $COMMONDIR/util_functions.sh ]; then
    my_abort "7" "! Unable to extract zip file!"
fi
mkdir $tmp/magisk_files_tmp
cp $COMMONDIR/* $tmp/magisk_files_tmp/
for file in $COMMONDIR/*.sh; do
    sed -i 's|ui_print "|echo "|' $file
done

. $COMMONDIR/util_functions.sh
get_flags &>$(dirname $arg3)/log.txt
api_level_arch_detect &>$(dirname $arg3)/log.txt
if echo $MAGISK_VER | grep -q '\.'; then
    PRETTY_VER=$MAGISK_VER
else
    PRETTY_VER="$MAGISK_VER"
fi
api_level_arch_detect &>$(dirname $arg3)/log.txt
BINDIR=$INSTALLER/lib/$ABI
cd $BINDIR || my_abort "3"
for file in lib*.so; do mv "$file" "${file:3:${#file}-6}"; done
cp -af $INSTALLER/lib/$ABI32/libmagisk32.so $BINDIR/magisk32 &>$(dirname $arg3)/log.txt
cp -af $CHROMEDIR/. $BINDIR/chromeos
chmod -R 755 $BINDIR
rm -rf $MAGISKBIN/* &>$(dirname $arg3)/log.txt
mkdir -p $MAGISKBIN &>$(dirname $arg3)/log.txt
cp -af $BINDIR/. $tmp/magisk_files_tmp/* $BBBIN $MAGISKBIN
chmod -R 755 $MAGISKBIN
cd $tmp || my_abort "3"

. $tmp/LNG/english.sh

if (echo $(mygrep_prop "Force reading arguments.txt" $tmp/arguments.txt) | grep -q "true"); then
    MYLNG=$(mygrep_prop "Language" $tmp/arguments.txt)
    [[ -f $tmp/LNG/${MYLNG}.sh ]] && . $tmp/LNG/${MYLNG}.sh || $tmp/LNG/english.sh
elif [[ -z $LNGarg ]]; then
    LNG_tmp=$tmp/LNG/
    A=1
    for files in ${LNG_tmp}*; do
        [[ -z $LNGL ]] &&
            LNGL="$(basename ${files%.sh*})$LNGL" ||
            LNGL="$(basename ${files%.sh*})\n$LNGL"
        LNGL2="$(basename ${files%.sh*}) $LNGL2"
        ticks_lang=$((ticks_lang + 1))
    done
    for files in $LNGL2; do
        . ${LNG_tmp}$files.sh
        my_print "> [$files]" "selected"
        my_print "{$text105}"
        my_print "$text17" "selected"
        my_print "$text18" "selected"
        ui_print " "
    done
    while true; do
        LNGsell=$(echo -e "$LNGL" | head -n$A | tail -n1)
        my_print " > $LNGsell <" "selected"
        if chooseport 60; then
            A=$((A + 1))
        else
            break
        fi
        if [ $A -gt $ticks_lang ]; then
            A=1
        fi
    done
    my_print " >[$LNGsell]<" "selected"
    . ${LNG_tmp}$LNGsell.sh
    ui_print " "
elif ! [[ -z $LNGarg ]]; then
    . $LNGarg
fi
if ! (echo $(mygrep_prop "Force reading arguments.txt" $tmp/arguments.txt) | grep -q "true"); then
    if $my_magisk_installer && [[ -d /data/data/com.termux/ ]] && ! [[ $4 == termux ]]; then
        my_print "$text107"
        MYSELECT "$text108" "$text109" "$text110" "$text111"
        if [ $? = 1 ]; then
            rm -f /data/data/com.termux/customize.sh /data/data/com.termux/install.zip
            unzip -o "$arg3" \
                "customize.sh" \
                -j -d /data/data/com.termux/ &>$(dirname $arg3)/log.txt
            cp "$arg3" /data/data/com.termux/install.zip
            chmod 777 /data/data/com.termux/customize.sh
            chmod 777 /data/data/com.termux/install.zip
            am force-stop com.termux
            am start com.termux/com.termux.HomeActivity
            sleep 0.4
            input text 'su -c sh /data/data/com.termux/customize.sh 1 2 "/data/data/com.termux/install.zip" "termux" "'${LNG_tmp}$LNGsell.sh'"'
            input keyevent KEYCODE_ENTER
            exit 0
        fi
    fi
fi
skip_warning=false

my_print "$text11 $DFENV"
my_print "$text12"
my_print "$text13"
my_print "$text14"
#DEL="$MYSKIPP>> $( dirname $arg3 )/log.txt"

# Device A/B check

safetyfix=true
#sleep 1

my_print "$text8: $(getprop ro.build.product)"
my_print "$text9: $(getprop ro.product.model)"
my_print "$text10: $CPU"
my_print "$text15 $slot_ab"
dynamic120hz=false
echo $(mygrep_prop "Skip warnin" $tmp/arguments.txt) | grep -q "true" &&
        skip_warning=true || skip_warning=false
    echo $(mygrep_prop "DFE method" $tmp/arguments.txt) | grep -q "legacy" &&
        legacy_mode=true || legacy_mode=false
    echo $(mygrep_prop "Flash Magisk" $tmp/arguments.txt) | grep -q "true" &&
        Flash_Magisk=true || Flash_Magisk=false
    echo $(mygrep_prop "Hide No Encryption" $tmp/arguments.txt) | grep -q "true" &&
        Hide_No_Encryption=true || Hide_No_Encryption=false
    echo $(mygrep_prop "Reflash Recovery for OTA" $tmp/arguments.txt) | grep -q "true" &&
        Reflash_Recovery_After_Oat=true || Reflash_Recovery_After_Oat=false
    echo $(mygrep_prop "Reflash current Recovery for Recovery" $tmp/arguments.txt) | grep -q "true" &&
        Flash_Current_Rerovery=true || Flash_Current_Rerovery=false
    echo $(mygrep_prop "Hide not encrypted" $tmp/arguments.txt) | grep -q "true" &&
        Hide_No_Encryption=true || Hide_No_Encryption=false

    echo $(mygrep_prop "DISABLE DYNAMIC REFRESHRATE" $tmp/arguments.txt) | grep -q "true" &&
        dynamic120hz=true || dynamic120hz=false

    echo $(mygrep_prop "Wipe DATA" $tmp/arguments.txt) | grep -q "true" &&
        wipe_data=true || wipe_data=false

    echo $(mygrep_prop "Remove PIN" $tmp/arguments.txt) | grep -q "true" &&
        rem_lock=true || rem_lock=false

    echo $(mygrep_prop "Disable QUOTA" $tmp/arguments.txt) | grep -q "true" &&
        QUOTA_STAY=true || QUOTA_STAY=false

    echo $(mygrep_prop "Disable AVB" $tmp/arguments.txt) | grep -q "true" &&
        AVB_STAY=true || AVB_STAY=false

    rebootafter=false
    echo $(mygrep_prop "Reboot after installing" $tmp/arguments.txt) | grep -q "system" &&
        rebootARG=system && rebootafter=true
    echo $(mygrep_prop "Reboot after installing" $tmp/arguments.txt) | grep -q "bootloader" &&
        rebootARG=bootloader && rebootafter=true
    echo $(mygrep_prop "Reboot after installing" $tmp/arguments.txt) | grep -q "recovery" &&
        rebootARG=recovery && rebootafter=true
    echo $(mygrep_prop "Safetynet fix" $tmp/arguments.txt) | grep -q "true" &&
        safetyfix=true || safetyfix=false
    echo $(mygrep_prop "Force Zygisk mode" $tmp/arguments.txt) | grep -q "true" &&
        force_zygisk=true || force_zygisk=false
    echo $(mygrep_prop "Add castom packages automatic in denylist" $tmp/arguments.txt) | grep -q "true" &&
        add_deny_list=true || add_deny_list=false
if (echo $(mygrep_prop "Force reading arguments.txt" $tmp/arguments.txt) | grep -q "true"); then
    first_select=2
else
    ui_print " "
    my_print "$text16"
    my_print "$text121"
    $force_zygisk  && ! $legacy_mode
    my_print "$text122 $text126" "selected"
$add_deny_list  && ! $legacy_mode &&
    my_print "$text123 $text126" "selected"
$Flash_DFE && ! $legacy_mode &&
    my_print "$text62 $text126" "selected"
$Flash_DFE && $legacy_mode &&
    my_print "$text63 $text126" "selected"
$Flash_Magisk &&
    my_print "$text64 $text126" "selected"
$Hide_No_Encryption &&
    my_print "$text65" "selected"
$Reflash_Recovery_After_Oat && $my_magisk_installer &&
    my_print "$text66" "selected"
$Flash_Current_Rerovery && ! $my_magisk_installer &&
    my_print "$text67" "selected"
$rem_lock && ! $my_magisk_installer &&
    my_print "$text68" "selected"
$wipe_data &&
    my_print "$text69" "selected"
$QUOTA_STAY &&
    my_print "$text70 $text126" "selected"
$safetyfix &&
    my_print "$text118 $text126" "selected"
$AVB_STAY &&
    my_print "$text71 $text126" "selected"
$rebootafter &&
    my_print "$text72 $rebootARG" "selected"
if $dynamic120hz && ! $legacy_mode; then
    my_print "$text73" "selected"
fi
ui_print " "
    my_print "$text17"
    my_print "$text18"
    
    MYSELECT "$text104" "$text19"
    #"DFE-method=$legacy_mode, Flash-Magisk=$Flash_Magisk, Hide-No-Encryption=$Hide_No_Encryption, Reflash-Recovery-for-OTA=$Reflash_Recovery_After_Oat, Reflash-current-Recovery=$Flash_Current_Rerovery, DISABLE-DYNAMIC-REFRESHRATE=$dynamic120hz, Wipe-DATA=$wipe_data, Remove-PIN=$rem_lock, Disable-QUOTA=$QUOTA_STAY, Disable-AVB=$AVB_STAY, Reboot-after-installing=${rebootafter}-$rebootARG, Safetynet-fix=$safetyfix, Force-Zygisk-mode=$force_zygisk, Add-castom-packages-automatic-in-denylist=$add_deny_list"
    first_select=$?
fi
case $first_select in
2)
    sleep 0.1

    ;;
    1)

    #twrp install "/sdcard/Download/miuipro_v12.0_alioth_22.7.14.zip"
    my_print "$text20?"
    Flash_DFE=true
    MYSELECT "DFE-NEO" "DFE-LEGACY" "$text21" "$text22"
    if [ $? = 2 ]; then
        legacy_mode=true
    else
        legacy_mode=false
    fi
    AVB_STAY=false
    QUOTA_STAY=false
    my_print "$text23"
    MYSELECT "$text25" "$text24"
    if [ $? = 2 ]; then

        my_print "$text26"
        MYSELECT "$text27" "$text28"
        if [ $? = 1 ]; then
            QUOTA_STAY=true
        else
            QUOTA_STAY=false
        fi

        my_print "$text29"
        MYSELECT "$text30" "$text31"
        if [ $? = 1 ]; then
            AVB_STAY=true
        else
            AVB_STAY=false
        fi

    else
        AVB_STAY=true
        QUOTA_STAY=true
    fi

    if $my_magisk_installer; then
        my_print "$text32"
        MYSELECT "$text24" "$text33"
        if [ $? = 1 ]; then
            Reflash_Recovery_After_Oat=true
        else
            Reflash_Recovery_After_Oat=false
        fi
    else
        my_print "$text34"
        MYSELECT "$text24" "$text33"
        if [ $? = 1 ]; then
            Flash_Current_Rerovery=true
        else
            Flash_Current_Rerovery=false
        fi
    fi

    my_print "${text35}${MAGISK_VER}?"
    MYSELECT "$text24" "$text33"
    if [ $? = 1 ]; then
        Flash_Magisk=true
    else
        Flash_Magisk=false
    fi

    my_print "$text36"
    MYSELECT "$text40" "$text39" "$text38" "$text37"
    if [ $? = 2 ]; then
        Hide_No_Encryption=true
    else
        Hide_No_Encryption=false
    fi
add_deny_list=true
force_zygisk=true
    my_print "$text41"
    MYSELECT "$text24" "$text33"
    if [ $? = 1 ]; then

        my_print "$text115"
        MYSELECT "$text116" "$text117"
        if [ $? = 1 ]; then
            safetyfix=true
        else
            safetyfix=false
        fi

        if $Flash_Magisk ; then
        my_print "$text125"
        MYSELECT "$text24" "$text33"
        if [ $? = 1 ]; then
            force_zygisk=true
        else
            force_zygisk=false
        fi
        fi

        
        my_print "$text124 $(wc -l $tmp/denylist.txt | awk '{print $1}')"
        MYSELECT "$text24" "$text33"
        if [ $? = 1 ]; then
            add_deny_list=true
        else
            add_deny_list=false
        fi


        my_print "$text42"
        MYSELECT "$text44" "$text43"
        if [ $? = 1 ]; then
            skip_warning=false
        else
            skip_warning=true
        fi

        my_print "$text48"
        MYSELECT "$text50" "$text49" \
            "$text52" \
            "$text51"
        if [ $? = 1 ]; then
            wipe_data=false
        else
            wipe_data=true

        fi

        if ! $wipe_data && [[ -f /data/system/locksettings.db ]] && ! $my_magisk_installer; then
            my_print "$text45"
            MYSELECT "$text47" "$text46"
            if [ $? = 1 ]; then
                rem_lock=false
            else
                rem_lock=true
            fi
        fi

        my_print "$text53"
        MYSELECT4 "$text54" "$text55" "$text56" "$text57"
        selectreturn=$?

        if [ $selectreturn = 1 ]; then
            rebootafter=false
        elif [ $selectreturn = 2 ]; then
            rebootafter=true
            rebootARG=system
        elif [ $selectreturn = 3 ]; then
            rebootafter=true
            rebootARG=recovery
        elif [ $selectreturn = 4 ]; then
            rebootafter=true
            rebootARG=bootloader
        else
            rebootafter=false
            rebootARG=""
        fi

        my_print "$text58"
        MYSELECT "$text59" "$text60"
        if [ $? = 1 ]; then
            dynamic120hz=true
        else
            dynamic120hz=false
        fi
    fi

    ;;
esac

if ! $Flash_Magisk &&
    ! $Hide_No_Encryption &&
    ! $Flash_DFE &&
    ! $Reflash_Recovery_After_Oat &&
    ! $Flash_Current_Rerovery; then
    my_abort 71
fi

# Welcome ui
timer_start2=$(date +%s%N)
my_print "$text61"



$force_zygisk  && ! $legacy_mode && my_print "$text122 $text126" "selected" || {
    sed -i 's|exec_background u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} zygisk_on||g' "$tmp"/init.rc
}


$add_deny_list  && ! $legacy_mode &&
    my_print "$text123 $text126" "selected" || {
    sed -i 's|exec_background u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} add_denylist||g' "$tmp"/init.rc
}

    
$Flash_DFE && ! $legacy_mode &&
    my_print "$text62 $text126" "selected"
$Flash_DFE && $legacy_mode &&
    my_print "$text63 $text126" "selected"
$Flash_Magisk &&
    my_print "$text64 $text126" "selected"
$Hide_No_Encryption &&
    my_print "$text65" "selected" ||
    sed -i 's|setprop ro.crypto.state encrypted||' "$tmp"/init.rc
$Reflash_Recovery_After_Oat && $my_magisk_installer &&
    my_print "$text66" "selected"
$Flash_Current_Rerovery && ! $my_magisk_installer &&
    my_print "$text67" "selected"

$rem_lock && ! $my_magisk_installer &&
    my_print "$text68" "selected"
$wipe_data &&
    my_print "$text69" "selected"

$QUOTA_STAY &&
    my_print "$text70 $text126" "selected"
! $QUOTA_STAY &&
    sed -i 's|echo "quota"|#echo "quota"|' "$tmp"/init.sh

$safetyfix &&
    my_print "$text118 $text126" "selected" || {

    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_fs||g' "$tmp"/init.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_init||g' "$tmp"/init.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_boot_complite||g' "$tmp"/init.rc
}

$AVB_STAY &&
    my_print "$text71 $text126" "selected"
! $AVB_STAY &&
    sed -i 's|echo "avb="|#echo "avb="|' "$tmp"/init.sh &&
    sed -i 's|echo "avb_keys="|#echo "avb_keys="|' "$tmp"/init.sh &&
    sed -i 's|echo "avb"|#echo "avb"|' "$tmp"/init.sh

$rebootafter &&
    my_print "$text72 $rebootARG" "selected"
if $dynamic120hz && ! $legacy_mode; then
    my_print "$text73" "selected" &&
        sed -i 's|#exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} patch120dynamic|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} patch120dynamic|' "$tmp"/init.rc
fi
if $legacy_mode && $Flash_DFE; then
    stop_dfe=false
    for file in /data/gsi/ota/*.img; do
        [[ -f $file ]] && stop_dfe=true
    done
    $stop_dfe && my_abort "98" "$text74"

    mount_part --mount
    if ! $my_magisk_installer && ! (mountpoint -q /vendor) && ! (mountpoint -q /system_root); then
        my_abort "88" "$text75"
    fi
    for file in $(find $($my_magisk_installer && echo /system || echo /system_root) /system_ext /odm /product /vendor -name "*fstab*"); do
        if (grep -q "/userdata" $file) && (grep -q "/metadata" $file); then
            rw_part_check "$(dirname "$file")" || my_abort "74" "$text106"
        fi
    done
    for file in $(find $($my_magisk_installer && echo /system || echo /system_root) /system_ext /odm /product /vendor -name "*fstab*"); do
        if (grep -q "/userdata" $file) && (grep -q "/metadata" $file); then
            DFE "$file"
            my_print "$(basename $file) successfully patched"
        fi
    done
    if $Hide_No_Encryption; then
        if ! $my_magisk_installer && (rw_part_check "/system_root/system"); then
            (grep -q "ro.crypto.state" /system_root/system/build.prop &&
                sed -i '/ro.crypto.state/d' /system_root/system/build.prop &&
                echo "ro.crypto.state=encrypted" >>/system_root/system/build.prop) ||
                echo "ro.crypto.state=encrypted" >>/system_root/system/build.prop
        elif $my_magisk_installer && (rw_part_check "/system"); then
            (grep -q "ro.crypto.state" /system/build.prop &&
                sed -i '/ro.crypto.state/d' /system/build.prop &&
                echo "ro.crypto.state=encrypted" >>/system/build.prop) ||
                echo "ro.crypto.state=encrypted" >>/system/build.prop
        fi
    fi
fi
ui_print " "
for forslot in $(
    if $A_only; then
        echo "A_only"
    elif (echo $(mygrep_prop "Flash SLOT" $tmp/arguments.txt) | grep -q "in-current"); then
        echo $slot_ab
    elif (echo $(mygrep_prop "Flash SLOT" $tmp/arguments.txt) | grep -q "un-current"); then
        echo $not_slot_ab
    else
        echo $slot_ab $not_slot_ab
    fi
); do
    {
        mkdir $tmp/current_boot$forslot
        tmp_boot=$tmp/current_boot$forslot
        ! $my_magisk_installer && mount_part --umount
 
        if [[ $forslot == "A_only" ]]; then
            BOOTIMAGE=
            if $RECOVERYMODE; then
                BOOTIMAGE=$(find_block "recovery_ramdisk$SLOT" "recovery$SLOT" "sos")
            elif [ ! -z $SLOT ]; then
                BOOTIMAGE=$(find_block "ramdisk$SLOT" "recovery_ramdisk$SLOT" "init_boot$SLOT" "boot$SLOT")
            else
                BOOTIMAGE=$(find_block ramdisk recovery_ramdisk kern-a android_boot kernel bootimg init_boot boot lnx boot_a)
            fi
            if [ -z $BOOTIMAGE ]; then
                # Lets see what fstabs tells me
                BOOTIMAGE=$(grep -v '#' /etc/*fstab* | grep -E '/boot(img)?[^a-zA-Z]' | grep -oE '/dev/[a-zA-Z0-9_./-]*' | head -n 1)
            fi
        else
            SLOT=$forslot
            find_boot_image
        fi
        boot=$BOOTIMAGE
        #boot=/storage/emulated/0/Download/boot.img
        #BOOTIMAGE=/storage/emulated/0/Download/boot.img
        [[ -z $boot ]] && my_abort 4
        cd $tmp_boot
        magiskboot unpack -h $boot &>$(dirname $arg3)/log.txt
        
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/my_mg_64" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/my_mg_64"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/my_mg_32" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/my_mg_32"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/init.dfe.sh" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/init.dfe.sh"
        magiskboot cpio ramdisk.cpio "exists overlay.d/init.dfe.rc" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/init.dfe.rc"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/dfe_neo_support_binary" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/dfe_neo_support_binary"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/dfe.neo.magisk.lib.txt" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/dfe.neo.magisk.lib.txt"

        if $Flash_Current_Rerovery && ! $my_magisk_installer && ! [ $forslot = "A_only" ]; then
            ! $my_magisk_installer && mount_part --umount
            ramdisk_files=$(find / -maxdepth 1 -type f -name "*ramdisk-files*" -and -not -name "*.txt")
            cd /
            if (sha256sum --status -c "$ramdisk_files"); then
                my_print "$text112 $($A_only || echo $text78 $forslot)"
                cd $tmp_boot || my_abort "3"
                rm -f ramdisk.cpio
                cd /
                cpio -H newc -o </ramdisk-files.txt >$tmp_boot/ramdisk.cpio
                cd $tmp_boot || my_abort "3"

                #magiskboot repack /dev/block/by-name/boot$forslot &>$(dirname $arg3)/log.txt

                #flash_image \
                #    "$tmp/recovery$forslot/new-boot.img" \
                #    "/dev/block/by-name/boot$forslot"

                cd $tmp || my_abort "3"
                #rm -rf $tmp/recovery$forslot
            else
                my_abort "65" "$text76"
            fi
        fi
        if $Reflash_Recovery_After_Oat && $my_magisk_installer && ! [ $forslot = "A_only" ]; then
            if [[ $forslot == $not_slot_ab ]]; then
                mkdir -pv $tmp/recovery$slot_ab &>$(dirname $arg3)/log.txt
                cd $tmp/recovery$slot_ab || my_abort "3"
                magiskboot unpack -h /dev/block/by-name/boot$slot_ab &>$(dirname $arg3)/log.txt               
                rm -f $tmp_boot/ramdisk.cpio

                mv \
                    $tmp/recovery$slot_ab/ramdisk.cpio \
                    $tmp_boot/ramdisk.cpio
                cd $tmp || my_abort "3"
            fi
        fi

        if $Flash_Magisk; then
            cp $MAGISKBIN/* $tmp_boot/
            chmod -R 755 $tmp_boot
            my_print "$text77$MAGISK_VER $($A_only || echo $text78 $forslot)"
            BOOTIMAGE=$boot
            cd $tmp_boot
            sed -i 's|cd|#cd|' $tmp_boot/boot_patch.sh
            sed -i 's|./magiskboot unpack|#./magiskboot unpack|' $tmp_boot/boot_patch.sh
            sed -i 's|./magiskboot repack|#./magiskboot repack|' $tmp_boot/boot_patch.sh
            if [ ! -c $BOOTIMAGE ]; then
                eval $BOOTSIGNER -verify <$BOOTIMAGE && BOOTSIGNED=true
                $BOOTSIGNED && ui_print "- Boot image is signed with AVB 1.0"
            fi

            # Source the boot patcher
            SOURCEDMODE=true
            . ./boot_patch.sh "$BOOTIMAGE" &>$(dirname $arg3)/log.txt
            case $? in
            1)
                abort "! Insufficient partition size"
                ;;
            2)
                abort "! $BOOTIMAGE is read only"
                ;;
            esac
            run_migrations &>$(dirname $arg3)/log.txt
            cd $tmp || my_abort "3"
        fi

        if $Flash_DFE && ! $legacy_mode; then
            my_print "$text79 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
            cd $tmp_boot || my_abort "3"
            magiskboot cpio ramdisk.cpio test &>$(dirname $arg3)/log.txt
            STATUSM=$?
            if [[ $STATUSM == 0 ]] ||
                ( ! (magiskboot cpio ramdisk.cpio \
                    "exists overlay.d/sbin/magisk64.xz" &>$(dirname $arg3)/log.txt) ||
                    ! (magiskboot cpio ramdisk.cpio \
                        "exists overlay.d/sbin/magisk32.xz" &>$(dirname $arg3)/log.txt)); then
                STATUSM=0
            fi
            case $STATUSM in
            1)
                my_print "$text80 $($A_only || echo $text78 $forslot)"
                my_print "$text81 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
                magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" && \
                echo magisk64 >> dfe.neo.magisk.lib.txt
                magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" && \
                echo magisk32 >> dfe.neo.magisk.lib.txt
                ;;
            0)
                my_print "$text82 $($A_only || echo $text78 $forslot)"
                my_print "$text83 $($A_only || echo $text78 $forslot)"
                            cp $MAGISKBIN/* $tmp_boot/
            chmod -R 755 $tmp_boot
            BOOTIMAGE=$boot
            cd $tmp_boot
            sed -i 's|cd|#cd|' $tmp_boot/boot_patch.sh
            sed -i 's|./magiskboot unpack|#./magiskboot unpack|' $tmp_boot/boot_patch.sh
            sed -i 's|./magiskboot repack|#./magiskboot repack|' $tmp_boot/boot_patch.sh
            if [ ! -c $BOOTIMAGE ]; then
                eval $BOOTSIGNER -verify <$BOOTIMAGE && BOOTSIGNED=true
                $BOOTSIGNED && ui_print "- Boot image is signed with AVB 1.0"
            fi

            # Source the boot patcher
            SOURCEDMODE=true
            . ./boot_patch.sh "$BOOTIMAGE" &>$(dirname $arg3)/log.txt
            case $? in
            1)
                abort "! Insufficient partition size"
                ;;
            2)
                abort "! $BOOTIMAGE is read only"
                ;;
            esac
            run_migrations &>$(dirname $arg3)/log.txt
                cd $tmp_boot || my_abort "3"
                my_print "$text85 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
                if ( magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" ) ; then
                magiskboot cpio ramdisk.cpio "extract overlay.d/sbin/magisk64.xz 64.xz"
                magiskboot decompress 64.xz my_mg_64
                echo magisk64 >> dfe.neo.magisk.lib.txt
                magiskboot cpio ramdisk.cpio "add 0750 overlay.d/sbin/my_mg_64 my_mg_64"
                fi
                if ( magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk32.xz" ) ; then
                magiskboot cpio ramdisk.cpio "extract overlay.d/sbin/magisk32.xz 32.xz"
                magiskboot decompress 32.xz my_mg_32
                echo magisk32 >> dfe.neo.magisk.lib.txt
                magiskboot cpio ramdisk.cpio "add 0750 overlay.d/sbin/my_mg_32 my_mg_32"
                fi
                magiskboot cpio ramdisk.cpio \
                    "rm overlay.d/sbin/magisk64.xz" \
                    "rm overlay.d/sbin/magisk32.xz" &>$(dirname $arg3)/log.txt

                ;;
            esac
            cd $tmp_boot
            unzip -o "$tmp/magisklite.zip" \
    "lib/$CPU/libmagisk64.so" -j -d $tmp_boot &>$(dirname $arg3)/log.txt
    unzip -o "$tmp/magisklite.zip" \
    "lib/$CPU/libmagisk32.so" -j -d $tmp_boot &>$(dirname $arg3)/log.txt
            [ -f $tmp_boot/libmagisk64.so ] && inject_my_magisk=$tmp_boot/libmagisk64.so
            [ -f $tmp_boot/libmagisk32.so ] && inject_my_magisk=$tmp_boot/libmagisk32.so
            magiskboot cpio ramdisk.cpio "exists .backup/.magisk" &>$(dirname $arg3)/log.txt &&
                magiskboot cpio ramdisk.cpio "extract .backup/.magisk fconfig" &>$(dirname $arg3)/log.txt
            (cat fconfig | grep -q "KEEPVERITY=true") &&
                sed -i 's|KEEPVERITY=true|KEEPVERITY=false|' fconfig
            (cat fconfig | grep -q "KEEPFORCEENCRYPT=true") &&
                sed -i 's|KEEPFORCEENCRYPT=true|KEEPFORCEENCRYPT=false|' fconfig
            magiskboot cpio ramdisk.cpio \
                "add 0750 overlay.d/sbin/init.dfe.sh $tmp/init.sh" \
                "add 0750 overlay.d/sbin/m.db $tmp/magisk.db" \
                "add 0750 overlay.d/sbin/sql $tmp/sql" \
                "add 0750 overlay.d/sbin/denylist.txt $tmp/denylist.txt" \
                "add 0750 overlay.d/sbin/dfe.neo.magisk.lib.txt dfe.neo.magisk.lib.txt" \
                "add 0750 overlay.d/sbin/dfe_neo_support_binary $inject_my_magisk" \
                "add 0750 overlay.d/init.dfe.rc $tmp/init.rc" \
                "add 000 .backup/.magisk fconfig" &>$(dirname $arg3)/log.txt
        fi
     cd $tmp_boot
     my_print "$text113 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
            magiskboot repack $boot &>$(dirname $arg3)/log.txt
            my_print "$text114 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
            flash_image ./new-boot.img $boot
            #cp ./new-boot.img /sdcard/boot$forslot.img
            rm -f ./new-boot.img ./kernel ./header ./ramdisk.cpio
            cd $tmp
    } &
done
wait
if $rem_lock && ! $my_magisk_installer; then
    my_print "$text86"
    rm -f /data/system/locksettings*
fi
#rm -rf $tmp
#[[ -d $tmp_super_part ]] && rm -rf $tmp_super_part

timer_end=$(date +%s%N)
timer_time1=$(expr $timer_end - $timer_start1)
timer_time2=$(expr $timer_end - $timer_start2)
second_time1=$(expr $timer_time1 / 1000000000)
second_time2=$(expr $timer_time2 / 1000000000)
msecond_time1=$(expr ${timer_time1#*$second_time1} / 10000000)
msecond_time2=$(expr ${timer_time2#*$second_time2} / 10000000)
if $wipe_data; then
    my_print "Wiping data"
    find /data -maxdepth 1 -mindepth 1 -not -name "media" -exec rm -rf {} \;
fi

mkdir -p $MAGISKBIN &>$(dirname $arg3)/log.txt
cp -af $BINDIR/. $tmp/magisk_files_tmp/* $BBBIN $MAGISKBIN
chmod -R 755 $MAGISKBIN

my_print " "
my_print " "
my_print "$text87 ${second_time1}.$msecond_time1 $text88"
my_print "$text89 ${second_time2}.$msecond_time2 $text88"
ui_print "    $text90"
ui_print "    **** v$DFENV ****"
my_print " "
my_print " "
$BOOTMODE || recovery_cleanup
rm -rf $TMPDIR $tmp
[[ -f /data/adb/modules_update/DFENEO/customize.sh ]] && rm -rf /data/adb/modules_update/DFENEO
[[ -f /data/adb/modules/DFENEO/customize.sh ]] && rm -rf /data/adb/modules/DFENEO
if $Flash_DFE && ! $skip_warning; then
    sleep 2
    my_print " "
    my_print "$text91"
    my_print "$text91"
    my_print "$text91"
    my_print "$text91"
    my_print " "
    sleep 1
    if $my_magisk_installer; then
        if ! $ISENCRYPTED || [[ $(getprop ro.dfe.neo.state) == "decrypted" ]]; then
            ui_print "************************************"
            ui_print " "
            my_print "$text92"
            ui_print " "
            ui_print "************************************"
        else
            ui_print "************************************"
            my_print " "
            my_print "$text93"
            my_print " "
            ui_print "************************************"

        fi
    else
        ui_print "************************************"
        ui_print " "
        my_print "$text94"
        ui_print " "
        ui_print "************************************"
    fi
    if ! $legacy_mode; then
        my_print "$text95"
        ui_print " "
        sleep 1
        my_print "$text96"
        ui_print " "
        sleep 1
        my_print "$text97"
        ui_print " "
        sleep 1
        my_print "$text98"
        ui_print " "
        sleep 1
        my_print "$text99"
        ui_print " "
    else
        my_print "$text100"
        ui_print " "
    fi
    if $my_magisk_installer; then
        ui_print " "
        ui_print " "
        ui_print " "
        ui_print " "
    fi
fi
if $rebootafter; then
    ui_print "$text101 $rebootARG $text102..."
    n=7
    while ! [ $n = "-1" ]; do
        sleep 1
        ui_print "-  ${n}s..."
        n=$((n - 1))
    done
    reboot $rebootARG
fi

exit 0
