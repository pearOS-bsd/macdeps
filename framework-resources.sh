#!/bin/sh
# framework-resources.sh DEST [IMAGE]
# Brings, from your own Mac, the resources that the Mac's frameworks (the code in the dyld cache) read from their bundles at run time:
#   AppKit      Resources/*.car + Info.plist   NSImage imageNamed: of AppKit's own images (NSScrollPocketAdditionalDimming: every titled window
#                                              of macOS 26 builds its scroll pocket from it and Swift traps on nil: SIGILL in -[NSWindow init...])
#   SwiftUI     Assets.car, mac-materials.json, *.loctable, *.materialrecipe, Info.plist
#   CoreUI      DesignLibrary-macOS.bundle (SwiftUI's system colours), default.metallib, DuplicateImageNames.plist, Info.plist
#   QuartzCore  default.metallib (its filters' and the glass's Metal shaders; WindowServer's glass_gpu.c loads them), Info.plist
# (macdeps/loaded-libraries.txt lists them.)  The image of pearOS has only skeletons of these frameworks (iso/tools/macfs.py), never Apple's files.
# DEST gets the layout of the cache disk (the disk labelled MACCACHE, mounted on /System/Volumes by iso's rc script wsbsd_macdeps, which copies
#   DEST/System/Library/Frameworks and PrivateFrameworks over the tmpfs copy of /System/Library at boot).
# IMAGE (optional): a FAT32 image of the cache disk (cache.img); the tree is copied into it with mtools (the image must not be in use by a VM).
# Needs ssh to the Mac (port 2229, key ~/fbsd-vm/id_ed25519, user alex).  The files stay on your machine and on the cache disk: they are never committed.
set -e
DEST="${1:?destination directory}"; IMAGE="$2"
MAC="ssh -i $HOME/fbsd-vm/id_ed25519 -p 2229 -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q alex@localhost"
mkdir -p "$DEST"
# on the Mac (in sh: its login shell is zsh, whose unmatched globs are errors): the list of files (relative to /), then one tar stream of them; Versions/<letter> is the real directory
$MAC /bin/sh -s <<'MACSIDE' | tar xf - -C "$DEST"
cd / && {
	F=System/Library/Frameworks; P=System/Library/PrivateFrameworks
	for f in $F/AppKit.framework/Versions/C/Resources/*.car $F/AppKit.framework/Versions/C/Resources/Info.plist; do [ -f "$f" ] && echo "$f"; done
	for f in $F/SwiftUI.framework/Versions/A/Resources/Assets.car $F/SwiftUI.framework/Versions/A/Resources/mac-materials.json $F/SwiftUI.framework/Versions/A/Resources/*.loctable $F/SwiftUI.framework/Versions/A/Resources/*.materialrecipe $F/SwiftUI.framework/Versions/A/Resources/Info.plist; do [ -f "$f" ] && echo "$f"; done
	for f in $P/CoreUI.framework/Versions/A/Resources/default.metallib $P/CoreUI.framework/Versions/A/Resources/DuplicateImageNames.plist $P/CoreUI.framework/Versions/A/Resources/Info.plist; do [ -f "$f" ] && echo "$f"; done
	[ -d $P/CoreUI.framework/Versions/A/Resources/DesignLibrary-macOS.bundle ] && find $P/CoreUI.framework/Versions/A/Resources/DesignLibrary-macOS.bundle -type f
	for f in $F/QuartzCore.framework/Versions/A/Resources/default.metallib $F/QuartzCore.framework/Versions/A/Resources/Info.plist; do [ -f "$f" ] && echo "$f"; done
} > /tmp/framework-resources.list
tar cf - -T /tmp/framework-resources.list
MACSIDE
echo "$(find "$DEST/System/Library" -type f | wc -l | tr -d ' ') files, $(du -sh "$DEST/System/Library" | cut -f1)"
if [ -n "$IMAGE" ]; then
	mcopy -s -o -i "$IMAGE" "$DEST/System" ::/
	echo "copied into $IMAGE"
fi
