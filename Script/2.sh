pacstrap /mnt base base-devel linux linux-firmware nvim networkmanager reflector rsync

PKGS=(
    'mesa'
    'xorg'
    'xorg-server'
    'xorg-drivers'
    'xorg-xkill'
    'xorg-xinit'
    'alsa-plugins'
    'alsa-utils'
    'cronie'
    'efibootmgr'
    'exfat-utils'
    'dosfstools'
    'firefox'
    'git'
    'htop'
    'ufw'
    'neofetch'
    'sddm'
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    pacstrap "$PKG" --noconfirm --needed
done

genfstab -U /mnt >> /mnt/etc/fstab
reboot