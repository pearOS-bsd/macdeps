# macdeps

Brings what Apple owns from **your own Mac** to the test machine.  This repository holds **scripts and lists only — no Apple files**.

- `macdeps.sh PROGRAM [loops]` — runs a Mac program through the real dyld on the FreeBSD machine; every "Library not loaded: PATH" is fetched from the Mac (the path itself, or the same path in its cryptex) and put where dyld looks next, until the program loads.
- `app-resources.sh DEST [IMAGE]` — the `Info.plist`, icon files (`*.icns`) and asset catalog (`Assets.car`) of the Mac's system applications (/System/Applications, CoreServices, Safari's cryptex), in the layout of the cache disk (MACCACHE, mounted on /System/Volumes); with IMAGE it copies them into that FAT32 image (mtools). The image of pearOS has only skeletons of these bundles; Launch Services, IconServices and the Dock read these files.
- `feature-flags.sh DEST [IMAGE]` — the Mac's /System/Library/FeatureFlags (os_feature_enabled reads them; without them every flag is off and Mac programs take other paths), for the cache disk.
- `loaded-libraries.txt` — the libraries that had to be brought this way for the Dock/Finder stack (28).
- `stack-files.txt` — the files of the Mac userland the stack uses (1282 paths: shell tools, daemons, bundles).

Needs ssh to the FreeBSD machine (port 2222) and to the Mac (port 2229), same key.  What is copied stays on the machine and is never committed.
