#/usr/bin/env bash

set -e

# Make sure you have the proper ISO loaded as the first CLI argument
ISO_PATH="$1"
DESTINATION="source-files"
BASE=$(basename "$ISO_PATH" | python3 -c 'import sys; print(sys.stdin.read().split(".iso")[0])')
FILENAME="$BASE-auto-installer.iso"

[[ -d "$DESTINATION" ]] && rm -rf "$DESTINATION"
[[ ! -d "$DESTINATION" ]] && mkdir "$DESTINATION"

# You need to have xorriso installed on this machine
# Extract the entire filesystem to the destination path
xorriso -osirrox on -indev "$ISO_PATH" --extract_boot_images source-files/bootpart -extract / "$DESTINATION"
mkdir "$DESTINATION"/{nocloud,scripts}

# Generate a new password for your account
SALTED_PASSWORD=$(openssl passwd -6 "xxx")
USERNAME="jared"

# Place the password inside of the generated YAML file
yq '.autoinstall.identity.password = "'$SALTED_PASSWORD'" | .autoinstall.identity.username = "'$USERNAME'"' user-data.yaml > "$DESTINATION"/nocloud/user-data

# Copy the meta-data file (required for cloud-init nocloud datasource)
cp meta-data "$DESTINATION"/nocloud/meta-data

# Change the boot menu to point to this installer script instead of the manual one provided by Ubuntu
cp grub.cfg "$DESTINATION"/boot/grub
chmod 644 "$DESTINATION"/boot/grub/grub.cfg

cp bootstrap.sh "$DESTINATION"/scripts

# Package the ISO again

cd "$DESTINATION"

xorriso -as mkisofs -r -V "ubuntu-autoinstall" -J -boot-load-size 4 -boot-info-table -input-charset utf-8 -eltorito-alt-boot -b bootpart/eltorito_img1_bios.img -no-emul-boot -o ../"$FILENAME" .

cd ..

echo "Uploading ISO to proxmox"

rsync -e ssh -avP "$FILENAME" root@192.168.1.253:/var/lib/vz/template/iso/
