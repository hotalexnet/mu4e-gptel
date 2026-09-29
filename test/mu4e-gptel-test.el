;;; mu4e-gptel-test.el --- Tests for mu4e-gptel -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'gptel)
(require 'gptel-openai)
(require 'mu4e-gptel)

(ert-deftest mu4e-gptel-prompt-keeps-subject-and-body ()
  (let ((prompt (mu4e-gptel--prompt "Summarize" "Project update" "Ship Friday")))
    (should (string-match-p "Subject: Project update" prompt))
    (should (string-match-p "Ship Friday" prompt))
    (should (string-match-p "untrusted content" prompt))))

(ert-deftest mu4e-gptel-requires-message-view ()
  (with-temp-buffer
    (should-error (mu4e-gptel--current-message) :type 'user-error)))

(ert-deftest mu4e-gptel-falls-back-to-rendered-view-body ()
  (with-temp-buffer
    (insert "From: sender@example.test\nSubject: Synthetic\n\nRendered body text")
    (mu4e-view-mode)
    (cl-letf (((symbol-function 'mu4e-message-at-point)
               (lambda (&optional _noerror) 'synthetic-message))
              ((symbol-function 'mu4e-message-field)
               (lambda (_message field)
                 (when (eq field :subject) "Synthetic"))))
      (should (equal (plist-get (mu4e-gptel--current-message) :body)
                     "Rendered body text")))))

(ert-deftest mu4e-gptel-joins-streamed-response-before-callback ()
  (let (request-callback result)
    (cl-letf (((symbol-function 'gptel-request)
               (lambda (&rest args)
                 (setq request-callback (plist-get (cdr args) :callback)))))
      (mu4e-gptel--request "prompt" nil (lambda (response)
                                          (setq result response)))
      (funcall request-callback "first " '(:stream t))
      (funcall request-callback "second" '(:stream t))
      (should-not result)
      (funcall request-callback t '(:stream t :status "HTTP/2 200"))
      (should (equal result "first second")))))

(provide 'mu4e-gptel-test)
;;; mu4e-gptel-test.el ends here
