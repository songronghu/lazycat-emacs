;; -*- lexical-binding: t; -*-
(require 'nov)

(setq nov-unzip-program "unzip"
      nov-unzip-args '("-od" directory filename))

(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

(provide 'init-nov)
