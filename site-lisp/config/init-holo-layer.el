;;; init-holo-layer.el --- Config for holo-layer   -*- lexical-binding: t; -*-

;; Filename: init-holo-layer.el
;; Description: Config for holo-layer
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2023, Andy Stewart, all rights reserved.
;; Created: 2023-08-11 12:54:46
;; Version: 0.1
;; Last-Updated: 2023-08-11 12:54:46
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-holo-layer
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
;; Config for holo-layer
;;

;;; Installation:
;;
;; Put init-holo-layer.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-holo-layer)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-holo-layer RET
;;

;;; Change log:
;;
;; 2023/08/11
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
(require 'holo-layer)

;;; Code:

(setq holo-layer-cursor-animation-type "jelly easing")
(setq holo-layer-enable-window-border t)
(setq holo-layer-enable-cursor-animation t)
(setq holo-layer-hide-mode-line t)
(setq holo-layer-enable-place-info t)
;; (setq holo-layer-sort-tab-ui t)
;; (setq holo-layer-enable-indent-rainbow t)
;; (setq holo-layer-indent-colors '("#5BAB3C" "#4B713F" "#244E30" "#774C3E" "#1E588D" "#3B8155" "#396977" "#18362B" "#525169" "#0B2837"))

(holo-layer-enable)

(provide 'init-holo-layer)

;;; init-holo-layer.el ends here
