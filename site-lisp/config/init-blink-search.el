;;; init-blink-search.el --- Config for blink search   -*- lexical-binding: t; -*-

;; Filename: init-blink-search.el
;; Description: Config for blink search
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2022, Andy Stewart, all rights reserved.
;; Created: 2022-11-01 21:06:59
;; Version: 0.1
;; Last-Updated: 2022-11-01 21:06:59
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-blink-search
;; Keywords:
;; Compatibility: GNU Emacs 28.2
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
;; Config for blink search
;;

;;; Installation:
;;
;; Put init-blink-search.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-blink-search)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-blink-search RET
;;

;;; Change log:
;;
;; 2022/11/01
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
(require 'blink-search)

;;; Code:

(setq blink-search-common-directory '(("REPO" "~/lazycat-emacs/site-lisp/extensions/")
                                      ("HOME" "~/")
                                      ("CONFIG" "~/lazycat-emacs/site-lisp/config/")
                                      ("EAF" "~/lazycat-emacs/site-lisp/extensions/emacs-application-framework/app/")
                                      ("Book" "/data/Book/")
                                      ("ChatGPT" "~/ChatGPT")
                                      ))

(setq blink-search-grep-pdf-search-paths "/data/Book")
(setq blink-search-grep-pdf-backend 'eaf-pdf-viewer)
(setq blink-search-pdf-backend 'eaf-pdf-viewer)

;; (setq blink-search-enable-posframe t)

(provide 'init-blink-search)

;;; init-blink-search.el ends here
