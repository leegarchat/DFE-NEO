#!/sbin/sh

my_print "Unpacking tools"
cd $tmp
# Unpack busybox
mkdir -pv "$tmp/my_BB"
mkdir -pv "$tmp/my_bins"
unzip -o "$arg3" "tools/busybox.zip" -d "$tmp"/
unzip -o "$tmp/tools/busybox.zip" -d "$tmp"/my_BB/
BB=""
chmod 777 $tmp/my_BB/*

# Find busybox for arch
{
    "$tmp"/my_BB/busybox-x86_64 &&
        BB="$tmp/my_BB/busybox-x86_64" &&
        MB="$tmp/magiskboot/magiskboot-x86_64" &&
        little_arch="x86" &&
        big_arch="x86_64"
} ||
    {
        "$tmp"/my_BB/busybox-x86 &&
            BB="$tmp/my_BB/busybox-x86" &&
            MB="$tmp/magiskboot/magiskboot-x86" &&
            little_arch="x86" &&
            big_arch="x86"
    } ||
    {
        "$tmp"/my_BB/busybox-arm64 &&
            BB="$tmp/my_BB/busybox-arm64" &&
            MB="$tmp/magiskboot/magiskboot-arm64" &&
            little_arch="armeabi-v7a" &&
            big_arch="arm64-v8a"
    } ||
    {
        "$tmp"/my_BB/busybox-arm &&
            BB="$tmp/my_BB/busybox-arm" &&
            MB="$tmp/magiskboot/magiskboot-arm" &&
            little_arch="armeabi-v7a" &&
            big_arch="armeabi-v7a"
    } ||
    my_abort "75" "Cant find busybox arch"

cp "$BB" "$tmp/my_bins/busybox"
BB=$tmp/my_bins/busybox
chmod 777 "$BB"

# Unpack dfe-neo.zip
mkdir -pv "$tmp/LNG"

$BB unzip -o "$arg3" \
    "arguments.txt" \
    "denylist.txt" \
    "tools/bootctl" \
    "tools/magiskboot.zip" \
    "tools/magisklite25.2.zip" \
    "tools/others.magisk.files.zip" \
    "tools/init.rc" \
    "tools/magisk.db" \
    "tools/init.sh" \
    "tools/sql" \
    -j -d $tmp/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"

# unpack languages
$BB unzip -o "$arg3" \
    "languages/*.sh" \
    -j -d $tmp/LNG/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"

# Magiksboot unpack
mkdir -pv "$tmp/magiskboot"
$BB unzip -o "$tmp/magiskboot.zip" -j -d $tmp/magiskboot/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
cp "$MB" "$tmp/my_bins/magiskboot"
MB="$tmp/my_bins/magiskboot"
chmod 777 "$MB"
mv "$tmp/bootctl" "$tmp/my_bins/bootctl"
PATH=$tmp/my_bins:$PATH

[ -f $BB ] || my_abort 63

chmod 777 $tmp/my_bins/*

# Slot detected
slot_num=$(bootctl get-current-slot)
slot_ab=$(bootctl get-suffix $slot_num)
if ! [ "$(getprop ro.virtual_ab.enabled)" = "true" ]; then A_only=true; fi
if $A_only; then
    sleep 0.1
elif [[ $slot_ab == "_a" ]]; then
    not_slot_ab="_b"
elif [[ $slot_ab == "_b" ]]; then
    not_slot_ab="_a"
else
    slot_ab=""
    not_slot_ab=""
fi


