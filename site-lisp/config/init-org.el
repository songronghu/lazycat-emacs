;;; init-org.el --- Configure for org-mode

;; Filename: init-org.el
;; Description: Configure for org-mode
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2020, Andy Stewart, all rights reserved.
;; Created: 2020-03-31 22:32:49
;; Version: 0.1
;; Last-Updated: 2020-03-31 22:32:49
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-org.el
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
;; Configure for org-mode
;;

;;; Installation:
;;
;; Put init-org.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-org)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-org RET
;;

;;; Change log:
;;
;; 2020/03/31
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


;;; Code:

(setq-default ispell-program-name nil)

(with-eval-after-load 'org
  (setq org-odt-preferred-output-format "docx") ;ODT转换格式默认为docx
  (setq org-startup-folded nil)                 ;默认展开内容
  (setq org-startup-indented t)                 ;默认缩进内容

  ;; 隐藏 HTML 导出文件底部的一些无用信息
  (setq org-export-with-author nil)
  (setq org-export-time-stamp-file nil)
  (setq org-html-validation-link nil)

  (defun org-export-docx ()
    (interactive)
    (let ((docx-file (concat (file-name-sans-extension (buffer-file-name)) ".docx"))
          (template-file (concat (file-name-as-directory lazycat-emacs-root-dir)
                                 (file-name-as-directory "template")
                                 "template.docx")))
      (shell-command (format "pandoc %s -o %s --reference-doc=%s"
                             (buffer-file-name)
                             docx-file
                             template-file
                             ))
      (message "Convert finish: %s" docx-file))))

(dolist (hook (list
               'org-mode-hook
               ))
  (add-hook hook #'(lambda ()
                     (require 'eaf)

                     (setq truncate-lines nil) ;默认换行

                     (lazy-load-set-keys
                      '(
                        ("M-h" . set-mark-command) ;选中激活
                        ("C-c C-o" . eaf-open-url-at-point)
                        )
                      org-mode-map)

                     (require 'valign)
                     (valign-mode)
                     )))


(require 'org-bullets)

;; 配置org-bullets
(setq org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●"))
;;(add-hook 'org-mode-hook 'org-bullets-mode)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; 配置ox-mermaind
(require 'ob-mermaid)
(setq ob-mermaid-cli-path "/home/ronghusong/.nvm/versions/node/v22.12.0/bin/mmdc") ;; Replace with the actual path to mmdc

;; 配置ox-hugo
(with-eval-after-load 'ox
                      (require 'ox-hugo))

 ;; paste image from clipboard
(defvar tkj/image-dir "../static/images")       ; 实际保存路径
(defvar tkj/image-insert-dir "/images")         ; 插入到文档的路径

(defun tkj/ensure-directory (path)
  "create directory if it does not exist and user agrees"
  (when (and (not (file-exists-p path))
             (y-or-n-p (format "Directory %s does not exist. Create it?" path)))
    (make-directory path :parents)))

(defun tkj/paste-image-clipboard ()
  "Paste screenshot from clipboard"
  (interactive)
  (tkj/ensure-directory (file-name-as-directory tkj/image-dir))
  (let ((image-path (concat (file-name-as-directory tkj/image-dir)
                            (file-name-base (buffer-name))
                            (format-time-string "_%Y_%m_%d_%H_%M_%S")
                            ".png")))
    (shell-command-to-string (format "xclip -selection clipboard -t image/png -o > %s" image-path))
    (insert "[[file:" image-path "]]\n")
    (org-display-inline-images)))

(defun tkj/paste-image-path ()
  "Paste screenshot from clipboard"
  (interactive)
  (tkj/ensure-directory (file-name-as-directory tkj/image-dir))
  (let* ((filename (concat (file-name-base (buffer-name))
                           (format-time-string "_%Y_%m_%d_%H_%M_%S")
                           ".png"))
         (save-path (concat (file-name-as-directory tkj/image-dir) filename))
         (insert-path (concat (file-name-as-directory tkj/image-insert-dir) filename)))
    (shell-command-to-string (format "xclip -selection clipboard -t image/png -o > %s" save-path))
    (insert "" insert-path "")
    (org-display-inline-images)))

(setq org-image-actual-width nil)

(provide 'init-org)
;;; init-org.el ends here
