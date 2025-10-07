;;; rose-pine-dawn-theme.el --- Rose Pine Dawn theme for Doom Emacs

;;; Commentary:
;; Light variant of Rose Pine theme.
;; All natural pine, faux fur and a bit of soho vibes for the classy minimalist.

;;; Code:

(deftheme rose-pine-dawn
  "Light variant of Rose Pine theme.")

(let ((class '((class color) (min-colors 89)))
      ;; Rose Pine Dawn color palette (light variant)
      (text       "#575279")  ;; foreground
      (base       "#faf4ed")  ;; background
      (surface    "#fffaf3")  ;; surface
      (overlay    "#f2e9e1")  ;; overlay
      (muted      "#9893a5")  ;; muted
      (subtle     "#797593")  ;; subtle
      (love       "#b4637a")  ;; love (red)
      (gold       "#ea9d34")  ;; gold (yellow)
      (rose       "#d7827e")  ;; rose
      (pine       "#286983")  ;; pine (cyan)
      (foam       "#56949f")  ;; foam (teal)
      (iris       "#907aa9")  ;; iris (purple)
      (leaf       "#618774")  ;; leaf (green)
      (highlight-low    "#f4ede8")
      (highlight-med    "#dfdad9")
      (highlight-high   "#cecacd"))

  (custom-theme-set-faces
   'rose-pine-dawn
   
   ;; Basic faces
   `(default ((,class (:background ,base :foreground ,text))))
   `(cursor ((,class (:background ,text))))
   `(region ((,class (:background ,highlight-med))))
   `(highlight ((,class (:background ,highlight-low))))
   `(hl-line ((,class (:background ,highlight-low))))
   `(fringe ((,class (:background ,base))))
   `(show-paren-match ((,class (:background ,love :foreground ,base))))
   `(isearch ((,class (:background ,love :foreground ,base))))
   `(lazy-highlight ((,class (:background ,highlight-med))))
   
   ;; Font lock faces
   `(font-lock-builtin-face ((,class (:foreground ,rose))))
   `(font-lock-comment-face ((,class (:foreground ,muted))))
   `(font-lock-constant-face ((,class (:foreground ,gold))))
   `(font-lock-function-name-face ((,class (:foreground ,rose))))
   `(font-lock-keyword-face ((,class (:foreground ,pine))))
   `(font-lock-string-face ((,class (:foreground ,gold))))
   `(font-lock-type-face ((,class (:foreground ,foam))))
   `(font-lock-variable-name-face ((,class (:foreground ,text))))
   `(font-lock-warning-face ((,class (:foreground ,love))))
   `(font-lock-doc-face ((,class (:foreground ,muted))))
   
   ;; Mode line
   `(mode-line ((,class (:background ,surface :foreground ,subtle))))
   `(mode-line-inactive ((,class (:background ,highlight-low :foreground ,muted))))
   
   ;; Minibuffer
   `(minibuffer-prompt ((,class (:foreground ,foam))))
   
   ;; Line numbers
   `(line-number ((,class (:foreground ,muted :background ,base))))
   `(line-number-current-line ((,class (:foreground ,foam :background ,base))))
   
   ;; Links
   `(link ((,class (:foreground ,iris :underline t))))
   `(link-visited ((,class (:foreground ,love :underline t))))
   
   ;; Org mode
   `(org-level-1 ((,class (:foreground ,love :weight bold))))
   `(org-level-2 ((,class (:foreground ,gold :weight bold))))
   `(org-level-3 ((,class (:foreground ,foam :weight bold))))
   `(org-level-4 ((,class (:foreground ,iris :weight bold))))
   `(org-level-5 ((,class (:foreground ,rose))))
   `(org-level-6 ((,class (:foreground ,pine))))
   `(org-todo ((,class (:foreground ,love :weight bold))))
   `(org-done ((,class (:foreground ,foam :weight bold))))
   `(org-code ((,class (:foreground ,rose))))
   `(org-block ((,class (:background ,highlight-low))))
   
   ;; Markdown
   `(markdown-header-face-1 ((,class (:foreground ,love :weight bold))))
   `(markdown-header-face-2 ((,class (:foreground ,gold :weight bold))))
   `(markdown-header-face-3 ((,class (:foreground ,foam :weight bold))))
   `(markdown-code-face ((,class (:background ,highlight-low :foreground ,rose))))
   `(markdown-inline-code-face ((,class (:background ,highlight-low :foreground ,rose))))
   
   ;; Dired
   `(dired-directory ((,class (:foreground ,foam))))
   `(dired-header ((,class (:foreground ,love))))
   
   ;; Compilation
   `(compilation-error ((,class (:foreground ,love))))
   `(compilation-warning ((,class (:foreground ,gold))))
   `(compilation-info ((,class (:foreground ,foam))))
   
   ;; Diff
   `(diff-added ((,class (:foreground ,foam))))
   `(diff-removed ((,class (:foreground ,love))))
   `(diff-changed ((,class (:foreground ,gold))))
   
   ;; Magit
   `(magit-branch-local ((,class (:foreground ,foam))))
   `(magit-branch-remote ((,class (:foreground ,gold))))
   `(magit-hash ((,class (:foreground ,muted))))
   `(magit-section-heading ((,class (:foreground ,love :weight bold))))
   
   ;; Company
   `(company-tooltip ((,class (:background ,surface :foreground ,text))))
   `(company-tooltip-selection ((,class (:background ,highlight-med))))
   `(company-tooltip-common ((,class (:foreground ,iris))))
   
   ;; Doom modeline
   `(doom-modeline-bar ((,class (:background ,iris))))
   `(doom-modeline-buffer-file ((,class (:foreground ,text))))
   `(doom-modeline-buffer-modified ((,class (:foreground ,love))))
   `(doom-modeline-project-dir ((,class (:foreground ,foam))))))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'rose-pine-dawn)

;;; rose-pine-dawn-theme.el ends here