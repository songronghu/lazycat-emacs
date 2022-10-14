;;; init-telega.el --- Telega config   -*- lexical-binding: t; -*-

;; Filename: init-telega.el
;; Description: Telega config
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2022, Andy Stewart, all rights reserved.
;; Created: 2022-10-13 22:18:22
;; Version: 0.1
;; Last-Updated: 2022-10-13 22:18:22
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-telega
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
;; Telega config
;;

;;; Installation:
;;
;; Put init-telega.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-telega)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-telega RET
;;

;;; Change log:
;;
;; 2022/10/13
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
(require 'telega)
(require 'olivetti)

;;; Code:

(setq telega-proxies
      (list
       '(:server "127.0.0.1" :port 1080 :enable t :type (:@type "proxyTypeSocks5"))
       ))

(dolist (hook (list
               'telega-chat-mode-hook
               ))
  (add-hook hook
            #'(lambda ()
                (olivetti-mode 1)
                (olivetti-set-width 120)
                )))

(setq telega-chat-fill-column 120)

;; 修复图片分割和不对齐的问题
(defun telega-buffer-face-mode-variable ()
  (interactive)
  (make-face 'my-telega-face)
  (set-face-attribute 'my-telega-face nil :font "等距更纱黑体 SC 13")
  (setq buffer-face-mode-face 'my-telega-face)
  (buffer-face-mode))
(add-hook 'telega-root-mode-hook 'telega-buffer-face-mode-variable)
(add-hook 'telega-webpage-mode-hook 'telega-buffer-face-mode-variable)
(add-hook 'telega-chat-mode-hook 'telega-buffer-face-mode-variable)

;; EAF打开telega 链接
(defun telega-browse-url-advisor (orig-fun &optional arg &rest args)
  (eaf-open-browser arg))
(advice-add #'telega-browse-url :around #'telega-browse-url-advisor)

(provide 'init-telega)

;;; init-telega.el ends here
