;;; init-vundo.el --- Configuration file vundo   -*- lexical-binding: t; -*-

;; Filename: init-vundo.el
;; Description: Configuration file vundo
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2023, Andy Stewart, all rights reserved.
;; Created: 2023-05-06 13:28:36
;; Version: 0.1
;; Last-Updated: 2023-05-06 13:28:36
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-vundo
;; Keywords:
;; Compatibility: GNU Emacs 30.0.50
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
;; Configuration file vundo
;;

;;; Installation:
;;
;; Put init-vundo.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-vundo)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-vundo RET
;;

;;; Change log:
;;
;; 2023/05/06
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
(require 'vundo)

;;; Code:
(lazy-load-set-keys
 '(
   ("l" . vundo-forward)
   ("h" . vundo-backward)
   ("n" . vundo-next)
   ("p" . vundo-previous)
   ("j" . vundo-stem-root)
   ("k" . vundo-stem-end)
   ("," . vundo-goto-last-saved)
   ("q" . vundo-quit)
   ("C-g" . vundo-quit)
   ("f" . vundo-confirm)
   ("C-m" . vundo-confirm)
   ("i" . vundo--inspect)
   ("d" . vundo--debug)
   )
 vundo-mode-map)

(provide 'init-vundo)

;;; init-vundo.el ends here
