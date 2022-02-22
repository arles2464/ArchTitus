timedatectl set-ntp true
sed -i 's/^#Para/Para/' /etc/pacman.conf
pacman -Syu
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --country Australia --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt
echo "Hey dude, format the disk please"