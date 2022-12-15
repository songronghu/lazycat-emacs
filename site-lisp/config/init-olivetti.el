;;; init-olivetti.el --- Config for olivetti   -*- lexical-binding: t; -*-

;; Filename: init-olivetti.el
;; Description: Config for olivetti
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2022, Andy Stewart, all rights reserved.
;; Created: 2022-11-17 21:57:57
;; Version: 0.1
;; Last-Updated: 2022-11-17 21:57:57
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-olivetti
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
;; Config for olivetti
;;

;;; Installation:
;;
;; Put init-olivetti.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-olivetti)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-olivetti RET
;;

;;; Change log:
;;
;; 2022/11/17
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
(require 'olivetti)

;;; Code:

(dolist (hook (list
               'Info-mode-hook
               'rcirc-mode-hook
               ))
  (add-hook hook
            #'(lambda ()
                (olivetti-mode 1)
                (olivetti-set-width 120)
                )))

(dolist (hook (list
               'markdown-mode-hook
               'org-mode-hook
               ))
  (add-hook hook
            #'(lambda ()
                (when (buffer-file-name)
                  (unless (string-prefix-p "README" (file-name-base (buffer-file-name)))
                   (olivetti-mode 1)
                   (olivetti-set-width 120))))))

(provide 'init-olivetti)

;;; init-olivetti.el ends here
