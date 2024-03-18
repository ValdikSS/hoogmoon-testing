#!/bin/bash
[[ "$1" ]] && cd "$1" || cd provision
tar --no-selinux --numeric-owner --group=0 --owner=0 -acf ../provision_temp.tar.gz *
(python3 -c 'print("{:<512}".format("PROVISION"), end="")' && cat ../provision_temp.tar.gz) > ../provision.tar.gz
truncate -s 64K ../provision.tar.gz
#rm ../provision_temp.tar.gz

echo "Provision archive is generated as provision.tar.gz"
echo "To write it to the physical disk (DANGEROUS!), execute the following:"
echo
echo 'dd if=provision.tar.gz of=/dev/sdX conv=notrunc bs=512 seek=246335'
echo 'Or for network:'
echo 'ncat -l -p 4444 | dd of=/dev/sdX conv=notrunc bs=512 seek=246335'
echo
echo "To append it into the disk image, replace /dev/sdX with the disk image name."
echo
