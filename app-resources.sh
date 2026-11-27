#!/bin/sh
# app-resources.sh DEST [IMAGE]
# Brings, from your own Mac, what the Dock, Launch Services and IconServices read in the applications of the system: each bundle's Contents/Info.plist,
# its icon files (Contents/Resources/*.icns) and its asset catalog (Contents/Resources/Assets.car, where IconServices finds the icon named by
# CFBundleIconName).  The image of pearOS has only skeletons of these bundles (iso/tools/macfs.py: names and a minimal Info.plist), never Apple's files.
# DEST gets the layout of the cache disk (the disk labelled MACCACHE is mounted on /System/Volumes, see iso's rc script wsbsd_macdeps):
#   DEST/System/Applications/...                       /System/Applications and Utilities (laid over the skeletons at boot)
#   DEST/System/Library/CoreServices/...                the applications of CoreServices (Finder ...)
#   DEST/Preboot/Cryptexes/App/System/Applications/...  Safari, from the cryptex of the applications: the path a Mac has, under /System/Volumes
# IMAGE (optional): a FAT32 image of the cache disk (cache.img); the tree is copied into it with mtools (the image must not be in use by a VM).
# Needs ssh to the Mac (port 2229, key ~/fbsd-vm/id_ed25519, user alex).  The files stay on your machine and on the cache disk: they are never committed.
set -e
DEST="${1:?destination directory}"; IMAGE="$2"
MAC="ssh -i $HOME/fbsd-vm/id_ed25519 -p 2229 -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q alex@localhost"
mkdir -p "$DEST"
# on the Mac (in sh: its login shell is zsh, whose unmatched globs are errors): the list of files (relative to /), then one tar stream of them
$MAC /bin/sh -s <<'MACSIDE' | tar xf - -C "$DEST"
cd / && for a in System/Applications/*.app System/Applications/Utilities/*.app System/Library/CoreServices/*.app System/Volumes/Preboot/Cryptexes/App/System/Applications/*.app; do
	[ -f "$a/Contents/Info.plist" ] || continue
	echo "$a/Contents/Info.plist"
	for f in "$a"/Contents/Resources/*.icns "$a/Contents/Resources/Assets.car"; do [ -f "$f" ] && echo "$f"; done
done > /tmp/app-resources.list
tar cf - -T /tmp/app-resources.list
MACSIDE
# the cryptex path is the cache disk's own Preboot directory (the disk is mounted on /System/Volumes)
if [ -d "$DEST/System/Volumes/Preboot" ]; then
	mkdir -p "$DEST/Preboot"
	cp -R "$DEST/System/Volumes/Preboot/." "$DEST/Preboot/"
	rm -rf "$DEST/System/Volumes"
fi
echo "$(find "$DEST" -name Info.plist | wc -l | tr -d ' ') bundles, $(du -sh "$DEST" | cut -f1)"
if [ -n "$IMAGE" ]; then
	for d in System Preboot; do [ -d "$DEST/$d" ] && mcopy -s -o -i "$IMAGE" "$DEST/$d" ::/; done
	echo "copied into $IMAGE"
fi
