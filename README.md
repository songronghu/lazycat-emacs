# Lazycat Emacs

*What is lazycat emacs can do?*
This is video show: [Video](https://www.youtube.com/watch?v=ZA3uuflGtk8)

**Description**:
Emacs is hackable OS for top hackers, most of emacs extensions are written in elisp.
Lazycat Emacs merged many extensions from [AndyStewart](http://www.emacswiki.org/emacs/AndyStewart),
you can find all extensions under [site-lisp](https://github.com/manateelazycat/lazycat-emacs/tree/master/site-lisp).

Lazycat Emacs’s target is to build a development environment that users don’t need to config elisp code line by line.
Lazycat Emacs provides below features:

- Code auto completion with most languages. (by autocomplete extensions)
- Code template system. (by yasnippet extension)
- Anything search system. (by helm extensions)
- Auto save when figure idle.
- Line number support. (by linum extension)
- Kill ring search. (by kill-ring-search extension)
- File manager. (by dired extension)
- Music player. (by emms extensions)
- Pdf viewer. (by doc-view extension)
- Irc client. (by rcirc and erc extension)
- Minibuffer tray and disable fringe. (by minibuffer-tray extension)
- Oddmuse wiki editor. (by yaoddmuse extension)
- Remember window position. (by winpoint extension)
- Web browser. (by w3m extension)
- Code speed bar. (by speedbar extension)
- Tab manager. (by tabbar extension)
- Terminal manager. (by multi-term extension)
- Powerful syntax edit. (by paredit extension)
- One key system. (by one-key extensions)
- Point translate system. (by sdcv extension)
- Org GTD manager. (by org extensions)
- News reader. (by newsticker extension)
- Code search and replace. (by moccur extension)
- RFC reader. (by irfc extension)
- Edit multiple regions in the same way simultaneously. (by iedit.el)
- Quick global jump. (by ace-jump extension)
- Apt search. (by apt-utils extension)
- Man manual reader. (by woman extension)
- IDE features. (by ecb extension)
- API document helper. (by eldoc extension)
- Tag search. (by etags extension)
- Fly make checker. (by flymake extension)
- Git manage. (by magit extension)
- Mailing reader. (by gnus extension)
- Code function expander. (by hideshow extension)
- Command completion. (by icicles extensions)
- Info reader. (by info extension)
- Vi-reader. (by less extension)
- Elisp package manager. (by auto-install and package extension)
- Regex real-time matcher. (by rebuilder extension)
- Smooth scroll. (by smooth-scrolling extension)
- Donkey download manager. (by mldonkey extension)
- English completion helper. (by predictive extension)
- Webkit browser. (by webkit extension)

## Installation

### Mac OS High Sierra

1. Install compile dependencies
```
$ brew install autoconf automake texinfo gnutls pkg-config --debug --verbose
```
    Note, you need install pkg-config before compile emacs git, otherwise ./configure emacs will throw error "can't found gnutls"

2. Download emacs git code
```
$ git clone --depth 1 git://git.savannah.gnu.org/emacs.git
```

3. Compile emacs git
```
$ cd ./emacs && ./autogen.sh
$ ./configure && make && make install
```

4. Install in launcher:

    open -R nextstep/Emacs.app

    and dragging Emacs to the Applications folder.

5. Add config in ~/.emacs
```Elisp
(defun add-subdirs-to-load-path (dir)
  "Recursive add directories to `load-path'."
  (let ((default-directory (file-name-as-directory dir)))
    (add-to-list 'load-path dir)
    (normal-top-level-add-subdirs-to-load-path)))
(add-subdirs-to-load-path "~/lazycat-emacs/site-lisp/")

(require 'init)
```

### Install PyQt5 libraries for Mac OS:
1. Install python3 and qt:
```
$ brew install python3 qt
```

2. Change pip.conf with below if your pip3 will report SSL error when install:
```
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host=pypi.tuna.tsinghua.edu.cn
```

3. Install PyQt5:
```
sudo pip3 intall PyQt5
```

$ brew install python3 qt
$ sudo pip3 install pyqt5 jedi epc pyflakes
```

4. Add below in ~/.bash_profile:
```
$ export PATH=/Library/Frameworks/Python.framework/Versions/3.7/bin:$PATH
```

5. Add below in ~/.zshrc:
```
source ~/.bash_profile
```

### ArchLinux
1. Install emacs git version:
```
sudo pacman -S emacs-git
```

2. Install necessary dependency for plugins:
```
sudo pacman -S python-xlib python-pyqt5 python-pip
sudo pip install jedi epc pyflakes
```

3. Build my config symlink to emacs directory:
```
sudo ln -s /home/username/lazycat-emacs/site-lisp /usr/share/emacs/lazycat
```

4. Copy site-start.el in emacs directory to start my config:
```
sudo cp /home/username/lazycat-emacs/site-start.el /usr/share/emacs/site-lisp/
```

5. Start emacs:
```
emacs
```

### Debian 8.0 (jessie)

Build dependencies

- build-essential (>= 12.1)
- git (>= 1:2.6.2-1)
- autoconf (>= 2.69-9)
- texinfo (>= 6.0.0.dfsg.1-3)

Runtime dependencies

- libxaw7-dev (>= 2:1.0.13-1)
- libxpm-dev (>= 1:3.5.11-1)
- libpng12-dev (>= 1.2.50-2)
- libjpeg-dev (>= 1:1.4.1-2)
- libtiff5-dev (>= 4.0.5-1)
- libgif-dev (>= 4.1.6-11)
- libncurses5-dev (>= 6.0+20151024-2)
- libdbus-1-dev (>= 1.10.2-1)
- libgtk-3-dev (>= 3.18.4-1)
- w3m (>= 0.5.3-25)
- w3m-img (>= 0.5.3-25)
- pyflakes (>= 1.0.0-4）
- locate (>= 4.4.2-10)

Install rtags for C/C++
```
git clone --recursive https://github.com/Andersbakken/rtags.git
cd rtags
mkdir build
cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..
make
sudo make install
```

Install prerequisites
```
$ sudo apt-get install \
build-essential \
git \
autoconf \
texinfo \
libxaw7-dev \
libxpm-dev \
libpng-dev \
libjpeg-dev \
libtiff5-dev \
libgif-dev \
libncurses5-dev \
libdbus-1-dev \
libgtk-3-dev \
w3m \
w3m-img \
pyflakes \
elpa-pdf-tools-server \
locate
```
```
$ sudo apt-get install python-pip && sudo pip install jedi epc mocker
```

Download emacs git code
```
$ git clone --depth 1 git://git.savannah.gnu.org/emacs.git
```

Compile emacs git
```
$ sudo mkdir -p /usr/share/lazycat-emacs/common
$ cd ./emacs-git && ./autogen.sh
$ ./configure --prefix=/usr/share/lazycat-emacs/common --with-x-toolkit=gtk3 && make && sudo make install
```

Install Lazycat emacs
```
$ sudo cp ./site-start.el /usr/share/lazycat-emacs/common/share/emacs/site-lisp/
$ sudo cp -r ./site-lisp /usr/share/lazycat-emacs
$ sudo ln -s /usr/share/lazycat-emacs/common/bin/emacs /usr/bin/lazycat-emacs
$ sudo cp ./lazycat-emacs.svg /usr/share/icons/hicolor/scalable/apps/
$ sudo cp ./lazycat-emacs.desktop /usr/share/applications/
```

## License

Lazycat Emacs is licensed under [GPLv3](LICENSE).
