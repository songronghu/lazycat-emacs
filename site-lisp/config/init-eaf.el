;;; init-eaf.el --- Configuration for eaf

;; Filename: init-eaf.el
;; Description: Configuration for eaf
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2018, Andy Stewart, all rights reserved.
;; Created: 2018-07-21 12:44:34
;; Version: 0.1
;; Last-Updated: 2018-07-21 12:44:34
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-eaf.el
;; Keywords:
;; Compatibility: GNU Emacs 27.0.50
;;
;; Features that might be required by this library:
;;
;;
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Configuration for eaf
;;

;;; Installation:
;;
;; Put init-eaf.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-eaf)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-eaf RET
;;

;;; Change log:
;;
;; 2018/07/21
;;      * First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require
(require 'eaf)
(require 'eaf-browser)
(require 'eaf-pdf-viewer)
(require 'eaf-markdown-previewer)
(require 'eaf-markmap)
(require 'eaf-js-video-player)
(require 'eaf-video-player)
(require 'eaf-image-viewer)
(require 'eaf-org-previewer)
(require 'eaf-mindmap)
(require 'eaf-mail)
(require 'eaf-camera)
(require 'eaf-jupyter)
(require 'eaf-music-player)
(require 'eaf-system-monitor)
(require 'eaf-file-manager)
(require 'eaf-file-browser)
(require 'eaf-rss-reader)
(require 'eaf-git)
(require 'eaf-map)
(require 'eaf-pyqterminal)

(require 'popweb-dict)

;;; Code:

;; You need configuration your own local proxy program first.
;; (setq eaf-proxy-type "socks5")
;; (setq eaf-proxy-host "127.0.0.1")
;; (setq eaf-proxy-port "1080")

;; Make `eaf-browser-restore-buffers' restore last close browser buffers.
(setq eaf-browser-continue-where-left-off t)

(eaf-bind-key undo_action "C-/" eaf-browser-keybinding)
(eaf-bind-key redo_action "C-?" eaf-browser-keybinding)
(eaf-bind-key scroll_up "M-j" eaf-browser-keybinding)
(eaf-bind-key scroll_down "M-k" eaf-browser-keybinding)
(eaf-bind-key scroll_up_page "M-n" eaf-browser-keybinding)
(eaf-bind-key scroll_down_page "M-p" eaf-browser-keybinding)
(eaf-bind-key open_link "M-h" eaf-browser-keybinding)
(eaf-bind-key open_link_new_buffer "M-H" eaf-browser-keybinding)
(eaf-bind-key insert_or_open_link_new_buffer "D" eaf-browser-keybinding)
(eaf-bind-key insert_or_open_link_background_buffer "F" eaf-browser-keybinding)
(eaf-bind-key watch-other-window-up-line "M-<" eaf-browser-keybinding)
(eaf-bind-key watch-other-window-down-line "M->" eaf-browser-keybinding)
(eaf-bind-key emacs-session-save "<f5>" eaf-browser-keybinding)
(eaf-bind-key refresh_page "M-r" eaf-browser-keybinding)

(setq eaf-webengine-default-zoom 1.5)
(setq eaf-browser-aria2-proxy-host "127.0.0.1")
(setq eaf-browser-aria2-proxy-port "9888")
(setq eaf-browser-enable-adblocker nil)
(setq eaf-browser-enable-autofill t)
(setq eaf-music-play-order "random")
(setq eaf-marker-letters "JKHLNMUIOYPFDSAVCRREW")
(setq eaf-terminal-font-size 18)
(setq eaf-webengine-font-family "WenQuanYi Micro Hei Mono")
(setq eaf-webengine-fixed-font-family "WenQuanYi Micro Hei Mono")
(setq eaf-webengine-serif-font-family "TsangerJinKai03-6763")
(setq eaf-webengine-font-size 18)
(setq eaf-webengine-fixed-font-size 18)
(setq eaf-terminal-font-family "WenQuanYi Micro Hei Mono")
(setq eaf-jupyter-font-family "WenQuanYi Micro Hei Mono")
(setq eaf-file-manager-show-hidden-file nil)
(setq eaf-music-default-file "/data/Music/")
(setq eaf-music-player-buffer " *eaf music player*") ;改成隐藏标签， 避免标签kill掉后关闭音乐
(setq eaf-pyqterminal-font-family "FiraCode Nerd Font Mono")
(setq eaf-pyqterminal-font-size 24)
(setq eaf-jupyter-font-family "FiraCode Nerd Font Mono")
(setq eaf-jupyter-font-size 20)
(setq eaf-rebuild-buffer-after-crash nil)
(setq eaf-pyqterminal-refresh-ms 16)
(setq eaf-music-cache-dir "/data/Music/Favorite")
(setq eaf-pdf-show-progress-on-page nil)
(setq eaf-rss-reader-phone-agent-list '("https://www.solidot.org/index.rss"))

(setq eaf-pdf-dark-mode "ignore")

;; (setq eaf-enable-debug t)
;; (global-set-key (kbd "s-x s-x") (lambda () (interactive) (message "%s" (with-current-buffer eaf-name (buffer-string)))))

(defun jekyll-start-server ()
  (interactive)
  (eaf-terminal-run-command-in-dir "jekyll serve --livereload" "/home/andy/manateelazycat.github.io"))

(defun jekyll-open-local ()
  (interactive)
  (eaf-open-browser "http://127.0.0.1:4000"))

(defun eaf-goto-left-tab ()
  (interactive)
  (sort-tab-select-prev-tab))

(defun eaf-goto-right-tab ()
  (interactive)
  (sort-tab-select-next-tab))

(defun eaf-translate-text (text)
  (popweb-dict-bing-input text))

(setq eaf-goto-right-after-close-buffer t)

(one-key-create-menu
 "GIT"
 '(
   (("s" . "Git status") . eaf-open-git)
   (("u" . "Git push to remote") . eaf-git-push)
   (("i" . "Git pull") . eaf-git-pull)
   (("b" . "Git submodule pull") . eaf-git-submodule-pull)
   (("c" . "Git clone") . eaf-git-clone)
   (("h" . "Git history") . eaf-git-show-history)
   )
 t)

(eaf-bind-key eaf-send-backspace-key "M-o" eaf-pyqterminal-keybinding)
(eaf-bind-key scroll_up "M-," eaf-pyqterminal-keybinding)
(eaf-bind-key scroll_down "M-." eaf-pyqterminal-keybinding)
(eaf-bind-key eaf-open-in-file-manager "M-j" eaf-pyqterminal-keybinding)

(defun eaf-open-terminal ()
  "Try to open fish if fish exist, otherwise use default shell."
  (interactive)
  (eaf-pyqterminal-run-command-in-dir
   (if (executable-find "fish")
       "fish"
     (eaf--generate-terminal-command))
   (eaf--non-remote-default-directory)
   t))

(provide 'init-eaf)

;;; init-eaf.el ends here
