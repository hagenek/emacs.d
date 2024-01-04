(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(bug-reference-bug-regexp "klajwfp9812p3ulaksdjfads")
 '(connection-local-criteria-alist
   '(((:application tramp :protocol "flatpak")
      tramp-flatpak-connection-local-default-profile)
     ((:application tramp :protocol "kubernetes")
      tramp-kubernetes-connection-local-default-profile)
     d
     ((:application tramp :machine "localhost")
      tramp-connection-local-darwin-ps-profile)
     ((:application tramp :machine "Magnars-MacBook-Pro.local")
      tramp-connection-local-darwin-ps-profile)
     ((:application tramp) tramp-connection-local-default-system-profile
      tramp-connection-local-default-shell-profile)
     ((:application eshell) eshell-connection-default-profile)))
 '(connection-local-profile-alist
   '((tramp-flatpak-connection-local-default-profile
      (tramp-remote-path "/app/bin" tramp-default-remote-path "/bin" "/usr/bin"
                         "/sbin" "/usr/sbin" "/usr/local/bin" "/usr/local/sbin"
                         "/local/bin" "/local/freeware/bin" "/local/gnu/bin"
                         "/usr/freeware/bin" "/usr/pkg/bin" "/usr/contrib/bin"
                         "/opt/bin" "/opt/sbin" "/opt/local/bin"))
     (tramp-kubernetes-connection-local-default-profile
      (tramp-config-check . tramp-kubernetes--current-context-data)
      (tramp-extra-expand-args 97
                               (tramp-kubernetes--container
                                (car tramp-current-connection))
                               104
                               (tramp-kubernetes--pod
                                (car tramp-current-connection))
                               120
                               (tramp-kubernetes--context-namespace
                                (car tramp-current-connection))))
     (tramp-connection-local-darwin-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o"
                                        "pid,uid,user,gid,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                        "-o" "state=abcde" "-o"
                                        "ppid,pgid,sess,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etime,pcpu,pmem,args")
      (tramp-process-attributes-ps-format (pid . number) (euid . number)
                                          (user . string) (egid . number)
                                          (comm . 52) (state . 5)
                                          (ppid . number) (pgrp . number)
                                          (sess . number) (ttname . string)
                                          (tpgid . number) (minflt . number)
                                          (majflt . number)
                                          (time . tramp-ps-time) (pri . number)
                                          (nice . number) (vsize . number)
                                          (rss . number) (etime . tramp-ps-time)
                                          (pcpu . number) (pmem . number) (args)))
     (tramp-connection-local-busybox-ps-profile
      (tramp-process-attributes-ps-args "-o"
                                        "pid,user,group,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                        "-o" "stat=abcde" "-o"
                                        "ppid,pgid,tty,time,nice,etime,args")
      (tramp-process-attributes-ps-format (pid . number) (user . string)
                                          (group . string) (comm . 52)
                                          (state . 5) (ppid . number)
                                          (pgrp . number) (ttname . string)
                                          (time . tramp-ps-time) (nice . number)
                                          (etime . tramp-ps-time) (args)))
     (tramp-connection-local-bsd-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o"
                                        "pid,euid,user,egid,egroup,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                        "-o"
                                        "state,ppid,pgid,sid,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etimes,pcpu,pmem,args")
      (tramp-process-attributes-ps-format (pid . number) (euid . number)
                                          (user . string) (egid . number)
                                          (group . string) (comm . 52)
                                          (state . string) (ppid . number)
                                          (pgrp . number) (sess . number)
                                          (ttname . string) (tpgid . number)
                                          (minflt . number) (majflt . number)
                                          (time . tramp-ps-time) (pri . number)
                                          (nice . number) (vsize . number)
                                          (rss . number) (etime . number)
                                          (pcpu . number) (pmem . number) (args)))
     (tramp-connection-local-default-shell-profile (shell-file-name . "/bin/sh")
                                                   (shell-command-switch . "-c"))
     (tramp-connection-local-default-system-profile (path-separator . ":")
                                                    (null-device . "/dev/null"))
     (eshell-connection-default-profile (eshell-path-env-list))))
 '(custom-safe-themes
   '("9527feeeec43970b1d725bdc04e97eb2b03b15be982ac50089ad223d3c6f2920"
     "c03d60937e814932cd707a487676875457e0b564a615c1edfd453f23b06fe879"
     "f3ec2da81c2b1f66f911fe47843a09055754b40fafaddcce79bbd4d781161329"
     "30c6aef3025cd6f05ccb611ec8838a448a14a6784987ed98b24f78916d63b388"
     "84ff07913c6109d12bfda40644daeaaa8f4665afb5f04e13e422bd98b02ee88b"
     "cf33119622dd833e4d8f904f34c5e3ff95d1d3d45bada72dd44648b3470bdebe"
     "f5776f3da6117901f29405fe52edb2bcba6a687629b4cbd5923d1a642484f2f9"
     "d56e289b10204629ac5c35b9621a650a534ef3baf183a1c601b4936482321df1"
     "50ceca952b37826e860867d939f879921fac3f2032d8767d646dd4139564c68a"
     "ff73e1b0216feca9e041dcb3196938442cc6aa8319f97eedbc2a3e38c8ca9825"
     "a18dd0a954ac63a80e62c8cb1b550ffcf5d8461189c7c672555faadf2facfcf3"
     "cb36f8e44d41595010baa23737984c4ecb2d8cc2e363ec15fbfa0408c2f8ea9f"
     "ea0c5df0f067d2e3c0f048c1f8795af7b873f5014837feb0a7c8317f34417b04"
     "9f42bccce1e13fa5017eb8718574db099e85358b9f424db78e7318f86d1be08f" default))
 '(forge-bug-reference-hooks nil)
 '(ido-use-filename-at-point nil)
 '(package-selected-packages
   '(angular-snippets avy browse-kill-ring buster-snippets cargo change-inner
                      clj-refactor clojure-mode-extra-font-locking consult
                      css-eldoc datomic-snippets deadgrep diff-hl
                      dockerfile-mode edn elisp-slime-nav exec-path-from-shell
                      fill-column-indicator find-file-in-project flx-ido
                      flycheck-joker flycheck-pos-tip flycheck-rust forge gist
                      groovy-mode highlight-escape-sequences htmlize
                      ido-at-point ido-completing-read+ ido-vertical-mode jet
                      jump-char kaocha-runner lsp-mode lsp-ui marginalia
                      move-text multifiles nodejs-repl orderless perspective
                      prodigy projectile request restclient ripgrep rustic
                      simple-httpd smart-forward smartparens smex sqlite3
                      string-edit-at-point tagedit vertico visual-regexp wgrep
                      whitespace-cleanup-mode zprint-mode))
 '(safe-local-variable-values
   '((eval font-lock-add-keywords nil
           '(("defexamples\\|def-example-group\\| => "
              (0 'font-lock-keyword-face))
             ("(defexamples[[:blank:]]+\\(.*\\)"
              (1 'font-lock-function-name-face))))
     (eval font-lock-add-keywords nil
           '(("defexamples\\|def-example-group\\| => "
              (0 'font-lock-keyword-face))))
     (eval when
           (and (buffer-file-name) (file-regular-p (buffer-file-name))
                (string-match-p "^[^.]" (buffer-file-name)))
           (emacs-lisp-mode))
     (eval font-lock-add-keywords nil
           '(("defexamples\\| => " (0 'font-lock-keyword-face))))
     (encoding . utf-8))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(highlight ((t (:background "dark magenta"))))
 '(js2-error-face ((t nil)) t)
 '(js2-warning-face ((t nil)) t))
