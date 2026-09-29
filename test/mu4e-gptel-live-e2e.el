;;; mu4e-gptel-live-e2e.el --- Live API integration check -*- lexical-binding: t; -*-

;;; This test sends only the synthetic message below to the configured provider.

(require 'cl-lib)
(require 'gptel)
(require 'gptel-openai)
(require 'mu4e-gptel)

(defun mu4e-gptel-live-e2e--configured-key ()
  "Read the configured gptel key without printing it."
  (with-temp-buffer
    (insert-file-contents "~/.emacs.d/init.el")
    (goto-char (point-min))
    (search-forward "(use-package gptel")
    (search-forward "gptel-api-key")
    (skip-chars-forward " \t")
    (let ((key (read (current-buffer))))
      (unless (and (stringp key) (not (string-empty-p key)))
        (error "No literal gptel-api-key found in init.el"))
      key)))

(setq gptel-api-key (mu4e-gptel-live-e2e--configured-key)
      gptel-backend
      (gptel-make-openai "DeepSeek"
        :host "api.deepseek.com"
        :endpoint "/v1/chat/completions"
        :stream t
        :key 'gptel-api-key
        :models '(deepseek-flash))
      gptel-model 'deepseek-flash
      gptel-use-curl t
      gptel-stream t)

(let ((source (generate-new-buffer " *mu4e-gptel-e2e-source*"))
      (deadline (+ (float-time) 90))
      result)
  (unwind-protect
      (progn
        (cl-letf (((symbol-function 'mu4e-message-at-point)
                   (lambda (&optional _include-related) 'synthetic-message))
                  ((symbol-function 'mu4e-message-field)
                   (lambda (_message field)
                     (pcase field
                       (:subject "E2E synthetic email")
                       (:body (concat "This is a synthetic integration test email. "
                                      "The delivery code is E2E-OK. "
                                      "Please summarize the key point."))))))
          (with-current-buffer source
            (mu4e-view-mode)
            (mu4e-gptel-summarize)))
        (while (and (< (float-time) deadline)
                    (not (setq result
                               (get-buffer
                                "*mu4e-gptel: 摘要 E2E synthetic email*"))))
          (accept-process-output nil 0.25))
        (unless result
          (error "Timed out waiting for the live gptel response"))
        (with-current-buffer result
          (let ((response (buffer-substring-no-properties
                           (point-min) (point-max))))
            (unless (> (length (string-trim response)) 30)
              (error "The live response buffer is empty or too short"))
            (princ (format "E2E_PASS\n%s\n" response)))))
    (when (buffer-live-p result)
      (kill-buffer result))
    (when (buffer-live-p source)
      (kill-buffer source))))

;;; mu4e-gptel-live-e2e.el ends here
