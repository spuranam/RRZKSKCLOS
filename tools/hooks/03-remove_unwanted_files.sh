#!/bin/sh
# Thanks to https://git-tails.immerda.ch/tails/tree/config/chroot_local-hooks

set -x
set -e
set -u

echo "Removing unwanted files"

find $WD/chroot/usr/share/doc -type f -name changelog.gz        -delete
find $WD/chroot/usr/share/doc -type f -name changelog.Debian.gz -delete
find $WD/chroot/usr/share/doc -type f -name NEWS.Debian.gz      -delete

# Remove the snakeoil SSL key pair generated by ssl-cert
find $WD/chroot/etc/ssl/certs $WD/chroot/etc/ssl/private |
	while read f; do
		if [ "$(readlink -f "$f")" = "$WD/chroot/etc/ssl/certs/ssl-cert-snakeoil.pem" ] || \
		   [ "$(readlink -f "$f")" = "$WD/chroot/etc/ssl/private/ssl-cert-snakeoil.key" ]; then
			rm -f "${f}"
		fi
	done
debuerreotype-chroot $WD/chroot update-ca-certificates

# Other unwanted files

# Not truly important files
rm -f $WD/chroot/var/lib/dpkg/info/*.md5sums

#  These will be generated on-the-fly
rm -f $WD/chroot/var/lib/systemd/catalog/database

# Empty non-deterministically generated file. If it exists and is empty, systemd
# will automatically set up a new unique ID. But if does not exist, systemd
# will populate /etc with preset unit settings, which will for example re-enable
# units we have disabled TAILS (#11970).
: > $WD/chroot/etc/machine-id

# END
