# Lazycat Emacs

**What is lazycat emacs can do?**

This is video show: [Video](https://www.youtube.com/watch?v=ZA3uuflGtk8)

**Description**:

Emacs is hackable OS for top hackers, most of emacs extensions are written in elisp.

My EmacsWiki hompage at [AndyStewart](http://www.emacswiki.org/emacs/AndyStewart),

All my extensions under [extensions](https://github.com/manateelazycat/lazycat-emacs/tree/master/site-lisp/extensions).

All my configuration files under [config](https://github.com/manateelazycat/lazycat-emacs/tree/master/site-lisp/extensions).

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

## Old extensions and configuration files.
In 2005, Emacs didn't have much advanced features, and it took me more than a decade to continuously improve Emacs.

Many extensions code that i wrote has been tossed, but I hope to still back up these unused code,
I hope some of the those old code snippets can help other Elisp hackers

You can find those old extensions and configuration files at [lazycat-emacs-time-machine](https://github.com/manateelazycat/lazycat-emacs-time-machine)

## License

Lazycat Emacs is licensed under [GPLv3](LICENSE).
