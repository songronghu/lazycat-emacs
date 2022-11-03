;;; init-one-key.el --- Init one key

;; Filename: init-one-key.el
;; Description: Init one key
;; Author: Andy Stewart <andy@freedom>
;; Maintainer: Andy Stewart <andy@freedom>
;; Copyright (C) 2013, Andy Stewart, all rights reserved.
;; Created: 2013-12-30 09:51:50
;; Version: 0.1
;; Last-Updated: 2013-12-30 09:51:50
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-one-key.el
;; Keywords:
;; Compatibility: GNU Emacs 24.3.50.1
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
;; Init one key
;;

;;; Installation:
;;
;; Put init-one-key.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-one-key)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-one-key RET
;;

;;; Change log:
;;
;; 2013/12/30
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
(require 'eaf-file-manager)

;;; Code:

(one-key-create-menu
 "DIRECTORY"
 '(
   (("h" . "Home") . (lambda () (interactive) (eaf-open-in-file-manager "~/")))
   (("b" . "Book") . (lambda () (interactive) (eaf-open-in-file-manager "/data/Book")))
   (("j" . "Picture") . (lambda () (interactive) (eaf-open-in-file-manager "/data/Picture")))
   (("m" . "Music") . (lambda () (interactive) (eaf-open-in-file-manager "/data/Music")))
   (("c" . "Config") . (lambda () (interactive) (eaf-open-in-file-manager lazycat-emacs-config-dir)))
   ((";" . "Extension") . (lambda () (interactive) (eaf-open-in-file-manager "/home/andy/lazycat-emacs/site-lisp/extensions")))
   (("o" . "EAF") . (lambda () (interactive) (eaf-open-in-file-manager "/home/andy/lazycat-emacs/site-lisp/extensions/emacs-application-framework")))
   )
 t)

(provide 'init-one-key)

;;; init-one-key.el ends here
