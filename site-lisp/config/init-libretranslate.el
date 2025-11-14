;; -*- lexical-binding: t; -*-

(require 'posframe)
(require 'json)
(require 'url)

(defun libretranslate-posframe-show (translated start end)
  "在选中区域附近显示 TRANSLATED 翻译结果。"
  (let* ((region-center (if (and start end)
                            (+ start (/ (- end start) 2))
                          (point)))
         (x-offset -30)   ;; 水平偏移，可微调
         (y-offset -45) ;; 垂直偏移，负值向上，正值向下
         (poshandler
          (lambda (info)
            (cons (+ (car (posframe-poshandler-point-bottom-left-corner info)) x-offset)
                  (+ (cdr (posframe-poshandler-point-bottom-left-corner info)) y-offset)))))
    (posframe-show
     "libretranslate-frame"
     :string (format "🌐%s" translated)
     :position region-center
     :poshandler poshandler
     ;;:timeout 4
     :background-color "#f0f4f8"  ;; 浅灰蓝色背景
     :foreground-color "#333333"  ;; 深灰文字，阅读舒适
     :border-width 1
     :border-color "#89b4fa"
     :internal-border-width 8
     :max-width (min 80 (round (* (frame-width) 0.8))) ;; 自动适配宽度
     :max-height (min 30 (round (* (frame-height) 0.6)))))) ;; 自动适配高度
     ;;:max-width 70
     ;;:max-height 15)))

(defun libretranslate-translate-region (start end source-lang target-lang)
  "Translate the selected text from SOURCE-LANG to TARGET-LANG using LibreTranslate,
and show the result in a floating posframe near the selection."
  (interactive
   (list (region-beginning)
         (region-end)
         (read-string "Source language (e.g. en): " "en")
         (read-string "Target language (e.g. zh): " "zh")))
  (let* ((text (buffer-substring-no-properties start end))
         (url "http://localhost:5000/translate")
         (url-request-method "POST")
         (url-request-extra-headers '(("Content-Type" . "application/json")))
         (url-request-data
          (encode-coding-string
           (json-encode `(("q" . ,text)
                          ("source" . ,source-lang)
                          ("target" . ,target-lang)))
           'utf-8)))
    (url-retrieve
     url
     (lambda (_status)
       (goto-char (point-min))
       (re-search-forward "\n\n")
       (let* ((raw (buffer-substring-no-properties (point) (point-max)))
              (json-text (decode-coding-string raw 'utf-8))
              (json-object-type 'alist)
              (json (json-read-from-string json-text))
              (translated (cdr (assq 'translatedText json))))
         (kill-new translated)
         (libretranslate-posframe-show translated start end)
         ;;(message "translate result: %s" translated)
         )))))

(defun translate (start end)
  "Translate selected English text to Chinese using LibreTranslate."
  (interactive "r")
  (libretranslate-translate-region start end "en" "zh"))

(defun libretranslate-posframe-hide ()
  "手动关闭翻译浮窗。"
  (interactive)
  (posframe-hide "libretranslate-frame"))

(global-set-key (kbd "C-c e") #'translate)
(global-set-key (kbd "C-g") #'libretranslate-posframe-hide)

(provide 'init-libretranslate)
