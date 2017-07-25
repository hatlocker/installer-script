parted /dev/vda -s -- \
	mklabel gpt \
	mkpart ESP fat32 1MiB 1GiB \
	set 1 boot on \
	mkpart OSA fat32 1GiB 11GiB \
	mkpart OSB fat32 11GiB 21GiB \
	mkpart DATA ext4 21GiB -1

echo provision123 | cryptsetup luksFormat -q /dev/vda4
echo provision123 | cryptsetup luksOpen -q /dev/vda4 data
pvcreate /dev/mapper/data
vgcreate datavg /dev/mapper/data
lvcreate -l 100%VG -n datavol datavg
mkfs.xfs /dev/mapper/datavg-datavol

# TODO: Store first image onto OSA and ESP
# TODO: Run efibootmgr to set up boot entries
# TODO: Setup mokutil for key import
