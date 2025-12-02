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

;;; Require
(require 'gptel)
(require 'gptel-request)
(require 'gptel-org)
(require 'gptel-transient)

;;; Code:

;;(lazy-load-set-keys
;; '(
;;   ("RET" . gptel-return-dwim))
;; gptel-mode-map)
(setq openrouter-key-claude3-haiku (with-temp-buffer
                                  (insert-file-contents "~/.config/openrouter/key-claude3-haiku.txt")
                                  (string-trim (buffer-string))))
(setq openrouter-key-gpt-free (with-temp-buffer
                                (insert-file-contents "~/.config/openrouter/key-gpt-free.txt")
                                (string-trim (buffer-string))))
(setq openrouter-key-gpt-nano (with-temp-buffer
                                (insert-file-contents "~/.config/openrouter/key-gpt-nano.txt")
                                (string-trim (buffer-string))))
(setq openrouter-key-gpt-mini (with-temp-buffer
                                (insert-file-contents "~/.config/openrouter/key-gpt-mini.txt")
                                (string-trim (buffer-string))))
(setq openrouter-key-gemini-2.5-flash-lite (with-temp-buffer
                                             (insert-file-contents "~/.config/openrouter/key-gemini-2.5-flash-lite.txt")
                                             (string-trim (buffer-string))))

(gptel-make-openai "OpenRouter1"
  :host "openrouter.ai"
  :endpoint "/api/v1/chat/completions"
  :stream t
  :key openrouter-key-claude3-haiku
  :models '("anthropic/claude-3-haiku"))

(gptel-make-openai "OpenRouter2"
  :host "openrouter.ai"
  :endpoint "/api/v1/chat/completions"
  :stream t
  :key openrouter-key-gpt-free
  :models '("openai/gpt-oss-20b:free"))

(gptel-make-openai "OpenRouter3"
  :host "openrouter.ai"
  :endpoint "/api/v1/chat/completions"
  :stream t
  :key openrouter-key-gemini-2.5-flash-lite
  :models '("google/gemini-2.5-flash-lite"))

(gptel-make-openai "OpenRouter5"
  :host "openrouter.ai"
  :protocol "https"
  :endpoint "/api/v1/chat/completions"
  :key openrouter-key-gpt-mini
  :stream t
  :models '("openai/gpt-5-mini"))

(setq gptel-model "openai/gpt-5-nano"
      gptel-backend
      (gptel-make-openai "OpenRouter4"
        :host "openrouter.ai"
        :endpoint "/api/v1/chat/completions"
        :stream t
        :key openrouter-key-gpt-nano
        :models '("openai/gpt-5-nano")))

(setq gptel-proxy "http://127.0.0.1:18080")
(setq gptel-default-mode 'org-mode)

(add-hook 'gptel-post-stream-hook 'gptel-auto-scroll)

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

(defun gptel-pinyin-to-chinese ()
  (interactive)
  (message "Convert pinyin to Chinese...")
  (gptel-request
      (format "把下面拼音转换成中文， 只输出内容， 不要解释：\n %s"
              (if (region-active-p)
                  (buffer-substring-no-properties (mark) (point))
                (substring-no-properties (buffer-string)))
              :system "你是一个语言学家， 精通英文和汉语")))

(provide 'init-gptel)
;;; init-gptel.el ends here
