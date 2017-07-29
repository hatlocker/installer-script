parted /dev/vda -s -- \
	mklabel gpt \
	mkpart ESP fat32 1MiB 2GiB \
	set 1 boot on \
	mkpart OSA fat32 2GiB 22GiB \
	mkpart OSB fat32 22GiB 42GiB \
	mkpart DATA ext4 42GiB -1
