bpar is a custom program developed by [swagtoy](https://github.com/swagtoy). It can extract and replace files in the DATA.BP file in Doko Demo Issyo PSP.

bpar was originally available in swaytoy's [ddi-tools](https://github.com/pumpkinhasapatch/dokodemo-psp-english), which has been taken down and archived here on GitHub.

The source code is available in `bpar.c`. The code has been slightly modified to work on Windows (see below).

`bpar` is a compiled version of the program that can be run from terminal. It has been tested on Debian and Fedora Linux.

`bpar_cosmo.com` is a cross-platform version compiled with [Cosmopolitan](https://github.com/jart/cosmopolitan) that is compatible with Windows and possibly other operating systems.

bpar has some known issues, such as corrupting the DATA.BP archive sometimes when resizing files. Because of this, it is recommended to make sure all inserted files and GIM images are the same size as the original extracted file.

If you are an experienced C programmer, we would love for you to take a look at the source code and try to squash some bugs.