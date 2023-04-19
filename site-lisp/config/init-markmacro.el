;;; init-markmacro.el --- config for markmacro   -*- lexical-binding: t; -*-

;; Filename: init-markmacro.el
;; Description: config for markmacro
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2023, Andy Stewart, all rights reserved.
;; Created: 2023-03-21 00:44:59
;; Version: 0.1
;; Last-Updated: 2023-03-21 00:44:59
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/init-markmacro
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
;; config for markmacro
;;

;;; Installation:
;;
;; Put init-markmacro.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-markmacro)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-markmacro RET
;;

;;; Change log:
;;
;; 2023/03/21
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
(require 'markmacro)

;;; Code:

(one-key-create-menu
 "MARK-MACRO"
 '(
   (("w" . "Mark word") . markmacro-mark-words) ;标记当前符号的单词或者选中区域的单词
   (("s" . "Mark symbol") . markmacro-mark-symbols) ;标记当前符号
   (("l" . "Mark line") . markmacro-mark-lines)     ;标记非空行
   (("c" . "Mark char") . markmacro-mark-chars)     ;标记当前字符
   (("p" . "Mark parameters") . markmacro-mark-parameters) ;标记参数
   (("i" . "Mark imenu") . markmacro-mark-imenus) ;标记函数或变量
   (("h" . "Secondary region set") . markmacro-secondary-region-set) ;设置二级选中区域
   (("j" . "Secondary region mark cursor") . markmacro-secondary-region-mark-cursors) ;标记二级选中区域内的光标对象
   )
 t)

(provide 'init-markmacro)

;;; init-markmacro.el ends here
