;;; paste-img.el --- Paste images from clipboard into org documents on macOS -*- lexical-binding: t -*-

;; Copyright (C) 2023 Duncan Britt

;; Author: Duncan Britt <dbru997@gmail.com>
;; URL: https://github.com/Duncan-Britt/paste-img
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.3") (org "9.6.15") (org-download "0.1.0"))
;; Keywords: multimedia, images, org-mode, macos

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This package extends org-download to allow pasting images directly
;; from the clipboard into org-mode documents on macOS.

;;; Code:

(require 'org)
(require 'org-download)

(defvar paste-img-clipboard-command "pngpaste"
  "Command used to get image data from clipboard on macOS.")

(defun paste-img-org-mode-p ()
  "Return T if major-mode or `derived-mode-p' equals 'org-mode, otherwise NIL."
  (or (eq major-mode 'org-mode) (when (derived-mode-p 'org-mode) t)))

(defun paste-img-get-image-from-clipboard ()
  "Retrieve image data from the clipboard on macOS."
  (when (executable-find paste-img-clipboard-command)
    (let ((temp-file (make-temp-file "clipboard-image-" nil ".png")))
      (when (zerop (call-process paste-img-clipboard-command nil nil nil temp-file))
        temp-file))))

(defun paste-img-save-image (temp-file final-filename)
  "Move image from TEMP-FILE to FINAL-FILENAME."
  (rename-file temp-file final-filename t))

(defun paste-img-from-clipboard ()
  "Paste an image from the clipboard into the current org document.
If the clipboard contains text, fall back to the default paste behavior."
  (interactive)
  (if (paste-img-org-mode-p)
      (let ((temp-file (paste-img-get-image-from-clipboard)))
        (if temp-file
            (let* ((final-filename (org-download--fullname temp-file))
                   (org-download-image-dir (org-download--dir)))
              (paste-img-save-image temp-file final-filename)
              (org-download-insert-link temp-file final-filename)
              (message "Image pasted successfully"))
          ;; If no image in clipboard, fall back to default paste
          (call-interactively 'paste-from-clipboard)))
    (call-interactively 'paste-from-clipboard)))

(defun paste-from-clipboard ()
  "Paste text from clipboard."
  (interactive)
  (yank))

;;;###autoload
(define-minor-mode paste-img-mode
  "Minor mode for pasting images from clipboard in org-mode."
  :lighter " PasteImg"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map [remap yank] #'paste-img-from-clipboard)
            map))

(provide 'paste-img)

;;; paste-img.el ends here
