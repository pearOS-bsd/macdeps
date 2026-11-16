# macdeps

Brings what Apple owns from **your own Mac** to the test machine.  This repository holds **scripts and lists only — no Apple files**.

- `macdeps.sh PROGRAM [loops]` — runs a Mac program through the real dyld on the FreeBSD machine; every "Library not loaded: PATH" is fetched from the Mac (the path itself, or the same path in its cryptex) and put where dyld looks next, until the program loads.
- `loaded-libraries.txt` — the libraries that had to be brought this way for the Dock/Finder stack (28).
- `stack-files.txt` — the files of the Mac userland the stack uses (1282 paths: shell tools, daemons, bundles).

Needs ssh to the FreeBSD machine (port 2222) and to the Mac (port 2229), same key.  What is copied stays on the machine and is never committed.
