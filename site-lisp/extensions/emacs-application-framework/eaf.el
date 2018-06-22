;;; eaf.el --- Emacs application framework

;; Filename: eaf.el
;; Description: Emacs application framework
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2018, Andy Stewart, all rights reserved.
;; Created: 2018-06-15 14:10:12
;; Version: 0.1
;; Last-Updated: 2018-06-15 14:10:12
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/eaf.el
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
;; Emacs application framework
;;

;;; Installation:
;;
;; Put eaf.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'eaf)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET eaf RET
;;

;;; Change log:
;;
;; 2018/06/15
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
(require 'dbus)

;;; Code:
(defcustom eaf-mode-hook '()
  "Eaf mode hook."
  :type 'hook
  :group 'eaf-mode)

(defvar eaf-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap used by `eaf-mode'.")

(define-derived-mode eaf-mode text-mode "Eaf"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'eaf-mode)
  (setq mode-name "EAF")
  (set (make-local-variable 'buffer-id) (eaf-generate-id))
  (use-local-map eaf-mode-map)
  (run-hooks 'eaf-mode-hook))

(defvar eaf-python-file (expand-file-name "eaf.py" (file-name-directory load-file-name)))

(defvar eaf-process nil)

(defcustom eaf-name "*eaf*"
  "Name of eaf buffer."
  :type 'string
  :group 'eaf)

(defun eaf-call (method &rest args)
  (apply 'dbus-call-method
         :session                   ; use the session (not system) bus
         "com.lazycat.eaf"          ; service name
         "/com/lazycat/eaf"         ; path name
         "com.lazycat.eaf"          ; interface name
         method args))

(defun eaf-get-emacs-xid ()
  (frame-parameter nil 'window-id))

(defun eaf-start-process ()
  (interactive)
  (if (process-live-p eaf-process)
      (message "EAF process has started.")
    (setq eaf-process
          (apply 'start-process
                 eaf-name
                 eaf-name
                 "python" (append (list eaf-python-file (eaf-get-emacs-xid)) (eaf-get-render-allocation))
                 ))
    (set-process-query-on-exit-flag eaf-process nil)
    (set-process-sentinel
     eaf-process
     #'(lambda (process event)
         (message (format "%s %s" process event))
         ))
    (message "EAF process starting...")))

(defun eaf-stop-process ()
  (interactive)
  (if (process-live-p eaf-process)
      (delete-process eaf-process)
    (message "EAF process has dead.")))

(defun eaf-restart-process ()
  (interactive)
  (eaf-stop-process)
  (eaf-start-process))

(defun eaf-get-render-allocation ()
  "Get allocation for render application in backend.
We need calcuate render allocation to make sure no black border around render content."
  (let* (;; We use `window-inside-pixel-edges' and `window-absolute-pixel-edges' calcuate height of window header, such as tabbar.
         (window-header-height (- (nth 1 (window-inside-pixel-edges)) (nth 1 (window-absolute-pixel-edges))))
         (x 0)
         (y window-header-height)
         (width (frame-pixel-width))
         ;; Render height should minus mode-line height, minibuffer height, header height.
         (height (- (frame-pixel-height) (window-mode-line-height) (window-pixel-height (minibuffer-window)) window-header-height)))
    (mapcar (lambda (x) (format "%s" x)) (list x y width height))))

(defun eaf-get-window-allocation (&optional window)
  (let* ((window-edges (window-inside-pixel-edges window))
         (x (nth 0 window-edges))
         (y (nth 1 window-edges))
         (w (- (nth 2 window-edges) x))
         (h (- (nth 3 window-edges) y))
         )
    (list x y w h)))

(defun eaf-generate-id ()
  (format "%04x%04x-%04x-%04x-%04x-%06x%06x"
          (random (expt 16 4))
          (random (expt 16 4))
          (random (expt 16 4))
          (random (expt 16 4))
          (random (expt 16 4))
          (random (expt 16 6))
          (random (expt 16 6)) ))

(defun eaf-create-buffer (input-content)
  (let ((eaf-buffer (generate-new-buffer input-content)))
    (with-current-buffer eaf-buffer
      (eaf-mode)
      )
    eaf-buffer))

(defun eaf-open (app-type input-content)
  (let* ((buffer (eaf-create-buffer input-content)))
    (with-current-buffer buffer
      (eaf-call "new_buffer" buffer-id app-type input-content)
      (message (format "eaf-open: %s %s %s" buffer-id app-type input-content)))
    (switch-to-buffer buffer)
    ))

(defun eaf-open-url (url)
  (interactive "sURL: ")
  (eaf-open "browser" url))

(defun eaf-monitor-configuration-change (&rest _)
  (ignore-errors
    (let (view-infos)
      (dolist (window (window-list))
        (let ((buffer (window-buffer window)))
          (with-current-buffer buffer
            (if (string= "eaf-mode" (format "%s" major-mode))
                (let* ((window-allocation (eaf-get-window-allocation window))
                       (x (nth 0 window-allocation))
                       (y (nth 1 window-allocation))
                       (w (nth 2 window-allocation))
                       (h (nth 3 window-allocation))
                       )
                  (add-to-list 'view-infos (format "%s:%s:%s:%s:%s" buffer-id x y w h))
                  )))))
      ;; I don't know how to make emacs send dbus-message with two-dimensional list.
      ;; So i package two-dimensional list in string, then unpack on server side. ;)
      (eaf-call "update_views" (mapconcat 'identity view-infos ","))
      )))

(add-hook 'window-configuration-change-hook #'eaf-monitor-configuration-change)

(defun eaf-monitor-buffer-kill ()
  (ignore-errors
    (with-current-buffer (buffer-name)
      (when (string= "eaf-mode" (format "%s" major-mode))
        (eaf-call "kill_buffer" buffer-id)
        (message (format "Kill %s" buffer-id))
        ))))

(add-hook 'kill-buffer-hook #'eaf-monitor-buffer-kill)

(eaf-start-process)

(provide 'eaf)

;;; eaf.el ends here
