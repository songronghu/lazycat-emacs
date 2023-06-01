;;; init-rcirc.el --- Rcirc init

;; Filename: init-rcirc.el
;; Description: Rcirc init
;; Author: Andy Stewart lazycat.manatee@gmail.com
;; Maintainer: Andy Stewart lazycat.manatee@gmail.com
;; Copyright (C) 2008, 2009, Andy Stewart, all rights reserved.
;; Created: 2008-10-20 09:28:25
;; Version: 0.1
;; Last-Updated: 2008-10-20 09:28:28
;;           By: Andy Stewart
;; URL:
;; Keywords: rcirc
;; Compatibility: GNU Emacs 23.0.60.1
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
;; Rcirc init
;;

;;; Installation:
;;
;; Put init-rcirc.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-rcirc)
;;
;; No need more.

;;; Change log:
;;
;; 2008/10/20
;;      First released.
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
(require 'rcirc)
(require 'rcirc-color)                  ;让每个名字都有自己的颜色
(require 'rcirc-extension)

;;; Code:

(defun rcirc-login ()
  (interactive)
  (let* ((server "irc.libera.chat")
         (server-plist (cdr (assoc-string server rcirc-server-alist)))
         (port "6697")
         (nick "ManateeLazyCat")
         (user-name "Andy Stewart")
         (password (read-passwd "IRC Password: "))
         (channels '("#emacs"))
         (encryption 'tls)
         (process (rcirc-connect server port nick user-name
                                 rcirc-default-full-name
                                 channels password encryption)))
    (when rcirc-display-server-buffer
      (pop-to-buffer-same-window (process-buffer process))))
  ;; connect to servers in `rcirc-server-alist'
  (let (connected-servers)
    (dolist (c rcirc-server-alist)
      (let ((server (car c))
            (nick (or (plist-get (cdr c) :nick) rcirc-default-nick))
            (port (or (plist-get (cdr c) :port) rcirc-default-port))
            (user-name (or (plist-get (cdr c) :user-name)
                           rcirc-default-user-name))
            (full-name (or (plist-get (cdr c) :full-name)
                           rcirc-default-full-name))
            (channels (plist-get (cdr c) :channels))
            (password (plist-get (cdr c) :password))
            (encryption (plist-get (cdr c) :encryption))
            (server-alias (plist-get (cdr c) :server-alias))
            contact)
        (when-let (((not password))
                   (auth (auth-source-search :host server
                                             :user user-name
                                             :port port))
                   (fn (plist-get (car auth) :secret)))
          (setq password (funcall fn)))
        (when server
          (let (connected)
            (dolist (p (rcirc-process-list))
              (when (string= (or server-alias server) (process-name p))
                (setq connected p)))
            (if (not connected)
                (condition-case nil
                    (let ((process (rcirc-connect server port nick user-name
                                                  full-name channels password encryption
                                                  server-alias)))
                      (when rcirc-display-server-buffer
                        (pop-to-buffer-same-window (process-buffer process))))
                  (quit (message "Quit connecting to %s"
                                 (or server-alias server))))
              (with-current-buffer (process-buffer connected)
                (setq contact (process-contact
                               (get-buffer-process (current-buffer)) :name))
                (setq connected-servers
                      (cons (if (stringp contact)
                                contact (or server-alias server))
                            connected-servers))))))))
    (when connected-servers
      (message "Already connected to %s"
               (if (cdr connected-servers)
                   (concat (mapconcat 'identity (butlast connected-servers) ", ")
                           ", and "
                           (car (last connected-servers)))
                 (car connected-servers))))))

(setq rcirc-omit-responses              ;设置忽略的响应类型
      (quote ("JOIN" "PART" "QUIT" "NICK" "AWAY" "MODE")))

(add-hook 'rcirc-mode-hook #'(lambda ()
                               ;; 默认打开忽略模式
                               (rcirc-omit-mode)
                               ))

(provide 'init-rcirc)

;;; init-rcirc.el ends here
