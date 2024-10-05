;;; init-gptel.el --- Config for gptel   -*- lexical-binding: t; -*-

;; Filename: init-gptel.el
;; Description: Config for gptel
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2024, Andy Stewart, all rights reserved.
;; Created: 2024-09-27 01:38:08
;; Version: 0.1
;; Last-Updated: 2024-09-27 01:38:08
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-gptel
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
;; Config for gptel
;;

;;; Installation:
;;
;; Put init-gptel.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-gptel)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-gptel RET
;;

;;; Change log:
;;
;; 2024/09/27
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
(require 'gptel)
(require 'gptel-curl)

;;; Code:

(lazy-load-set-keys
 '(
   ("RET" . gptel-return-dwim))
 gptel-mode-map)

(setq open-router-key (with-temp-buffer
                        (insert-file-contents "~/.config/openrouter/key.txt")
                        (string-trim (buffer-string))))

(setq gptel-model "anthropic/claude-3.5-sonnet"
      gptel-backend
      (gptel-make-openai "OpenRouter"
        :host "openrouter.ai"
        :endpoint "/api/v1/chat/completions"
        :stream t
        :key open-router-key
        :models '("anthropic/claude-3.5-sonnet")))

(defun start-gptel ()
  (interactive)
  (gptel "OpenRouter" nil nil t))

;;;###autoload
(defun gptel-return-dwim (&optional arg)
  "If cursor at prompt line, call `gptel-send', otherwise call RET function."
  (interactive "P")
  (let ((in-prompt-line-p
         (save-excursion
           (beginning-of-line)
           (search-forward-regexp "^#+\\s-" (line-end-position) t))))
    (if in-prompt-line-p
        (gptel-send arg)
      (call-interactively (key-binding (kbd "C-m"))))))

(provide 'init-gptel)

;;; init-gptel.el ends here
