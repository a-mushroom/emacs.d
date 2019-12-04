;; -*- coding: utf-8; lexical-binding: t; -*-
(setq emacs-load-start-time (current-time)) ;; load start time

;; speed up emacs startup by enlarge memory threshold
;; https://github.com/hlissner/doom-emacs/wiki/FAQ#how-is-dooms-startup-so-fast
(setq gc-cons-threshold (* 64 1024 1024)
      gc-cons-percentage 0.5)

(setq-default inhibit-startup-screen t) ;; disable startup display emacs manual

(if (display-graphic-p)
    (progn
      (tool-bar-mode -1) ;; disable toolbar
      (menu-bar-mode -1) ;; disable menubar
      )
  (xterm-mouse-mode)
  )

;; display line number, need emacs version >= 26.0.50
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

(setq auto-save-default nil) ;; disable autosave
(setq backup-directory-alist '(("" . "~/.emacs.d/backup"))) ;;save backup file together

(setq dired-listing-switches "-alh") ;; make dired display size human readable

(require 'package)
(setq package-enable-at-startup nil)
;; use emacs china elpa mirror
(setq package-archives '(("gnu" . "https://elpa.emacs-china.org/gnu/")
			 ("melpa-stable" . "http://elpa.emacs-china.org/melpa-stable/")
			 ("melpa" . "http://elpa.emacs-china.org/melpa/")))
(package-initialize)

;; auto install use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(require 'use-package-ensure)
(setq use-package-always-ensure t)
(use-package bind-key)
(use-package diminish)

(use-package helm
  :pin melpa-stable
  :diminish helm-mode
  :bind (("M-x" . helm-M-x)
	 ("M-s" . helm-occur)
	 ("C-x f" . helm-find-files)
	 ("C-x b" . helm-mini))
  :bind (:map helm-map
	      ("<tab>" . helm-execute-persistent-action))
  :config
  (setq helm-split-window-inside-p t)
  (helm-autoresize-mode)
  (setq helm-autoresize-max-height 0)
  (setq helm-autoresize-min-height 20)
  :hook ((after-init . helm-mode))
  )

(use-package evil
  :pin melpa-stable
  :diminish undo-tree-mode
  :hook ((after-init . evil-mode))
  )

(use-package evil-leader
  :diminish evil-leader-mode
  :config
  (evil-leader/set-leader ",")
  (evil-leader/set-key
   "xd" 'dired
   "xb" 'helm-mini
   "xk" 'kill-buffer
   "xf" 'helm-find-files)
  :hook ((evil-mode . global-evil-leader-mode))
  )

(use-package clang-format) ;; need install clang-tools

(use-package yasnippet
  :diminish yas-minor-mode
  :hook ((emacs-lisp-mode . yas-minor-mode)
	 (python-mode . yas-minor-mode)
	 (c++-mode . yas-minor-mode))
  )

(use-package yasnippet-snippets)

(use-package lsp-mode
  :defer
  :hook ((c++-mode . lsp)
	 (python-mode . lsp))
  )

(use-package flymake-diagnostic-at-point
  :defer
  :after flymake
  :custom
  (flymake-diagnostic-at-point-timer-delay 1)
  (flymake-diagnostic-at-point-display-diagnostic-function
   'flymake-diagnostic-at-point-display-popup)
  :hook
  (flymake-mode . flymake-diagnostic-at-point-mode)
  )

(use-package company
  :diminish company-mode
  :hook (after-init . global-company-mode)
  :config
  (push 'company-yasnippet company-backends)
  )

(use-package company-lsp
  :config
  (push 'company-lsp company-backends)
  )

(use-package magit
  :defer)

(use-package dracula-theme)
;;(use-package arc-dark-theme)

(use-package powerline
  :hook
  (after-init . powerline-default-theme))

(defun create-tags (dir-name)
  "Create tags file for DIR-NAME."
  (interactive "DDirectory: ")
  (shell-command
   (format "ctags -f %s/TAGS -e -R %s" (directory-file-name dir-name)))
  )

(setq c-default-style "linux"
      c-basic-offset 4)

(fset 'delete-empty-lines (kbd "M-x flush-lines RET ^\s-*$ RET"))

;; @see https://www.reddit.com/r/emacs/comments/4q4ixw/how_to_forbid_emacs_to_touch_configuration_files/
;; See `custom-file' for details.
(load (setq custom-file (expand-file-name "~/.emacs.d/emacs-custom.el")) t t)

(when (require 'time-date nil t)
  (message "Emacs startup use %d seconds."
	   (time-to-seconds (time-since emacs-load-start-time))))
