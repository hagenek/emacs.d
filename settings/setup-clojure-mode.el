;;; clojure-mode.el --- Major mode for Clojure code -*- lexical-binding: t; -*-

(require 'clojure-mode)
(require 'clojure-mode-extra-font-locking)

;; To get linting, install joker:
;;
;;     brew install candid82/brew/joker
;;
(require 'flycheck-joker)

(defadvice clojure-test-run-tests (before save-first activate)
  (save-buffer))

(defadvice nrepl-load-current-buffer (before save-first activate)
  (save-buffer))

(require 'clj-refactor)

(setq cljr-favor-prefix-notation nil)
(setq cljr-favor-private-functions nil)
(setq cljr-insert-newline-after-require nil)
(setq cljr-assume-language-context "clj")

(cljr-add-keybindings-with-modifier "C-s-")
(define-key clj-refactor-map (kbd "C-x C-r") 'cljr-rename-file)

(defun clj-goto-toplevel ()
  (interactive)
  (cljr--goto-toplevel))

(define-key clojure-mode-map (kbd "C-S-M-u") 'clj-goto-toplevel)

(define-key clojure-mode-map (kbd "C-:") 'hippie-expand-lines)
(define-key clojure-mode-map (kbd "C-\"") 'clojure-toggle-keyword-string)

(define-key clojure-mode-map [remap paredit-forward] 'clojure-forward-logical-sexp)
(define-key clojure-mode-map [remap paredit-backward] 'clojure-backward-logical-sexp)

;; Don't tread the last one

(setq clojure-thread-all-but-last t)

(defun clojure--remove-superfluous-parens ()
  "Remove extra parens from a form."
  (when (looking-at "([^ )]+)")
    (let ((delete-pair-blink-delay 0))
      (delete-pair))))

;; Treat top level forms in comment forms as top level forms

(setq clojure-toplevel-inside-comment-form t)

;; Automatically download all available .jars with Java sources and javadocs -
;; allowing you to navigate to Java sources and javadocs in your Clojure
;; projects.

(setq cider-enrich-classpath nil) ;; don't do it, it's a trap! At least if you're using Datomic.

;; kaocha

(require 'kaocha-runner)

(defun kaocha-runner-run-relevant-tests ()
  (interactive)
  (when (cljr--project-depends-on-p "kaocha")
    (if (clj--is-test? (buffer-file-name))
        (kaocha-runner--run-tests
         (kaocha-runner--testable-sym (cider-current-ns) nil (eq major-mode 'clojurescript-mode))
         nil t)
      (let ((original-buffer (current-buffer)))
        (save-window-excursion
          (let* ((file (clj-other-file-name))
                 (alternative-file (clj-find-alternative-name file)))
            (cond
             ((file-exists-p file) (find-file file))
             ((file-exists-p alternative-file) (find-file alternative-file))))
          (when (clj--is-test? (buffer-file-name))
            (kaocha-runner--run-tests
             (kaocha-runner--testable-sym (cider-current-ns) nil (eq major-mode 'clojurescript-mode))
             nil t original-buffer)))))))

(add-hook 'cider-file-loaded-hook #'kaocha-runner-run-relevant-tests)

(define-key clojure-mode-map (kbd "<f5>") 'kaocha-runner-run-relevant-tests)

(define-key clojure-mode-map (kbd "C-c k t") 'kaocha-runner-run-test-at-point)
(define-key clojure-mode-map (kbd "C-c k r") 'kaocha-runner-run-tests)
(define-key clojure-mode-map (kbd "C-c k a") 'kaocha-runner-run-all-tests)
(define-key clojure-mode-map (kbd "C-c k w") 'kaocha-runner-show-warnings)
(define-key clojure-mode-map (kbd "C-c k h") 'kaocha-runner-hide-windows)

(require 'core-async-mode)

(defun enable-clojure-mode-stuff ()
  (clj-refactor-mode 1)
  (when (not (s-ends-with-p "/dev/user.clj" (buffer-file-name)))
    (core-async-mode 1)))

(add-hook 'clojure-mode-hook 'enable-clojure-mode-stuff)

(require 'symbol-focus)
(define-key clojure-mode-map (kbd "M-s-f") 'sf/focus-at-point)

(defun clj-duplicate-top-level-form ()
  (interactive)
  (save-excursion
    (cljr--goto-toplevel)
    (insert (cljr--extract-sexp) "\n")
    (cljr--just-one-blank-line)))

(define-key clojure-mode-map (kbd "M-s-d") 'clj-duplicate-top-level-form)

(add-to-list 'cljr-project-clean-functions 'cleanup-buffer)

(define-key clojure-mode-map (kbd "C->") 'cljr-thread)
(define-key clojure-mode-map (kbd "C-<") 'cljr-unwind)

(define-key clojure-mode-map (kbd "s-j") 'clj-jump-to-other-file)

(define-key clojure-mode-map (kbd "C-.") 'clj-hippie-expand-no-case-fold)

(defun clj-hippie-expand-no-case-fold ()
  (interactive)
  (let ((old-syntax (char-to-string (char-syntax ?/))))
    (modify-syntax-entry ?/ " ")
    (hippie-expand-no-case-fold)
    (modify-syntax-entry ?/ old-syntax)))

(require 'cider)

;; don't kill the REPL when printing large data structures
(setq cider-print-options
      '(("length" 80)
        ("level" 20)
        ("right-margin" 80)))

;; save files when evaluating them
(setq cider-save-file-on-load t)

;; work around logging issues, figwheel-main vs cider ... fight!
(defun cider-figwheel-workaround--boot-up-cljs ()
  (format "(boot-up-cljs %s)" cider-figwheel-main-default-options))

(cider-register-cljs-repl-type 'boot-up-cljs #'cider-figwheel-workaround--boot-up-cljs)


(define-key cider-repl-mode-map (kbd "<home>") nil)
(define-key cider-repl-mode-map (kbd "C-,") 'complete-symbol)
(define-key cider-repl-mode-map (kbd "M-s") nil)
(define-key cider-repl-mode-map (kbd "<return>") 'cider-repl-closing-return)
(define-key cider-mode-map (kbd "C-,") 'complete-symbol)
(define-key cider-mode-map (kbd "C-c C-q") 'nrepl-close)
(define-key cider-mode-map (kbd "C-c C-Q") 'cider-quit)

(defun cider-find-and-clear-repl-buffer ()
  (interactive)
  (cider-find-and-clear-repl-output t))

(define-key cider-mode-map (kbd "C-c C-l") 'cider-find-and-clear-repl-buffer)
(define-key cider-repl-mode-map (kbd "C-c C-l") 'cider-repl-clear-buffer)

(setq cljr-clojure-test-declaration "[clojure.test :refer [deftest is testing]]")
(setq cljr-cljs-clojure-test-declaration cljr-clojure-test-declaration)
(setq cljr-cljc-clojure-test-declaration cljr-clojure-test-declaration)

;; indent [quiescent.dom :as d] specially

(define-clojure-indent
 (forcat 1)
 (add-watch 2)
 (async 1))

;; Don't warn me about the dangers of clj-refactor, fire the missiles!
(setq cljr-warn-on-eval nil)

;; Use figwheel for cljs repl

(setq cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")

;; Indent and highlight more commands
(put-clojure-indent 'match 'defun)

;; Hide nrepl buffers when switching buffers (switch to by prefixing with space)
(setq nrepl-hide-special-buffers t)

;; Enable error buffer popping also in the REPL:
(setq cider-repl-popup-stacktraces t)

;; Specify history file
(setq cider-history-file "~/.emacs.d/nrepl-history")

;; auto-select the error buffer when it's displayed
(setq cider-auto-select-error-buffer t)

;; Prevent the auto-display of the REPL buffer in a separate window after connection is established
(setq cider-repl-pop-to-buffer-on-connect nil)

;; Pretty print results in repl
(setq cider-repl-use-pretty-printing t)

;; Don't prompt for symbols
(setq cider-prompt-for-symbol nil)

;; Enable eldoc in Clojure buffers
(add-hook 'cider-mode-hook #'eldoc-mode)

;; Some expectations features

(defun my-toggle-expect-focused ()
  (interactive)
  (save-excursion
    (search-backward "(expect" (cljr--point-after 'cljr--goto-toplevel))
    (forward-word)
    (if (looking-at "-focused")
        (paredit-forward-kill-word)
      (insert "-focused"))))

(defun my-remove-all-focused ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (search-forward "(expect-focused" nil t)
      (delete-char -8))))

(define-key clj-refactor-map (cljr--key-pairs-with-modifier "C-s-" "xf") 'my-toggle-expect-focused)
(define-key clj-refactor-map (cljr--key-pairs-with-modifier "C-s-" "xr") 'my-remove-all-focused)

;; Focus tests

(defun my-toggle-focused-test ()
  (interactive)
  (save-excursion
    (search-backward "(deftest " (cljr--point-after 'cljr--goto-toplevel))
    (forward-word)
    (if (looking-at " ^:test-refresh/focus")
        (kill-sexp)
      (insert " ^:test-refresh/focus"))))

(defun my-blur-all-tests ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (search-forward " ^:test-refresh/focus" nil t)
      (delete-region (match-beginning 0) (match-end 0)))))

(define-key clj-refactor-map
            (cljr--key-pairs-with-modifier "C-s-" "ft") 'my-toggle-focused-test)

(define-key clj-refactor-map
            (cljr--key-pairs-with-modifier "C-s-" "bt") 'my-blur-all-tests)

;; Cycle between () {} []

(defun live-delete-and-extract-sexp ()
  "Delete the sexp and return it."
  (interactive)
  (let* ((begin (point)))
    (forward-sexp)
    (let* ((result (buffer-substring-no-properties begin (point))))
      (delete-region begin (point))
      result)))

(defun live-cycle-clj-coll ()
  "convert the coll at (point) from (x) -> {x} -> [x] -> (x) recur"
  (interactive)
  (let* ((original-point (point)))
    (while (and (> (point) 1)
                (not (equal "(" (buffer-substring-no-properties (point) (+ 1 (point)))))
                (not (equal "{" (buffer-substring-no-properties (point) (+ 1 (point)))))
                (not (equal "[" (buffer-substring-no-properties (point) (+ 1 (point))))))
      (backward-char))
    (cond
     ((equal "(" (buffer-substring-no-properties (point) (+ 1 (point))))
      (insert "{" (substring (live-delete-and-extract-sexp) 1 -1) "}"))
     ((equal "{" (buffer-substring-no-properties (point) (+ 1 (point))))
      (insert "[" (substring (live-delete-and-extract-sexp) 1 -1) "]"))
     ((equal "[" (buffer-substring-no-properties (point) (+ 1 (point))))
      (insert "(" (substring (live-delete-and-extract-sexp) 1 -1) ")"))
     ((equal 1 (point))
      (message "beginning of file reached, this was probably a mistake.")))
    (goto-char original-point)))

(define-key clojure-mode-map (kbd "C-`") 'live-cycle-clj-coll)

;; Warn about missing nREPL instead of doing stupid things

(defun nrepl-warn-when-not-connected ()
  (interactive)
  (message "Oops! You're not connected to an nREPL server. Please run M-x cider or M-x cider-jack-in to connect."))

(define-key clojure-mode-map (kbd "C-M-x")   'nrepl-warn-when-not-connected)
(define-key clojure-mode-map (kbd "C-x C-e") 'nrepl-warn-when-not-connected)
(define-key clojure-mode-map (kbd "C-c C-e") 'nrepl-warn-when-not-connected)
(define-key clojure-mode-map (kbd "C-c C-l") 'nrepl-warn-when-not-connected)
(define-key clojure-mode-map (kbd "C-c C-z") 'nrepl-warn-when-not-connected)
(define-key clojure-mode-map (kbd "C-c C-k") 'nrepl-warn-when-not-connected)
(define-key clojure-mode-map (kbd "C-c C-n") 'nrepl-warn-when-not-connected)
(define-key clojure-mode-map (kbd "C-c C-p") 'nrepl-warn-when-not-connected)
(define-key clojure-mode-map (kbd "C-c C-q") 'nrepl-warn-when-not-connected)

(setq cljr-magic-require-namespaces
      '(("edn"  . "clojure.edn")
        ("io"   . "clojure.java.io")
        ("set"  . "clojure.set")
        ("str"  . "clojure.string")
        ("walk" . "clojure.walk")
        ("zip"  . "clojure.zip")
        ("time" . "clj-time.core")
        ("log"  . "clojure.tools.logging")
        ("json" . "cheshire.core")))

;; refer all from expectations

(setq cljr-expectations-test-declaration "[expectations :refer :all]")

;; Add requires to blank devcards files

(defun cljr--find-source-ns-of-devcard-ns (test-ns test-file)
  (let* ((ns-chunks (split-string test-ns "[.]" t))
         (test-name (car (last ns-chunks)))
         (src-dir-name (s-replace "devcards/" "src/" (file-name-directory test-file)))
         (replace-underscore (-partial 's-replace "_" "-"))
         (src-ns (car (--filter (or (s-prefix-p it test-name)
                                    (s-suffix-p it test-name))
                                (-map (lambda (file-name)
                                        (funcall replace-underscore
                                                 (file-name-sans-extension file-name)))
                                      (directory-files src-dir-name))))))
    (when src-ns
      (mapconcat 'identity (append (butlast ns-chunks) (list src-ns)) "."))))

(defun clj--find-devcards-component-name ()
  (or
   (ignore-errors
     (with-current-buffer
         (find-file-noselect (clj--src-file-name-from-cards (buffer-file-name)))
       (save-excursion
         (goto-char (point-max))
         (search-backward "defcomponent ")
         (clojure-forward-logical-sexp)
         (skip-syntax-forward " ")
         (let ((beg (point))
               (end (progn (re-search-forward "\\w+")
                           (point))))
           (buffer-substring-no-properties beg end)))))
   ""))

(defun cljr--add-card-declarations ()
  (save-excursion
    (let* ((ns (clojure-find-ns))
           (source-ns (cljr--find-source-ns-of-devcard-ns ns (buffer-file-name))))
      (cljr--insert-in-ns ":require")
      (when source-ns
        (insert "[" source-ns " :refer [" (clj--find-devcards-component-name) "]]"))
      (cljr--insert-in-ns ":require")
      (insert (if (cljr--project-depends-on-p "reagent")
                  "[devcards.core :refer-macros [defcard-rg]]"
                "[devcards.core :refer-macros [defcard]]")))
    (indent-region (point-min) (point-max))))

;; Add requires to blank portfolio scenes

(defun cljr--find-source-ns-of-portfolio-ns (test-ns test-file)
  (let* ((ns-chunks (split-string test-ns "[.]" t))
         (test-name (car (last ns-chunks)))
         (src-dir-name (s-replace "portfolio/" "ui/" (file-name-directory test-file)))
         (replace-underscore (-partial 's-replace "_" "-"))
         (src-ns (car (--filter (or (s-prefix-p it test-name)
                                    (s-suffix-p it test-name))
                                (-map (lambda (file-name)
                                        (funcall replace-underscore
                                                 (file-name-sans-extension file-name)))
                                      (directory-files src-dir-name))))))
    (when src-ns
      (mapconcat 'identity (append (butlast ns-chunks) (list src-ns)) "."))))

(defun clj--find-portfolio-component-name ()
  (or
   (ignore-errors
     (with-current-buffer
         (find-file-noselect (clj--src-file-name-from-scenes (buffer-file-name)))
       (save-excursion
         (goto-char (point-max))
         (re-search-backward "defcomponent\\|defn")
         (clojure-forward-logical-sexp)
         (skip-syntax-forward " ")
         (let ((beg (point))
               (end (progn (re-search-forward "\\w+")
                           (point))))
           (buffer-substring-no-properties beg end)))))
   ""))

(defun cljr--add-scene-declarations ()
  (save-excursion
    (let* ((ns (clojure-find-ns))
           (source-ns (cljr--find-source-ns-of-portfolio-ns ns (buffer-file-name))))
      (cljr--insert-in-ns ":require")
      (when source-ns
        (insert "[" source-ns " :refer [" (clj--find-portfolio-component-name) "]]"))
      (cljr--insert-in-ns ":require")
      (insert (if (cljr--project-depends-on-p "reagent")
                  "[portfolio.reagent :as portfolio :refer [defscene]]"
                "[portfolio.dumdom :as portfolio :refer [defscene]]")))
    (indent-region (point-min) (point-max))))

(defun cljr--add-ns-if-blank-clj-file ()
  (when (and cljr-add-ns-to-blank-clj-files
             (cljr--clojure-ish-filename-p (buffer-file-name))
             (= (point-min) (point-max)))
    (insert (format "(ns %s)\n\n" (->> (clojure-expected-ns)
                                       (s-chop-prefix "src.")
                                       (s-chop-prefix "test."))))
    (when (cljr--in-tests-p)
      (cljr--add-test-declarations))
    (when (clj--is-card? (buffer-file-name))
      (cljr--add-card-declarations))
    (when (clj--is-scene? (buffer-file-name))
      (cljr--add-scene-declarations))))

(defun clojure-mode-indent-top-level-form (&optional cleanup-buffer?)
  (interactive "P")
  (if cleanup-buffer?
      (cleanup-buffer)
    (save-excursion
      (cljr--goto-toplevel)
      (indent-region (point)
                     (progn (paredit-forward) (point))))))

(define-key clojure-mode-map (vector 'remap 'cleanup-buffer) 'clojure-mode-indent-top-level-form)

(defun clojure-mode-paredit-wrap (pre post)
  (unless (looking-back "[ #\(\[\{]" 1)
    (insert " "))
  (let ((beg (point))
        (end nil))
    (insert pre)
    (save-excursion
      (clojure-forward-logical-sexp 1)
      (insert post)
      (setq end (point)))
    (indent-region beg end)))

(defun clojure-mode-paredit-wrap-square ()
  (interactive)
  (clojure-mode-paredit-wrap "[" "]"))

(defun clojure-mode-paredit-wrap-round ()
  (interactive)
  (clojure-mode-paredit-wrap "(" ")"))

(defun clojure-mode-paredit-wrap-curly ()
  (interactive)
  (clojure-mode-paredit-wrap "{" "}"))

(defun clojure-mode-paredit-wrap-round-from-behind ()
  (interactive)
  (clojure-backward-logical-sexp 1)
  (clojure-mode-paredit-wrap "(" ")"))

(define-key clojure-mode-map (vector 'remap 'paredit-wrap-round) 'clojure-mode-paredit-wrap-round)
(define-key clojure-mode-map (vector 'remap 'paredit-wrap-square) 'clojure-mode-paredit-wrap-square)
(define-key clojure-mode-map (vector 'remap 'paredit-wrap-curly) 'clojure-mode-paredit-wrap-curly)
(define-key clojure-mode-map (vector 'remap 'paredit-wrap-round-from-behind) 'clojure-mode-paredit-wrap-round-from-behind)

(defun cider-switch-to-any-repl-buffer (&optional set-namespace)
  "Switch to current REPL buffer, when possible in an existing window.
The type of the REPL is inferred from the mode of current buffer.  With a
prefix arg SET-NAMESPACE sets the namespace in the REPL buffer to that of
the namespace in the Clojure source buffer"
  (interactive "P")
  (or (ignore-errors
        (cider--switch-to-repl-buffer
         (cider-current-repl "any" t)
         set-namespace))
      (cider--switch-to-repl-buffer
       (concat "*cider-repl " (car (sesman-current-session 'CIDER)) "(clj)*")
       set-namespace)))

(define-key clojure-mode-map (kbd "C-c z") 'cider-switch-to-any-repl-buffer)

;; Make q quit out of find-usages to previous window config

(defadvice cljr-find-usages (before setup-grep activate)
  (window-configuration-to-register ?$))

;; ------------

;; TODO: Loot more stuff from:
;;  - https://github.com/overtone/emacs-live/blob/master/packs/dev/clojure-pack/config/paredit-conf.el

;; eval-current-sexp while also including any surrounding lets with C-x M-e

(defun my/cider-looking-at-lets? ()
  (or (looking-at "(let ")
      (looking-at "(letfn ")
      (looking-at "(when-let ")
      (looking-at "(if-let ")))

(defun my/cider-collect-lets (&optional max-point)
  (let* ((beg-of-defun (save-excursion (beginning-of-defun) (point)))
         (lets nil))
    (save-excursion
      (while (not (= (point) beg-of-defun))
        (paredit-backward-up 1)
        (when (my/cider-looking-at-lets?)
          (save-excursion
            (let ((beg (point)))
              (paredit-forward-down 1)
              (paredit-forward 2)
              (when (and max-point (< max-point (point)))
                (goto-char max-point))
              (setq lets (cons (concat (buffer-substring-no-properties beg (point))
                                       (if max-point "]" ""))
                               lets))))))
      lets)))

(defun my/inside-let-block? ()
  (save-excursion
    (paredit-backward-up 2)
    (my/cider-looking-at-lets?)))

(defun my/cider-eval-including-lets (&optional output-to-current-buffer)
  "Evaluates the current sexp form, wrapped in all parent lets."
  (interactive "P")
  (let* ((beg-of-sexp (save-excursion (paredit-backward 1) (point)))
         (code (buffer-substring-no-properties beg-of-sexp (point)))
         (lets (my/cider-collect-lets (when (my/inside-let-block?)
                                        (save-excursion (paredit-backward 2) (point)))))
         (code (concat (s-join " " lets)
                       " " code
                       (s-repeat (length lets) ")"))))
    (cider-interactive-eval code
                            (when output-to-current-buffer
                              (cider-eval-print-handler))
                            nil
                            (cider--nrepl-pr-request-map))))

(define-key clojure-mode-map (kbd "C-x M-e") 'my/cider-eval-including-lets)

(defun my/clojure-should-unwind-once? ()
  (save-excursion
    (ignore-errors
      (when (looking-at "(")
        (forward-char 1)
        (forward-sexp 1)))
    (let ((forms nil))
      (while (not (looking-at ")"))
        (clojure-forward-logical-sexp)
        (clojure-backward-logical-sexp)
        (setq forms (cons (buffer-substring-no-properties (point) (+ 1 (point))) forms))
        (clojure-forward-logical-sexp))
      (and (--any? (s-equals? it "(") forms)
           (< 2 (length forms))))))

(defun clojure--thread-all (first-or-last-thread but-last)
  "Fully thread the form at point.

FIRST-OR-LAST-THREAD is \"->\" or \"->>\".

When BUT-LAST is non-nil, the last expression is not threaded.
Default value is `clojure-thread-all-but-last'."
  (save-mark-and-excursion
    (save-excursion
      (insert-parentheses 1)
      (insert first-or-last-thread))
    (while (save-excursion (clojure-thread)))
    (when (my/clojure-should-unwind-once?)
      (clojure-unwind))))

(font-lock-add-keywords 'clojure-mode
                        `((,(concat "(\\(?:" clojure--sym-regexp "/\\)?"
                                    "\\(\\(?:.+/\\)?def[^a ][^ ]*\\)\\>")
                           1 font-lock-keyword-face)))

(font-lock-add-keywords 'clojurescript-mode
                        `((,(concat "(\\(?:" clojure--sym-regexp "/\\)?"
                                    "\\(\\(?:.+/\\)?def[^a ][^ ]*\\)\\>")
                           1 font-lock-keyword-face)))

;; Jet

(require 'jet)

(defun copy-edn-as-json ()
  (interactive)
  (jet-to-clipboard
   (jet--thing-at-point)
   '("--from=edn" "--to=json"))
  (deactivate-mark))

(defun copy-json-as-edn ()
  (interactive)
  (jet-to-clipboard
   (jet--thing-at-point)
   '("--from=json" "--to=edn" "--keywordize"))
  (deactivate-mark))

(global-set-key (kbd "C-c j e j") 'copy-edn-as-json)
(global-set-key (kbd "C-c j j e") 'copy-json-as-edn)

(provide 'setup-clojure-mode)
