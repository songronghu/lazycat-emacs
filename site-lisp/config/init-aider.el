;;; init-aider.el --- Config for aider   -*- lexical-binding: t; -*-

;; Filename: init-aider.el
;; Description: Config for aider
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2024, Andy Stewart, all rights reserved.
;; Created: 2024-10-06 21:29:41
;; Version: 0.1
;; Last-Updated: 2024-10-06 21:29:41
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-aider
;; Keywords:
;; Compatibility: GNU Emacs 31.0.50
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
;; Config for aider
;;

;;; Installation:
;;
;; Put init-aider.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-aider)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-aider RET
;;

;;; Change log:
;;
;; 2024/10/06
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
(require 'aider)

;;; Code:
(setq aider-args '("--no-auto-commits"
                   "--model"
                   "anthropic/claude-3-5-sonnet-20241022"
                   ;; "openrouter/deepseek/deepseek-coder"
                   ))
(setenv "OPENROUTER_API_KEY" (with-temp-buffer
                               (insert-file-contents "~/.config/openrouter/key.txt")
                               (string-trim (buffer-string))))

(defun eaf-file-manager-send-files-to-aider ()
  (interactive)
  (let ((files (eaf-call-sync "execute_function" eaf--buffer-id "get_mark_file_names")))
    (if files
        (let ((command (concat "/add " (mapconcat 'expand-file-name files " "))))
          (aider--send-command command))
      (message "No files marked in EAF file manager."))))

(eaf-bind-key eaf-file-manager-send-files-to-aider "s" eaf-file-manager-keybinding)

(provide 'init-aider)

;;; init-aider.el ends here
