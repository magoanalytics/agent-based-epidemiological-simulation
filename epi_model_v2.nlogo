globals [
  quarantined-count
  death-count
  max-infected-count
  variance-infected-count
  mean-infected-count
  movement
  trace-list
]

; turtle-level properties
turtles-own [
  vulnerability
  infected?
  recovered?
  infected-duration
  quarantined-duration
  recovery-rate
  recovery-time
  death-rate
  quarantined?
  infected-count
  agents-proximity
  asymptomatic?
  elder?
  male?
  traced?
]

patches-own [
  border?
  quarantine?
]

to initialized-patches
  ; define quarantine patches
  ask patches [set quarantine? false]
  ask patches with [(pxcor = 0 and pycor = 0) or (pxcor = 1 and pycor = 1) or (pxcor = -1 and pycor = -1) or (pxcor = -1 and pycor = 1) or (pxcor = 1 and pycor = -1) or
                    (pxcor = 0 and pycor = 1) or (pxcor = 0 and pycor = -1) or (pxcor = 1 and pycor = 0) or (pxcor = -1 and pycor = 0)] [
    set pcolor 48
    set quarantine? true
  ]

  ; define border patches
  ask patches [set border? false]
  ask patches with [((pxcor >= -2 and pxcor <= 2) or (pycor >= -2 and pycor <= 2) or (pxcor >= (- (max-pxcor * 0.5) - 2) and pxcor <= (- (max-pxcor * 0.5) + 2)) or
                    (pxcor >= ((max-pxcor * 0.5) - 2) and pxcor <= ((max-pxcor * 0.5) + 2)) or (pycor >= (- (max-pycor * 0.5) - 2) and pycor <= (- (max-pycor * 0.5) + 2)) or
                    (pycor >= ((max-pycor * 0.5) - 2) and pycor <= ((max-pycor * 0.5) + 2))) and not quarantine?] [
    set pcolor 41
    set border? true
  ]
end

to initialize-population
  create-turtles initial-population [
    move-to one-of patches with [border? = false and quarantine? = false]
    set shape "person"
    set color green

    set vulnerability random-normal average-vulnerability (average-vulnerability / 5)
    if vulnerability > 100 [set vulnerability 100]
    if vulnerability < 0 [set vulnerability 0]

    set infected? false
    set recovered? false
    set quarantined? false
    set infected-duration 0
    set quarantined-duration 0

    set recovery-time random-normal average-recovery-time (7 * 24)
    if recovery-time > ((average-recovery-time) + (3 * 7 * 24)) [set recovery-time ((average-recovery-time) + (3 * 7 * 24))]
    if recovery-time < 0 [set recovery-time 0]

    set recovery-rate random-normal average-recovery-rate (average-recovery-rate / 5)
    if recovery-rate > 100 [set recovery-rate 100]
    if recovery-rate < 0 [set recovery-rate 10]

    set death-rate random-normal average-death-rate (average-death-rate / 5)
    if death-rate < 0 [set death-rate 0]

    set infected-count 0
    set agents-proximity turtles in-radius 1

    set elder? False
    set male? False
    set traced? False
  ]

  ; fixed initial condition
  ask n-of initial-infected turtles [
    setxy -24 24
    set color red
    set infected? True
    set asymptomatic? True
  ]

  ; fixed initial elder proportion
  ask n-of (elder-fraction * 0.01 * initial-population) turtles [
    set elder? True
  ]

  ; fixed initial gender proportion
  ask n-of (male-fraction * 0.01 * initial-population) turtles [
    set male? True
  ]

  set quarantined-count 0
  set death-count 0
  set max-infected-count 0
  set variance-infected-count 0
  set mean-infected-count 0
  ifelse infected-movement? = True
  [set movement 0.5]
  [set movement 1]
  set trace-list turtles with [quarantined? = True]
end

to move
  let nearest-neighbor min-one-of (other turtles in-radius 2) [distance myself]
  ifelse random 100 < social-distancing-intensity [
    ifelse nearest-neighbor != nobody [
      face nearest-neighbor
      rt 180
      let patch-in-front patch-ahead 1
      if patch-in-front != nobody [
        ifelse [quarantine?] of patch-in-front = true [
          ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
          [rt 180 fd 0.5 * movement]
          [rt 180 fd 0.5]
        ]
        [
          ifelse [border?] of patch-in-front = true and random 100 < lockdown-intensity
          [ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
            [rt 180 fd 0.5 * movement]
            [rt 180 fd 0.5]
          ]
          [ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
            [fd 0.5 * movement]
            [fd 0.5]
          ]
        ]
      ]
    ]
    [
      rt random-float 360
      let patch-in-front patch-ahead 1
      if patch-in-front != nobody [
        ifelse [quarantine?] of patch-in-front = true [
          ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
          [rt 180 fd 0.5 * movement]
          [rt 180 fd 0.5]
        ]
        [
          ifelse [border?] of patch-in-front = true and random 100 < lockdown-intensity
          [ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
            [rt 180 fd 0.5 * movement]
            [rt 180 fd 0.5]
          ]
          [ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
            [fd 0.5 * movement]
            [fd 0.5]
          ]
        ]
      ]
    ]
  ]
  [
    rt random-float 360
    let patch-in-front patch-ahead 1
    if patch-in-front != nobody [
      ifelse [quarantine?] of patch-in-front = true [
        ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
        [rt 180 fd 1 * movement]
        [rt 180 fd 1]
      ]
      [
        ifelse [border?] of patch-in-front = true and random 100 < lockdown-intensity
        [ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
          [rt 180 fd 1 * movement]
          [rt 180 fd 1]
        ]
        [ifelse [infected?] of self = true and infected-movement? = true and asymptomatic? = False
          [fd 1 * movement]
          [fd 1]
        ]
      ]
    ]
  ]
end

to quarantine
  ; add variance to quarantine delays
  let delay random-normal (quarantine-delay * 24) 4
  if delay < 0 [set delay 0]

  if infected-duration >= delay [
    set quarantined-count quarantined-count + 1
    move-to one-of patches with [quarantine? = True]
    set quarantined? true
  ]
end

to infect
  let nearby-neighbors turtles in-radius 1 with [not infected? and not recovered? and not quarantined?]
  if ([quarantined?] of self = false) and nearby-neighbors != nobody[
    ask nearby-neighbors [
      if random 100 < vulnerability [
        set color red
        set infected? true
        ifelse asymptomatic-fraction > 0 and random 100 < asymptomatic-fraction
        [set asymptomatic? True set color yellow]
        [set asymptomatic? False]
        ask myself [set infected-count infected-count + 1]
      ]
    ]
  ]
end

to die-infected
  ; elder and male agents have increased fatality rate
  let fatality death-rate
  if [elder?] of self = True [set fatality fatality * 0.18]
  if [male?] of self = True [set fatality fatality * 2]

  if random-float 100 < fatality [
    set death-count death-count + 1
    die
  ]
end

to recover
  if infected-duration >= recovery-time [
    if random-float 100 < recovery-rate [
      set color blue
      set infected? false
      set recovered? true
      if [quarantined?] of self = True [
        move-to one-of patches with [quarantine? = False]
        set quarantined? False
        set quarantined-count quarantined-count - 1
      ]
    ]
  ]
end

to trace-contact
  ; ask each susceptible and not in quarantine agents to keep records of close contacts
  ask turtles with [recovered? = False and quarantined? = False] [
    let nearby-neighbors turtles in-radius 1
    set agents-proximity (turtle-set nearby-neighbors agents-proximity)
  ]

  ask turtles-on patches with [quarantine? = True] [
    ; add variance to contact tracing delays
    let delay random-normal (contact-tracing-delay * 24) 4
    if delay < 0 [set delay 0]

    if traced? = False and quarantined-duration >= contact-tracing-delay * 24 [
      set trace-list (turtle-set agents-proximity trace-list)
      set traced? True
    ]
  ]

  ask trace-list with [infected? = True][
    set quarantined-count quarantined-count + 1
    move-to one-of patches with [quarantine? = True]
    set quarantined? true
  ]
  set trace-list trace-list with [quarantined? = False]
end

to update-turtle-params
  ask turtles with [infected? = True] [set infected-duration infected-duration + 1]
  ask turtles with [quarantined? = True] [set quarantined-duration quarantined-duration + 1]
end

to update-infected-count
  if count turtles with [infected-count > 0] > 0 [
    set max-infected-count max [infected-count] of turtles with [infected-count > 0]
    set mean-infected-count mean [infected-count] of turtles with [infected-count > 0]
  ]
  if count turtles with [infected-count > 0] >= 2 [
    set variance-infected-count standard-deviation [infected-count] of turtles with [infected-count > 0]
  ]
end

;==========================================================
to setup
  clear-all
  initialized-patches
  initialize-population
  reset-ticks
end

to go
  if count turtles with [infected? = true] = 0 [stop]
  ask turtles with [quarantined? = false] [move]
  if ticks mod 24 = 0 and ticks != 0 [
    if count turtles with [quarantined? = false] > 0 [
      ask n-of (mass-testing-intensity * 0.01 * count turtles with [quarantine? = false]) turtles with [quarantined? = false] [
        if [infected?] of self = true and (count turtles-on patches with [quarantine? = True] < health-capacity * 0.01 * 5000) and random 100 < testing-accuracy [
          quarantine
        ]
      ]
    ]
  ]

  ask turtles with [infected? = true] [
    infect
    die-infected
    recover
  ]

  if contact-tracing? = True [
    trace-contact
  ]
  update-turtle-params
  update-infected-count
  tick
end
;==========================================================
@#$#@#$#@
GRAPHICS-WINDOW
431
10
849
429
-1
-1
2.04
1
10
1
1
1
0
0
0
1
-100
100
-100
100
1
1
1
ticks
30.0

BUTTON
327
10
393
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
10
168
43
initial-population
initial-population
10
5000
5000.0
1
1
NIL
HORIZONTAL

BUTTON
327
43
393
77
Run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
76
168
109
average-vulnerability
average-vulnerability
0
100
100.0
1
1
NIL
HORIZONTAL

PLOT
0
188
353
385
Population Partitioned by Health Status
time (hours)
Partition Count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"infected" 1.0 0 -2674135 true "" "plot count turtles with [infected?]"
"recovered" 1.0 0 -13345367 true "" "plot count turtles with [recovered?]"

MONITOR
353
188
432
233
active cases 
count turtles with [infected?]
0
1
11

SLIDER
0
109
168
142
average-recovery-rate
average-recovery-rate
0
100
90.0
1
1
NIL
HORIZONTAL

SLIDER
168
43
327
76
initial-infected
initial-infected
1
10
1.0
1
1
NIL
HORIZONTAL

CHOOSER
0
142
168
187
average-recovery-time
average-recovery-time
336 504 672
1

SLIDER
168
142
336
175
average-death-rate
average-death-rate
0
1
0.02
0.01
1
NIL
HORIZONTAL

MONITOR
353
233
432
278
death count
death-count
17
1
11

SLIDER
874
78
1037
111
quarantine-delay
quarantine-delay
0
7
7.0
1
1
NIL
HORIZONTAL

SLIDER
168
109
353
142
lockdown-intensity
lockdown-intensity
0
100
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
874
44
1037
77
mass-testing-intensity
mass-testing-intensity
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
168
76
353
109
social-distancing-intensity
social-distancing-intensity
0
100
0.0
1
1
NIL
HORIZONTAL

MONITOR
291
385
431
430
max infected-count
max-infected-count
17
1
11

MONITOR
147
385
291
430
variance infected-count
variance-infected-count
2
1
11

MONITOR
0
385
147
430
mean infected-count
mean-infected-count
2
1
11

SLIDER
874
10
1037
43
health-capacity
health-capacity
0
100
25.0
1
1
NIL
HORIZONTAL

SWITCH
874
188
1043
221
infected-movement?
infected-movement?
0
1
-1000

SLIDER
874
221
1047
254
asymptomatic-fraction
asymptomatic-fraction
0
100
20.0
1
1
NIL
HORIZONTAL

MONITOR
995
111
1116
156
current-capacity
count turtles-on patches with [quarantine? = True]
0
1
11

SLIDER
874
277
1026
310
testing-accuracy
testing-accuracy
0
100
100.0
1
1
NIL
HORIZONTAL

SWITCH
1038
45
1184
78
contact-tracing?
contact-tracing?
1
1
-1000

MONITOR
875
111
995
156
health facility capacity
health-capacity * 0.01 * initial-population
2
1
11

SLIDER
0
43
168
76
elder-fraction
elder-fraction
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
168
10
327
43
male-fraction
male-fraction
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
1038
78
1184
111
contact-tracing-delay
contact-tracing-delay
0
7
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Sensitivity Analysis -&gt; mass testing and delay" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [infected? = True]</metric>
    <enumeratedValueSet variable="initial-infected">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-vulnerability">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="health-capacity">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-death-rate">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-fraction">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testing-accuracy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contact-tracing?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="elder-fraction">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-recovery-time">
      <value value="504"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-movement?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="asymptomatic-fraction">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-testing-intensity">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-recovery-rate">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quarantine-delay">
      <value value="1"/>
      <value value="3"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contact-tracing-delay">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-distancing-intensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown-intensity">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Sensitivity Analysis -&gt; 0 delay" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [infected? = True]</metric>
    <enumeratedValueSet variable="initial-infected">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-vulnerability">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-death-rate">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="health-capacity">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-fraction">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testing-accuracy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contact-tracing?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="elder-fraction">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-recovery-time">
      <value value="504"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-movement?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="asymptomatic-fraction">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-testing-intensity">
      <value value="30"/>
      <value value="60"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-recovery-rate">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quarantine-delay">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contact-tracing-delay">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-distancing-intensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown-intensity">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@