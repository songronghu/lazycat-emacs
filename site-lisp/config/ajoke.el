;;; ajoke.el --- Ambitious Java On Emacs, K is silent.

;; Copyright (C) 2013 Bao Haojun

;; Author: Bao Haojun <baohaojun@gmail.com>
;; Maintainer: Bao Haojun <baohaojun@gmail.com>
;; Created: 2013-07-25
;; Keywords: java
;; Version: 0.0.20130725
;; URL: https://github.com/baohaojun/ajoke

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; For more information see the readme at:
;; https://github.com/baohaojun/ajoke

;;; Code:

(require 'cl)

(defsubst ajoke--current-line (&optional to-here)
  (buffer-substring-no-properties (point-at-bol) (if to-here (point) (point-at-eol))))

(defcustom ajoke--emacs-ctags-alist
  '(("emacs-lisp" . "lisp")
    ("sawfish" . "lisp")
    ("org" . "OrgMode")
    ("js" . "javascript")
    ("c" . "c++")
    ("objc" . "ObjectiveC")
    ("makefile-gmake" . "make")
    ("cperl" . "perl")
    ("java-ts" . "java")
    ("csharp" . "C#"))
  "Map from Emacs major modes to ctags languages")

(defcustom ajoke--emacs-filter-alist
  '(("c" . "| perl -ne '@f = split; print unless $f[1] =~ m/^member|macro$/'")
    ("php" . "| perl -ne '@f = split; print unless $f[1] =~ m/^variable$/'"))
  "Map from Emacs major modes to ctags output filter")

(defvar ajoke--marker-ring (make-ring 32)
  "Ring of markers which are locations from which ajoke was invoked.")

(defvar ajoke--marker-ring-poped (make-ring 32)
  "Ring of markers which are locations poped from ajoke--marker-ring.")

(defvar ajoke--last-tagged-buffer nil
  "The last buffer tagged, use for optimization.")

(defvar ajoke--last-tagged-tick 0
  "The modification tick of the last tagged buffer, for optimization.")

(defvar ajoke--tagged-lines nil
  "A vector of the tagged lines for the current buffer.

Each element of it is the line number on the source code buffer,
where a tag is defined.")

(defun ajoke--push-marker-ring ()
  (nodup-ring-insert ajoke--marker-ring (point-marker)))

(defun ajoke--buffer-file-name (&optional buf)
  (setq buf (or buf (current-buffer)))
  (with-current-buffer buf
    (if (eq major-mode 'dired-mode)
        (directory-file-name default-directory)
      (or (buffer-file-name buf) (buffer-name buf) ""))))

(defun ajoke--buffer-file-name-local (&optional buf)
  (let ((name (ajoke--buffer-file-name buf)))
    (or (file-remote-p name 'localname)
        name)))

(defun ajoke--delete-empty-strings (l)
  (delete-if
   (lambda (s) (string-equal s ""))
   l))

(defun ajoke--setup-env ()
  "Set environment variable for the current file.

So that the scripts know which source code file you're editing,
and treat it specialy, because in most cases the gtags database
record about this file is outdated since you're editing it right
now, and thus need rebuild tags for this file."
  (let ((file (ajoke--buffer-file-name)))
    (if (file-remote-p file)
        (progn
          (with-parsed-tramp-file-name file nil
            (with-tramp-file-property v localname "file-exists-p"
              (tramp-send-command v (format "export %s=%s" "GTAGS_START_FILE" (file-remote-p file 'localname)))))
        (let ((process-environment tramp-remote-process-environment))
          (setenv "GTAGS_START_FILE" (file-remote-p file 'localname))
          (setq tramp-remote-process-environment process-environment)))
      (setenv "GTAGS_START_FILE" file))))

(defun ajoke--tag-current-buffer (output-buf)
  "Tag the current buffer using ctags."
  (interactive)
  (let ((current-buffer (current-buffer))
        (current-buffer-tick (buffer-chars-modified-tick))
        last-code-line)
    (unless (and
             (eq current-buffer ajoke--last-tagged-buffer)
             (= current-buffer-tick ajoke--last-tagged-tick))
      ;; tag is out-dated, retag
      (message "Ajoke: re-tag the buffer")
      (let (deactivate-mark) ;;see the help of save-excursion
        (save-excursion
          (save-window-excursion
            (save-restriction
              (widen)
              (setq last-code-line (line-number-at-pos (buffer-end 1)))
              (shell-command-on-region
               (point-min)
               (point-max)
               (let ((mode-name-minus-mode
                      (replace-regexp-in-string "-mode$" "" (symbol-name major-mode))))
                    (concat "ctags-stdin --extra=+q --language-force="
                         (shell-quote-argument
                          (or (cdr (assoc mode-name-minus-mode ajoke--emacs-ctags-alist))
                              mode-name-minus-mode))
                         " -xu "
                         (cdr (assoc mode-name-minus-mode ajoke--emacs-filter-alist))))
               output-buf))))
        (with-current-buffer output-buf
          (goto-char (point-max))
          (insert (concat "hello function "
                          (number-to-string last-code-line)
                          " hello world"))
          (let* ((number-of-tags (line-number-at-pos))
                 (it 1)
                 (vec (make-vector number-of-tags 0)))
            (setq ajoke--tagged-lines nil)
            (while (<= it number-of-tags)
              (aset vec (1- it) (list (ajoke--extract-line-number it)
                                      (ajoke--extract-tag it)))
              (setq it (1+ it)))
            (setq ajoke--tagged-lines vec))))
      (setq ajoke--last-tagged-buffer current-buffer
            ajoke--last-tagged-tick current-buffer-tick))))

(defun ajoke--extract-line-number (nth-tag-line)
  "Extract line number for `ajoke--thing-at-tag'."
  (if ajoke--tagged-lines
      (nth 0 (aref ajoke--tagged-lines (max 0 (min (1- nth-tag-line) (1- (seq-length ajoke--tagged-lines))))))
    (goto-line nth-tag-line)
    (let ((subs (split-string (ajoke--current-line))))
      (string-to-number
       (if (string-equal (car subs) "operator")
           (cadddr subs) ;operator +=      function    183 /home...
         (caddr subs)))))) ;region_iterator  struct      189 /home...

(defun ajoke--extract-tag (nth-tag-line)
  "Extract tag for `ajoke--thing-at-tag'."
  (if ajoke--tagged-lines
      (nth 1 (aref ajoke--tagged-lines (1- nth-tag-line)))
    (goto-line nth-tag-line)
    (car (split-string (ajoke--current-line)))))

(defun ajoke--extract-class (nth-tag-line)
  "Extract classes for `ajoke--thing-at-tag'.

If there are more than one classes/interfaces before
NTH-TAG-LINE, ask user to pick."
  (with-current-buffer "*ajoke--tags*"
    (goto-line nth-tag-line)
    (let ((limit (line-end-position))
          classes)
      (goto-char (point-min))
      (while (search-forward-regexp "class\\|interface" limit t)
        (let* ((tagstr (ajoke--current-line))
               (fields (split-string tagstr))
               (name (car fields))
               (type (cadr fields)))
          (cond
           ((or (string-equal type "class")
                (string-equal type "interface"))
            (setq classes (cons tagstr classes))))))
      (car (split-string (ajoke--pick-one "Which class/interface? " (delete-dups (nreverse classes)) nil t))))))

;;;###autoload
(defun ajoke--pick-one (prompt collection &rest args)
  "Pick an item from COLLECTION, which is a list.
ARGS is passed to the supporting function completing-read (or
HELM's or Anything's version of completing-read: you are strongly
advised to use one of these elisp tools)."
  (if (= (length (delete-dups collection)) 1)
      (car collection)
    (apply 'completing-read prompt collection args)))

(defun ajoke--thing-at-tag (thing-func nth-tag-cur)
  "Like `thing-at-point', this function finds something for the current tag.

THING-FUNC is a function to specify which thing of the tag to
extract, for e.g., the line number the tag is on, or the name of
the tag.

NTH-TAG-CUR means the NTH-TAG-CUR'th tag around the current code
line. If it is positive, it means the NTH-TAG-CUR-th tag whose
code line is smaller than the current code line. If it is
negative, it means larger. If it is 0, it means equal or
smaller. In most cases NTH-TAG-CUR should be 0, because we are
most interested in the current tag."
  (interactive)
  (ajoke--tag-current-buffer (get-buffer-create "*ajoke--tags*"))
  (let ((old-code-line (line-number-at-pos))
        (last-def-line 1))
    (let* ((min 1)
           (max (length ajoke--tagged-lines))
           (mid (/ (+ min max) 2))
           (mid-code-line (ajoke--extract-line-number mid))
           (mid+1-codeline (ajoke--extract-line-number (1+ mid))))
      (while (and
              (not (and
                    (< mid-code-line old-code-line)
                    (>= mid+1-codeline old-code-line)))
              (< min max))
        (if (>= mid-code-line old-code-line)
            (setq max (1- mid))
          (setq min (1+ mid)))
        (setq mid (/ (+ min max) 2)
              mid-code-line (ajoke--extract-line-number mid)
              mid+1-codeline (ajoke--extract-line-number (1+ mid))))
      (funcall thing-func
               (cond
                ((= 0 nth-tag-cur)
                 (if (= mid+1-codeline old-code-line)
                     (1+ mid)
                   mid))
                ((< nth-tag-cur 0)
                 (if (= mid+1-codeline old-code-line)
                     (+ mid 1 (- nth-tag-cur))
                   (+ mid (- nth-tag-cur))))
                (t ; (> nth-tag-cur 0)
                 (+ mid -1 nth-tag-cur)))))))

(defun ajoke--delete-current-regexp (re)
  (ajoke--current-regexp re (lambda (start end) (delete-region start end))))

(defun ajoke--current-regexp (re &optional func)
  "Look for regular expression RE around the current point.

When matched, return the matched string by default. But if FUNC
is set, call FUNC with the start and end of the matched region."
  (save-excursion
    (let (start end)
      (while (not (looking-at re))
        (backward-char))
      (while (looking-at re)
        (backward-char))
      (forward-char)
      (setq start (point))
      (search-forward-regexp re)
      (setq end (point))
      (funcall (or func 'buffer-substring-no-properties) start end))))

(defun ajoke--beginning-of-defun-function (&optional arg)
  "Ajoke's version of `beginning-of-defun-function'."
  (if (or (null arg) (= arg 0)) (setq arg 1))
  (let ((target-line
         (ajoke--thing-at-tag
          'ajoke--extract-line-number
          (if (and (not (bolp)) (> arg 0))
              (1- arg)
            arg))))
  (goto-line target-line)))

(defun ajoke-display-the-current-function ()
  (interactive)
  (let* ((imenu-indices (ajoke--create-index-function))
         (imenu-indices (sort imenu-indices (lambda (a b) (< (cdr a) (cdr b)))))
         (point (point))
         last-index
         answer)
    (while imenu-indices
      (if (and
           (< (cdar imenu-indices) point)
           (or (not (cdr imenu-indices))
               (>= (cdadr imenu-indices) point)))
          (setq answer (caar imenu-indices)  imenu-indices nil)
        (setq imenu-indices (cdr imenu-indices))))
    (message "%s" answer)))


(defun ajoke--create-index-function ()
  "Ajoke's version of `imenu-default-create-index-function'."
  (let ((source-buffer (current-buffer))
        (temp-buffer (get-buffer-create "* imenu-ctags *"))
        result-alist)
    (save-excursion
      (save-restriction
        (unless (or
                 (eq major-mode 'Info-mode) ; should not do the whole info page.
                 )
          (widen))
        (save-window-excursion
          (shell-command-on-region
           (point-min)
           (point-max)
           (concat "MAJOR_MODE=" (symbol-name major-mode) " imenu-ctags "
                   (shell-quote-argument (file-name-nondirectory (ajoke--buffer-file-name-local source-buffer))))
           temp-buffer))
        (with-current-buffer temp-buffer
          (goto-char (point-min))
          (while (search-forward-regexp "^\\([0-9]+\\) : \\(.*\\)" nil t)
            (setq result-alist
                  (cons (cons (match-string 2)
                              (let ((marker (make-marker)))
                                (set-marker marker (string-to-number (match-string 1)) source-buffer)))
                        result-alist))))))
    (nreverse result-alist)))

(defun ajoke-find-header ()
  (interactive)
  (let* ((current-regexp (shell-quote-argument (ajoke--current-regexp "\\(\\w\\|/\\)+")))
         (header (ajoke--pick-output-line "Which header to find" (format "cc-find-header %s" current-regexp))))
    (find-file header)))

(defun ajoke-get-includes ()
  (interactive)
  (save-excursion
    (search-backward "#include")
    (goto-char (line-end-position))
    (let* ((head-regexp (read-string "What header to include (such as q/qtline for QLineEdit)? "))
           (head-regexp (shell-quote-argument head-regexp))
           (header (ajoke--pick-output-line "Which header to include" (format "cc-get-include %s" head-regexp))))
      (insert (format (if (file-exists-p header)
                          "\n#include \"%s\""
                        "\n#include <%s>")
                      header)))))

;;;###autoload
(defun ajoke-get-imports ()
  "Write the java import statements automatically."
  (interactive)
  (if (not (eq major-mode 'java-mode))
      (ajoke-get-includes)
    (save-excursion
      (let ((old-buffer (current-buffer))
            import-list)
        (with-temp-buffer
          (shell-command (format "ajoke-get-imports.pl %s -v" (ajoke--buffer-file-name-local old-buffer)) (current-buffer))
          (goto-char (point-min))
          (while (search-forward-regexp "^import" nil t)
            (save-excursion
              (if (looking-at "-multi")
                  (setq
                   import-list
                   (cons
                    (format
                     "import %s;\n"
                     (ajoke--pick-one
                      "Import which? "
                      (cdr
                       (ajoke--delete-empty-strings
                        (split-string (ajoke--current-line) "\\s +")))
                      nil
                      t))
                    import-list))
                (setq import-list (cons (format "%s;\n" (ajoke--current-line)) import-list))))
            (forward-line)
            (beginning-of-line)))
        (goto-char (point-max))
        (or (search-backward-regexp "^import\\s +" nil t)
            (search-backward-regexp "^package\\s +" nil t))
        (forward-line)
        (beginning-of-line)
        (while import-list
          (insert (car import-list))
          (setq import-list (cdr import-list)))
        (let ((end-imports (point))
              (start-imports
               (save-excursion
                 (previous-line)
                 (beginning-of-line)
                 (while (looking-at "^import\\s +")
                   (previous-line)
                   (beginning-of-line))
                 (next-line)
                 (beginning-of-line)
                 (point))))
          (shell-command-on-region start-imports end-imports "sort -u" nil t))))))

;;;###autoload
(defun ajoke-get-hierarchy ()
  "Print the class/interface inheritance hierarchy for the
current class. Output is in compilation-mode for ease of cross
referencing."
  (interactive)
  (ajoke--setup-env)
  (let ((class-name (ajoke--thing-at-tag 'ajoke--extract-class 0))
        (method-name
         (replace-regexp-in-string
          ".*\\." ""
          (or (and transient-mark-mode mark-active
                   (/= (point) (mark))
                   (buffer-substring-no-properties (point) (mark)))
              (ajoke--thing-at-tag 'ajoke--extract-tag 0))))
        (compilation-buffer-name-function (lambda (_ign) "*ajoke-get-hierarchy*")))
    (compile (format "ajoke-get-hierarchy.pl %s %s"
                     class-name
                     (if current-prefix-arg
                         "-v"
                       (concat "-m " method-name))))))

;;;###autoload
(defun ajoke-get-override ()
  "Overide a method defined in super classes/interfaces."
  (interactive)
  (ajoke--setup-env)
  (let (method)
    (save-excursion
      (let* ((class-name
              (if current-prefix-arg
                  (ajoke-resolve (read-string "Whose methods to overide? " (save-excursion
                                                                             (backward-up-sexp 1) ;; new OnItemClickListener() { *
                                                                             (backward-sexp 1)
                                                                             (current-word))))
                (ajoke--thing-at-tag 'ajoke--extract-class 0)))
             (hierarchy (shell-command-to-string (format "ajoke-get-hierarchy.pl %s -v|grep '('|perl -npe 's/^\\s+//'|sort -u" class-name)))
             (methods (split-string hierarchy "\n")))
        (setq method (completing-read "Which method to override? " methods nil t))))
    (insert "@Override\n")
    (insert (replace-regexp-in-string  "\\(,\\|)\\)" "\\1 " method))))

;;;###autoload
(defun ajoke-resolve (id)
  "Resolve the type (class/interface) of ID."
  (interactive
   (list (or (and transient-mark-mode mark-active
                  (/= (point) (mark))
                  (buffer-substring-no-properties (point) (mark)))
             (ajoke--current-regexp "[.a-z0-9]+"))))
  (let ((res
         (shell-command-to-string (format "ajoke-get-imports.pl %s -r %s"
                                          (shell-quote-argument (ajoke--buffer-file-name-local))
                                          (shell-quote-argument id)))))
    (message "%s" res)
    res))

(defun shell-command-on-region-to-string (command &optional start end )
  "Execute string COMMAND in inferior shell with region from START to END as input."
  (let ((my-start (or start (and (use-region-p) (region-beginning)) (point-min)))
        (my-end (or end (and (use-region-p) (region-end)) (point-max))))
    (with-output-to-string
      (shell-command-on-region my-start my-end command standard-output))))

;;;###autoload
(defun ajoke-complete-method (id)
  "Complete a method given an ID. First will resolve the
type (class/interface) of ID, then complete using the type's
methods."
  (interactive
   (list (or (and transient-mark-mode mark-active
                  (/= (point) (mark))
                  (buffer-substring-no-properties (point) (mark)))
             (ajoke--current-regexp "[.a-z0-9_]+"))))
  (let (method (remove ""))
    (save-excursion
      (let* ((resolve
              (if current-prefix-arg
                  (let* ((resolve
                          (replace-regexp-in-string "\\.*$" "" (read-string "What class's method do you want to import? ")))
                         (has-a-dot-resolve
                          (if (string-match "\\." resolve)
                              resolve
                            (ajoke--pick-one
                             "Complete which class's methods/fields? "
                             (split-string
                              (shell-command-to-string (format "GTAGS_START_FILE= ajoke-get-qclass %s"
                                                               (shell-quote-argument resolve))) "\n" t)))))
                    (format "%s." has-a-dot-resolve))
                (let ((resolve-line
                       (ajoke--pick-one
                        "Complete which class's methods/fields? "
                        (split-string
                         (shell-command-on-region-to-string (format "ajoke-get-imports.pl -r %s -"
                                                                    (shell-quote-argument id))) "\n" t)
                        nil
                        t)))
                  (car (split-string resolve-line "\\s +" t)))))
             (comp (split-string resolve "\\."))
             (comp-last (car (last comp)))
             (class (cond
                     ((string= comp-last "")
                      (setq remove ".")
                      (mapconcat 'identity (butlast comp) "."))
                     ((let ((case-fold-search nil))
                        (string-match "^[a-z]" comp-last))
                      (setq remove (concat "." comp-last))
                      (mapconcat 'identity (butlast comp) "."))
                     (t resolve)))
             (hierarchy (shell-command-to-string (format "ajoke-get-hierarchy.pl %s -v|perl -npe 's/^\\s+//; if (not m/\\(/) {s/=.*|;//}'|sort -u" class)))
             (methods (split-string hierarchy "\n" t)))
        (setq method (completing-read "Which method to call? " methods nil t))))
    (goto-char (ajoke--current-regexp "[.a-z0-9_]+" (lambda (start end) end)))
    (when (not (string-equal remove ""))
      (delete-region (- (point) (length remove)) (point)))
    (insert ".")
    (if (string-match "(" method)
        (insert (replace-regexp-in-string ".*\\s \\(\\S *(.*)\\).*" "\\1" method))
      (insert (replace-regexp-in-string ".*\\s \\(\\S +\\)\\s *" "\\1" method)))))

;;;###autoload
(defun ajoke-search-local-id ()
  "Search an identifier such as a local variable from the
beginning of current defun."
  (interactive)
  (with-syntax-table (let ((new-table (make-syntax-table (syntax-table))))
                       (modify-syntax-entry ?_ "w" new-table)
                       new-table)
    (let ((word (current-word)))
      (nodup-ring-insert ajoke--marker-ring (point-marker))
      (ajoke--beginning-of-defun-function)
      (unless (string-equal (car regexp-search-ring) (concat "\\b" word "\\b"))
        (add-to-history
         'regexp-search-ring
         (concat "\\b" word "\\b")
         regexp-search-ring-max))
      (let ((not-match t))
        (while not-match
          (search-forward-regexp (concat "\\b" word "\\b"))
          (when (string-equal word (current-word))
            (setq not-match nil)))))))

(setq-default imenu-create-index-function #'ajoke--create-index-function)

(defun ajoke-insert-package ()
  "GUESS and insert the package name at the beginning of the file."
  (interactive)
  (let* ((dir (file-name-directory (buffer-file-name)))
         (package (replace-regexp-in-string ".*?/src/\\|/$" "" dir))
         (package (replace-regexp-in-string "/" "." package))
         (file (file-name-nondirectory (buffer-file-name)))
         (class (replace-regexp-in-string ".java$" "" file)))
    (goto-char (point-min))
    (insert "package " package ";\n")
    (insert "public class " class " {\n}\n")))

(defun ajoke--goto-start-of-try ()
  "Goto start of the preceeding try block"
  (backward-list)
  (while (not (string-match-p "try\\s *{" (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
    (backward-list)))

(defun ajoke-insert-exception-catchers ()
  "Find out what exceptions are being thrown out of the preceding try block"
  (interactive)
  (ajoke--setup-env)
  (save-excursion
    (let* ((try-start (save-excursion (ajoke--goto-start-of-try) (point)))
           (try-end (save-excursion (ajoke--goto-start-of-try) (forward-list) (point)))
           (exceptions (shell-command-to-string
                        (format "echo %s | ajoke-get-exceptions 2>~/.cache/system-config/logs/ajoke-get-exceptions.log"
                                (shell-quote-argument (buffer-substring-no-properties try-start try-end)))))
           (exceptions (split-string exceptions "\n"))
           (exceptions (cons "done" exceptions))
           (done nil))
      (while (not done)
        (indent-for-tab-command)
        (let ((ans (ajoke--pick-one "Which exception to catch?" exceptions nil t)))
          (if (string= ans "done")
              (progn
                (setq done t)
                (when (and (looking-at "catch (Exception e)")
                           (yes-or-no-p "Remove the old Exception catcher?"))
                  (let ((start (point))
                        (end (save-excursion
                               (forward-list)
                               (forward-list)
                               (point))))
                    (kill-region start end))))
            (setq exceptions (delete ans exceptions))
            (setq ans (replace-regexp-in-string " <- .*" "" ans))
            (just-one-space)
            (insert "catch (" ans " e) {\n")
            (indent-for-tab-command)
            (insert "Log.e(\"bhj\", String.format(\"%s:%d: \", \"" (bhj-file-basename) "\", " (number-to-string (line-number-at-pos)) "), e);\n")
            (indent-for-tab-command)
            (insert "}")
            (just-one-space)))))))

;;;###autoload
(defun ajoke-get-imports-if-java-mode ()
  "get imports if java-mode"
  (interactive)
  (when (and (eq major-mode 'java-mode) (not (file-remote-p (buffer-file-name))))
    (let ((before-save-hook nil))
      (save-buffer))
    (ajoke-get-imports)))

;;;###autoload
(defun ajoke--pick-output-line (prompt command &rest comp-read-args)
  (ajoke--pick-one
   prompt
   (split-string (shell-command-to-string command))
   comp-read-args))

;;;###autoload
(defun ajoke-find-file-using-beagrep ()
  (interactive)
  (let* ((init-input (read-from-minibuffer "The pattern of your file: ")))
    (find-file (ajoke--pick-output-line
                "Select the file you want: "
                (format "beagrep-glob-files %s" (shell-quote-argument init-input))))))

;;;###autoload
(defun ajoke-android-add-string ()
  (interactive)
  (let ((tag (bhj-grep-tag-default))
        (string-file (shell-command-to-string "lookup-file res/values/strings.xml")))
    (find-file (concat (file-remote-p (buffer-file-name)) string-file))
    (goto-char (point-max))
    (search-backward "/string")
    (move-end-of-line nil)
    (insert (format "\n<string name=\"%s\"></string>" tag))
    (search-backward "<")))

(defun ajoke-header-and-source ()
  (interactive)
  (let* ((current-file (bhj-file-basename))
         (target-file-name (file-name-sans-extension current-file)))
    (if (string-match ".cpp$\\|.c$" current-file)
        (if (file-exists-p (concat target-file-name ".h"))
            (find-file (concat target-file-name ".h"))
          (find-file (concat target-file-name ".hpp")))
      (if (file-exists-p (concat target-file-name ".cpp"))
          (find-file (concat target-file-name ".cpp"))
        (find-file (concat target-file-name ".c"))))))

(global-set-key [(meta g)(j)(p)] 'ajoke-insert-package)
(global-set-key [(meta g)(j)(i)] 'ajoke-get-imports)
(global-set-key [(control c)(i)(h)] 'ajoke-get-imports)
(global-set-key [(control c)(f)(s)] 'ajoke-header-and-source)
(global-set-key [(meta g) (h)] 'ajoke-header-and-source)
(global-set-key [(meta g)(j)(h)] 'ajoke-get-hierarchy)
(global-set-key [(meta g)(j)(o)] 'ajoke-get-override)
(global-set-key [(meta g)(j)(r)] 'ajoke-resolve)
(global-set-key [(meta g)(j)(m)] 'ajoke-complete-method)
(global-set-key [(meta g)(j)(e)] 'ajoke-insert-exception-catchers)
(global-set-key [(meta g)(j)(f)] 'ajoke-find-header)
(global-set-key [(shift meta s)] 'ajoke-search-local-id)
(global-set-key [(meta s)(f)] 'ajoke-find-file-using-beagrep)
(global-set-key [(meta s)(??)] 'ajoke-display-the-current-function)
;; the correct way to do it is to customize 'before-save-hook
;; (add-hook 'before-save-hook 'ajoke-get-imports-if-java-mode)

(provide 'ajoke)
