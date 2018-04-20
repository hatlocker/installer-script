if [ $# -lt 3 ];
then
	echo "Usage: $0 <disk> <version> <urlroot>"
	exit 1
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
echo provision123 | cryptsetup luksOpen -q /dev/${disk}4 data
pvcreate /dev/mapper/data
vgcreate datavg /dev/mapper/data
lvcreate -L 1GB -n etcvol datavg
lvcreate -l 100%FREE -n datavol datavg
mkfs.ext4 /dev/mapper/datavg-etcvol
mkfs.xfs /dev/mapper/datavg-datavol
lvchange -an /dev/datavg/datavol
vgchange -an datavg
cryptsetup luksClose data

mkdir /mnt/ESP
mount /dev/${disk}1 /mnt/ESP
curl $urlroot/$version.efi | dd of=/mnt/ESP/OSA.EFI
curl $urlroot/$version.efi | dd of=/mnt/ESP/OSB.EFI
umount /mnt/ESP
rmdir /mnt/ESP

efibootmgr --create-only --bootnum 111A --label "HatLocker OS A" --disk /dev/${disk} --part 1 --loader /OSA.EFI
efibootmgr --create-only --bootnum 111B --label "HatLocker OS B" --disk /dev/${disk} --part 1 --loader /OSB.EFI

efibootmgr --bootorder 111A

curl $urlroot/$version.gz | gzip --decompress | dd of=/dev/${disk}2

# TODO: Setup mokutil for key import
