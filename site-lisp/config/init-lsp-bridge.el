;;; init-lsp-bridge.el --- Configuration for lsp-bridge

;; Filename: init-lsp-bridge.el
;; Description: Configuration for display line number
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2018, Andy Stewart, all rights reserved.
;; Created: 2018-08-26 02:03:32
;; Version: 0.1
;; Last-Updated: 2018-08-26 02:03:32
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-lsp-bridge.el
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
;; Configuration for display line number
;;

;;; Installation:
;;
;; Put init-lsp-bridge.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-lsp-bridge)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-lsp-bridge RET
;;

;;; Change log:
;;
;; 2018/08/26
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
(require 'lsp-bridge)
(require 'lsp-bridge-icon)
(require 'lsp-bridge-orderless)
(require 'lsp-bridge-jdtls)

;;; Code:

(require 'corfu)
(require 'corfu-history)
(require 'cape)

;; 默认用这三个补全后端
(add-to-list 'completion-at-point-functions #'cape-symbol)
(add-to-list 'completion-at-point-functions #'cape-file)
(add-to-list 'completion-at-point-functions #'cape-dabbrev)

;; 修改Corfu默认按键
(lazy-load-set-keys
 '(
   ("M-h" . corfu-insert)
   ("M-H" . lsp-bridge-insert-common-prefix)
   ("M-." . corfu-first)
   ("M-," . corfu-last)
   ("M-j" . corfu-next)
   ("M-k" . corfu-previous)
   )
 corfu-map)

;; 让Corfu适应高分屏
(when (> (frame-pixel-width) 3000) (custom-set-faces '(corfu-default ((t (:height 1.3))))))

;; 开启 history mode
(corfu-history-mode t)

(global-lsp-bridge-mode)

(global-corfu-mode)

;; 融合 `lsp-bridge' `find-function' 以及 `dumb-jump' 的智能跳转
(defun lsp-bridge-jump ()
  (interactive)
  (cond
   ((eq major-mode 'emacs-lisp-mode)
    (let ((symb (function-called-at-point)))
      (when symb
        (find-function symb))))
   (lsp-bridge-mode
    (lsp-bridge-find-def))
   (t
    (require 'dumb-jump)
    (dumb-jump-go))))

(defun lsp-bridge-jump-back ()
  (interactive)
  (cond
   (lsp-bridge-mode
    (lsp-bridge-return-from-def))
   (t
    (require 'dumb-jump)
    (dumb-jump-back))))

;; 打开日志，开发者才需要
;; (setq lsp-bridge-enable-log t)

;; (require 'tabnine-capf)

;; 通过Cape融合不同的补全后端，比如lsp-bridge、 tabnine、 file、 dabbrev.
;; (defun lsp-bridge-mix-multi-backends ()
;;   (setq-local completion-category-defaults nil)
;;   (setq-local completion-at-point-functions
;;               (list
;;                (cape-capf-buster
;;                 (cape-super-capf
;;                  #'lsp-bridge-capf

;;                  ;; 我嫌弃TabNine太占用我的CPU了， 需要的同学注释下面这一行就好了
;;                  ;; #'tabnine-completion-at-point

;;                  ;; #'cape-file
;;                  ;; #'cape-dabbrev
;;                  )
;;                 'equal)
;;                )))

;; (dolist (hook lsp-bridge-default-mode-hooks)
;;   (add-hook hook (lambda ()
;;                    (lsp-bridge-mix-multi-backends) ; 通过Cape融合多个补全后端
;;                    )))

(provide 'init-lsp-bridge)

;;; init-lsp-bridge.el ends here
