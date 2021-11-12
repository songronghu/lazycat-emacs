;;; init-highlight-parentheses.el --- Config for highlight-parentheses-mode

;; Filename: init-highlight-parentheses.el
;; Description: Config for highlight-parentheses-mode
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2021, Andy Stewart, all rights reserved.
;; Created: 2021-11-12 08:24:43
;; Version: 0.1
;; Last-Updated: 2021-11-12 08:24:43
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-highlight-parentheses
;; Keywords:
;; Compatibility: GNU Emacs 29.0.50
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
;; Config for highlight-parentheses-mode
;;

;;; Installation:
;;
;; Put init-highlight-parentheses.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-highlight-parentheses)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-highlight-parentheses RET
;;

;;; Change log:
;;
;; 2021/11/12
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
(require 'highlight-parentheses)

;;; Code:
(setq hl-paren-colors '("DarkOrange" "DeepSkyBlue" "DarkRed"))

(provide 'init-highlight-parentheses)

;;; init-highlight-parentheses.el ends here
