;;; -*- Mode: Lisp; Package: CLIM-INTERNALS -*-

;;;  (c) copyright 1998,1999,2000 by Michael McDonald (mikemac@mikemac.com)
;;;  (c) copyright 2000 by 
;;;           Iban Hatchondo (hatchond@emi.u-bordeaux.fr)
;;;           Julien Boninfante (boninfan@emi.u-bordeaux.fr)
;;;           Robert Strandh (strandh@labri.u-bordeaux.fr)

;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Library General Public
;;; License as published by the Free Software Foundation; either
;;; version 2 of the License, or (at your option) any later version.
;;;
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Library General Public License for more details.
;;;
;;; You should have received a copy of the GNU Library General Public
;;; License along with this library; if not, write to the 
;;; Free Software Foundation, Inc., 59 Temple Place - Suite 330, 
;;; Boston, MA  02111-1307  USA.

(in-package :CLIM-INTERNALS)

;; *application-frame* is in decls.lisp
(defvar *default-frame-manager* nil)

;;; Frame-Manager class

(defclass frame-manager ()
  ((port :initarg :port
	 :reader frame-manager-port)
   (frames :initform nil
	   :reader frame-manager-frames)
   )
  )

(defun frame-manager-p (x)
  (typep x 'frame-manager))

(defun find-frame-manager (&rest options &key port &allow-other-keys)
  (declare (special *frame-manager*))
  (if (boundp '*frame-manager*)
      *frame-manager*
    (if (and *default-frame-manager*
	     (frame-manager-p *default-frame-manager*))
	*default-frame-manager*
      (first (frame-managers (or port (apply #'find-port options)))))))

(defmacro with-frame-manager ((frame-manager) &body body)
  `(let ((*frame-manager* ,frame-manager))
     (declare (special *frame-manager*))
     (locally ,@body)))

;;; Application-Frame class
;;; XXX All these slots should move to a mixin or to standard-application-frame.
;;; -- moore

(defclass application-frame ()
  ((port :initform nil
	 :initarg :port
	 :accessor port)
   (graft :initform nil
	  :initarg :graft
	  :accessor graft)
   (name :initarg :name
	 :reader frame-name)
   (pretty-name :initarg :pretty-name
		:accessor frame-pretty-name)
   (command-table :initarg :command-table
		  :initform nil
		  :accessor frame-command-table)
   (disabled-commands :initarg :disabled-commands
		      :initform nil
		      :accessor frame-disabled-commands)
   (pane :reader frame-pane)
   (panes :initform nil
	  :reader frame-panes)
   (layouts :initform nil
	    :initarg :layouts
	    :reader frame-layouts)
   (current-layout :initform nil
		   :initarg :current-layout
		   :reader frame-current-layout)
   (top-level-sheet :initform nil
		    :reader frame-top-level-sheet)
   (menu-bar :initarg :menu-bar
	     :initform nil)
   (calling-frame :initarg :calling-frame
		  :initform nil)
   (state :initarg :state
	  :initform nil
	  :accessor frame-state)
   (manager :initform nil
	    :reader frame-manager
            :accessor %frame-manager)
   (properties :initarg :properties
	       :initform nil)
   (top-level :initform '(default-frame-top-level)
	      :initarg :top-level
	      :reader frame-top-level)
   (hilited-presentation :initform nil
			 :initarg :hilited-presentation
			 :accessor frame-hilited-presentation)))

(defun application-frame-p (x)
  (typep x 'application-frame))

(defmethod initialize-instance :after ((frame application-frame) &rest args)
  (declare (ignore args)))

;;; Generic operations
; (defgeneric frame-name (frame))
; (defgeneric frame-pretty-name (frame))
; (defgeneric (setf frame-pretty-name) (name frame))
; (defgeneric frame-command-table (frame))
; (defgeneric (setf frame-command-table) (command-table frame))
(defgeneric frame-standard-output (frame)
  (:documentation
   "Returns the stream that will be used for *standard-output* for the FRAME."))
(defgeneric frame-standard-input (frame)
  (:documentation
   "Returns the stream that will be used for *standard-input* for the FRAME."))
(defgeneric frame-query-io (frame)
  (:documentation
   "Returns the stream that will be used for *query-io* for the FRAME."))
(defgeneric frame-error-output (frame)
  (:documentation
   "Returns the stream that will be used for *error-output* for the FRAME."))
(defgeneric frame-pointer-documentation-output (frame)
  (:documentation
   "Returns the stream that will be used for *pointer-documentation-output*
for the FRAME."))
(defgeneric frame-calling-frame (frame)
  (:documentation
   "Returns the application frame that invoked the FRAME."))
(defgeneric frame-parent (frame)
  (:documentation
   "Returns the object that acts as the parent for the FRAME."))
;(defgeneric frame-pane (frame) ; XXX Is it in Spec?
;  (:documentation
;   "Returns the pane that is the top-level pane in the current layout
;of the FRAME's named panes."))
(defgeneric frame-top-level-sheet (frame)
  (:documentation
   "Returns the shhet that is the top-level sheet for the FRAME. This
is the sheet that has as its descendants all of the panes of the FRAME."))
(defgeneric frame-current-panes (frame)
  (:documentation
   "Returns a list of those named panes in the FRAME's current layout.
If there are no named panes, only the single, top level pane is returned."))
(defgeneric get-frame-pane (frame pane-name)
  (:documentation
   "Returns the named CLIM stream pane in the FRAME whose name is PANE-NAME."))
(defgeneric find-pane-named (frame pane-name)
  (:documentation
   "Returns the pane in the FRAME whose name is PANE-NAME."))
;(defgeneric frame-current-layout (frame))
;(defgeneric frame-all-layouts (frame)) ; XXX Is it in Spec?
(defgeneric layout-frame (frame &optional width height))
(defgeneric frame-exit-frame (condition)
  (:documentation
   "Returns the frame that is being exited from associated with the
FRAME-EXIT condition."))
(defgeneric frame-exit (frame) ; XXX Is it in Spec?
  (:documentation
   "Exits from the FRAME."))
(defgeneric pane-needs-redisplay (pane))
(defgeneric (setf pane-needs-redisplay) (value pane))
(defgeneric redisplay-frame-pane (frame pane &key force-p))
(defgeneric redisplay-frame-panes (frame &key force-p))
(defgeneric frame-replay (frame stream &optional region))
(defgeneric notify-user (frame message &key associated-window title
                         documentation exit-boxes name style text-style))
;(defgeneric frame-properties (frame property))
;(defgeneric (setf frame-properties) (value frame property))


(defclass standard-application-frame (application-frame)
  ((event-queue :initarg :frame-event-queue
		:accessor frame-event-queue
		:documentation "The event queue that, by default, will be
  shared by all panes in the stream")
   (documentation-state :accessor frame-documentation-state
			:initform nil
			:documentation "Used to keep of track of what
  needs to be rendered in the pointer documentation frame.")))

;;; Support the :input-buffer initarg for compatibility with "real CLIM"

(defmethod initialize-instance :after ((obj standard-application-frame)
				       &key (input-buffer nil input-buffer-p))
  (cond (input-buffer-p
	 (setf (frame-event-queue obj) input-buffer))
	((not (slot-boundp obj 'event-queue))
	 (setf (frame-event-queue obj) (make-instance 'standard-event-queue)))
	(t nil)))


(defmethod (setf frame-manager) (fm (frame application-frame))
  (let ((old-manager (frame-manager frame)))
    (setf (%frame-manager frame) nil)
    (when old-manager
      (disown-frame old-manager frame)
      (setf (slot-value frame 'panes) nil)
      (setf (slot-value frame 'layouts) nil))
    (setf (%frame-manager frame) fm)))

(defmethod (setf frame-current-layout) (name (frame application-frame))
  (declare (ignore name))
  (generate-panes (frame-manager frame) frame))

(defmethod generate-panes :before (fm  (frame application-frame))
  (declare (ignore fm))
  (when (and (slot-boundp frame 'pane)
	     (frame-pane frame))
    (sheet-disown-child (frame-top-level-sheet frame) (frame-pane frame))))

(defmethod generate-panes :after (fm  (frame application-frame))
  (declare (ignore fm))
  (sheet-adopt-child (frame-top-level-sheet frame) (frame-pane frame))
  (sheet-adopt-child (graft frame) (frame-top-level-sheet frame))
  (let ((space (compose-space (frame-top-level-sheet frame))))
    ;; automatically generates a window-configuation-event
    ;; which then calls allocate-space
    ;;
    ;; Not any longer, we turn of CONFIGURE-NOTIFY events until the
    ;; window is mapped and do the space allocation now, so that all
    ;; sheets will have their correct geometry at once. --GB
    (setf (sheet-region (frame-top-level-sheet frame))
	  (make-bounding-rectangle 0 0
				   (space-requirement-width space)
				   (space-requirement-height space)))
    (allocate-space (frame-top-level-sheet frame)
                    (space-requirement-width space)
                    (space-requirement-height space)) ))

(defmethod layout-frame ((frame application-frame) &optional width height)
  (let ((pane (frame-pane frame)))
    (if (and  width (not height))
	(error "LAYOUT-FRAME must be called with both WIDTH and HEIGHT or neither"))
    (if (and (null width) (null height))
	(let ((space (compose-space pane)))
	  (setq width (space-requirement-width space))
	  (setq height (space-requirement-height space))))
    (allocate-space pane width height)))

(defun find-pane-if (predicate panes)
  "Returns a pane satisfying PREDICATE in the forest growing from PANES"
  (loop for pane in panes
	do (map-over-sheets #'(lambda (p)
				(when (funcall predicate p)
				  (return-from find-pane-if p)))
			    pane)
	finally (return nil)))

(defun find-pane-of-type (panes type)
  (find-pane-if #'(lambda (pane) (typep pane type)) panes))

(defmethod frame-current-panes ((frame application-frame))
  (find-pane-if #'(lambda (pane) (pane-name pane))
                (frame-current-layout frame)))

(defmethod get-frame-pane ((frame application-frame) pane-name)
  (find-pane-if #'(lambda (pane)
                    (and (typep pane 'clim-stream-pane)
                         (eq pane-name
                             (pane-name pane))))
                (frame-panes frame)))

(defmethod find-pane-named ((frame application-frame) pane-name)
  (find-pane-if #'(lambda (pane)
                    (eq pane-name
                        (pane-name pane)))
                (frame-panes frame)))

(defmethod frame-standard-output ((frame application-frame))
  (or (find-pane-of-type (frame-panes frame) 'application-pane)
      (find-pane-of-type (frame-panes frame) 'interactor-pane)))

(defmethod frame-standard-input ((frame application-frame))
  (or (find-pane-of-type (frame-panes frame) 'interactor-pane)
      (frame-standard-output frame)))

(defmethod frame-query-io ((frame application-frame))
  (or (frame-standard-input frame)
      (frame-standard-output frame)))

(defmethod frame-error-output ((frame application-frame))
  (frame-standard-output frame))

(defvar *pointer-documentation-output* nil)

(defmethod frame-pointer-documentation-output ((frame application-frame))
  (find-pane-of-type (frame-panes frame) 'pointer-documentation-pane))

;;; Command loop interface

(define-condition frame-exit (condition)
  ((frame :initarg :frame :reader %frame-exit-frame)))

(defmethod frame-exit ((frame standard-application-frame))
  (signal 'frame-exit :frame frame))

(defmethod frame-exit-frame ((c frame-exit))
  (%frame-exit-frame c))

(defmethod run-frame-top-level ((frame application-frame) &key &allow-other-keys)
  (handler-bind ((frame-exit #'(lambda (condition)
                                 (declare (ignore condition))
				 (return-from run-frame-top-level nil))))
    (apply (first (frame-top-level frame)) frame (rest (frame-top-level frame)))))

(defmethod run-frame-top-level :around ((frame application-frame) &key)
  (let ((*application-frame* frame)
	(*input-context* nil)
	(*input-wait-test* nil)
	(*input-wait-handler* nil)
	(*pointer-button-press-handler* nil))
    (declare (special *input-context* *input-wait-test* *input-wait-handler*
		      *pointer-button-press-handler*))
    (let ((query-io (frame-query-io frame)))
      (if query-io
	  (with-input-focus (query-io)
	    (call-next-method))
	  (call-next-method)))))

(defmethod default-frame-top-level
    ((frame application-frame)
     &key (command-parser 'command-line-command-parser)
	  (command-unparser 'command-line-command-unparser)
	  (partial-command-parser
	   'command-line-read-remaining-arguments-for-partial-command)
	  (prompt "Command: "))
  (loop
    (let ((*standard-input* (frame-standard-input frame))
	  (*standard-output* (frame-standard-output frame))
	  (*query-io* (frame-query-io frame))
	  (*pointer-documentation-output* (frame-pointer-documentation-output
					   frame))
	  ;; during development, don't alter *error-output*
          ;; (*error-output* (frame-error-output frame))
	  (*command-parser* command-parser)
	  (*command-unparser* command-unparser)
	  (*partial-command-parser* partial-command-parser)
	  (prompt-style (make-text-style :fix :italic :normal)))
      (map-over-sheets #'(lambda (pane)
			   (if (and (typep pane 'clim-stream-pane)
				    (eq (pane-display-time pane) :command-loop)
				    (pane-display-function pane))
			       (let ((func (pane-display-function pane)))
				 (window-clear pane)
				 (funcall func frame pane) ; XXX other arguments
                                        ; XXX incremental redisplay
                                 )))
		       (frame-top-level-sheet frame))
      (when *standard-input*
	(setf (cursor-visibility (stream-text-cursor *standard-input*)) t)
	(when prompt
	  (with-text-style (*standard-input* prompt-style)
	    (if (stringp prompt)
		(write-string prompt *standard-input*)
	      (funcall prompt *standard-input* frame))
	    (finish-output *standard-input*)))
	(let ((command (read-frame-command frame)))
	  (fresh-line *standard-input*)
	  (when command
	    (execute-frame-command frame command))
	  (fresh-line *standard-input*))))))


(defmethod read-frame-command ((frame application-frame) &key (stream *standard-input*))
  (read-command (frame-command-table frame) :stream stream))

(defmethod execute-frame-command ((frame application-frame) command)
  (apply (command-name command) (command-arguments command)))

(defmethod make-pane-1 ((fm frame-manager) (frame application-frame) type &rest args)
  `(make-pane-1 ,fm ,frame ',type ,@args))

(defmethod make-pane-1 :around (fm (frame standard-application-frame) type
				&rest args
				&key (input-buffer nil input-buffer-p))
  "Default input-buffer to the frame event queue."
  (if input-buffer-p
      (call-next-method)
      (apply #'call-next-method fm frame type
	     :input-buffer (frame-event-queue frame)
	     args)))

(defmethod adopt-frame ((fm frame-manager) (frame application-frame))
  (setf (slot-value fm 'frames) (cons frame (slot-value fm 'frames)))
  (setf (frame-manager frame) fm)
  (let* ((*application-frame* frame)
	 (t-l-s (make-pane-1 fm frame 'top-level-sheet-pane
			     :name 'top-level-sheet)))
    (setf (slot-value frame 'top-level-sheet) t-l-s)
    (generate-panes fm frame)))

(defmethod disown-frame ((fm frame-manager) (frame application-frame))
  (setf (slot-value fm 'frames) (remove frame (slot-value fm 'frames)))
  (sheet-disown-child (graft frame) (frame-top-level-sheet frame))
  (setf (%frame-manager frame) nil))

(defvar *pane-realizer* nil)

(defmacro with-look-and-feel-realization ((frame-manager frame) &body body)
  `(let ((*pane-realizer* ,frame-manager)
	 (*application-frame* ,frame))
     (locally
         ,@body)))

; The menu-bar code in the following two functions is incorrect.
; it needs to be moved to somewhere after the backend, since
; it depends on the backend chosen.
;
; This hack slaps a menu-bar into the start of the application-frame,
; in such a way that it is hard to find.
;
; FIXME
(defun make-single-pane-generate-panes-form (class-name menu-bar pane)
  `(defmethod generate-panes ((fm frame-manager) (frame ,class-name))
     ; v-- hey, how can this be?
     (with-look-and-feel-realization (fm frame)
       (let ((pane ,(cond
                      ((eq menu-bar t)
                       `(vertically () (clim-internals::make-menu-bar
                                         ',class-name)
                                       ,pane))
                      ((consp menu-bar)
                       `(vertically () (clim-internals::make-menu-bar
                                         (make-command-table nil
                                              :menu ',menu-bar))
                                       ,pane))
                      (menu-bar
                       `(vertically () (clim-internals::make-menu-bar
                                        ',menu-bar)
                                      ,pane))
                      ;; The form below is unreachable with (listp
                      ;; menu-bar) instead of (consp menu-bar) above
                      ;; --GB
                      (t pane))))
         (setf (slot-value frame 'pane) pane)))))

; could do with some refactoring [BTS] FIXME
(defun make-panes-generate-panes-form (class-name menu-bar panes layouts
				       pointer-documentation)
  (when pointer-documentation
    (setf panes (append panes
			'((%pointer-documentation%
			   pointer-documentation-pane)))))
  `(defmethod generate-panes ((fm frame-manager) (frame ,class-name))
     (let ((*application-frame* frame))
       (with-look-and-feel-realization (fm frame)
	 (let ,(loop for (name . form) in panes
		     collect `(,name (or (find-pane-named frame ',name)
					 (let ((pane
						,(cond
						  ((and (= (length form) 1)
							(listp (first form)))
						   (first form))
						  ((keywordp (first form))
						   (let ((maker (intern (concatenate 'string
									  "MAKE-CLIM-"
									  (symbol-name (first form))
									  "-PANE") :clim)))
						     (if (fboundp maker)
							 `(,maker :name ',name ,@(cdr form))
						       `(make-pane ',(first form)
								   :name ',name ,@(cdr form)))))
						  (t `(make-pane ',(first form) :name ',name ,@(cdr form))))))
                                           ;; hmm?! --GB
                                           (setf (slot-value pane 'name) ',name)
                                           ;;
					   (push pane (slot-value frame 'panes))
					   pane))))
           ; [BTS] added this, but is not sure that this is correct for adding
           ; a menu-bar transparently, should also only be done where the
           ; exterior window system does not support menus
          ,(if (or menu-bar pointer-documentation)
	      `(setf (slot-value frame 'pane)
	         (ecase (frame-current-layout frame)
	           ,@(mapcar (lambda (layout)
                               `(,(first layout)
				 (vertically ()
				  ,@(cond
				     ((eq menu-bar t)
				      `((clim-internals::make-menu-bar
					',class-name)))
				     ((consp menu-bar)
				      `((raising (:border-width 2 :background +Gray83+)
					 (clim-internals::make-menu-bar
					  (make-command-table
					   nil
					   :menu ',menu-bar)))))
				     (menu-bar
				      `((clim-internals::make-menu-bar
					 ',menu-bar)))
				     (t nil))
				  ,@(rest layout)
				  ,@(when pointer-documentation
					  '(%pointer-documentation%)))))
                             layouts)))
	      `(setf (slot-value frame 'pane)
	         (ecase (frame-current-layout frame)
	           ,@layouts))))))))

(defmacro define-application-frame (name superclasses slots &rest options)
  (if (null superclasses)
      (setq superclasses '(standard-application-frame)))
  (let ((pane nil)
	(panes nil)
	(layouts nil)
	(current-layout nil)
	(command-table (list name))
	(menu-bar t)
	(disabled-commands nil)
	(command-definer t)
	(top-level '(default-frame-top-level))
	(others nil)
	(command-name (intern (concatenate 'string "DEFINE-" (symbol-name name)
					   "-COMMAND")))
	(pointer-documentation nil))
    (loop for (prop . values) in options
	do (case prop
	     (:pane (setq pane (first values)))
	     (:panes (setq panes values))
	     (:layouts (setq layouts values))
	     (:command-table (setq command-table (first values)))
	     (:menu-bar (setq menu-bar (if (listp values)
                                           (first values)
                                           values)))
	     (:disabled-commands (setq disabled-commands values))
	     (:command-definer (setq command-definer (first values)))
	     (:top-level (setq top-level (first values)))
	     (:pointer-documentation (setq pointer-documentation (car values)))
	     (t (push (cons prop values) others))))
    (if (or (and pane panes)
	    (and pane layouts))
	(error ":pane cannot be specified along with either :panes or :layouts"))
    (if pane
	(setq panes (list 'single-pane pane)
	      layouts `((:default ,(car pane)))))
    (setq current-layout (first (first layouts)))
    `(progn
       (defclass ,name ,superclasses
	 ,slots
	 (:default-initargs
	   :name ',name
	   :pretty-name ,(string-capitalize name)
	   :command-table (find-command-table ',(first command-table))
	   :disabled-commands ',disabled-commands
	   :menu-bar ',menu-bar
	   :current-layout ',current-layout
	   :layouts ',layouts
	   :top-level ',top-level
	     )
	 ,@others)
       ,(if pane
	    (make-single-pane-generate-panes-form name menu-bar pane)
            (make-panes-generate-panes-form name menu-bar panes layouts
					    pointer-documentation))
       ,@(if command-table
	     `((define-command-table ,@command-table)))
       ,@(if command-definer
	     `((defmacro ,command-name (name-and-options arguements &rest body)
		 (let ((name (if (listp name-and-options) (first name-and-options) name-and-options))
		       (options (if (listp name-and-options) (cdr name-and-options) nil))
		       (command-table ',(first command-table)))
		   `(define-command (,name :command-table ,command-table ,@options) ,arguements ,@body))))))))

(defun make-application-frame (frame-name
			       &rest options
			       &key pretty-name frame-manager enable state
				    left top right bottom width height save-under
				    frame-class
			       &allow-other-keys)
  (declare (ignore enable state left top right bottom width height save-under))
  (setq options (loop for (key value) on options by #'cddr
		    if (not (member key '(:pretty-name :frame-manager :enable :state
					  :left :top :right :bottom :width :height :save-under
					  :frame-class)
				    :test #'eq))
		       nconc (list key value)))
  (if (null frame-class)
      (setq frame-class frame-name))
  (if (null pretty-name)
      (setq pretty-name (string-capitalize frame-name)))
  (if (null frame-manager)
      (setq frame-manager (find-frame-manager)))
  (let ((frame (apply #'make-instance frame-class
		      :port (frame-manager-port frame-manager)
		      :graft (find-graft :port (frame-manager-port frame-manager))
		      :name frame-name :pretty-name pretty-name options)))
    (adopt-frame frame-manager frame)
    frame))

;;; Menu frame class

(defclass menu-frame ()
  ((left :initform 0 :initarg :left)
   (top :initform 0 :initarg :top)
   (top-level-sheet :initform nil :reader frame-top-level-sheet)
   (pane :reader frame-pane :initarg :pane)
   (graft :initform nil :accessor graft)
   (manager :initform nil :accessor frame-manager)))

(defmethod adopt-frame ((fm frame-manager) (frame menu-frame))
  (setf (slot-value fm 'frames) (cons frame (slot-value fm 'frames)))
  (setf (frame-manager frame) fm)
  (let* ((t-l-s (make-pane-1 fm *application-frame* 'unmanaged-top-level-sheet-pane
			     :name 'top-level-sheet)))
    (setf (slot-value frame 'top-level-sheet) t-l-s)
    (sheet-adopt-child t-l-s (frame-pane frame))
    (let ((graft (find-graft :port (frame-manager-port fm))))
      (sheet-adopt-child graft t-l-s)
      (setf (graft frame) graft))
    (let ((space (compose-space t-l-s)))
      (allocate-space (frame-pane frame)
		      (space-requirement-width space)
		      (space-requirement-height space))
      (setf (sheet-region t-l-s)
	    (make-bounding-rectangle 0 0
				     (space-requirement-width space)
				     (space-requirement-height space))))
    (setf (sheet-transformation t-l-s)
	  (make-translation-transformation (slot-value frame 'left)
					   (slot-value frame 'top)))))

(defmethod disown-frame ((fm frame-manager) (frame menu-frame))
  (setf (slot-value fm 'frames) (remove frame (slot-value fm 'frames)))
  (sheet-disown-child (graft frame) (frame-top-level-sheet frame))
  (setf (frame-manager frame) nil))

(defun make-menu-frame (pane &key (left 0) (top 0))
  (make-instance 'menu-frame :pane pane :left left :top top))

;;; Frames and presentations

(defmethod frame-find-innermost-applicable-presentation
    ((frame standard-application-frame) input-context stream x y
     &key event)
  (find-innermost-applicable-presentation input-context stream
					  x y
					  :frame frame :event event))

(defmethod frame-input-context-button-press-handler
    ((frame standard-application-frame)
     (stream output-recording-stream)
     button-press-event)
  (let ((presentation (find-innermost-applicable-presentation
		       *input-context*
		       stream
		       (pointer-event-x button-press-event)
		       (pointer-event-y button-press-event)
		       :frame frame
		       :event button-press-event)))
    (when presentation
      (throw-highlighted-presentation presentation
				      *input-context*
				      button-press-event))))

(defmethod frame-input-context-button-press-handler
    ((frame standard-application-frame) stream button-press-event)
  (declare (ignore stream button-press-event))
  nil)

(defgeneric frame-update-pointer-documentation
    (frame input-context stream event))

(defconstant +button-documentation+ '((#.+pointer-left-button+ "L")
				      (#.+pointer-middle-button+ "M")
				      (#.+pointer-right-button+ "R")))

(defmethod frame-update-pointer-documentation
    ((frame standard-application-frame) input-context stream event)
  (when *pointer-documentation-output*
    (with-accessors ((frame-documentation-state frame-documentation-state))
	frame
      (destructuring-bind (&optional modifier-bits translators)
	  frame-documentation-state
	(let* ((current-modifier (event-modifier-state event))
	       (x (pointer-event-x event))
	       (y (pointer-event-y event))
	       (new-translators
		(loop for (button) in +button-documentation+
		      for context-list = (multiple-value-list
					  (find-innnermost-presentation-context
					   input-context
					   stream
					   x y
					   :modifier-state current-modifier
					   :button button))
		      when (car context-list)
		      collect (cons button context-list))))
	  (unless (and (eql modifier-bits current-modifier)
		       (equal translators new-translators))
	    ;; State is different, so print out new documentation
	    (window-clear *pointer-documentation-output*)
	    (loop for (button presentation translator context)
		    in new-translators
		  for name = (cadr (assoc button +button-documentation+))
		  do (progn
		       (format *pointer-documentation-output* "~A: " name)
		       (document-presentation-translator
			translator
			presentation
			(input-context-type context)
			*application-frame*
			event
			stream
			x y
			:stream *pointer-documentation-output*
			:documentation-type :pointer)
		       (write-string " " *pointer-documentation-output*)))
	    (setq frame-documentation-state (list current-modifier
						  new-translators))))))))

(defmethod frame-input-context-track-pointer
    ((frame standard-application-frame)
     input-context
     (stream output-recording-stream) event)
  (declare (ignore input-context event))
  nil)

(defmethod frame-input-context-track-pointer
    ((frame standard-application-frame) input-context stream event)
  (declare (ignore input-context stream event))
  nil)

(defmethod frame-input-context-track-pointer :before
    ((frame standard-application-frame) input-context stream event)
  (flet ((maybe-unhighlight (presentation)
	   (when (and (frame-hilited-presentation frame)
		      (not (eq presentation
			       (car (frame-hilited-presentation frame)))))
	     (highlight-presentation-1 (car (frame-hilited-presentation frame))
				       (cdr (frame-hilited-presentation frame))
				       :unhighlight))))
    (if (output-recording-stream-p stream)
	(let ((presentation (find-innermost-applicable-presentation
			     input-context
			     stream
			     (pointer-event-x event)
			     (pointer-event-y event)
			     :frame frame
			     :modifier-state (event-modifier-state event))))
	  (maybe-unhighlight presentation)
	  (if presentation
	      (when (not (eq presentation
			     (car (frame-hilited-presentation frame))))
		(setf (frame-hilited-presentation frame)
		      (cons presentation stream))
		(highlight-presentation-1 presentation stream :highlight))
	      (setf (frame-hilited-presentation frame) nil)))
	(progn
	  (maybe-unhighlight nil)
	  (setf (frame-hilited-presentation frame) nil))))
  (frame-update-pointer-documentation frame input-context stream event))


(defun simple-event-loop ()
  "An simple event loop for applications that want all events to be handled by
 handle-event methods"
  (let ((queue (frame-event-queue *application-frame*)))
    (loop for event = (event-queue-read queue)
       ;; EVENT-QUEUE-READ in single-process mode calls PROCESS-NEXT-EVENT itself.
       do (handle-event (event-sheet event) event))))
