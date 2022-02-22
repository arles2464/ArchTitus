systemctl enable --now NetworkManager
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf

echo "-------------------------------------------------"
echo "       Setup Language to AU and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
localectl --no-ask-password set-locale LANG="en_AU.UTF-8" LC_COLLATE="" LC_TIME="en_AU.UTF-8"
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^#Para/Para/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac
# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

useradd -m charlie
usermod -aG wheel,video,audio,optical,storage,libvirt
read -p "Please name your machine:" nameofmachine
echo $nameofmachine > /etc/hostname