;;; paste-img-tests.el --- Tests for paste-img

(require 'ert)
(require 'paste-img)

(ert-deftest paste-img-test-org-mode-p ()
  "Test the paste-img-org-mode-p function."
  (with-temp-buffer
    (org-mode)
    (should (paste-img-org-mode-p)))
  (with-temp-buffer
    (fundamental-mode)
    (should-not (paste-img-org-mode-p))))

(ert-deftest paste-img-test-get-image-from-clipboard ()
  "Test the paste-img-get-image-from-clipboard function."
  (skip-unless (executable-find paste-img-clipboard-command))
  (let ((temp-file (paste-img-get-image-from-clipboard)))
    (should (or (null temp-file)
                (and)
                (file-exists-p temp-file)))))

(ert-deftest paste-img-test-save-image ()
  "Test the paste-img-save-image function."
  (let ((temp-file (make-temp-file "test-image-" nil ".png"))
        (final-file (make-temp-file "final-image-" nil ".png")))
    (with-temp-file temp-file
      (insert "test image content"))
    (paste-img-save-image temp-file final-file)
    (should (file-exists-p final-file))
    (should-not (file-exists-p temp-file))
    (delete-file final-file)))

(provide 'paste-img-tests)

;;; paste-img-tests.el ends here
