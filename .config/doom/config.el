;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:

;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

;; Load the local everblush theme
;; (load! "everblush")
;; (setq doom-theme 'everblush)
(setq doom-theme 'doom-one)

;; catppuccin specific option
;; (setq doom-theme 'catppuccin)
;; (setq catppuccin-flavor 'mocha) ;; latte, frappe, macchiato, mocha

(setq doom-font (font-spec :family "JetBrains Mono" :size 14))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")



;; Own shit
;; defaults to change

(setq confirm-kill-emacs nil)        ;; Don't confirm on exit
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)
;;
;; Markdown
(custom-set-faces
 '(markdown-header-face ((t (:inherit font-lock-function-name-face :weight bold :family "variable-pitch"))))
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.6))))
 '(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.5))))
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.4))))
 '(markdown-header-face-4 ((t (:inherit markdown-header-face :height 1.3))))
 '(markdown-header-face-5 ((t (:inherit markdown-header-face :height 1.2))))
 '(markdown-header-face-6 ((t (:inherit markdown-header-face :height 1.1)))))

(defun dt/toggle-markdown-view-mode ()
  "Toggle between `markdown-mode' and `markdown-view-mode'."
  (interactive)
  (if (eq major-mode 'markdown-view-mode)
      (markdown-mode)
    (markdown-view-mode)))

;; Keybindings
;; toogle bindings
(map! :leader
      (:prefix ("t" . "toggle")
       :desc "Toggle eshell split"            "e" #'+eshell/toggle
       :desc "Toggle line highlight in frame" "h" #'hl-line-mode
       :desc "Toggle line highlight globally" "H" #'global-hl-line-mode
       :desc "Toggle line numbers"            "l" #'doom/toggle-line-numbers
       :desc "Toggle markdown-view-mode"      "m" #'dt/toggle-markdown-view-mode
       :desc "Toggle truncate lines"          "t" #'toggle-truncate-lines
       :desc "Toggle treemacs"                "T" #'+treemacs/toggle
       :desc "Toggle vterm split"             "v" #'+vterm/toggle))

(map! :leader
      (:prefix ("o" . "open here")
       :desc "Open eshell here"    "e" #'+eshell/here
       :desc "Open vterm here"     "v" #'+vterm/here))

;; comment line
(map! :leader
      :desc "Comment line" "-" #'comment-line)



;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

;; Tree-sitter configuration
(use-package! treesit
  :config
  ;; Set tree-sitter as the default for supported modes
  (setq treesit-font-lock-level 4) ; Maximum syntax highlighting level
  
  ;; Enable tree-sitter highlighting globally
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
  
  ;; Language source definitions for tree-sitter grammars
  (setq treesit-language-source-alist
        '((c "https://github.com/tree-sitter/tree-sitter-c")
          (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
          (c-sharp "https://github.com/tree-sitter/tree-sitter-c-sharp")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
          (java "https://github.com/tree-sitter/tree-sitter-java")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (kotlin "https://github.com/fwcd/tree-sitter-kotlin")
          (lua "https://github.com/tree-sitter-grammars/tree-sitter-lua")
          (markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src")
          (markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (rust "https://github.com/tree-sitter/tree-sitter-rust")
          (bash "https://github.com/tree-sitter/tree-sitter-bash")
          (yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (elisp "https://github.com/Wilfred/tree-sitter-elisp")))

  ;; Auto-install grammars when needed
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang)))

  ;; Enable tree-sitter modes for specific file types
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
  (add-to-list 'major-mode-remap-alist '(csharp-mode . csharp-ts-mode))
  (add-to-list 'major-mode-remap-alist '(go-mode . go-ts-mode))
  (add-to-list 'major-mode-remap-alist '(java-mode . java-ts-mode))
  (add-to-list 'major-mode-remap-alist '(js-mode . js-ts-mode))
  (add-to-list 'major-mode-remap-alist '(javascript-mode . js-ts-mode))
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  (add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode))
  (add-to-list 'major-mode-remap-alist '(sh-mode . bash-ts-mode))
  (add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode))
  (add-to-list 'major-mode-remap-alist '(json-mode . json-ts-mode))

  ;; Configure indentation for tree-sitter modes
  (setq c-ts-mode-indent-offset 4)
  (setq c++-ts-mode-indent-offset 4)
  (setq go-ts-mode-indent-offset 4)
  (setq java-ts-mode-indent-offset 4)
  (setq js-ts-mode-indent-offset 2)
  (setq python-ts-mode-indent-offset 4)
  (setq rust-ts-mode-indent-offset 4)
  (setq yaml-ts-mode-indent-offset 2)
  (setq json-ts-mode-indent-offset 2))

;; Enhanced tree-sitter features
(after! treesit
  ;; Better syntax highlighting for tree-sitter modes
  (setq treesit-font-lock-level 4)
  
  ;; Enable tree-sitter highlighting for all supported modes
  (add-hook 'prog-mode-hook #'tree-sitter-hl-mode)
  
  ;; Enable tree-sitter based folding
  (add-hook 'c-ts-mode-hook #'hs-minor-mode)
  (add-hook 'c++-ts-mode-hook #'hs-minor-mode)
  (add-hook 'go-ts-mode-hook #'hs-minor-mode)
  (add-hook 'java-ts-mode-hook #'hs-minor-mode)
  (add-hook 'js-ts-mode-hook #'hs-minor-mode)
  (add-hook 'python-ts-mode-hook #'hs-minor-mode)
  (add-hook 'rust-ts-mode-hook #'hs-minor-mode)
  (add-hook 'yaml-ts-mode-hook #'hs-minor-mode)
  (add-hook 'json-ts-mode-hook #'hs-minor-mode))

;; Tree-sitter structural navigation
(use-package! treesit
  :bind (("C-M-f" . treesit-forward-sexp)
         ("C-M-b" . treesit-backward-sexp)
         ("C-M-u" . treesit-backward-up-list)
         ("C-M-d" . treesit-forward-list)
         ("C-M-n" . treesit-forward-sentence)
         ("C-M-p" . treesit-backward-sentence)))

;; nyan mode
;; (setq mode-line-format
;;       (list
;;        '(:eval (list (nyan-create)))
;;        ))
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
