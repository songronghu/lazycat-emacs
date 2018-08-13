# What is aweshell?

I created `multi-term.el' and use it many years.

Now I'm a big fans of `eshell'.

So i write `aweshell.el' to extension `eshell' with below features:

1. Create and manage multiple eshell buffers.
2. Add some useful commands, such as: clear buffer, toggle sudo etc.
3. Display extra information and color like zsh, powered by `eshell-prompt-extras'
4. Add Fish-like history autosuggestions, powered by `esh-autosuggest'
5. Validate and highlight command before post to eshell.

# Installation

Put `aweshell.el', `esh-autosuggest.el', `eshell-prompt-extras.el' to your load-path.
The load-path is usually ~/elisp/.
It's set in your ~/.emacs like this:
```Elisp
(add-to-list 'load-path (expand-file-name "~/elisp"))
(require 'aweshell)
```

Binding your favorite key to functions:

```Elisp
aweshell-new
aweshell-next
aweshell-prev
aweshell-clear-buffer
aweshell-sudo-toggle
```

# Customize:

Below of the above can customize by:
```Elisp
M-x customize-group RET aweshell RET
```

```Elisp
aweshell-complete-selection-key
aweshell-clear-buffer-key
aweshell-sudo-toggle-key
```
