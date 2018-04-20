#!/bin/bash
set -xe
if [ $# -lt 3 -o $# -gt 5 ];
then
	echo "Usage: $0 <disk> <version> <urlroot> [--skip-efi [--efi-boot]]"
	exit 1
fi
do_efi="y"
do_efi_boot="n"
if [ $# -ge 4 ];
then
	if [ "$4" == "--skip-efi" ];
	then
		do_efi="n"
		if [ $# -ge 5 ];
		then
			if [ "$5" == "--efi-boot" ];
			then
				do_efi_boot="y"
			else
				echo "Usage: $0 <disk> <version> <urlroot> [--skip-efi]"
				exit 1
			fi
		fi
	else
		echo "Usage: $0 <disk> <version> <urlroot> [--skip-efi]"
		exit 1
	fi
fi
disk="$1"
if [ ! -b /dev/${disk}1 ];
then
	echo "$disk seems to be an incorrect target"
	exit 1
fi
version="$2"
urlroot="$3"

mkfs.fat -F32 /dev/${disk}1

echo provision123 | cryptsetup luksFormat -q --uuid=ca9ea0ec-7514-11e7-a171-e4a4714acfe5 /dev/${disk}4
echo provision123 | cryptsetup luksOpen -q /dev/${disk}4 hldata
pvcreate /dev/mapper/hldata
vgcreate hldatavg /dev/mapper/hldata
lvcreate -L 1GB -n etcvol hldatavg
lvcreate -l 100%FREE -n datavol hldatavg
mkfs.ext4 /dev/mapper/hldatavg-etcvol
mkfs.xfs /dev/mapper/hldatavg-datavol
dmsetup remove hldatavg-etcvol
dmsetup remove hldatavg-datavol
dmsetup remove hldata

mkdir /mnt/ESP
mount /dev/${disk}1 /mnt/ESP
curl $urlroot/$version.efi | dd of=/mnt/ESP/OSA.EFI
curl $urlroot/$version.efi | dd of=/mnt/ESP/OSB.EFI
if [ "$do_efi_boot" == "y" ];
then
	echo "Installing /mnt/ESP/BOOT/BOOTX64.efi"
	mkdir -p /mnt/ESP/BOOT
	cp /mnt/ESP/OSA.EFI /mnt/ESP/BOOT/BOOTX64.EFI
fi
umount /mnt/ESP
rmdir /mnt/ESP

if [ "$do_efi" == "y" ];
then
	efibootmgr --create-only --bootnum 111A --label "HatLocker OS A" --disk /dev/${disk} --part 1 --loader /OSA.EFI
	efibootmgr --create-only --bootnum 111B --label "HatLocker OS B" --disk /dev/${disk} --part 1 --loader /OSB.EFI

	efibootmgr --bootorder 111A
else
	echo "Skipping EFI enrollment"
fi

curl $urlroot/$version.gz | gzip --decompress | dd of=/dev/${disk}2

# TODO: Setup mokutil for key import
