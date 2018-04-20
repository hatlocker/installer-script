disk="$1"
if [ ! -b /dev/$disk ];
then
	echo "$disk seems to be an incorrect target"
	exit 1
fi

parted /dev/$disk -s -- \
	mklabel gpt \
	mkpart ESP fat32 1MiB 2GiB \
	set 1 boot on \
	mkpart OSA fat32 2GiB 22GiB \
	mkpart OSB fat32 22GiB 42GiB \
	mkpart DATA ext4 42GiB -1
