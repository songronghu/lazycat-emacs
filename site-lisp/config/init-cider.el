(add-hook 'clojure-mode-hook #'paredit-mode)
(add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)

(require 'sesman)
(require 'nrepl-client)
(require 'cider)

(setq cider-repl-display-help-banner nil)
(setq cider-repl-pop-to-buffer-on-connect 'display-only)
(setq cider-show-error-buffer t)
(setq cider-auto-select-error-buffer t)
(setq cider-reuse-dead-repls t)

(with-eval-after-load 'cider
  (define-key cider-mode-map (kbd "C-M-i") #'down-list))

(provide 'init-cider)
