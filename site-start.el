(tool-bar-mode -1)                      ;禁用工具栏
(menu-bar-mode -1)                      ;禁用菜单栏
(scroll-bar-mode -1)                    ;禁用滚动条

(defun normal-top-level-add-subdirs-to-load-path ()
  "Recursively add all subdirectories of `default-directory' to `load-path'.
More precisely, this uses only the subdirectories whose names
start with letters or digits; it excludes any subdirectory named `RCS'
or `CVS', and any subdirectory that contains a file named `.nosearch'."
  (let (dirs
        attrs
        (pending (list default-directory)))
    ;; This loop does a breadth-first tree walk on DIR's subtree,
    ;; putting each subdir into DIRS as its contents are examined.
    (while pending
      (push (pop pending) dirs)
      (let* ((this-dir (car dirs))
             (contents (directory-files this-dir))
             (default-directory this-dir)
             (canonicalized (if (fboundp 'w32-untranslated-canonical-name)
                                (w32-untranslated-canonical-name this-dir))))
        ;; The Windows version doesn't report meaningful inode numbers, so
        ;; use the canonicalized absolute file name of the directory instead.
        (setq attrs (or canonicalized
                        (nthcdr 10 (file-attributes this-dir))))
        (unless (member attrs normal-top-level-add-subdirs-inode-list)
          (push attrs normal-top-level-add-subdirs-inode-list)
          (dolist (file contents)
            (and
             ;; NOTE:
             ;; Don't scan node_modules directories, such as EAF npm subdirectories.
             (not (string-match-p "/node_modules" this-dir))
             (not (string-match-p "/dist" this-dir))

             (string-match "\\`[[:alnum:]]" file)
             ;; The lower-case variants of RCS and CVS are for DOS/Windows.
             (not (member file '("RCS" "CVS" "rcs" "cvs")))
             (file-directory-p file)
             (let ((expanded (expand-file-name file)))
               (or (file-exists-p (expand-file-name ".nosearch" expanded))
                   (setq pending (nconc pending (list expanded))))))))))
    (normal-top-level-add-to-load-path (cdr (nreverse dirs)))))

(defun add-subdirs-to-load-path (dir)
  "Recursive add directories to `load-path'."
  (let ((default-directory (file-name-as-directory dir)))
    (add-to-list 'load-path dir)
    (normal-top-level-add-subdirs-to-load-path)
    (dolist (path load-path)
      (when (or (string-match-p "/node_modules" path)
                (string-match-p "/dist" path))
        (setq load-path (delete path load-path))))))

(add-subdirs-to-load-path "/usr/share/emacs/lazycat/")

(require 'init)
