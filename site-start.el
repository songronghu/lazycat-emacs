(require 'cl-lib)

(tool-bar-mode -1)                      ;禁用工具栏
(menu-bar-mode -1)                      ;禁用菜单栏
(scroll-bar-mode -1)                    ;禁用滚动条

(defun add-subdirs-to-load-path (search-dir)
  (interactive)
  (let* ((dir (file-name-as-directory search-dir)))
    (dolist (subdir (cl-remove-if
                     #'(lambda (subdir)
                         (or (member subdir '("." ".." "dist" "node_modules" "RCS" "CVS" "rcs" "cvs" "__pycache__" ".git" ".gitattributes" ".gitignore" ".gitmodules"))
                             (not (file-directory-p (concat dir subdir)))))
                     (directory-files dir)))
      (let ((subdir-path (concat dir (file-name-as-directory subdir))))
        (when (cl-some #'(lambda (subdir-file)
                           (and (file-regular-p (concat subdir-path subdir-file))
                                (member (file-name-extension subdir-file) '("el" "so" "dll"))))
                       (directory-files subdir-path))
          ;; NOTE:
          ;; We should add path to `load-path' by append, otherwise Emacs can't load expected.
          (add-to-list 'load-path subdir-path t))

        ;; Search subdirectories recursively.
        (add-subdirs-to-load-path subdir-path)))))

(add-subdirs-to-load-path "/usr/share/emacs/lazycat")

(require 'init)
