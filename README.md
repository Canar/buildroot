# Buildroot

Buildroot is a simple, efficient and easy-to-use tool to generate embedded
Linux systems through cross-compilation.

The documentation can be found in docs/manual. You can generate a text
document with 'make manual-text' and read output/docs/manual/manual.text.
Online documentation can be found at http://buildroot.org/docs.html

To build and use the buildroot stuff, do the following:

1. run 'make menuconfig'
2. select the target architecture and the packages you wish to compile
3. run 'make'
4. wait while it compiles
5. find the kernel, bootloader, root filesystem, etc. in output/images

You do not need to be root to build or run buildroot.  Have fun!

Buildroot comes with a basic configuration for a number of boards. Run
'make list-defconfigs' to view the list of provided configurations.

Please feed suggestions, bug reports, insults, and bribes back to the
buildroot mailing list: buildroot@buildroot.org

You can also find us on #buildroot on Freenode IRC.

## About this fork

This fork is a modest attempt at teaching Buildroot to build itself. In order to do so, I've had to reinstate some packages. As is packaged here on GitHub, this package presently successfully builds itself on my Barcelona-class machine. I've been using systemd-nspawn containers for the build. Everything else is yet untested... so far.

The only reason this is going up now is because I'm nervous that I might fat-finger the codebase like I've done once already. It's wildly untested, and doesn't accomplish much other than run to completion.

The thing is, it runs to completion inside the image that it created before. As of release date, I'm about seven generations deep. I've done no analysis so I'm not sure if I'm losing information or anything... More to come.

Packages added: 
* mercurial
* unzip

Target packages added:
* automake
* autoconf
* m4
* bison
* gcc
* flex
* isl
* gmp
* cloog
* mpc
* mpfr

I've also hack-fixed a few libraries to work properly with ncursesw, as some have their config files set to depend on ncurses not ncursesw. Additionally, two packages depend on your c-compiler being `cc`. Minor stuff, really.

Happy hacking. <3 

Canar 
