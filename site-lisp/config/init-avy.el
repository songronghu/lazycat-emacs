(require 'avy)
(require 'general)
(general-define-key
  :keymaps 'global
  "j" (general-key-dispatch 'self-insert-command
                            :timeout 0.25
                            "c" 'avy-goto-char
                            "w" 'avy-goto-word-1
                            "l" 'avy-goto-line))
(provide 'init-avy)
