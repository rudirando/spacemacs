(defun mymegamailfun ()
  (interactive)
  (whitespace-cleanup)
  (evil-open-below 1)
  (evil-force-normal-state)
  (mark-whole-buffer)
  (call-interactively 'fill-region)
  (pop-mark)
  (evil-goto-first-line)
  (evil-open-above 1)
  (evil-force-normal-state)
  (evil-goto-first-line)
  (evil-open-above 1)
  )

;; Meine dirty-little-helpers Hydra
(defhydra fm/hydra-helpers (:color blue :hint nil)
  "
 _f_: fill-mode  _w_: wspace-cleanup _m_: megamailfun  _q_: quit
  "
  ("f" auto-fill-mode)
  ("w" whitespace-cleanup)
  ("m" mymegamailfun)
  ("q" nil :color blue))

(bind-key (kbd "<f12>") 'fm/hydra-helpers/body)
