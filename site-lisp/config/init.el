;; 定义一些启动目录，方便下次迁移修改
(defvar lazycat-emacs-root-dir (file-truename "~/lazycat-emacs/site-lisp"))
(defvar lazycat-emacs-config-dir (concat lazycat-emacs-root-dir "/config"))
(defvar lazycat-emacs-extension-dir (concat lazycat-emacs-root-dir "/extensions"))
(defvar lazycat-emacs-sdcv-data-dir (concat lazycat-emacs-root-dir "/sdcv-dict"))

(with-temp-message ""                   ;抹掉插件启动的输出
  ;; 必须加载的
  (require 'benchmark-init)
  (require 'theme)                 ;第一次尽量加载主题，让启动不要闪烁
  (require 'init-startup)
  (require 'init-flymake)
  (require 'lazy-set-key)
  (require 'one-key)
  (require 'paredit)
  (require 'paredit-extension)
  (require 'tabbar)
  (require 'basic-toolkit)
  (require 'redo)
  (require 'highlight-parentheses)

  (require 'init-backup)
  (require 'init-smex)
  (require 'init-linum)
  (require 'init-auto-save)
  (require 'init-tabbar)
  (require 'init-mode)
  (require 'init-qt)
  (require 'init-dired)
  (require 'init-session)
  (require 'init-paredit)
  (require 'init-indent)
  (require 'init-auto-complete)
  (require 'init-one-key)
  (require 'init-iedit)
  (require 'init-visual-regexp)
  (require 'init-key)
  (require 'init-generic)
  (require 'init-auto-indent-mode)
  (unless (string-equal system-type "darwin")
    (require 'init-minibuffer-tray))

  ;; 可以延后加载的
  (run-with-idle-timer
   1 nil
   #'(lambda ()
       (require 'pretty-lambdada)
       (require 'browse-kill-ring)
       (require 'elf-mode)

       (require 'init-tempbuf)
       (require 'init-eldoc)
       (require 'init-doxymacs)
       (require 'init-yasnippet)
       (require 'init-package)
       (require 'init-smooth-scrolling)
       (require 'init-cursor-chg)
       (require 'init-winpoint)
       (require 'init-benchmark)
       (require 'init-info)
       (require 'init-aggressive-indent)
       (require 'init-auto-sudoedit)
       (require 'init-pdf-tools)

       (require 'init-idle)

       (load-file (concat lazycat-emacs-config-dir "/theme.el")) ;最后重新加载一次让所有插件的主题都生效
       )))


(provide 'init)
