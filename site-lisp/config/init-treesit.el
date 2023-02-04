;;; init-treesit.el --- Config for treesit   -*- lexical-binding: t; -*-

;; Filename: init-treesit.el
;; Description: Config for treesit
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2023, Andy Stewart, all rights reserved.
;; Created: 2023-02-04 12:37:41
;; Version: 0.1
;; Last-Updated: 2023-02-04 12:37:41
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-treesit
;; Keywords:
;; Compatibility: GNU Emacs 30.0.50
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
;; Config for treesit
;;

;;; Installation:
;;
;; Put init-treesit.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-treesit)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-treesit RET
;;

;;; Change log:
;;
;; 2023/02/04
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
(require 'treesit)

;;; Code:

;; M-x `treesit-install-language-grammar` to install language grammar.
(setq treesit-language-source-alist
      '((bash       . ("https://github.com/tree-sitter/tree-sitter-bash.git"))
        (c          . ("https://github.com/tree-sitter/tree-sitter-c.git"))
        (cmake      . ("https://github.com/uyha/tree-sitter-cmake.git"))
        (cpp        . ("https://github.com/tree-sitter/tree-sitter-cpp.git"))
        (csharp     . ("https://github.com/tree-sitter/tree-sitter-c-sharp.git"))
        (css        . ("https://github.com/tree-sitter/tree-sitter-css.git"))
        (dockerfile . ("https://github.com/camdencheek/tree-sitter-dockerfile.git"))
        (go         . ("https://github.com/tree-sitter/tree-sitter-go.git"))
        (gomod      . ("https://github.com/camdencheek/tree-sitter-go-mod.git"))
        (html       . ("https://github.com/tree-sitter/tree-sitter-html.git"))
        (java       . ("https://github.com/tree-sitter/tree-sitter-java.git"))
        (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript.git"))
        (json       . ("https://github.com/tree-sitter/tree-sitter-json.git"))
        (python     . ("https://github.com/tree-sitter/tree-sitter-python.git"))
        (ruby       . ("https://github.com/tree-sitter/tree-sitter-ruby.git"))
        (rust       . ("https://github.com/tree-sitter/tree-sitter-rust.git"))
        (toml       . ("https://github.com/tree-sitter/tree-sitter-toml.git"))
        (tsx        . ("https://github.com/tree-sitter/tree-sitter-typescript.git" nil "tsx/src"))
        (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript.git" nil "typescript/src"))
        (yaml       . ("https://github.com/ikatyang/tree-sitter-yaml.git"))))

(setq major-mode-remap-alist
      '((c-mode          . c-ts-mode)
        (c++-mode        . c++-ts-mode)
        (cmake-mode      . cmake-ts-mode)
        (conf-toml-mode  . toml-ts-mode)
        (css-mode        . css-ts-mode)
        (js-mode         . js-ts-mode)
        (js-json-mode    . json-ts-mode)
        (python-mode     . python-ts-mode)
        (sh-mode         . bash-ts-mode)
        (typescript-mode . typescript-ts-mode)))

(provide 'init-treesit)

;;; init-treesit.el ends here
