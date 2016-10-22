;; Mostly taken from https://sam217pa.github.io/2016/09/13/from-helm-to-ivy/
;;

(use-package ivy :ensure t
  :ensure t
  :ensure ivy-hydra
  :ensure counsel
  :ensure counsel-projectile
  :diminish
  :bind
  ("C-'" . avy-goto-char-2)
  ("M-x" . counsel-M-x)
  ("C-x C-m" . counsel-M-x)
  ("C-x C-f" . counsel-find-file)
  ("C-M-y" . counsel-yank-pop)
  :init
  (with-eval-after-load 'ido
    (ido-mode -1)
    ;; Enable ivy
    (ivy-mode 1))

  (defun edd-theme-ivy ()
    (let ((func (face-foreground 'font-lock-function-name-face)))
      (message func)
      (set-face-attribute 'minibuffer-prompt nil :foreground func)))

  :config
  (ivy-mode 1)
  ;; add ‘recentf-mode’ and bookmarks to ‘ivy-switch-buffer’.
  (setq ivy-use-virtual-buffers t)
  ;; number of result lines to display
  (setq ivy-height 10)
  ;; does not count candidates
  (setq ivy-count-format "")

  ;; turns out this was the only thing I miss from helm
  (defun edd-ivy-updir ()
    "for ivy file prompts, either delete back to subdirectory prompt or go up a directory"
    (interactive)
    (when ivy--directory
      (if (= (minibuffer-prompt-end) (point))
          (ivy-backward-delete-char)
        (while (not (= (minibuffer-prompt-end) (point)))
          (ivy-backward-kill-word)))))

  (define-key ivy-minibuffer-map (kbd "C-l") 'edd-ivy-updir)

  (with-eval-after-load 'info
    (define-key Info-mode-map (kbd "C-s") 'isearch-forward))
  (with-eval-after-load 'company
    (define-key company-mode-map (kbd "C-M-i") 'counsel-company)
    (define-key company-active-map (kbd "C-M-i") 'counsel-company))
  (with-eval-after-load 'projectile
    (setq projectile-completion-system 'ivy)
    (counsel-projectile-on))
  (eval-after-load 'imenu-anywhere
    '(global-set-key (kbd "C-c ,") 'ivy-imenu-anywhere))

  (define-key isearch-mode-map (kbd "M-i") 'swiper-from-isearch)
  (add-hook 'edd-load-theme-hook 'edd-theme-ivy)
  (edd-theme-ivy))

(provide 'edd-ivy)
