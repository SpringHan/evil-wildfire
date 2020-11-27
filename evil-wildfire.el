;;; evil-wildfire.el --- Smart selection of closest object for Emacs Evil -*- lexical-binding: t -*-

;; Author: SpringHan
;; Maintainer: SpringHan
;; Version: 1.0
;; Package-Requires: ((emacs "26.3") (evil "0"))
;; Homepage: https://github.com/SpringHan/evil-wildfire.git
;; Keywords: Selection, Smart


;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; `evil-wildfire' can help you to select the object smartly in `evil-mode'.

;;; Code:

(defgroup evil-wildfire nil
  "The group of `evil-wildfire'."
  :group 'evil)

(defcustom evil-wildfire-global-symbol-alist
  '(("\"" . "\"")
    ("'" . "'")
    ("[" . "]")
    ("<" . ">")
    ("(" . ")"))
  "The global symbol alist."
  :group 'evil-wildfire)

(defcustom evil-wildfire-catch-key "RET"
  "The key for catch."
  :type 'string
  :group 'evil-wildfire)


(defcustom evil-wildfire-catch-char-key "SPC"
  "The key for catch."
  :type 'string
  :group 'evil-wildfire)

(defun evil-wildfire-init ()
  "Enable evil-wildfire."
  (when (featurep 'evil)
    (evil-wildfire-mode 1)))

(define-globalized-minor-mode global-evil-wildfire-mode
  evil-wildfire-mode evil-wildfire-init)

(define-minor-mode evil-wildfire-mode
  "The minor mode for `evil-wildfire'."
  nil nil nil
  (if evil-wildfire-mode
      (progn
        (define-key evil-normal-state-map (kbd evil-wildfire-catch-key) 'evil-wildfire-catch)
        (define-key evil-normal-state-map (kbd evil-wildfire-catch-char-key) 'evil-wildfire-catch-by-char)
        (define-key evil-motion-state-map (kbd evil-wildfire-catch-key) 'evil-wildfire-catch)
        (define-key evil-motion-state-map (kbd evil-wildfire-catch-char-key) 'evil-wildfire-catch-by-char)
        (define-key evil-visual-state-map (kbd evil-wildfire-catch-key) 'evil-wildfire-catch)
        (define-key evil-visual-state-map (kbd evil-wildfire-catch-char-key) 'evil-wildfire-catch-by-char))
    (define-key evil-normal-state-map (kbd evil-wildfire-catch-key) 'evil-ret)
    (define-key evil-normal-state-map (kbd evil-wildfire-catch-char-key) 'evil-forward-char)
    (define-key evil-motion-state-map (kbd evil-wildfire-catch-key) 'evil-ret)
    (define-key evil-motion-state-map (kbd evil-wildfire-catch-char-key) 'evil-forward-char)
    (define-key evil-visual-state-map (kbd evil-wildfire-catch-key) 'evil-ret)
    (define-key evil-visual-state-map (kbd evil-wildfire-catch-char-key) 'evil-forward-char)))

(provide 'evil-wildfire)

;;; evil-wildfire.el ends here
