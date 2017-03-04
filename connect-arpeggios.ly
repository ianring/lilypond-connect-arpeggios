\version "2.13.3"

% by Mark Polesky
% http://lilypond.1069038.n5.nabble.com/cross-staff-versions-of-arpeggioArrowUp-etc-td119964.html#none

%%%%%% begin property-init.ly revision %%%%%%

#(define (arpeggio-generic pushpops)
  (lambda (context)
    (let* ((parent
             (ly:context-property-where-defined context
                                                'connectArpeggios))
           (target
             (if (and (not (null? parent))
                      (eq? #t (ly:context-property parent
                                                   'connectArpeggios)))
                 parent
                 context)))
      (for-each
        (lambda (pushpop)
          (if (pair? pushpop)
              (ly:context-pushpop-property target
                                           'Arpeggio
                                           (car pushpop)
                                           (cdr pushpop))
              (ly:context-pushpop-property target
                                           'Arpeggio
                                           pushpop)))
        pushpops))))

#(define (find-spannable-context context)
  (let ((spannable-contexts '(GrandStaff PianoStaff StaffGroup)))
    (if (member (ly:context-name context) spannable-contexts)
        context
        (let ((parent (ly:context-parent context)))
          (if parent
              (let ((parent-name (ly:context-name parent)))
                (if (member parent-name spannable-contexts)
                    parent
                    (find-spannable-context parent)))
              #f)))))

#(define (move-arpeggio-generic origin destination)
  ;; origin and destination are contexts
  (let* ((Arpeggio (ly:context-grob-definition origin 'Arpeggio))
         (X-extent           (assoc 'X-extent           Arpeggio))
         (stencil            (assoc 'stencil            Arpeggio))
         (arpeggio-direction (assoc 'arpeggio-direction Arpeggio))
         (direction          (assoc 'direction          Arpeggio))
         (dash-definition    (assoc 'dash-definition    Arpeggio))
         (props `((X-extent           . ,X-extent)
                  (stencil            . ,stencil)
                  (arpeggio-direction . ,arpeggio-direction)
                  (direction          . ,direction)
                  (dash-definition    . ,dash-definition))))
    (for-each
      (lambda (prop)
        ;; copy <origin>.Arpeggio props to <destination>.Arpeggio
        (if (cdr prop)
            (ly:context-pushpop-property destination
                                         'Arpeggio
                                         (cadr prop)
                                         (cddr prop))
            (ly:context-pushpop-property destination
                                         'Arpeggio
                                         (car prop)))
        ;; revert <origin>.Arpeggio props
        (ly:context-pushpop-property origin 'Arpeggio (car prop)))
      props)))

#(define (move-arpeggio-to-spannable-context context)
  ;; move the active arpeggio properties to the closest GrandStaff,
  ;; PianoStaff, or StaffGroup parent that can be found.
  (let ((target (find-spannable-context context)))
    (if target (move-arpeggio-generic context target))))

#(define (move-arpeggio-to-this-context context)
  ;; move any arpeggio props, active in a parent context where
  ;; 'connectArpeggios is #t, to this context (usually Voice).
  (let ((origin (ly:context-property-where-defined context
                                                   'connectArpeggios)))
    (if (and (not (null? origin))
             (eq? #t (ly:context-property origin 'connectArpeggios)))
        (move-arpeggio-generic origin context))))

#(define (connect-arpeggios-switch value)
  (lambda (context)
    (let ((target (find-spannable-context context)))
      (if target
          (ly:context-set-property! target 'connectArpeggios value)
          (ly:warning "No viable context found for connectArpeggios")))))

connectArpeggiosOn = {
  \applyContext #move-arpeggio-to-spannable-context
  \applyContext #(connect-arpeggios-switch #t)
}

connectArpeggiosOff = {
  \applyContext #move-arpeggio-to-this-context
  \applyContext #(connect-arpeggios-switch #f)
}

arpeggioArrowUp =
  \applyContext
    #(arpeggio-generic `(stencil
                         X-extent
                         (arpeggio-direction . ,UP)))

arpeggioArrowDown =
  \applyContext
    #(arpeggio-generic `(stencil
                         X-extent
                         (arpeggio-direction . ,DOWN)))

arpeggioNormal =
  \applyContext
    #(arpeggio-generic '(stencil
                         X-extent
                         arpeggio-direction
                         dash-definition))

arpeggioBracket =
  \applyContext
    #(arpeggio-generic `(X-extent
                         (stencil . ,ly:arpeggio::brew-chord-bracket)))


%%%%%% end property-init.ly revision %%%%%%



