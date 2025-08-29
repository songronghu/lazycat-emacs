(require 'ajoke)
(require 'gnus-sum)
(require 'qmake-mode "qmake.el")
(when (file-exists-p "~/.local-config/.emacs_d/bhj-emacs.el")
  (load "~/.local-config/.emacs_d/bhj-emacs.el"))

;;;###autoload
(defun cleanup-buffer-safe ()
  "Perform a bunch of safe operations on the whitespace content of a buffer.
Does not indent buffer, because it is used for a before-save-hook, and that
might be bad."
  (interactive)
  (set-buffer-file-coding-system 'utf-8)
  ;; for making .wiki table treated as org table for editing, and
  ;; convert back to .wiki format (with spaces removed). invented when
  ;; supporting mtop test.
  (when (and (string-match ".*/java/.*\\.wiki$" (or (buffer-file-name) ""))
             (eq major-mode 'org-mode))
    (save-excursion
      (goto-char (point-min))
      (while (search-forward " " (point-max) t)
        (replace-match ""))))
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (when (and (search-forward-regexp "\t\\|[ \t]$" nil t)
                 (or bhj-force-cleanup-buffer (eq this-command 'cleanup-buffer-safe)))
        (unless (string-match "makefile\\|message-mode\\|org-mode\\|text-mode\\|fundamental-mode" (symbol-name major-mode))
          (untabify (point-min) (point-max)))
        (delete-trailing-whitespace)))))

;;;###autoload
(defun bhj-2-window-visit-next-file()
  "Make there 2 windows, and the other window visit the next buffer in buffer-list"
  (interactive)
  (delete-other-windows)
  (split-window-below)
  (helm-buffers-list)
  (other-window 0))

;;;###autoload
(defun confirm-risky-remote-edit ()
  (let ((filename (buffer-file-name)))
    (when (and filename (file-remote-p filename) (string-match "/system-config/" filename))
      (yes-or-no-p "Are you sure it's alright to save this remote file when you have a local copy?"))))

;;;###autoload
(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (c-set-style "k&r")
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 8))

;;;###autoload
(defun linux-c++-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c++-mode)
  (c-set-style "k&r")
  (setq tab-width 8)
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4))

;;;###autoload
(defun compout-mode ()
  "compilation mode, which is not buffer readonly for org export"
  (interactive)
  (compilation-mode)
  (setq buffer-read-only nil))

;;;###autoload
(defun grepout-mode ()
  "grep mode, which is not buffer readonly for org export"
  (interactive)
  (grep-mode)
  (setq buffer-read-only nil))

(defun nodup-ring-insert (ring obj)
  (unless (and (not (ring-empty-p ring))
               (equal (ring-ref ring 0) obj))
    (ring-insert ring obj)))

;;;###autoload
(defun bhj-c-get-includes (prefix)
  (interactive "P")
  ;; when use call this function, 1) assume we will have some headers
  ;; to include, 2) assume we need insert them at a special position
  ;; marked with /**** start of bhj auto includes ****/ and /**** end
  ;; of bhj auto includes ****/.
  ;;
  ;; If prefix is set, get the missing functions from the '*compilation*' buffer.
  (let (start-include-mark-line
        end-include-mark-line
        mark-line-found
        (start-mark "/**** start of bhj auto includes ****/")
        (end-mark "/**** end of bhj auto includes ****/")
        (includes
         (if prefix
             (with-temp-buffer
               (let ((temp-buffer (current-buffer)))
                 (with-current-buffer (get-buffer-create "*compilation*")
                   (shell-command-on-region (point-min) (point-max) "c-get-includes" temp-buffer)
                   (split-string (with-current-buffer temp-buffer
                                   (buffer-substring-no-properties (point-min) (point-max))) "\n" t))))
         (split-string
                   (shell-command-to-string
                    (concat "c-get-includes "
                            (shell-quote-argument (ajoke--buffer-file-name-local))))
                   "\n" t))))
    (save-excursion
      (goto-char (point-min))
      (if (search-forward start-mark nil t)
          (setq start-include-mark-line (line-number-at-pos)
                end-include-mark-line (save-excursion
                                        (search-forward end-mark)
                                        (line-number-at-pos)))
        (goto-char (point-min))
        (insert start-mark "\n" end-mark "\n\n")
        (setq start-include-mark-line 1
              end-include-mark-line 2))
      (goto-line (1+ start-include-mark-line))
      (goto-char (point-at-bol))
      (mapc (lambda (head)
              (insert head "\n"))
            includes)
      (setq end-include-mark-line (save-excursion
                                    (search-forward end-mark)
                                    (line-number-at-pos)))
      (shell-command-on-region
       (save-excursion
         (goto-line (1+ start-include-mark-line))
         (point-at-bol))
       (save-excursion
         (goto-line end-include-mark-line)
         (point-at-bol))
       "sort -u"
       nil
       t))))

;;;###autoload
(defun bhj-indent-region-as-prev-line()
  (interactive)
  (when mark-active
    (let* ((begin (region-beginning))
          (end (region-end))
          (last-line-indent
           (save-excursion
             (goto-char begin)
             (previous-line)
             (back-to-indentation)
             (current-column)))
          (this-line-indent
           (save-excursion
             (goto-char begin)
             (back-to-indentation)
             (current-column))))
      (if (> last-line-indent this-line-indent)
          (replace-regexp "^" (make-string last-line-indent ? ) nil begin end)
        (replace-regexp (concat "^" (make-string (- this-line-indent last-line-indent) ? )) "" nil begin end)))))



;;;###autoload
(defun bhj-occur ()
  (interactive)
  (with-syntax-table (let ((new-table (make-syntax-table (syntax-table))))
                       (modify-syntax-entry ?_ "w" new-table)
                       new-table)
    (let
        ((regexp (or bhj-occur-regexp
                     (if mark-active
                         (buffer-substring-no-properties (region-beginning)
                                                         (region-end))
                       (current-word)))))
      (progn
        (nodup-ring-insert ajoke--marker-ring (point-marker))
        (when (or (equal regexp "")
                  (not regexp))
          (setq regexp
                (buffer-substring-no-properties
                 (save-excursion
                   (back-to-indentation)
                   (point))
                 (line-end-position))))

        (unless bhj-occur-regexp
          (setq regexp (concat
                        (if (string-match "^\\w" regexp)
                            "\\b"
                          "")
                        (replace-regexp-in-string "\\([][^$*?\\\\.+]\\)" "\\\\\\1" regexp)
                        (if (string-match "\\w$" regexp)
                            "\\b"
                          ""))))

        (setq regexp
              (read-shell-command "List lines matching regexp: " regexp))
        (if (eq major-mode 'antlr-mode)
            (let ((occur-excluded-properties t))
              (occur regexp))
          (occur regexp))))))

;;;###autoload
(defun bhj-occur-make-errors ()
  (interactive)
  (let ((bhj-occur-regexp (downcase "\\*\\*\\*.*stop\\|acp: partial write to\\|method does not override or implement\\|syntax error\\|invalid argument\\|no such \\|circular.*dropped\\|no rule to\\|failed\\|[0-9]elapsed \\|cannot find symbol\\|error [0-9]\\| : error \\|because of errors\\|[0-9] error\\b\\|error:\\|command not found\\|error while loading shared libraries\\|undefined symbol\\|undefined reference to\\|permission denied\\|test.*unary operator expected\\|No space left on device\\|Traceback (most recent call last\\|javac: file not found:\\|illegal start of type\\|error, forbidden warning: \\|Out of memory error\\|Multiple same specifications\\|Communication error with Jack server\\|te:[0-9]*:ERROR 'unknown type\\|fatal: cannot obtain manifest")))
    (call-interactively 'bhj-occur)))

(defvar bhj-search-url-history nil)
(defun bhj-search-url ()
  (interactive)
  (let* ((search-entry (bhj-current-word))
         (search-engine (completing-read "Which search engine? " (split-string (shell-command-to-string "cd ~/system-config/bin; echo urlof-search-*")) nil nil nil 'bhj-search-url-history)))
    (when (region-active-p)
      (delete-region (region-beginning) (region-end)))
    (insert (format "[[%s][%s]]" (shell-command-to-string (format "%s %s" search-engine (shell-quote-argument search-entry))) search-entry))))

;;;###autoload
(defun bhj-occur-logcat-errors ()
  (interactive)
  ;;; xxxxxxxxxxxxxx Please note! do not use up case here!!! xxxxxxxxxxxxxxx ;;;
  (let ((bhj-occur-regexp (downcase "\\*\\*\\*.*stop\\|Caused by: \\|method does not override or implement\\|syntax error\\|invalid argument\\|circular.*dropped\\|no rule to\\|[0-9]elapsed \\|cannot find symbol\\| : error \\|because of errors\\|[0-9] error\\b\\|heap corruption detected by dlfree\\|undefined reference to\\|fatal exception")))
    (call-interactively 'bhj-occur)))

;;;###autoload
(defun bhj-occur-merge-conflicts ()
  (interactive)
  (let ((bhj-occur-regexp "<<<<<<<\\|>>>>>>\\|^=======$"))
    (call-interactively 'bhj-occur)))

;;;###autoload
(defun bhj-w3m-scroll-up-or-next-url ()
  (interactive)
  (if (pos-visible-in-window-p (point-max))
      (save-excursion
        (end-of-buffer)
        (search-backward-regexp "下一\\|下章\\|后一\\|还看了")
        (if (w3m-url-valid (w3m-anchor))
            (call-interactively 'w3m-view-this-url)
          (call-interactively 'w3m-next-anchor)
          (call-interactively 'w3m-view-this-url)))
    (call-interactively 'w3m-scroll-up-or-next-url)))

;;;###autoload
(defun bhj-w3m-scroll-down-or-previous-url ()
  (interactive)
  (if (pos-visible-in-window-p (point-min))
      (save-excursion
        (end-of-buffer)
         (search-backward-regexp "上一\\|上章")
         (call-interactively 'w3m-view-this-url))
    (call-interactively 'w3m-scroll-down-or-previous-url)))

;;;###autoload
(defun bhj-mimedown ()
  (interactive)
  (if (not mark-active)
      (message "mark not active\n")
    (save-excursion
      (let* ((start (min (point) (mark)))
             (end (max (point) (mark)))
             (orig-txt (buffer-substring-no-properties start end)))
        (shell-command-on-region start end "markdown" nil t)
        (insert "<#multipart type=alternative>\n")
        (insert orig-txt)
        (insert "<#part type=text/html>\n<html>\n<head>\n<title> HTML version of email</title>\n</head>\n<body>")
        (exchange-point-and-mark)
        (insert "\n</body>\n</html>\n<#/multipart>\n")))))

(defvar bhj-gmail-host "smtp.gmail.com")

;;;###autoload
(defun bhj-set-smtp-cred-to-company-mail ()
  (setq smtpmail-auth-credentials ; fixme
        `((,(shell-command-to-string "cat ~/.config/system-config/about_me/smtp")
           ,(string-to-number (shell-command-to-string "cat ~/.config/system-config/about_me/smtp-port"))
           ,(shell-command-to-string "cat ~/.config/system-config/about_me/mail")
           nil))

        message-send-mail-function 'smtpmail-send-it
        user-mail-address (shell-command-to-string "cat ~/.config/system-config/about_me/mail")
        smtpmail-stream-type (intern (shell-command-to-string "cat ~/.config/system-config/about_me/smtp-type"))
        smtpmail-default-smtp-server (shell-command-to-string "cat ~/.config/system-config/about_me/smtp")
        smtpmail-smtp-server (shell-command-to-string "cat ~/.config/system-config/about_me/smtp")
        smtpmail-smtp-service (string-to-number (shell-command-to-string "cat ~/.config/system-config/about_me/smtp-port"))))

;;;###autoload
(defun bhj-set-reply ()
  (interactive)
  (save-excursion
    (let ((receivers
           (concat
            (save-restriction (message-narrow-to-headers)
                              (message-fetch-field "to"))
            ", "
            (save-restriction (message-narrow-to-headers)
                              (message-fetch-field "cc"))
            ", "
            (save-restriction (message-narrow-to-headers)
                              (message-fetch-field "bcc"))))
          (all-marvell t)
          (start-pos 0))

      (when (save-excursion
              (save-restriction
                (message-narrow-to-headers)
                (message-fetch-field "Newsgroups")))
        (setq all-marvell nil))

      (while (and all-marvell (string-match "@" receivers start-pos))
        (setq start-pos (match-end 0))
        (unless (equal (string-match
                        (if (boundp 'my-company-mail-regexp)
                            my-company-mail-regexp
                          "example.com")
                    receivers
                    (1- start-pos))
                   (1- start-pos))
          (setq all-marvell nil)))

      (when all-marvell
        (save-excursion
          (message-goto-from)
          (message-beginning-of-line)
          (kill-line)
          (insert "\"Bao Haojun\" <" (shell-command-to-string "cat ~/.config/system-config/about_me/mail") ">")))

      (save-excursion
        (message-goto-from)
        (message-beginning-of-line)
        (when (save-excursion
                (search-forward-regexp "@ask.com" (line-end-position) t))
          (kill-line)
          (insert (completing-read "use account? " `(,(shell-command-to-string "cat ~/.config/system-config/about_me/mail") "baohaojun@gmail.com") nil t "baohaojun@gmail.com")))
        (message-goto-from)
        (message-beginning-of-line)
        (cond ((save-excursion
                 (search-forward-regexp
                  (if (boundp 'my-company-mail-regexp)
                      my-company-mail-regexp
                    "example.com")
                  (line-end-position) t))
               (kill-line)
               (insert (format "%s <%s>"
                               (shell-command-to-string "cat ~/.config/system-config/about_me/FullName")
                               (shell-command-to-string "cat ~/.config/system-config/about_me/mail")))
               (bhj-set-smtp-cred-to-company-mail))

              ((save-excursion (search-forward-regexp "@gmail.com" (line-end-position) t))
               (kill-line)
               (insert "\"Bao Haojun\" <baohaojun@gmail.com>")
               (setq smtpmail-auth-credentials
                     '((bhj-gmail-host
                        465
                        "baohaojun@gmail.com"
                        nil))
                     message-send-mail-function 'smtpmail-send-it
                     smtpmail-stream-type 'ssl
                     user-mail-address "baohaojun@gmail.com"
                     smtpmail-default-smtp-server bhj-gmail-host
                     smtpmail-smtp-server bhj-gmail-host
                     smtpmail-smtp-service 465))
              (t
               (error "don't know send as whom")))))))

(defun devenv-cmd (&rest args)
  "Send a command-line to a running VS.NET process.  'devenv' comes from devenv.exe"
  (apply 'call-process "DevEnvCommand" nil nil nil args))

;;;###autoload
(defun switch-to-devenv ()
  "Jump to VS.NET, at the same file & line as in emacs"
  (interactive)
  (save-some-buffers)
  (let ((val1
           (devenv-cmd "File.OpenFile" (buffer-file-name (current-buffer))))
        (val2
           (devenv-cmd "Edit.GoTo" (int-to-string (line-number-at-pos)))))
    (cond ((zerop (+ val1 val2))
              ;(iconify-frame)  ;; what I really want here is to raise the VS.NET window
                 t)
            ((or (= val1 1) (= val2 1))
                (error "command failed"))  ;; hm, how do I get the output of the command?
              (t
                  (error "couldn't run DevEnvCommand")))))

;;;###autoload
(defun devenv-toggle-breakpoint ()
  "Toggle a breakpoint at the current line"
  (interactive)
  (switch-to-devenv)
  (devenv-cmd "Debug.ToggleBreakpoint"))

;;;###autoload
(defun devenv-debug ()
  "Run the debugger in VS.NET"
  (interactive)
  (devenv-cmd "Debug.Start"))

;;;###autoload
(defun poor-mans-csharp-mode ()
  (csharp-mode)
  (setq mode-name "C#")
  (set-variable 'tab-width 8)
  (set-variable 'indent-tabs-mode t)
  (set-variable 'c-basic-offset 8)
  (c-set-offset 'inline-open 0)
  (c-set-offset 'case-label 0)
)

;;;###autoload
(defun try-all-themes()
  (interactive)
  (dolist (theme (custom-available-themes))
    (dolist (theme custom-enabled-themes)
      (disable-theme theme))
    (message "will enable %s" theme)
    (load-theme theme)
    (recursive-edit)))

;;;###autoload
(defun try-all-color-themes()
  (interactive)
  (dolist (theme color-themes)
    (recursive-edit)
    (message "will use %s" (car theme)
    (funcall (car theme)))))

(defun markdown-nobreak-p ()
  "Returns nil if it is ok for fill-paragraph to insert a line
  break at point"
  ;; are we inside in square brackets
  (or (looking-back "\\[[^]]*")
      (save-excursion
        (beginning-of-line)
        (looking-at "    \\|\t"))))

;;;###autoload
(defun where-are-we ()
  (interactive)
  (save-excursion
    (end-of-line)
    (shell-command-on-region
     1 (point)
     (concat "where-are-we "
             (shell-quote-argument (or (buffer-file-name) (buffer-name)))
             (format " %s" tab-width))))
  (pop-to-buffer "*Shell Command Output*")
  (end-of-buffer)
  (read-only-mode 0)
  (insert "\n")
  (beginning-of-buffer)
  (forward-line)
  (waw-mode)
  (let ((note (buffer-substring-no-properties (point-min) (point-max)))
        mark)
    (find-file "~/src/github/projects/notebook.org")
    (goto-char (point-max))
    (setq mark (point))
    (insert "\n#+begin_src waw\n")
    (insert note)
    (insert "\n#+end_src\n")
    (goto-char mark)))



;;;###autoload
(defun android-get-help ()
  (interactive)
  (shell-command (format "%s %s" "android-get-help" (ajoke--buffer-file-name-local))))

;;;###autoload
(defun visit-code-reading (&optional arg)
  (interactive "p")
  (let ((from-waw nil))
    (when (equal (buffer-name (current-buffer))
               "*Shell Command Output*")
      (setq from-waw t))

    (if (= arg 1)
        (find-file code-reading-file)
      (call-interactively 'find-file)
      (setq code-reading-file (buffer-file-name)))
    (when from-waw
      (goto-char (point-max))
      (insert "\n****************\n\n\n")
      (insert-buffer "*Shell Command Output*")
      (forward-line -2))
      (waw-mode)))

(defun waw-find-match (n search message)
  (if (not n) (setq n 1))
  (while (> n 0)
    (or (funcall search)
        (error message))
    (setq n (1- n))))

(defun java-bt-find-match (n search message)
  (if (not n) (setq n 1))
    (while (> n 0)
      (or (funcall search)
          (error message))
      (setq n (1- n))))

(defun waw-search-prev ()
  (beginning-of-line)
  (search-backward-regexp "^    ")
  (let ((this-line-str (ajoke--current-line)))
    (cond ((string-match ":[0-9]+:" this-line-str)
           (search-backward "    =>"))
          ((string-match "^\\s *\\.\\.\\.$" this-line-str)
           (forward-line -1))
          (t))))

(defun waw-search-next ()
  (end-of-line)
  (search-forward-regexp "^    ")
  (let ((this-line-str (ajoke--current-line)))
    (cond ((string-match ":[0-9]+:" this-line-str)
           (forward-line))
          ((string-match "^\\s *\\.\\.\\.$" this-line-str)
           (forward-line))
          (t))))

;;;###autoload
(defun waw-next-error (&optional argp reset)
  (interactive "p")
  (with-current-buffer
      (if (next-error-buffer-p (current-buffer))
          (current-buffer)
        (next-error-find-buffer nil nil
                                (lambda()
                                  (eq major-mode 'waw-mode))))

    (goto-char (cond (reset (point-min))
                     ((< argp 0) (line-beginning-position))
                     ((> argp 0) (line-end-position))
                     ((point))))
    (waw-find-match
     (abs argp)
     (if (> argp 0)
         #'waw-search-next
       #'waw-search-prev)
     "No more matches")

    (forward-line) ;;this is because the following was written
                   ;;originally as prev-error :-)

    (catch 'done
      (let ((start-line-number (line-number-at-pos))
            (start-line-str (ajoke--current-line))
            new-line-number target-file target-line
            error-line-number error-line-str
            msg mk end-mk)

        (save-excursion
          (end-of-line) ;; prepare for search-backward-regexp
          (search-backward-regexp ":[0-9]+:")
          (setq error-line-str (ajoke--current-line)
                error-line-number (line-number-at-pos))
          (string-match "^\\s *\\(.*?\\):\\([0-9]+\\):" error-line-str)
          (setq target-file (match-string 1 error-line-str)
                target-line (match-string 2 error-line-str)))

        (when (equal start-line-number error-line-number)
          (search-forward "=>")
          (forward-line))

        (when (equal start-line-number (1+ error-line-number))
          (search-backward-regexp "=>")
          (forward-line)
          (waw-next-error -1)
          (throw 'done nil))

        (setq new-line-number (line-number-at-pos))
        (forward-line -1)

        (while (> new-line-number error-line-number)
          (if (string-match "^\\s *\\.\\.\\.$" (ajoke--current-line))
              (progn
                (setq new-line-number (1- new-line-number))
                (forward-line -1))
            (back-to-indentation)
            (let ((search-str (buffer-substring-no-properties (point) (line-end-position))))
              (if (string-match "=>  \\s *\\(.*\\)" search-str)
                  (setq search-str (match-string 1 search-str)))
              (setq msg (point-marker))
              (save-excursion
                (with-current-buffer (find-file-noselect target-file)
                  (goto-line (read target-line))
                  (end-of-line)
                  (search-backward search-str)
                  (back-to-indentation)
                  (setq mk (point-marker) end-mk (line-end-position))))
              (compilation-goto-locus msg mk end-mk))
            (throw 'done nil)))))))

;;;###autoload
(defun waw-ret-key ()
  (interactive)
  (let ((start-line-str (ajoke--current-line)))
    (if (string-match "^    .*:[0-9]+:" start-line-str)
        (progn
          (search-forward-regexp "^    =>")
          (next-error 0))
      (if (string-match "^    " start-line-str)
          (progn
            (next-error 0))
        (insert "\n")))))

;;;###autoload
(defun waw-mode ()
  "Major mode for output from \\[where-are-we]."
  (interactive)
  (kill-all-local-variables)
  (use-local-map waw-mode-map)
  (setq major-mode 'waw-mode)
  (setq mode-name "Where-are-we")
  (setq next-error-function 'waw-next-error)
  (run-mode-hooks 'waw-mode-hook))

(defun java-bt-search-prev ()
  (beginning-of-line)
  (search-backward-regexp "(.*:[0-9]+)$"))

(defun java-bt-search-next ()
  (end-of-line)
  (search-forward-regexp "(.*:[0-9]+)$"))

;;;###autoload
(defun java-bt-ret-key ()
  (interactive)
  (let ((start-line-str (ajoke--current-line)))
    (when (string-match "(.*:[0-9]+)" start-line-str)
      (nodup-ring-insert ajoke--marker-ring (point-marker))
      (next-error 0))))

;;;###autoload
(defun java-bt-next-error (&optional argp reset)
  (interactive "p")
  (with-current-buffer
      (if (next-error-buffer-p (current-buffer))
          (current-buffer)
        (next-error-find-buffer nil nil
                                (lambda()
                                  (eq major-mode 'java-bt-mode))))

    (message "point is at %d" (point))
    (goto-char (cond (reset (point-min))
                     ((< argp 0) (line-beginning-position))
                     ((> argp 0) (line-end-position))
                     ((point))))
    (java-bt-find-match
     (abs argp)
     (if (> argp 0)
         #'java-bt-search-next
       #'java-bt-search-prev)
     "No more matches")
    (message "point is at %d" (point))

    (catch 'done
      (let ((start-line-number (line-number-at-pos))
            (start-line-str (ajoke--current-line))
            new-line-number target-file target-line
            error-line-number error-line-str grep-output temp-buffer
            msg mk end-mk)
          (save-excursion
            (end-of-line)
            (search-backward "(")
            (search-backward ".")
            (setq msg (point-marker))
            (end-of-line)
            (setq grep-output (cdr (assoc-string start-line-str java-bt-tag-alist)))
            (unless grep-output
              (setq grep-output (shell-command-to-string (concat "java-trace-grep 2>/dev/null " (shell-quote-argument (ajoke--current-line)))))
              (when (string-equal grep-output "")
                (setq grep-output (shell-command-to-string (concat "cd ~/src/android/; java-trace-grep " (shell-quote-argument (ajoke--current-line))))))
              (setq java-bt-tag-alist (cons (cons start-line-str grep-output) java-bt-tag-alist))))

        (when (string-match "^\\(.*\\):\\([0-9]+\\):" grep-output)
          (setq target-file (concat (file-remote-p (or (buffer-file-name (current-buffer)) default-directory)) (match-string 1 grep-output))
                target-line (match-string 2 grep-output))
          (save-excursion
            (with-current-buffer (find-file-noselect target-file)
              (goto-line (read target-line))
              (beginning-of-line)
              (setq mk (point-marker) end-mk (line-end-position)))))

        (compilation-goto-locus msg mk end-mk))

      (throw 'done nil))))

;;;###autoload
(defun java-bt-mode ()
  "Major mode for output from java back trace."
  (interactive)
  (kill-all-local-variables)
  (use-local-map java-bt-mode-map)
  (make-local-variable 'java-bt-tag-alist)
  (setq major-mode 'java-bt-mode-map)
  (setq mode-name "java-bt")
  (setq next-error-function 'java-bt-next-error)
  (flycheck-mode -1)
  (run-mode-hooks 'java-bt-mode-hook))

(defvar sc--git-directory nil
  "Denotes the git directory for current buffer."
  )

;;;###autoload
(defun buffer-file-localname (&optional buffer)
  (or (file-remote-p (buffer-file-name buffer) 'localname)
      (buffer-file-name buffer)))

;;;###autoload
(defun sc--after-save ()
  "Mark git need merge for system-config."
  (interactive)
  (unless (file-remote-p (buffer-file-name))
    (unless sc--git-directory
      (make-local-variable 'sc--git-directory)
      (setq sc--git-directory (shell-command-to-string "lookup-file -e .git/")))
    (unless (string= sc--git-directory "")
      (shell-command-to-string
       (format
        "nohup setsid bash -c %s"
        (shell-quote-argument
         (format
          "cd %s && nohup sc--after-save %s >/dev/null 2>&1"
          (shell-quote-argument sc--git-directory)
          (shell-quote-argument (buffer-file-localname)))))))))

;;;###autoload
(defun indent-same-space-as-prev-line (n-prev &optional from-bol)
  (interactive "p")
  (when from-bol
    (goto-char (line-beginning-position)))
  (let ((start-point (point))
        (end-point (point)))
    (let* ((col-start-indent (current-column))
           (compare-to-prev-lines (if (> n-prev 0)
                                      t
                                    nil))
           (n-prev (if (> n-prev 0)
                       n-prev
                     (- n-prev)))
           (col-end-indent (save-excursion
                             (or (looking-at "\\S ")
                                 (when (search-forward-regexp "\\S " (line-end-position) t)
                                   (backward-char)
                                   t)
                                 (goto-char (line-end-position)))
                             (setq end-point (point))
                             (current-column)))
           (col-indent-to (save-excursion
                            (while (> n-prev 0)
                              (forward-line (if compare-to-prev-lines -1 1))
                              (goto-char (if compare-to-prev-lines (line-end-position) (line-beginning-position)))
                              (apply (if compare-to-prev-lines 'search-backward-regexp 'search-forward-regexp) (list "\\S "))
                              (setq n-prev (1- n-prev)))
                            (move-to-column col-start-indent)
                            (when (and (looking-at "\\S ")
                                       (not (and
                                             (looking-back "\t")
                                             (> (current-column) col-start-indent))))
                              (search-forward-regexp "\\s "))
                            (search-forward-regexp "\\S " (line-end-position))
                            (backward-char)
                            (current-column))))
      (unless (equal start-point end-point)
        (delete-region start-point end-point))
      (insert (make-string (- col-indent-to col-start-indent) ? )))))

;;;###autoload
(defun back-to-indent-same-space-as-prev-line (n-prev)
  (interactive "p")
  (if (looking-back "\\S ")
      (progn
        (untabify (line-beginning-position) (point))
        (let* ((old-pos (point))
               (old-col (current-column))
               (pat-start (save-excursion
                            (search-backward-regexp "\\(^\\|\\s \\)\\S ")
                            (unless (looking-at "^")
                              (forward-char))
                            (point)))
               (pat (buffer-substring-no-properties old-pos pat-start))
               (col-back-to (save-excursion
                              (goto-char pat-start)
                              (search-backward pat)
                              (current-column)))
               (pos-back-to (- old-pos (- old-col col-back-to))))
          (untabify (line-beginning-position) old-pos)
          (if (< pos-back-to old-pos)
              (delete-region pos-back-to old-pos)
            (delete-region pat-start old-pos)
            (insert (make-string (- pos-back-to pat-start) ?\ )))))
    (indent-same-space-as-prev-line n-prev t)))

;;;###autoload
(defun save-all-buffers-no-check-modified ()
  (interactive)
  (cl-flet ((verify-visited-file-modtime (&rest args) t)
         (ask-user-about-supersession-threat (&rest args) t))
    (mapcar (lambda (x)
              (when (and (buffer-file-name x)
                         (file-exists-p (buffer-file-name x)))
                (with-current-buffer x
                  (unless buffer-read-only
                    (set-buffer-modified-p t)
                    (basic-save-buffer)))))
            (buffer-list))))

;;;###autoload
(defun revert-all-buffers ()
  (interactive)
  (mapcar (lambda (x)
            (when (buffer-file-name x)
              (with-current-buffer x
                (if (file-exists-p (buffer-file-name x))
                    (revert-buffer t t)
                  (kill-buffer)))))
          (buffer-list)))

;;;###autoload
(defun switch-buffer-same-filename (&optional reverse)
  (interactive)
  (let* ((buf-list (if reverse
                       (nreverse (buffer-list))
                     (buffer-list)))
         (current-filepath (ajoke--buffer-file-name))
         (current-filename (file-name-nondirectory current-filepath))
         checking-filename
         checking-filepath
         buf-switched)
    (while buf-list
      (setq checking-filepath (ajoke--buffer-file-name (car buf-list))
            checking-filename (file-name-nondirectory checking-filepath))
      (unless (eq (current-buffer) (car buf-list))
        (when (string-equal checking-filename current-filename)
            (progn
              (unless reverse
                (bury-buffer (current-buffer)))
              (switch-to-buffer (car buf-list))
              (message "switched to `%s'" (ajoke--buffer-file-name))
              (setq buf-list nil
                    buf-switched t))))
      (setq buf-list (cdr buf-list)))
    (unless buf-switched
      (message "You have no other buffer named `%s'" current-filename))))

;;;###autoload
(defun switch-buffer-same-filename-rev ()
  (interactive)
  (switch-buffer-same-filename t))

(defvar remote-sudo-prefix "/scp:root@localhost:"
  "The prefix for visiting a file's remote counterpart or with sudo permission")

;;;###autoload
(defun bhj-sudoedit ()
  (interactive)
  (find-alternate-file
   (if (file-remote-p (buffer-file-name))
       (replace-regexp-in-string ":.*?@" ":root@" (buffer-file-name))
     (concat remote-sudo-prefix (buffer-file-name)))))

;;;###autoload
(defun localedit ()
  (interactive)
  (find-alternate-file (replace-regexp-in-string "^/scp:.*?:" "" (buffer-file-name))))

;;;###autoload
(defun gnus-gmail-search-subject ()
  (interactive)
  (shell-command (concat
                  "search-gmail "
                  (shell-quote-argument (cl-case major-mode
                                          ('gnus-summary-mode
                                           (gnus-summary-article-subject))
                                          ('gnus-article-mode
                                           (save-excursion
                                             (beginning-of-buffer)
                                             (search-forward-regexp "^Subject: ")
                                             (buffer-substring-no-properties (point) (line-end-position))))))
                  "&")))

(defun bhj-get-nnmaildir-article-filename ()
  (let ((nnmaildir-article-file-name nnmaildir-article-file-name))
    (let ((article_id (if (eq major-mode 'gnus-summary-mode)
                          (gnus-summary-article-number)
                        gnus-current-article)))
      (with-temp-buffer
        (nnmaildir-request-article
         article_id
         gnus-newsgroup-name)))
    nnmaildir-article-file-name))

(defun bhj-current-word ()
    (if current-prefix-arg
        (read-shell-command "What word do you want? ")
      (bhj-grep-tag-default)))

;;;###autoload
(defun bhj-help-it ()
  "open help for the current word"
  (interactive)
  (ajoke--setup-env)
  (let ((default-directory (expand-file-name "~")))
    (shell-command-to-string (format "bhj-help-it %s %s >~/.cache/system-config/logs/bhj-help-it.log 2>&1&" major-mode (shell-quote-argument (bhj-current-word))))))

(defcustom bhj-help-qt-prog "bhj-help-qt"
  "The program to run when user want MSDN like help.")

;;;###autoload
(defun bhj-set-working-buffer ()
  "set the current working buffer"
  (interactive)
  (setq bhj-working-buffer (current-buffer)))

;;;###autoload
(defun bhj-help-qt ()
  "open help for the current word for qt"
  (interactive)
  (ajoke--setup-env)
  (shell-command-to-string (format "setsid setsid nohup %s %s &>~/.cache/system-config/logs/bhj-help-qt.log </dev/null" bhj-help-qt-prog (shell-quote-argument (bhj-current-word)))))

;;;###autoload
(defun bhj-view-mail-external ()
  "open the current maildir file in kmail"
  (interactive)
  (let ((default-directory "/"))
    (shell-command (concat "kmail-view " (shell-quote-argument (bhj-get-nnmaildir-article-filename))))))

(defun bhj-nnmaildir-search-aliman ()
  "Get the header of the current mail"
  (interactive)
  (if (region-active-p)
      (shell-command-to-string (format "search-aliman %s >/dev/null 2>&1&" (buffer-substring-no-properties (point) (mark))))
    (shell-command (format "maildir-search-aliman %s" (shell-quote-argument (bhj-get-nnmaildir-article-filename))))))

(defun bhj-nnmaildir-find-file()
  "Open the maildir file"
  (interactive)
  (find-file (bhj-get-nnmaildir-article-filename)))

;;;###autoload
(defun my-bbdb/gnus-update-records-mode ()
  (progn
    ;(message "hello bbdb/gnus-update-records-mode: %s %s %s" (buffer-name gnus-article-current-summary) (buffer-name) bbdb/news-auto-create-p)
    (if (and (boundp 'auto-create-p) (null auto-create-p))
        (if (and (boundp 'gnus-article-current-summary)
                 (string-match "^\\*Summary nntp" (buffer-name gnus-article-current-summary)))
            'annotating
          'searching)
      'annotating)))

(defun rename-refactory ()
  (interactive)
  (save-excursion
    (replace-regexp (read-string "The original? " (regexp-quote (symbol-name (symbol-at-point))))
                    (read-string "The replacement? " (symbol-name (symbol-at-point)))
                    nil
                    (point-min)
                    (point-max))))

(defun bhj-bbdb-search-all (regexp records)
  "Search the regexp in all fields."
  (bbdb-search records regexp regexp regexp
               (cons '* regexp) regexp regexp))

;;;###autoload
(defun bhj-flatten-list (list)
  "Return a new, flat list that contains all elements of LIST.

\(bhj-flatten-list '(1 (2 3 (4 5 (6))) 7))
=> (1 2 3 4 5 6 7)"
  (cond ((consp list)
         (apply 'append (mapcar 'bhj-flatten-list list)))
        (list
         (list list))))

(defun bhj-bbdb-dwim-all-mails (record)
  (let ((mails (bbdb-record-mail record)))
    (mapcar
     (lambda (n)
       (bbdb-dwim-mail record (nth n mails)))
     (number-sequence 0 (1- (length mails))))))

;;;###autoload
(defun bhj-bbdb-complete-mail (&optional start-pos)
  "Complete the user full-name or net-address before point (up to the
preceeding newline, colon, or comma, or the value of START-POS).  If
what has been typed is unique, insert an entry of the form \"User Name
<net-addr>\" (although see documentation for
bbdb-dwim-net-address-allow-redundancy).  If it is a valid completion
but not unique, a list of completions is displayed.

If the completion is done and `bbdb-complete-name-allow-cycling' is
true then cycle through the nets for the matching record.

When called with a prefix arg then display a list of all nets.

Completion behaviour can be controlled with `bbdb-completion-type'."
  (interactive)
  (let* ((end (point))
         (beg (or start-pos
                  (save-excursion
                    (re-search-backward "\\(\\`\\|[\n:,]\\)[ \t]*")
                    (goto-char (match-end 0))
                    (point))))
         (patterns (split-string (bbdb-string-trim (downcase (buffer-substring beg end)))))
         (records (bbdb-records))
         last-pattern the-record)
    (while (and records patterns)
      (setq
       last-pattern (regexp-quote (car patterns))
       records (bhj-bbdb-search-all last-pattern records)
       patterns (cdr patterns)))
    (when records
      (setq records
            (remove-if
             (lambda (mail)
               (not (string-match last-pattern mail)))
             (bhj-flatten-list
              (mapcar
               (lambda (one-record) (bhj-bbdb-dwim-all-mails one-record))
               records)))
            the-record (ajoke--pick-one "Which record to use? " records nil t)))
    (delete-region beg end)
    (insert the-record)))

;;;###autoload
(defun bhj-org-tasks-closed-last-week (&optional match-string)
  "Produces an org agenda tags view list of the tasks completed
in the specified month and year. Month parameter expects a number
from 1 to 12. Year parameter expects a four digit number. Defaults
to the current month when arguments are not provided. Additional search
criteria can be provided via the optional match-string argument "
  (interactive "sShow tasks before (default: last mon): ")
  (if (or (not match-string)
          (and (stringp match-string) (string-equal match-string "")))
      (setq match-string "last mon"))
  (org-tags-view nil
                 (concat
                  (format "+CLOSED>=\"[%s]\""
                          (shell-command-to-string (concat "today '" match-string "'"))))))

;;;###autoload
(defun bhj-do-code-generation ()
  (interactive)
  (let (start-of-code end-of-code code-text start-of-text end-of-text code-transform)
    (search-backward "start code-generator")
    (forward-char (length "start code-generator"))
    (if (looking-at "\\s *\\(\"\\|(\\)")
        (setq code-transform
             (read
              (buffer-substring-no-properties (point) (line-end-position)))))
    (next-line)
    (move-beginning-of-line nil)
    (setq start-of-code (point))
    (search-forward "end code-generator")
    (previous-line)
    (move-end-of-line nil)
    (setq end-of-code (point))
    (setq code-text (buffer-substring-no-properties start-of-code end-of-code))
    (cond
     ((stringp code-transform)
      (setq code-text (replace-regexp-in-string code-transform "" code-text)))
     ((consp code-transform)
      (setq code-text (replace-regexp-in-string (car code-transform) (cadr code-transform) code-text))))
    (search-forward "start generated code")
    (next-line)
    (move-beginning-of-line nil)
    (setq start-of-text (point))
    (search-forward "end generated code")
    (previous-line)
    (move-end-of-line nil)
    (setq end-of-text (point))
    (let ((output (shell-command-to-string code-text)))
      (delete-region start-of-text end-of-text)
      (insert output))
    (unless (or (eq major-mode 'fundamental-mode)
                (eq major-mode 'text-mode))
      (indent-region start-of-text (point)))
    (save-excursion
      (search-backward "start code-generator")
      (when (string-match "once start code-generator" (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
        (delete-region (line-beginning-position) (save-excursion (search-forward "end code-generator") (line-end-position)))))))

(defun bh/display-inline-images ()
  (condition-case nil
      (org-display-inline-images)
    (error nil)))

;;;###autoload
(defun dos2unix ()
  "Convert this entire buffer from MS-DOS text file format to UNIX."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "\r$" "" nil)
    (goto-char (1- (point-max)))
    (if (looking-at "\C-z")
        (delete-char 1))))

(defun copy-string (str)
  "copy the string into kill-ring"
  (with-temp-buffer
    (insert str)
    (kill-region (point-min) (point-max))))

;;;###autoload
(defun insert-today ()
  (interactive)
  (insert (shell-command-to-string "today")))

;;;###autoload
(defun bhj-do-dictionary (word)
  "lookup the current word (or region) in dictionary"
  (interactive
   (list (if mark-active
             (buffer-substring-no-properties (region-beginning)
                                             (region-end))
           (current-word))))
  (shell-command (format "setsid bash -c %s\\& >/dev/null 2>&1"
                         (shell-quote-argument
                          (format "md %s"
                                  (shell-quote-argument word))))))

(defun s-dicts ()
  "Look up the current WORD with English or Japanese dictionaries."
  (interactive)
  (bhj-do-search "s-dicts"))

(defun shell-setsid (&rest command-and-args)
  "Start a process with COMMAND-AND-ARGS with setsid in emacs."
  (let ((command-str
         (format
          "setsid setsid nohup %s >~/tmp/shell-setsid.log 2>&1"
          (string-join
           (mapcar
            (lambda (str)
              (shell-quote-argument str))
            command-and-args)
           " "))))
    (when (file-remote-p default-directory)
      (message "running remote command %s, maybe won't work!" command-str))
    (shell-command-to-string command-str)))

;;;###autoload
(defun bhj-do-search (&optional program word)
  "lookup the current word (or region) in dictionary"
  (interactive)
  (unless word
    (setq word (if mark-active
                   (buffer-substring-no-properties (region-beginning)
                                                   (region-end))
                 (current-word))))
  (unless program
    (setq program "s"))
  (let ((default-directory
          (if (file-remote-p default-directory)
              "/"
            default-directory)))
    (shell-setsid program word)))

;;;###autoload
(defun bhj-open-android-doc-on-java-buffer ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward-regexp "^\\s *package ")
    (let ((package-name
           (buffer-substring-no-properties
            (point)
            (1- (line-end-position))))
          (doc-prefix "file:///home/bhj/system-config/bin/Linux/ext/android-sdk-linux_86/docs/reference")
          (html-name (replace-regexp-in-string
                      ".java$" ".html"
                      (replace-regexp-in-string
                       ".*/" ""
                       (buffer-file-name))))
          (default-directory (expand-file-name "~")))
      (shell-command (format "of %s/%s/%s"
                             doc-prefix
                             (replace-regexp-in-string
                              "\\."
                              "/"
                              package-name)
                             html-name)))))

(defun bhj-get-clang-completion-errors ()
  (interactive)
  (let ((cflags "")
        (ac-clang-cflags company-clang-arguments))
    (while ac-clang-cflags
      (setq cflags (format "%s %s" cflags (shell-quote-argument (car ac-clang-cflags)))
            ac-clang-cflags (cdr ac-clang-cflags)))
    (shell-command (format "bhj-get-clang-completion-errors %s %d %d %s" (ajoke--buffer-file-name-local) (line-number-at-pos) (current-column) cflags))))

;;;###autoload
(defun bhj-find-missing-file ()
  (interactive)
  (let (missing-file-name missing-file-name-save)
    (save-excursion
      (goto-char (point-min))
      (search-forward-regexp "(default \\(.*\\))")
      (setq missing-file-name (match-string 1))
      (setq missing-file-name-save missing-file-name))

    (setq missing-file-name
          (mapcar (lambda (b) (buffer-file-name b))
                  (delete-if-not
                   (lambda (b)
                     (let ((name (file-name-nondirectory (or (buffer-file-name b) ""))))
                       (string= name missing-file-name-save)))
                   (buffer-list))))
    (unless missing-file-name
      (setq missing-file-name (shell-command-to-string
                               (format "beagrep -e %s -f 2>&1|perl -ne 's/:\\d+:.*// and print'" missing-file-name-save)))
      (setq missing-file-name (ajoke--delete-empty-strings (split-string missing-file-name "\n"))))

    (when missing-file-name
      (if (nth 1 missing-file-name)
          (setq missing-file-name
                (skeleton-general-display-matches missing-file-name))
        (setq missing-file-name (car missing-file-name)))
      (when (and (not (file-remote-p missing-file-name))
                 (file-remote-p default-directory))
        (setq missing-file-name (concat (file-remote-p default-directory)
                                        missing-file-name)))
        (insert missing-file-name))))

(defun ca-with-comment (str)
  (format "%s%s%s" comment-start str comment-end))

;;;###autoload
(defun source-code-help()
  (interactive)
  (let ((word (current-word)))
    (async-shell-command
     (if current-prefix-arg
         (format "search-google %s" (shell-quote-argument word))
       (format "source-code-help %s %s" major-mode word)))))

;;;###autoload
(defun bhj-upcase-symbol-or-region()
  (interactive)
  (if (region-active-p)
      (call-interactively 'upcase-region)
    (save-excursion
      (backward-sexp)
      (upcase-region (point)
                     (progn
                       (forward-sexp)
                       (point))))))

;;;###autoload
(defun bhj-downcase-symbol-or-region()
  (interactive)
  (if (region-active-p)
      (call-interactively 'downcase-region)
    (save-excursion
      (backward-sexp)
      (downcase-region (point)
                     (progn
                       (forward-sexp)
                       (point))))))

;;;###autoload
(defun weekrep ()
  (interactive)
  (call-process "wr" nil t nil "-6"))

;;;###autoload
(defun wiki-local-bhj ()
  (interactive)
  (let
      ((search-string (current-word)))
    (progn
      (setq search-string
            (read-string (format "search local wiki with [%s]: " search-string) nil nil search-string))
      (call-process "bash" nil nil nil "local-wiki.sh" search-string)
      )))

;;;###autoload
(defun bhj-clt-insert-file-name ()
  (interactive)
  (let ((prev-buffer (other-buffer (current-buffer) t)))
    (when (string-match "^\\*helm-" (buffer-name prev-buffer))
      (setq prev-buffer (nth 2 (buffer-list))))
    (insert
     (if (buffer-file-name prev-buffer)
         (if current-prefix-arg
             (buffer-file-name prev-buffer)
           (replace-regexp-in-string ".*/" "" (buffer-file-name prev-buffer)))
       (buffer-name prev-buffer)))))

;;;###autoload
(defun bhj-file-basename ()
  (let ((buffers (buffer-list)))
    (while (and
            (car buffers)
            (minibufferp (car buffers)))
      (setq buffers (cdr buffers)))
    (with-current-buffer (or (car buffers) (current-buffer))
      (let ((fn (buffer-file-name)))
        (if fn
            (file-name-nondirectory fn)
          (buffer-name))))))

;;;###autoload
(defun bhj-insert-pwdw ()
  (interactive)
  (insert "'")
  (call-process "cygpath" nil t nil "-alw" default-directory)
  (backward-delete-char 1)
  (insert "'"))

;;;###autoload
(defun bhj-insert-pwdu ()
  (interactive)
  (insert "'")
  (insert
   (replace-regexp-in-string
    "^/.?scp:.*?@.*?:" ""
    (expand-file-name default-directory)))
  (insert "'"))

;;;###autoload
(defun bhj-jdk-help (jdk-word)
  "start jdk help"
  (interactive
   (progn
     (let ((default (current-word)))
       (list (read-string "Search JDK help on: "
                          default
                          'jdk-help-history)))))

  ;; Setting process-setup-function makes exit-message-function work
  (call-process "/bin/bash" nil nil nil "jdkhelp.sh" jdk-word)
  (w3m-goto-url "file:///d/knowledge/jdk-6u18-docs/1.html"))

;;;###autoload
(defun ajoke-pop-mark ()
  "Pop back to where ajoke was last invoked."
  (interactive)
  ;; This function is based on pop-tag-mark, which can be found in
  ;; lisp/progmodes/etags.el.
  (if (ring-empty-p ajoke--marker-ring)
      (error "There are no marked buffers in the ajoke--marker-ring yet"))
  (let* ( (marker (ring-remove ajoke--marker-ring 0))
          (old-buffer (current-buffer))
          (marker-buffer (marker-buffer marker))
          marker-window
          (marker-point (marker-position marker))
          (ajoke-buffer (get-buffer ajoke-output-buffer-name)) )
    (when (and (not (ring-empty-p ajoke--marker-ring))
               (equal marker (ring-ref ajoke--marker-ring 0)))
      (ring-remove ajoke--marker-ring 0))
    (nodup-ring-insert ajoke--marker-ring-poped (point-marker))
    ;; After the following both ajoke--marker-ring and ajoke-marker will be
    ;; in the state they were immediately after the last search.  This way if
    ;; the user now makes a selection in the previously generated *ajoke*
    ;; buffer things will behave the same way as if that selection had been
    ;; made immediately after the last search.
    (setq ajoke-marker marker)
    (if marker-buffer
        (if (eq old-buffer ajoke-buffer)
            (progn ;; In the *ajoke* buffer.
              (set-buffer marker-buffer)
              (setq marker-window (display-buffer marker-buffer))
              (set-window-point marker-window marker-point)
              (select-window marker-window))
          (switch-to-buffer marker-buffer))
      (error "The marked buffer has been deleted"))
    (goto-char marker-point)
    (set-buffer old-buffer)))

;;;###autoload
(defun ajoke-pop-mark-back ()
  "Pop back to where ajoke was last invoked."
  (interactive)
  ;; This function is based on pop-tag-mark, which can be found in
  ;; lisp/progmodes/etags.el.
  (if (ring-empty-p ajoke--marker-ring-poped)
      (error "There are no marked buffers in the ajoke--marker-ring-poped yet"))
  (let* ( (marker (ring-remove ajoke--marker-ring-poped 0))
          (old-buffer (current-buffer))
          (marker-buffer (marker-buffer marker))
          marker-window
          (marker-point (marker-position marker))
          (ajoke-buffer (get-buffer ajoke-output-buffer-name)) )
    (nodup-ring-insert ajoke--marker-ring (point-marker))
    ;; After the following both ajoke--marker-ring-poped and ajoke-marker will be
    ;; in the state they were immediately after the last search.  This way if
    ;; the user now makes a selection in the previously generated *ajoke*
    ;; buffer things will behave the same way as if that selection had been
    ;; made immediately after the last search.
    (setq ajoke-marker marker)
    (if marker-buffer
        (if (eq old-buffer ajoke-buffer)
            (progn ;; In the *ajoke* buffer.
              (set-buffer marker-buffer)
              (setq marker-window (display-buffer marker-buffer))
              (set-window-point marker-window marker-point)
              (select-window marker-window))
          (switch-to-buffer marker-buffer))
      (error "The marked buffer has been deleted"))
    (goto-char marker-point)
    (set-buffer old-buffer)))

;;;###autoload
(defun bhj-c-show-current-func ()
  (interactive)
  (save-excursion
    (ajoke--beginning-of-defun-function)
    (message "%s" (ajoke--current-line))))

(defadvice fill-paragraph (before fill-paragraph-insert-nl-if-eob activate)
  (when (or (eobp)
            (looking-at "\n###start of comment###"))
    (save-excursion
      (insert "\n"))))

(defadvice helm-initialize (around helm-initialize-no-input-method activate)
  (let ((current-input-method nil))
    ad-do-it))

(defun bhj-update-loge ()
  "Update logs in java files"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((filename (bhj-file-basename)))
      (while (search-forward-regexp "Log\\.e.*String.format(\"%s:%d: \", \"\\(.*?\\)\", \\([0-9]+\\)" nil t)
        (let ((old-filename (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
              (old-line (buffer-substring-no-properties (match-beginning 2) (match-end 2)))
              (old-start (match-beginning 0))
              (old-end (match-end 0))
              (old-filename-start (match-beginning 1))
              (old-filename-end (match-end 1))
              (old-line-start (match-beginning 2))
              (old-line-end (match-end 2)))
          (goto-char old-filename-start)
          (when (search-forward old-filename old-filename-end t)
            (replace-match filename))
          (goto-char old-start)
          (search-forward-regexp "Log\\.e.*String.format(\"%s:%d: \", \"\\(.*?\\)\", \\([0-9]+\\)" nil t)
          (let ((old-line-start (match-beginning 2))
                (old-line-end (match-end 2)))
            (goto-char old-line-start)
            (when (search-forward old-line old-line-end t)
              (replace-match (number-to-string (line-number-at-pos old-line-start))))))))))

(defun bhj-c-indent-setup ()
  (c-set-offset 'arglist-intro '+))
(add-hook 'java-mode-hook 'bhj-c-indent-setup)

(defun bhj-todo-from-mail-view-mail ()
  (interactive)
  (let ((go-back-to-agenda nil)
        (mail nil)
        (uri nil)
        (message-id nil))
    (ajoke--push-marker-ring)
    (when (eq major-mode 'org-agenda-mode)
      (setq go-back-to-agenda t)
      (org-agenda-goto))
    (setq mail (org-entry-get (point) "FROM")
          uri (org-entry-get (point) "URI")
          message-id (org-entry-get (point) "MESSAGE_ID"))
    (cond
     (message-id
      (mu4e-view-message-with-msgid message-id))
     (mail
      (setq mail (shell-quote-argument mail))
      (shell-command-to-string (format "of %s >/dev/null 2>&1&" mail)))
     (uri
      (setq uri (shell-quote-argument uri))
      (shell-command-to-string (format "(killall -STOP mplayer; mplayer.exp %s; killall -CONT mplayer) >/dev/null 2>&1 &" uri))))
    (when go-back-to-agenda
      (switch-window))))

(defun bhj-todo-copy-id ()
  (interactive)
  (ajoke--push-marker-ring)
  (let ((mail (org-entry-get (point) "ID")))
    (setq mail (shell-quote-argument mail))
    (shell-command-to-string (format "putclip %s >/dev/null 2>&1&" mail))))

(defun org-export-string (string fmt &optional dir)
  "Export STRING to FMT using existing export facilities.
During export STRING is saved to a temporary file whose location
could vary.  Optional argument DIR can be used to force the
directory in which the temporary file is created during export
which can be useful for resolving relative paths.  Dir defaults
to the value of `temporary-file-directory'."
  (let ((temporary-file-directory (or dir temporary-file-directory))
        (tmp-file (make-temp-file "org-" nil ".org")))
    (cond
     ((eq fmt 'org)
      (setq fmt 'ascii))
     (t
      (setq fmt 'html)))
    (unwind-protect
       (with-temp-buffer
         (insert string)
         (write-file tmp-file)
         (org-load-modules-maybe)
         (org-export-as fmt))
      (delete-file tmp-file))))
(load "emacs-25.el")

(defvar bhj-last-selected-text nil
  "The value of the text selection.")


(defun bhj-select-text (text)
  (let* ((default-directory "/")
         (process-connection-type nil)
         (proc (start-file-process "emacs-clip-cut" nil "emacs-clip-cut")))
    (when proc
      (process-send-string proc text)
      (process-send-eof proc))
    (setq bhj-last-selected-text text)))

(defun bhj-select-value ()
  (let* ((default-directory "/")
         (text (shell-command-to-string "emacs-clip-paste")))
    (if (string= text bhj-last-selected-text)
        nil
      text)))

(defun org-smb-link-export (path desc format)
  "For exporting smb link into html"
  (when (eq 'html format)
    (format "<a href='smb:%s'>%s</a>"
            path
            (if desc
                desc
              (replace-regexp-in-string "/" "\\\\" path)))))

(defun bhj-jwords-done ()
  "Mark the jword as done (learned)."
  (interactive)
  (save-excursion
    (save-restriction
      (org-back-to-heading)
      (org-narrow-to-subtree)
      (goto-char (point-min))
      (replace-regexp "^\\(\\*+\\) \\(TODO\\|DONE\\|SOMEDAY\\)" "\\1 DONE")
      (shell-command-on-region (point-min) (point-max) "jwords-done")
      (show-all)))
  (outline-next-visible-heading 1)
  (move-end-of-line nil)
  (backward-char 2))

(defun bhj-jwords-undone ()
  "Re-mark the previous jword as not done."
  (interactive)
  (outline-previous-visible-heading 1)
  (bhj-jwords-someday))

(defun bhj-jwords-someday ()
  "Mark the jword as someday (learn later)."
  (interactive)
  (save-excursion
    (save-restriction
      (org-back-to-heading)
      (org-narrow-to-subtree)
      (goto-char (point-min))
      (replace-regexp "^\\(\\*+\\) \\(TODO\\|DONE\\|SOMEDAY\\)" "\\1 SOMEDAY")
      (shell-command-on-region (point-min) (point-max) "jwords-someday")
      (show-all)))
  (outline-next-visible-heading 1)
  (move-end-of-line nil)
  (backward-char 2))

(setq interprogram-cut-function 'bhj-select-text
      interprogram-paste-function 'bhj-select-value)

(defun bhj-half-to-full ()
  "Replace full width with half width."
  (interactive)
  (replace-regexp "[ -~]"
                  (quote
                   (replace-eval-replacement
                    replace-quote
                    (if (string= " " (match-string 0))
                        (char-to-string 12288)
                      (char-to-string
                       (+ 65248 (string-to-char (match-string 0)))))))
                  nil
                  (if (use-region-p) (region-beginning))
                  (if (use-region-p) (region-end))
                  nil))

(defun bhj-wrench-post (&optional prefix)
  "Post it through Wrench"
  (interactive "P")
  (let ((beg (point-min))
        (end (point-max)))
    (when (and (region-active-p) (not (= (point) (mark))))
      (setq beg (mark)
            end (point)))
    (shell-command-to-string (format "nohup setsid Wrench-post %s -- %s >/dev/null 2>&1 </dev/null" (if prefix " --ask-to-whom" "") (shell-quote-argument (buffer-substring-no-properties beg end)))))
  (unless (region-active-p)
    (set-mark (point-min))
    (goto-char (point-max)))
  (when (string= (buffer-file-name) (expand-file-name "~/src/github/projects/chat.org"))
    (delete-region (point-min) (point-max))
    (save-buffer)))

(defun switch-to-file (file-name)
  (let* ((buffer-list (buffer-list))
         (buffer (car buffer-list)))
    (while buffer-list
      (when buffer
        (when (string= (buffer-file-name buffer) file-name)
          (switch-to-buffer buffer)
          (setq buffer-list nil)))
      (setq buffer-list (cdr buffer-list)
            buffer (car buffer-list))))
  (unless (string= (buffer-file-name) file-name)
    (find-file file-name)))

(defun goto-next-text-region (&optional text-prop)
  (interactive)
  (when (not text-prop)
    (setq text-prop (read-from-minibuffer "What text property do you want to goto: ")))
  (let ((target-point)
        (next-prop-point)
        (pos-text-prop))
    (save-excursion
      (catch 'found
        (while (setq next-prop-point (next-property-change (point)))
          (goto-char next-prop-point)
          (setq pos-text-prop (get-text-property (point) 'face))
          (when (string-match text-prop (format "%s" pos-text-prop))
            (setq target-point (point))
            (throw 'found t)))))
    (when target-point
      (goto-char target-point))))

(defun bhj-forward-to-same-indentation ()
  (interactive)
  (let ((old-indentation (save-excursion (back-to-indentation) (current-column)))
        new-indentation found)
    (set-mark (point))
    (while (not found)
      (forward-line)
      (setq new-indentation (save-excursion (back-to-indentation) (current-column)))
      (when (= new-indentation old-indentation)
        (setq found t)))))

(defun bhj-backward-to-same-indentation ()
  (interactive)
  (let ((old-indentation (save-excursion (back-to-indentation) (current-column)))
        new-indentation found)
    (set-mark (point))
    (while (not found)
      (forward-line -1)
      (setq new-indentation (save-excursion (back-to-indentation) (current-column)))
      (when (= new-indentation old-indentation)
        (setq found t)))))

(defun bhj-backward-to-less-indentation ()
  (interactive)
  (let ((old-indentation (save-excursion (back-to-indentation) (current-column)))
        new-indentation found)
    (set-mark (point))
    (while (not found)
      (forward-line -1)
      (setq new-indentation (save-excursion (back-to-indentation) (current-column)))
      (when (and (< new-indentation old-indentation)
                 (string-match "\\S .*\n" (thing-at-point 'line)))
        (setq found t)))))

(defun bhj-string-contains-each-other (str1 str2)
  (or (string-match-p (regexp-quote str1) str2)
      (string-match-p (regexp-quote str2) str1)))

(defun bhj-string-contains (str1 str2)
  (string-match-p (regexp-quote str2) str1))

(defun insert-kill-ring (text)
  (let ((first-entry (or (car kill-ring) "")))
    (cond
     ((string= text first-entry) t)
     ((bhj-string-contains text first-entry)
      (setq kill-ring (delete-dups kill-ring))
      (setq kill-ring (cons text (cdr kill-ring))))
     ((bhj-string-contains first-entry text)
      t)
     (t
      (setq kill-ring (delete-dups kill-ring))
      (setq kill-ring (cons text kill-ring)))))
  nil)

(provide 'bhj-defines)
