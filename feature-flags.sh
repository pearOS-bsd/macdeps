#!/bin/sh
# feature-flags.sh DEST [IMAGE]
# The feature flags of the owner's Mac (/System/Library/FeatureFlags: Domain/*.plist and Unified/*): os_feature_enabled() of the Mac's libraries reads them, and a
# missing directory turns every flag off (the real Dock then takes other paths than on a Mac: WindowServer/CAWindowContent is FeatureComplete on macOS 26.7.2).
# DEST gets the layout of the cache disk (System/Library/FeatureFlags; iso's rc script wsbsd_macdeps copies it into the tmpfs copy of /System/Library).
# IMAGE (optional): the FAT32 image of the cache disk (cache.img), copied into with mtools.  The files are Apple's: they stay on your machine and on the cache disk.
set -e
DEST="${1:?destination directory}"; IMAGE="$2"
MAC="ssh -i $HOME/fbsd-vm/id_ed25519 -p 2229 -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q alex@localhost"
mkdir -p "$DEST/System/Library"
$MAC 'cd /System/Library && tar cf - FeatureFlags' | tar xf - -C "$DEST/System/Library"
echo "$(find "$DEST/System/Library/FeatureFlags" -type f | wc -l | tr -d ' ') files"
[ -n "$IMAGE" ] && mcopy -s -o -i "$IMAGE" "$DEST/System" ::/ && echo "copied into $IMAGE"
