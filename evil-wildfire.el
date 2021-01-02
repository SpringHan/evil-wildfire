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

(require 'evil)

(defgroup evil-wildfire nil
  "The group of `evil-wildfire'."
  :group 'evil)

(defcustom evil-wildfire-global-symbol-alist
  '(("\"" . "\"")
    ("'" . "'")
    ("[" . "]")
    ("<" . ">")
    ("(" . ")")
    ("{" . "}"))
  "The global symbol alist."
  :group 'evil-wildfire)

(defcustom evil-wildfire-catch-key "RET"
  "The key for catch."
  :type 'string
  :group 'evil-wildfire)

(defcustom evil-wildfire-catch-char-key "C-<return>"
  "The key for catch."
  :type 'string
  :group 'evil-wildfire)

(defvar global-evil-wildfire-status nil
  "The status for `global-evil-wildfire-mode'")

(defun evil-wildfire-init ()
  "Enable evil-wildfire."
  (when (featurep 'evil)
    (evil-wildfire-mode 1)))

(define-minor-mode global-evil-wildfire-mode
  "Global mode for `evil-wildfire-mode'"
  nil nil nil
  (if global-evil-wildfire-status
      (progn
        (remove-hook 'evil-local-mode-hook #'evil-wildfire-mode t)
        (when evil-wildfire-mode
          (evil-wildfire-mode -1))
        (setq global-evil-wildfire-status nil))
    (add-hook 'evil-local-mode-hook #'evil-wildfire-mode t)
    (unless evil-wildfire-mode
      (evil-wildfire-mode t))
    (setq global-evil-wildfire-status t)))

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

(defun evil-wildfire-catch (&optional char)
  "Catch region."
  (interactive)
  (let (prefix-point second-char second-point tmp)
    (save-mark-and-excursion
      (when (region-active-p)
        (backward-char))
      ;; Get the `prefix-point'
      (if char
          (setq prefix-point
                (catch 'point-stop
                  (while t
                    (if (string=
                         char
                         (setq tmp
                               (buffer-substring-no-properties (point) (1+ (point)))))
                        (throw 'point-stop (point))
                      (if (bobp)
                          (throw 'point-stop nil)
                        (backward-char))))))
        (setq prefix-point
              (catch 'point-stop
                (while t
                  (if (evil-wildfire--get-second-char
                       (setq tmp (buffer-substring-no-properties (point) (1+ (point)))))
                      (progn
                        (setq char tmp)
                        (throw 'point-stop (point)))
                    (if (bobp)
                        (throw 'point-stop nil)
                      (backward-char)))))))

      (if (not char)
          (message "[Evil-Wildfire]: Can not find a symbol in alist.")
        (setq second-char (evil-wildfire--get-second-char char)
              second-point (evil-wildfire-format-point char second-char))))
    (goto-char prefix-point)
    (push-mark second-point t t)))

(defun evil-wildfire-catch-by-char (char)
  "Catch region by CHAR."
  (interactive (list (char-to-string (read-char))))
  (if (evil-wildfire--get-second-char char)
      (evil-wildfire-catch char)
    (message "[Evil-Wildfire]: %s is not defined in the symbol alist." char)))

(defun evil-wildfire-format-point (prefix second-char)
  "Format point with the PREFIX."
  (let ((times 1)
        tmp)
    (forward-char)
    (while (/= times 0)
      (setq tmp (buffer-substring-no-properties (point) (1+ (point))))
      (cond ((and (string= tmp prefix) (not (string= prefix second-char)))
             (setq times (1+ times)))
            ((and (string= tmp second-char) (> times 0))
             (setq times (1- times)))
            ((and (string= tmp second-char) (= times -1))
             (setq times 0)))
      (forward-char))
    (point)))

(defun evil-wildfire--get-second-char (prefix)
  "Get the second char by the PREFIX."
  (catch 'second-char
    (dolist (char-cons evil-wildfire-global-symbol-alist)
      (when (string= prefix (car char-cons))
        (throw 'second-char (cdr char-cons))))))

(defun evil-wildfire--symbol-exists-p (symbol)
  "Check if the SYMBOL is exists."
  (catch 'exists
    (let ((index 0))
      (dolist (symbol-cons evil-wildfire-global-symbol-alist)
        (when (string= symbol (car symbol-cons))
          (throw 'exists index))
        (setq index (1+ index))))))

(defmacro evil-wildfire-mode-defalist (mode-name &rest alist)
  "Define alist for major mode."
  (declare (indent 1))
  `(let ((sym-alist evil-wildfire-global-symbol-alist)
         tmp)
     (dolist (list ,alist)
       (if (setq tmp (evil-wildfire--symbol-exists-p (car list)))
           (setf (cdr (nth tmp sym-alist)) (cdr list))
         (add-to-list 'sym-alist list)))
     (add-hook (intern (concat (symbol-name ,mode-name) "-hook"))
               `(lambda () (setq-local evil-wildfire-global-symbol-alist
                                       ,sym-alist)))))

;;; Init
(add-hook 'emacs-lisp-mode-hook
          #'(lambda () (setq-local evil-wildfire-global-symbol-alist
                                   (delete '("'" . "'")
                                           evil-wildfire-global-symbol-alist))))

(provide 'evil-wildfire)

;;; evil-wildfire.el ends here
