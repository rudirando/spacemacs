(setq org-contacts-files '("~/org/contacts.org"))

(setq org-ellipsis "⤵")
(setq org-hide-emphasis-markers t)

;; (setq org-src-fontify-natively t)
;; (setq org-src-tab-acts-natively t)
;; (setq org-src-window-setup 'current-window)

;; (add-to-list 'org-structure-template-alist
;;              '("el" . "src emacs-lisp"))

(setq org-directory "~/org")

(defun org-file-path (filename)
  "Return the absolute address of an org file, given its relative name."
  (concat (file-name-as-directory org-directory) filename))

(setq org-inbox-file "~/org/inbox.org")
(setq org-index-file (org-file-path "index.org"))

(defun hrs/copy-tasks-from-inbox ()
  (when (file-exists-p org-inbox-file)
    (save-excursion
      (find-file org-index-file)
      (goto-char (point-max))
      (insert-file-contents org-inbox-file)
      (delete-file org-inbox-file))))

(setq org-agenda-files (list org-index-file
                             (org-file-path "recurring-events.org")
                             (org-file-path "work.org")
                             (org-file-path "termine.org")
                             (org-file-path "todo.org")
                             (org-file-path "studitodo.org")
                             (org-file-path "projis.org")))


(defun hrs/mark-done-and-archive ()
  "Mark the state of an org-mode item as DONE and archive it."
  (interactive)
  (org-todo 'done)
  (org-archive-subtree))

;; (define-key org-mode-map (kbd "C-c C-x C-s") 'hrs/mark-done-and-archive)

(setq org-log-done 'time)

(setq org-enforce-todo-dependencies t)
(setq org-enforce-todo-checkbox-dependencies t)


;; Display properties
(setq org-cycle-separator-lines 1)
;; (setq org-tags-column 80)
;; (setq org-agenda-tags-column org-tags-column)
;; (setq org-agenda-sticky t)


;; Dim blocked tasks (and other settings)
;; (setq org-enforce-todo-dependencies t)
;; (setq org-agenda-inhibit-startup nil)
;; (setq org-agenda-dim-blocked-tasks nil)

;; Compact the block agenda view (disabled)
;; (setq org-agenda-compact-blocks nil)

;; Some helper functions for selection within agenda views
(defun gs/select-with-tag-function (select-fun-p)
  (save-restriction
    (widen)
    (let ((next-headline
           (save-excursion (or (outline-next-heading)
                               (point-max)))))
      (if (funcall select-fun-p) nil next-headline))))

(defun gs/select-projects ()
  "Selects tasks which are project headers"
  (gs/select-with-tag-function #'bh/is-project-p))
(defun gs/select-project-tasks ()
  "Skips tags which belong to projects (and is not a project itself)"
  (gs/select-with-tag-function
   #'(lambda () (and
                 (not (bh/is-project-p))
                 (bh/is-project-subtree-p)))))
(defun gs/select-standalone-tasks ()
  "Skips tags which belong to projects. Is neither a project, nor does it blong to a project"
  (gs/select-with-tag-function
   #'(lambda () (and
                 (not (bh/is-project-p))
                 (not (bh/is-project-subtree-p))))))
(defun gs/select-projects-and-standalone-tasks ()
  "Skips tags which are not projects"
  (gs/select-with-tag-function
   #'(lambda () (or
                 (bh/is-project-p)
                 (bh/is-project-subtree-p)))))

(defun gs/org-agenda-project-warning ()
  "Is a project stuck or waiting. If the project is not stuck,
show nothing. However, if it is stuck and waiting on something,
show this warning instead."
  (if (gs/org-agenda-project-is-stuck)
      (if (gs/org-agenda-project-is-waiting) " !W" " !S") ""))

(defun gs/org-agenda-project-is-stuck ()
  "Is a project stuck"
  (if (bh/is-project-p) ; first, check that it's a project
      (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
             (has-next))
        (save-excursion
          (forward-line 1)
          (while (and (not has-next)
                      (< (point) subtree-end)
                      (re-search-forward "^\\*+ NEXT " subtree-end t))
            (unless (member "WAITING" (org-get-tags-at))
              (setq has-next t))))
        (if has-next nil t)) ; signify that this project is stuck
    nil)) ; if it's not a project, return an empty string

(defun gs/org-agenda-project-is-waiting ()
  "Is a project stuck"
  (if (bh/is-project-p) ; first, check that it's a project
      (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
        (save-excursion
          (re-search-forward "^\\*+ WAITING" subtree-end t)))
    nil)) ; if it's not a project, return an empty string

;; Some helper functions for agenda views
(defun gs/org-agenda-prefix-string ()
  "Format"
  (let ((path (org-format-outline-path (org-get-outline-path))) ; "breadcrumb" path
        (stuck (gs/org-agenda-project-warning))) ; warning for stuck projects
    (if (> (length path) 0)
        (concat stuck ; add stuck warning
                " [" path "]") ; add "breadcrumb"
      stuck)))

(defun gs/org-agenda-add-location-string ()
  "Gets the value of the LOCATION property"
  (let ((loc (org-entry-get (point) "LOCATION")))
    (if (> (length loc) 0)
        (concat "{" loc "} ")
      "")))

;; Variables for ignoring tasks with deadlines
;; (defvar gs/hide-deadline-next-tasks t)
;; (setq org-agenda-tags-todo-honor-ignore-options t)
;; (setq org-deadline-warning-days 10)

;; Custom agenda command definitions
;; (setq org-agenda-custom-commands
;;       '(("h" "Habits" agenda "STYLE=\"habit\""
;;          ((org-agenda-overriding-header "Habits")
;;           (org-agenda-sorting-strategy
;;            '(todo-state-down effort-up category-keep))))
;;         (" " "Export Schedule" (
;;                                 (agenda "" ((org-agenda-overriding-header "Today's Schedule:")
;;                                             (org-agenda-span 'day)
;;                                             (org-agenda-ndays 1)
;;                                             (org-agenda-start-on-weekday nil)
;;                                             (org-agenda-start-day "+0d")
;;                                             (org-agenda-todo-ignore-deadlines nil)))
;;                                 (tags "REFILE-ARCHIVE-REFILE=\"nil\""
;;                                       ((org-agenda-overriding-header "Tasks to Refile:")
;;                                        (org-tags-match-list-sublevels nil)))
;;                                 (tags-todo "-INACTIVE-CANCELLED-ARCHIVE/!NEXT"
;;                                            ((org-agenda-overriding-header "Next Tasks:")
;;                                             ))
;;                                 (tags-todo "-INACTIVE-HOLD-CANCELLED-REFILEr/!"
;;                                            ((org-agenda-overriding-header "Active Projects:")
;;                                             (org-agenda-skip-function 'gs/select-projects)))
;;                                 (tags "ENDOFAGENDA"
;;                                       ((org-agenda-overriding-header "End of Agenda")
;;                                        (org-tags-match-list-sublevels nil)))
;;                                 )
;;          ((org-agenda-start-with-log-mode t)
;;           (org-agenda-log-mode-items '(clock))
;;           (org-agenda-prefix-format '((agenda . "  %-12:c%?-12t %(gs/org-agenda-add-location-string)% s")
;;                                       (timeline . "  % s")
;;                                       (todo . "  %-12:c %(gs/org-agenda-prefix-string) ")
;;                                       (tags . "  %-12:c %(gs/org-agenda-prefix-string) ")
;;                                       (search . "  %i %-12:c")))
;;           (org-agenda-todo-ignore-deadlines 'near)
;;           (org-agenda-todo-ignore-scheduled t)))
;;         ("b" "Agenda Review" (
;;                               (tags "REFILE-ARCHIVE-REFILE=\"nil\""
;;                                     ((org-agenda-overriding-header "Tasks to Refile:")
;;                                      (org-tags-match-list-sublevels nil)))
;;                               (tags-todo "-INACTIVE-CANCELLED-ARCHIVE/!NEXT"
;;                                          ((org-agenda-overriding-header "Next Tasks:")
;;                                           ))
;;                               (tags-todo "-INACTIVE-HOLD-CANCELLED-REFILE-ARCHIVEr/!"
;;                                          ((org-agenda-overriding-header "Active Projects:")
;;                                           (org-agenda-skip-function 'gs/select-projects)))
;;                               (tags-todo "-INACTIVE-HOLD-CANCELLED-REFILE-ARCHIVE-STYLE=\"habit\"/!-NEXT"
;;                                          ((org-agenda-overriding-header "Standalone Tasks:")
;;                                           (org-agenda-skip-function 'gs/select-standalone-tasks)))
;;                               (tags-todo "-INACTIVE-HOLD-CANCELLED-REFILE-ARCHIVE/!-NEXT"
;;                                          ((org-agenda-overriding-header "Remaining Project Tasks:")
;;                                           (org-agenda-skip-function 'gs/select-project-tasks)))
;;                               (tags-todo "-INACTIVE-CANCELLED-ARCHIVE/!WAITING"
;;                                          ((org-agenda-overriding-header "Waiting Tasks:")
;;                                           ))
;;                               (tags "INACTIVE-ARCHIVE-CANCELLED"
;;                                     ((org-agenda-overriding-header "Inactive Projects and Tasks")
;;                                      (org-tags-match-list-sublevels nil)))
;;                               (tags "ENDOFAGENDA"
;;                                     ((org-agenda-overriding-header "End of Agenda")
;;                                      (org-tags-match-list-sublevels nil)))
;;                               )
;;          ((org-agenda-start-with-log-mode t)
;;           (org-agenda-log-mode-items '(clock))
;;           (org-agenda-prefix-format '((agenda . "  %-12:c%?-12t %(gs/org-agenda-add-location-string)% s")
;;                                       (timeline . "  % s")
;;                                       (todo . "  %-12:c %(gs/org-agenda-prefix-string) ")
;;                                       (tags . "  %-12:c %(gs/org-agenda-prefix-string) ")
;;                                       (search . "  %i %-12:c")))
;;           (org-agenda-todo-ignore-deadlines 'near)
;;           (org-agenda-todo-ignore-scheduled t)))

;;         ("O" "Export Schedule (old)" ((agenda "" ((org-agenda-overriding-header "Today's Schedule:")
;;                                                   (org-agenda-span 'day)
;;                                                   (org-agenda-ndays 1)
;;                                                   (org-agenda-start-on-weekday nil)
;;                                                   (org-agenda-start-day "+0d")
;;                                                   (org-agenda-todo-ignore-deadlines nil)))
;;                                       (tags-todo "-INACTIVE-CANCELLED-ARCHIVE/!NEXT"
;;                                                  ((org-agenda-overriding-header "Next Tasks:")
;;                                                   ))
;;                                       (tags "REFILE-ARCHIVE-REFILE=\"nil\""
;;                                             ((org-agenda-overriding-header "Tasks to Refile:")
;;                                              (org-tags-match-list-sublevels nil)))
;;                                       (tags-todo "-INACTIVE-HOLD-CANCELLED-REFILE-ARCHIVEr/!"
;;                                                  ((org-agenda-overriding-header "Active Projects:")
;;                                                   (org-agenda-skip-function 'gs/select-projects)))
;;                                       (tags-todo "-INACTIVE-HOLD-CANCELLED-REFILE-ARCHIVE-STYLE=\"habit\"/!-NEXT"
;;                                                  ((org-agenda-overriding-header "Standalone Tasks:")
;;                                                   (org-agenda-skip-function 'gs/select-standalone-tasks)))
;;                                       (tags-todo "-INACTIVE-HOLD-CANCELLED-REFILE-ARCHIVE/!-NEXT"
;;                                                  ((org-agenda-overriding-header "Remaining Project Tasks:")
;;                                                   (org-agenda-skip-function 'gs/select-project-tasks)))
;;                                       (tags "INACTIVE-ARCHIVE-CANCELLED"
;;                                             ((org-agenda-overriding-header "Inactive Projects and Tasks")
;;                                              (org-tags-match-list-sublevels nil)))
;;                                       (tags "ENDOFAGENDA"
;;                                             ((org-agenda-overriding-header "End of Agenda")
;;                                              (org-tags-match-list-sublevels nil))))
;;          ((org-agenda-start-with-log-mode t)
;;           (org-agenda-log-mode-items '(clock))
;;           (org-agenda-prefix-format '((agenda . "  %-12:c%?-12t %(gs/org-agenda-add-location-string)% s")
;;                                       (timeline . "  % s")
;;                                       (todo . "  %-12:c %(gs/org-agenda-prefix-string) ")
;;                                       (tags . "  %-12:c %(gs/org-agenda-prefix-string) ")
;;                                       (search . "  %i %-12:c")))
;;           (org-agenda-todo-ignore-deadlines 'near)
;;           (org-agenda-todo-ignore-scheduled t)))
;;         ("X" "Agenda" ((agenda "") (alltodo))
;;          ((org-agenda-ndays 10)
;;           (org-agenda-start-on-weekday nil)
;;           (org-agenda-start-day "-1d")
;;           (org-agenda-start-with-log-mode t)
;;           (org-agenda-log-mode-items '(closed clock state)))
;;          )))

;; ;; == Agenda Navigation ==

;; ;; Search for a "=" and go to the next line
;; (defun gs/org-agenda-next-section ()
;;   "Go to the next section in an org agenda buffer"
;;   (interactive)
;;   (if (search-forward "===" nil t 1)
;;       (forward-line 1)
;;     (goto-char (point-max)))
;;   (beginning-of-line))

;; ;; Search for a "=" and go to the previous line
;; (defun gs/org-agenda-prev-section ()
;;   "Go to the next section in an org agenda buffer"
;;   (interactive)
;;   (forward-line -2)
;;   (if (search-forward "===" nil t -1)
;;       (forward-line 1)
;;     (goto-char (point-min))))

;; ;; == Agenda Post-processing ==
;; ;; Highlight the "!!" for stuck projects (for emphasis)
;; (defun gs/org-agenda-project-highlight-warning ()
;;   (save-excursion
;;     (goto-char (point-min))
;;     (while (re-search-forward "!W" nil t)
;;       (progn
;;         (add-face-text-property
;;          (match-beginning 0) (match-end 0)
;;          '(bold :foreground "orange"))
;;         ))
;;     (goto-char (point-min))
;;     (while (re-search-forward "!S" nil t)
;;       (progn
;;         (add-face-text-property
;;          (match-beginning 0) (match-end 0)
;;          '(bold :foreground "white" :background "red"))
;;         ))
;;     ))
;; (add-hook 'org-agenda-finalize-hook 'gs/org-agenda-project-highlight-warning)

;; ;; Remove empty agenda blocks
;; (defun gs/remove-agenda-regions ()
;;   (save-excursion
;;     (goto-char (point-min))
;;     (let ((region-large t))
;;       (while (and (< (point) (point-max)) region-large)
;;         (set-mark (point))
;;         (gs/org-agenda-next-section)
;;         (if (< (- (region-end) (region-beginning)) 5) (setq region-large nil)
;;           (if (< (count-lines (region-beginning) (region-end)) 4)
;;               (delete-region (region-beginning) (region-end)))
;;           )))))
;; (add-hook 'org-agenda-finalize-hook 'gs/remove-agenda-regions)

;; (defun hrs/dashboard ()
;;   (interactive)
;;   (hrs/copy-tasks-from-inbox)
;;   (org-agenda nil "X"))

;; (global-set-key (kbd "C-c d") 'hrs/dashboard)

(setq org-capture-templates
      '(("b" "Blog idea"
         entry
         (file "~/org/blog-ideas.org")
         "* %?\n")

        ("c" "Contact"
         entry
         (file "~/org/contacts.org")
         "* %(org-contacts-template-name)
:PROPERTIES:
:ADDRESS: %^{123 Fake St., City, ST 12345}
:PHONE: %^{555-555-5555}
:EMAIL: %(org-contacts-template-email)
:NOTE: %^{note}
:END:")

        ("e" "Email" entry
         (file+headline org-index-file "Inbox")
         "* TODO %?\n\n%a\n\n")

        ("d" "Termin"
         entry
         (file "~/org/termine.org")
         "* TODO %?\n")

        ;; ("f" "Finished book"
        ;;  table-line (file "~/org/books-read.org")
        ;;  "| %^{Title} | %^{Author} | %u |")

        ;; ("r" "Reading"
        ;;  checkitem
        ;;  (file (org-file-path "to-read.org")))

        ;; ("s" "Subscribe to an RSS feed"
        ;;  plain
        ;;  (file "~/org/rss-feeds.org")
        ;;  "*** [[%^{Feed URL}][%^{Feed name}]]")

        ("p" "Proji"
         entry
         (file+headline  "~/org/projis.org" "Neue Projis")
         "* TODO %?\n")

        ("w" "Work"
         entry
         (file+headline "~/org/work.org" "Neue Todos")
         "* TODO %?\n")

        ("s" "Studi-Todo"
         entry
         (file+headline "~/org/studitodo.org" "Neue Todos")
         "* TODO %?\n")

        ("t" "Todo"
         entry
         (file+headline org-index-file "Inbox")
         "* TODO %?\n")))

(add-hook 'org-capture-mode-hook 'evil-insert-state)

;; stolen from https://stackoverflow.com/questions/22200312/refile-from-one-file-to-other#22200624
;; (setq org-refile-targets '((my-org-files-list :maxlevel . 3)))
(defun my-org-files-list ()
  (delq nil
    (mapcar (lambda (buffer)
      (buffer-file-name buffer))
      (org-buffer-list 'files t))))


;; Targets include this file and any file contributing to the agenda - up to 4 levels deep
(setq org-refile-targets (quote ((my-org-files-list :maxlevel . 4)
                                 (org-agenda-files :maxlevel . 4))))
;; (setq org-refile-targets (quote ((nil :maxlevel . 9)
;;                                  (org-agenda-files :maxlevel . 9))))

(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes (quote confirm)) ; allow refile to create parent tasks with confirmation

;; (define-key global-map "\C-cl" 'org-store-link)
;; (define-key global-map "\C-ca" 'org-agenda)
;; (define-key global-map "\C-cc" 'org-capture)

;; (defun hrs/open-index-file ()
;;   "Open the master org TODO list."
;;   (interactive)
;;   (hrs/copy-tasks-from-inbox)
;;   (find-file org-index-file)
;;   (flycheck-mode -1)
;;   (end-of-buffer))

;; (global-set-key (kbd "C-c i") 'hrs/open-index-file)

(defun org-capture-todo ()
  (interactive)
  (org-capture :keys "t"))

;; (global-set-key (kbd "M-n") 'org-capture-todo)
;; (add-hook 'gfm-mode-hook
;;           (lambda () (local-set-key (kbd "M-n") 'org-capture-todo)))
;; (add-hook 'haskell-mode-hook
;;           (lambda () (local-set-key (kbd "M-n") 'org-capture-todo)))

;; (require 'ox-md)
;; (require 'ox-beamer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stolen from bh
;;

;; Allow setting single tags without the menu
(setq org-fast-tag-selection-single-key 'expert)

;; Include the todo keywords
(setq org-fast-tag-selection-include-todo t)

;; == Custom State Keywords ==
(setq org-use-fast-todo-selection t)
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
        (sequence "WAITING(w@/!)" "INACTIVE(i)" "|" "CANCELLED(c@/!)" "MEETING")))


;; (setq org-agenda-span 14)
;; (setq org-agenda-start-on-weekday nil)

;; (setq org-agenda-prefix-format '((agenda . " %i %?-12t% s")
;;                                  (todo . " %i ")
;;                                  (tags . " %i ")
;;                                  (search . " %i ")))

;; last but not least: my org hydra

(defhydra org-hydra (:color blue :hint nil)
  "
_a_: agenda  _c_: capture  _t_: cap. todo  _s_: cap. studi-todo  _d_: termin  _w_: week-agenda  _q_: quit
"
  ("a" org-agenda)
  ("c" org-capture)
  ("t" (org-capture nil "t"))
  ("s" (org-capture nil "s"))
  ("d" (org-capture nil "d"))
  ("w" hrs/dashboard)
  ("q" nil :color blue)
  )

(global-set-key (kbd "M-s-o") #'org-hydra/body)
