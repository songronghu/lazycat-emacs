;;; init-emigo.el --- Config for emigo   -*- lexical-binding: t; -*-

;; Filename: init-emigo.el
;; Description: Config for emigo
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2025, Andy Stewart, all rights reserved.
;; Created: 2025-03-29 16:21:46
;; Version: 0.1
;; Last-Updated: 2025-03-29 16:21:46
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-emigo
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
;; Config for emigo
;;

;;; Installation:
;;
;; Put init-emigo.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-emigo)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-emigo RET
;;

;;; Change log:
;;
;; 2025/03/29
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
(require 'emigo)

;;; Code:
(emigo-start-process)

(setq emigo-model "openrouter/anthropic/claude-3.7-sonnet")
(setq emigo-base-url "https://openrouter.ai/api/v1")
(setq emigo-api-key (with-temp-buffer
                      (insert-file-contents "~/.config/openrouter/key.txt")
                      (string-trim (buffer-string))))

(provide 'init-emigo)

;;; init-emigo.el ends here
