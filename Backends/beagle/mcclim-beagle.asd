(in-package :asdf-user)

(defsystem :mcclim-beagle/core
  :depends-on (:clim)
  :serial t
  :components ((:file "package")
               (:file "cocoa-util")))

(defsystem :mcclim-beagle/native
  :depends-on (:mcclim-beagle/core)
  :serial t
  :components ((:module "native"
                        :components ((:file "lisp-bezier-path")
                                     (:file "lisp-window")
                                     (:file "lisp-window-delegate")
                                     (:file "lisp-view"
                                            :depends-on ("lisp-bezier-path"))
                                     (:file "lisp-view-additional"
                                            :depends-on ("lisp-view"))
                                     (:file "lisp-scroller")
                                     (:file "lisp-slider")
                                     (:file "lisp-button")
                                     (:file "lisp-image")))))

(defsystem :mcclim-beagle/windowing
  :depends-on (:mcclim-beagle/native)
  :serial t
  :components ((:module "windowing"
                        :components ((:file "port")
                                     (:file "frame-manager")
                                     (:file "mirror")
                                     (:file "graft")))))

(defsystem :mcclim-beagle/native-panes
  :depends-on (:mcclim-beagle/windowing)
  :serial t
  :components ((:module "native-panes"
                        :components ((:file "beagle-scroll-bar-pane")
                                     (:file "beagle-slider-pane")
                                     ;; Basic buttons - not collections of buttons
                                     (:file "beagle-fundamental-button-pane")
                                     ;; Button collections (radio + checkbox)
                                     ;; (:file "beagle-button-collection-pane")
                                     (:file "scroller-pane-fix")))))

(defsystem :mcclim-beagle/output
  :depends-on (:mcclim-beagle/native-panes)
  :serial t
  :components ((:module "output"
                        :components ((:file "medium")
                                     (:file "fonts")))))

(defsystem :mcclim-beagle/input
  :depends-on ()
  :serial t
  :components ((:module "input"
                        :components ((:file "events")
                                     (:file "keysymdef")))))
(defsystem :mcclim-beagle/glimpse
  :depends-on ()
  :serial t
  :components ((:module "glimpse"
                        :components ((:file "glimpse")
                                     (:file "glimpse-support")
                                     (:file "glimpse-command-tables")
                                     (:file "glimpse-present-process"
                                            :depends-on ("glimpse" "glimpse-support"))
                                     (:file "glimpse-present-window"
                                            :depends-on ("glimpse" "glimpse-support"))
                                     (:file "glimpse-modeless-commands"
                                            :depends-on ("glimpse" "glimpse-support"))
                                     (:file "glimpse-process-commands"
                                            :depends-on ("glimpse" "glimpse-support"))
                                     (:file "glimpse-window-commands"
                                            :depends-on ("glimpse" "glimpse-support"))))))

(defsystem :mcclim-beagle/
  :depends-on ()
  :serial t
  :components ((:module "profile"
                        :components ((:file "profile")))))

(defsystem :mcclim-beagle/tests
  :depends-on ()
  :serial t
  :components ((:module "tests"
                        :components ((:file "drawing-tests")
                                     (:file "graft-tests")))))
