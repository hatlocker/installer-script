parted /dev/vda -s -- \
	mklabel gpt \
	mkpart ESP fat32 1MiB 1GiB \
	set 1 boot on \
	mkpart OSA fat32 1GiB 11GiB \
	mkpart OSB fat32 11GiB 21GiB \
	mkpart DATA ext4 21GiB -1
