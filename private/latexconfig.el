(defun my-latex-quick-compile ()
  "Run `some-command' and `some-other-command' in sequence."
  (interactive)
  (save-buffer)
  (TeX-command "LaTeX" 'TeX-master-file -1))

(bind-key (kbd "M-s-x")  'my-latex-quick-compile )
(bind-key (kbd "M-s-i")  'latex-math-preview-insert-mathematical-symbol)

(setq TeX-view-program-list '(("zathura" "zathura %o")))
(setq TeX-view-program-selection '((output-pdf "zathura")))
(setq-default TeX-PDF-mode t)
(setq TeX-global-PDF-mode t)
(setq TeX-auto-save t) ; Enable parse on save.
(setq TeX-eletric-math t)
(setq TeX-show-compilation nil)
(setq LaTeX-indent-level 2)
(setq LaTeX-item-indent 0)

(defun LaTeX-my-leftright (charopen charclose)
  "Inserts the pattern '\leftC  \rightD' where C is the open input char and D the closed, and places the cursor in the center."
  (interactive)
  (setq out1 (concat "\\left" charopen " "))
  (setq out2 (concat " \\right" charclose))
  (insert out1)
  (push-mark)
  (insert out2)
  (exchange-point-and-mark))

(defun LaTeX-my-mathrm nil
  "Inserts '\mathrm{}'."
  (interactive)
  (setq out1 (concat "\\mathrm{" ""))
  (setq out2 "}")
  (insert out1)
  (push-mark)
  (insert out2)
  (exchange-point-and-mark))

(defun LaTeX-my-mathbb nil
  "Inserts '\mathbb{}'."
  (interactive)
  (setq out1 (concat "\\mathbb{" ""))
  (setq out2 "}")
  (insert out1)
  (push-mark)
  (insert out2)
  (exchange-point-and-mark))

(defun LaTeX-my-einheit nil
  "Inserts '\mathrm{}'."
  (interactive)
  (setq out1 (concat " \\, \\mathrm{" ""))
  (setq out2 "}")
  (insert out1)
  (push-mark)
  (insert out2)
  (exchange-point-and-mark))

(setq LaTeX-math-list
      '(("°" "circ" "" nil)
        ("=" "equiv" "" nil)
        ("8" "infty" "" nil)
        ("C-r" (lambda ()(interactive)
                 (LaTeX-my-mathrm)) "" nil)
        ("C-b" (lambda ()(interactive)
                 (LaTeX-my-mathbb)) "" nil)
        ("C-z" (lambda ()(interactive)
                 (LaTeX-my-einheit)) "" nil)
        ("C-(" (lambda ()(interactive)
                 (LaTeX-my-leftright "(" ")")) "" nil)
        ("C-{" (lambda ()(interactive)
                 (LaTeX-my-leftright "\\{" "\\}")) "" nil)
        ))

;;;;;;;;;;;;;;;;;;;;;;;
;; prettify-symbols-hack nach
;; http://endlessparentheses.com/improving-latex-equations-with-font-lock.html
;;
(defface endless/unimportant-latex-face
  '((t :height 0.7
       :inherit font-lock-comment-face))
  "Face used on less relevant math commands.")

(font-lock-add-keywords
 'latex-mode
 `((,(rx (or (and "\\" (or (any ",.!;")
                           (and (or "left" "right"
                                    "big" "Big")
                                symbol-end)))
             (any "_^")))
    0 'endless/unimportant-latex-face prepend))
 'end)
(add-hook 'LaTeX-mode-hook 'prettify-symbols-mode)

(use-package latex-math-preview
  :ensure t
  :init
  (defvar moin-schois
    '(("MoinSchois"
       ("ditunddat" nil
        (("\\lim\\limits_{" "n" " \\to \\infty}")
         ("\\frac{\\partial " "f" "}{\\partial x}"))))))
  (defvar meinematrizen
    '(("MeineMatrizen"
       ("Meine Matrizen" nil
        (("\\begin{vmatrix}\\alpha & \\beta \\\\ \\gamma & \\delta\\end{vmatrix}")
         ("\\begin{pmatrix} 1 & 0 & \\cdots & 0 \\\\ \\vdots & & \\ddots & \\\\ 1 & \\cdots & & 0 \\end{pmatrix}")
         ("\\begin{pmatrix} 1 & 0 & \\cdots & 0 \\\\  & \\bigzero & \\ddots & \\vdots \\\\ & & & 0 \\end{pmatrix}")
         )))))

  :config
  (setq latex-math-preview-mathematical-symbol-datasets
        (append
         latex-math-preview-mathematical-symbol-datasets
         moin-schois meinematrizen)))

;; TAB-cyclen im Outline mode.. oder so.
(use-package latex-extra
  :ensure t
  :init
  ;; ;; Um Warnung beim Start abzuschalten
  ;; (defvar latex-extra-mode)
  :hook (LaTeX-mode . latex-extra-mode)
  ;; :config
  ;; (add-hook 'LaTeX-mode-hook #'latex-extra-mode)
  ;; um auch itemize etc. cyclen zu können
  ;;(setq TeX-outline-extra '(("\beginitemize" 2)))
  )
                                     ;ende use-package
