;;; init-dimmer.el --- configure file for dimmer.el

;; Filename: init-dimmer.el
;; Description: configure file for dimmer.el
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2019, Andy Stewart, all rights reserved.
;; Created: 2019-01-24 20:17:16
;; Version: 0.1
;; Last-Updated: 2019-01-24 20:17:16
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-dimmer.el
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
;; configure file for dimmer.el
;;

;;; Installation:
;;
;; Put init-dimmer.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-dimmer)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-dimmer RET
;;

;;; Change log:
;;
;; 2019/01/24
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
(require 'dimmer)

;;; Code:
(dimmer-mode)
(setq dimmer-exclusion-regexp "\\s-.*pyim-page-tooltip-posframe-buffer.*")

(provide 'init-dimmer)

;;; init-dimmer.el ends here
