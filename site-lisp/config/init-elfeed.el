;;; init-elfeed.el --- Config for elfeed

;; Filename: init-elfeed.el
;; Description: Config for elfeed
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2020, Andy Stewart, all rights reserved.
;; Created: 2020-12-28 10:38:58
;; Version: 0.1
;; Last-Updated: 2020-12-28 10:38:58
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-elfeed.el
;; Keywords:
;; Compatibility: GNU Emacs 28.0.50
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
;; Config for elfeed
;;

;;; Installation:
;;
;; Put init-elfeed.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-elfeed)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-elfeed RET
;;

;;; Change log:
;;
;; 2020/12/28
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
(require 'elfeed)
(require 'eaf)

;;; Code:
(setq elfeed-feeds
      '(("https://manateelazycat.github.io/feed.xml" ManateeLazyCat)))

(provide 'init-elfeed)

;;; init-elfeed.el ends here
