# mu4e-gptel

Small mu4e commands that use the already-configured gptel backend to process
the message currently open in mu4e. It adds no model or HTTP client dependency.

## Commands

Open a message in mu4e, then use:

- `C-c g s` — summarize in Simplified Chinese
- `C-c g t` — translate (prompts for the target language)
- `C-c g r` — draft a reply in the original message's language

Summary and translation open in read-only result buffers. Reply text is inserted
at the top of a normal mu4e reply draft; it is never sent automatically.

## Setup

This project expects mu4e and gptel to be installed and configured already. Add
the project to `load-path` and install its mu4e key bindings:

```elisp
(add-to-list 'load-path "~/code/mu4e-gptel")
(with-eval-after-load 'mu4e-view
  (require 'mu4e-gptel)
  (mu4e-gptel-setup))
```

The commands use the current message's body and gptel backend/model from the
mu4e view buffer. Configure DeepSeek or another remote provider through gptel
as usual; this project does not store API keys or change your gptel settings.

## Scope and privacy

Only the currently open message's text body is sent; attachments and other
messages in the thread are not included. Email bodies are treated as untrusted
prompt content. The text is sent to whichever provider is configured in gptel,
so do not use the commands on messages that must remain local or confidential.

## Test

```sh
emacs --batch -Q \
  -L /usr/share/emacs/site-lisp/elpa/mu4e-1.12.9 \
  -L "$HOME/.emacs.d/elpa/gptel-20260919.1615" \
  -L . -l test/mu4e-gptel-test.el -f ert-run-tests-batch-and-exit
```

To make a live API request using only the synthetic message in the test file,
run `emacs --batch` with the mu4e and gptel load paths above and load
`test/mu4e-gptel-live-e2e.el`. This requires network access and a configured
DeepSeek key in `~/.emacs.d/init.el`.
