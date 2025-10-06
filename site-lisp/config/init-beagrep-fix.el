;;; init-beagrep-fix.el --- Complete fix for beagrep, grep-func-call and grep-beatags

(require 'compile)
(require 'grep)

;; 处理带 Entering directory 的跳转
(defun grep-with-entering-dir-jump ()
  "Jump for grep output with 'Entering directory' format."
  (interactive)
  (let ((line (buffer-substring-no-properties
                (line-beginning-position)
                (line-end-position)))
        (current-dir nil))
    ;; 查找 Entering directory
    (save-excursion
      (when (re-search-backward "Entering directory [`']\\(.+\\)'" nil t)
        (setq current-dir (match-string 1))))
    ;; 解析文件名和行号
    (when (string-match "^\\([^:]+\\):\\([0-9]+\\):" line)
      (let* ((filename (match-string 1 line))
             (line-num (string-to-number (match-string 2 line)))
             ;; 构建完整路径
             (full-path
               (cond
                 ;; 如果是绝对路径，直接使用
                 ((file-name-absolute-p filename)
                  filename)
                 ;; 如果有 current-dir，拼接路径
                 (current-dir
                   ;; 先尝试直接拼接
                   (let ((path1 (expand-file-name filename current-dir)))
                     (if (file-exists-p path1)
                       path1
                       ;; grep-beatags 的特殊情况：文件路径可能是相对于 Entering directory 的
                       ;; 例如：drama-notice-manage/src/... 相对于 /home/.../drama-server
                       (let ((path2 (concat current-dir "/" filename)))
                         (if (file-exists-p path2)
                           path2
                           ;; 都不存在，返回 path2 供错误提示
                           path2)))))
                 ;; 默认情况
                 (t filename))))
        (if (file-exists-p full-path)
          (progn
            (find-file-other-window full-path)
            (goto-char (point-min))
            (forward-line (1- line-num))
            (message "Jumped to %s:%d" (file-name-nondirectory full-path) line-num))
          ;; 文件不存在时，尝试使用 beagrep 查找
          (message "File not found: %s, trying beagrep..." full-path)
          (let* ((file-base (file-name-nondirectory filename))
                 (found-files (split-string
                                (shell-command-to-string
                                  (format "beagrep -f -e %s 2>/dev/null | grep %s"
                                          (shell-quote-argument file-base)
                                          (shell-quote-argument file-base)))
                                "\n" t)))
            (when found-files
              (let ((selected (if (= (length found-files) 1)
                                (car found-files)
                                (completing-read "Select file: " found-files nil t))))
                (find-file-other-window selected)
                (goto-line line-num)))))))))

;; 智能跳转函数
(defun smart-grep-jump ()
  "Smart jump for grep modes."
  (interactive)
  (cond
    ;; 有 Entering directory 的格式
    ((save-excursion
       (goto-char (point-min))
       (re-search-forward "Entering directory" nil t))
     (grep-with-entering-dir-jump))
    ;; 普通 beagrep，使用默认
    (t
      (compile-goto-error))))

;; 手动修复函数
(defun fix-grep-keys ()
  "Manually fix grep keys in current buffer."
  (interactive)
  (if (derived-mode-p 'grep-mode)
    (progn
      (local-set-key (kbd "RET") 'smart-grep-jump)
      (local-set-key [return] 'smart-grep-jump)
      (local-set-key (kbd "C-m") 'smart-grep-jump)
      (local-set-key [mouse-2] 'smart-grep-jump)
      (message "Keys fixed for %s! RET now calls smart-grep-jump" (buffer-name)))
    (message "Not in a grep buffer")))

;; 测试函数
(defun test-grep-jump ()
  "Test the jump logic without actually jumping."
  (interactive)
  (let ((line (buffer-substring-no-properties
                (line-beginning-position)
                (line-end-position)))
        (current-dir nil))
    (save-excursion
      (when (re-search-backward "Entering directory [`']\\(.+\\)'" nil t)
        (setq current-dir (match-string 1))))
    (if (string-match "^\\([^:]+\\):\\([0-9]+\\):" line)
      (let* ((filename (match-string 1 line))
             (line-num (match-string 2 line))
             (path1 (when current-dir (expand-file-name filename current-dir)))
             (path2 (when current-dir (concat current-dir "/" filename))))
        (message "Line: %s\nDir: %s\nFile: %s\nPath1: %s (exists: %s)\nPath2: %s (exists: %s)"
                 line current-dir filename
                 path1 (file-exists-p path1)
                 path2 (file-exists-p path2)))
      (message "Current line doesn't match pattern"))))

;; 全局快捷键
(global-set-key (kbd "C-c g f") 'fix-grep-keys)
(global-set-key (kbd "C-c g t") 'test-grep-jump)

;; 自动设置
(defun auto-fix-grep-keys ()
  "Auto fix grep keys."
  (when (and (derived-mode-p 'grep-mode)
             (or (string-match "grep" (buffer-name))
                 (string-match "beatags" (buffer-name))))
    (fix-grep-keys)
    (run-with-idle-timer
      0.5 nil
      (lambda (buf)
        (when (buffer-live-p buf)
          (with-current-buffer buf
                               (fix-grep-keys))))
      (current-buffer))))

(add-hook 'after-change-major-mode-hook 'auto-fix-grep-keys)
(add-hook 'grep-mode-hook 'auto-fix-grep-keys t)

;; 修复 minibuffer 问题
(with-eval-after-load 'ajoke
                      (when (fboundp 'ajoke--setup-env)
                        (advice-add 'ajoke--setup-env :around
                                    (lambda (orig-fun &rest args)
                                      "Fix environment setup when in minibuffer."
                                      (if (minibufferp)
                                        (with-current-buffer (window-buffer (minibuffer-selected-window))
                                                             (apply orig-fun args))
                                        (apply orig-fun args))))))

(provide 'init-beagrep-fix)
