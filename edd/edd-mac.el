;; certain builds do otherwise
;;
(setq mac-option-modifier 'meta
      mac-command-modifier 'super)

;; Mac OS requires messing with the path
;;
(dolist (dir '("/usr/local/bin" "~/bin" "/usr/local/MacGPG2/bin" "~/.nix-profile/bin"))
  (when (file-directory-p dir)
    (setenv "PATH" (concat (expand-file-name dir) ":" (getenv "PATH")))
    (add-to-list 'exec-path (expand-file-name dir))))


;; Use the mac gpg2 equiv
;;
(when (executable-find "gpg2")
  (setq epg-gpg-program "gpg2"))


;; Use homebrew's scalastyle
;;
(eval-after-load "flycheck"
  (setq flycheck-scalastyle-jar "/usr/local/Cellar/scalastyle/0.8.0/libexec/scalastyle_2.11-0.8.0-batch.jar"))

;; Use mdfind not locate
;;
(eval-after-load "helm"
  (setq helm-locate-command "mdfind -name %s %s"))


;; EMOJE
;;
(set-fontset-font t 'unicode "Apple Color Emoji" nil 'prepend)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (set-fontset-font t 'unicode "Apple Color Emoji" frame 'prepend)))

;; unbind some annoying defaults
;;
(dolist (troublesome '("<f11>" "s-h" "s-z" "C-z" "C-x C-z"))
  (global-unset-key (kbd troublesome)))

(global-set-key (kbd "<f10>") 'toggle-frame-fullscreen)

;; HYPER
;;
(setq ns-function-modifier 'hyper)

(provide 'edd-mac)
