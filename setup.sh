mkfs.fat -F32 /dev/vda1

echo provision123 | cryptsetup luksFormat -q /dev/vda4
echo provision123 | cryptsetup luksOpen -q /dev/vda4 data
pvcreate /dev/mapper/data
vgcreate datavg /dev/mapper/data
lvcreate -L 1GB -n etcvol datavg
lvcreate -l 100%FREE -n datavol datavg
mkfs.ext4 /dev/mapper/datavg-etcvol
mkfs.xfs /dev/mapper/datavg-datavol
lvchange -an /dev/datavg/datavol
vgchange -an datavg
cryptsetup luksClose data

tune2fs /dev/vda4 -U ca9ea0ec-7514-11e7-a171-e4a4714acfe5

version="3"
urlroot="http://172.16.0.100/"

mkdir /mnt/ESP
mount /dev/vda1 /mnt/ESP
curl $urlroot/$version.efi | dd of=/mnt/ESP/OSA.EFI
umount /mnt/ESP
rmdir /mnt/ESP

efibootmgr --create-only --bootnum 111A --label "HatLocker OSA" --disk /dev/vda --part 1 --loader /OSA.EFI
efibootmgr --create-only --bootnum 111B --label "HatLocker OSB" --disk /dev/vda --part 1 --loader /OSB.EFI

efibootmgr --bootorder 111A

curl $urlroot/$version.gz | gzip --decompress | dd of=/dev/vda2

# TODO: Setup mokutil for key import
