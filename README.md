ovr-overlay 
===

Packages and configs not maintained elsewhere

This overlay is not official and not available in layman (as an official source).

**Use ebuilds supplied in this repository on your own risk**. They've been tested on my own system setup (~amd64) and (most likely) tested on virtual systems (amd64 and x86).

### Installing

Please read https://wiki.gentoo.org/wiki/Layman for more information regarding layman.

### Add it using layman:

      layman -f -o https://raw.githubusercontent.com/kergalym/ovr/master/repositories.xml -a ovr

### Add it manually :

      cd /var/lib/layman
      git clone https://github.com/kergalym/ovr.git

then add it to your make.conf


