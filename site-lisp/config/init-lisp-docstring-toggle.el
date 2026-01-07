(require 'lisp-docstring-toggle)

;; For Emacs Lisp, Common Lisp and other lisp-mode derived modes
(add-hook 'emacs-lisp-mode-hook #'lisp-docstring-toggle-setup)
(add-hook 'lisp-mode-hook #'lisp-docstring-toggle-setup)

;; For other Lisp dialects, use the mode directly
(add-hook 'scheme-mode-hook #'lisp-docstring-toggle-mode)
(add-hook 'clojure-mode-hook #'lisp-docstring-toggle-mode)

;; or if you're using treesitter modes
(add-hook 'clojure-ts-mode-hook #'lisp-docstring-toggle-mode)

(provide 'init-lisp-docstring-toggle)
