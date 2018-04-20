disk="$1"
if [ ! -b /dev/$disk ];
then
	echo "$disk seems to be an incorrect target"
	exit 1
fi

parted /dev/$disk -s -- \
	mklabel gpt \
	mkpart ESP fat32 1MiB 1GiB \
	set 1 boot on \
	mkpart OSA fat32 1GiB 11GiB \
	mkpart OSB fat32 11GiB 21GiB \
	mkpart DATA ext4 21GiB -1
