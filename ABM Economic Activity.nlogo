;; Already have mathematica extensions up and running
;;extensions [ r ] ;; R extension TBD

;; every link breed must be declared as either directed or undirected
directed-link-breed [red-links red-link] ;; set up red links
directed-link-breed [blue-links blue-link] ;; set up blue links
red-links-own [ active? ]


globals [
  max-investors-broker       ;; the maximum investors any broker can have
  max-brokers-market-maker   ;; the maximum brokers any market maker can have
  spacing                    ;; layout of agents - spacing between agents
  stock-price                ;; the price of the current stock
  initial-stock              ;; place holder for setting variable stock - future development
  mean-fee-threshold         ;; Mean fee charged by Market Makers including brokers fee
  population-of-investors    ;; The population of investors at the start of a run - the participating investors are generated randomly from this population
  number-of-brokers          ;; number of brokers
]

breed [investors investor ]        ;; investor breed
breed [brokers broker ]            ;; broker breed
breed [market-makers market-maker] ;; market maker breed
investors-own [i-appetite-to-trade i-strategy i-max-investment i-market-orders-investment i-limit-orders-investment i-limit-orders-long
  i-limit-orders-short i-market-orders-long i-market-orders-short ] ;; ownership of attributes

brokers-own [ b-appetite-to-trade b-commissionx b-commission b-demand b-max-investment b-market-orders-investment b-limit-orders-investment
                       b-market-orders-long b-market-orders-short b-limit-orders-long b-limit-orders-short] ;; ownership of attributes
market-makers-own [ mb-commissionx mm-adjusted-charge mm-adjusted-chargex mm-demand mm-spreadx mm-spread mm-max-investment mm-market-orders-investment mm-limit-orders-investment
                       mm-market-orders-long mm-market-orders-short mm-limit-orders-long mm-limit-orders-short mm-bid mm-ask] ;; ownership of attributes

to setup
  ;; initial set up
  ca ;; clear all

  reset-ticks ;; ticks re-set

  set spacing 1.25 ;; setting distance between agents
  set initial-stock number-of-stock ;; set up initial stock size. This is a driver to work out broker fees
  set mean-fee-threshold 0 ;;

  set-default-shape investors "person" ;; investors shape a person

  set population-of-investors population-of-investorsx ;; population of investors available - participating investors are randomly set from this population
  set number-of-brokers number-of-brokersx ;; number of brokers

  ;; create the investor, then initialize their variables - note note all variables are used for calculations
  create-ordered-investors population-of-investors [
    setxy -15 0
    set ycor (floor (population-of-investors / 2) - who) * spacing  ;; space out the turtles in order by who number
    set color blue
    set i-appetite-to-trade random 2 ;; trdade no-trade. Replace with alogorithm with binary output
    if i-appetite-to-trade = 0 [ set color pink ]
    set i-max-investment 0
    set i-market-orders-investment  0
    set i-limit-orders-investment 0
    set i-limit-orders-long 0
    set i-limit-orders-short  0
    set i-market-orders-long  0
    set i-market-orders-short 0
    set label who
 ]

  set-default-shape brokers "square" ;; set brokers shape
  ;; create the brokers, then initialize their variables  - note note all variables are used for calculations
  create-ordered-brokers number-of-brokers [
    setxy -4 0
    set ycor (floor (number-of-brokers / 2)  + who - (population-of-investors + number-of-brokers - 1)) * spacing  ;; space out the turtles in order by who number
    set color pink ;; red
    set size 1
    set b-appetite-to-trade 0
    set b-commission 0
    set b-demand 0
    set b-max-investment 0
    set b-market-orders-long 0
    set b-market-orders-short 0
    set b-limit-orders-long 0
    set b-limit-orders-short 0
    set label who
 ]

  set-default-shape market-makers "triangle"  ;; set market makers shape
  ;; create the market makers, then initialize their variables  - note note all variables are used for calculations
  create-market-makers number-of-market-makers  ;; create the market maker, then initialize their variables
  [
    setxy 10 0
    set ycor (floor (number-of-market-makers / 2) + who - (population-of-investors + number-of-brokers + number-of-market-makers - 1)) * spacing * 1.50
    set color pink
    set size 2
    set mm-adjusted-charge 0
    set mm-adjusted-chargex 0
    set mm-spreadx 0
    set mm-spread 0
    set mm-demand 0
    set mm-max-investment 0
    set mm-market-orders-investment 0
    set mm-limit-orders-investment 0
    set mm-market-orders-long 0
    set mm-market-orders-short 0
    set mm-limit-orders-long 0
    set mm-limit-orders-short 0
    set mm-bid 0
    set mm-ask 0
    set label who
 ]

End
;; setup links from investors to brokers
to update-strategy-brokers
ask n-of population-of-investors investors [
    create-blue-link-to one-of brokers [  ;;; removed other  create-blue-link-to one-of other brokers
    ask links with [ [color] of end1 = pink AND [color] of end2 = pink ] [ die ] ;; kill links  one investor can only connect to one broker
    ask links with [ [color] of end1 = pink AND [color] of end2 = red ] [ die ]  ;; kill links  one investor can only connect to one broker
    set color blue
    ask end2 [set color red]
    set label ""
    ]
  ]
end
;; setup links from brokers to market makers
to update-strategy-market-makers
  ask n-of number-of-brokers brokers [
  create-red-link-to one-of market-makers [ ;;; removed other
    ask links with [ [color] of end1 = pink AND [color] of end2 = green ] [ die ] ;; kill links
    ask links with [ [color] of end1 = pink AND [color] of end2 = pink ] [ die ]  ;; kill links
    set color red
    set active? true
    set label end1
    ask end2 [set color green]
    ]
  ]
end

;; kill and reset to starting state up each iteration
to kill-links
  ask links with [ [color] of end1 = blue AND [color] of end2 = red ] [ die ] ;; kill limks
  ask links with [ [color] of end1 = red AND [color] of end2 = green ] [ die ] ;; kill links

  ask brokers [
    set color pink
    set b-appetite-to-trade 0
  ]
  ask market-makers [ set color pink ]
end

to go

kill-links ;; ensure links are killed

  set initial-stock number-of-stock ;; set up initial stock size. This is a driver to work out broker fees

;; ask investors to set parameters
ask investors [
    set color pink
    if show-agents = false [hide-turtle]
    set i-appetite-to-trade random 2 ;; yes or no may want to introduce a risk factor here for example LOW MED HIGH
    if  (i-appetite-to-trade = 1) and mean-fee-threshold  <= investor-threshold [
    set i-max-investment random initial-stock ;; from a stock portfolio randomly select a sub set
    set i-market-orders-investment  random i-max-investment ;; market orders are randomly selected from a subset
    set i-limit-orders-investment i-max-investment - i-market-orders-investment ;; limit orders are what is left over
    set i-limit-orders-long random i-limit-orders-investment ;; long and short selection
    set i-limit-orders-short   i-limit-orders-investment - i-limit-orders-long ;; short order are what is left over
    set i-market-orders-long  random i-market-orders-investment ;; long is a sub set
    set i-market-orders-short i-market-orders-investment - i-market-orders-long ;; short is waht is left over
    set color blue ;; Blue for participants
    show-turtle
    ]
  ]

;; set up brokers lnks
update-strategy-brokers

;; ask brokers to set parameters
  ask brokers [
    if show-agents = false [hide-turtle]
    set b-max-investment sum[i-max-investment] of in-link-neighbors
    set b-market-orders-investment sum[i-market-orders-investment] of in-link-neighbors
    set b-limit-orders-investment  sum[i-limit-orders-investment] of in-link-neighbors
    set b-market-orders-long  sum[i-market-orders-long] of in-link-neighbors
    set b-market-orders-short sum[i-market-orders-short] of in-link-neighbors
    set b-limit-orders-long  sum[i-limit-orders-long] of in-link-neighbors
    set b-limit-orders-short sum[i-limit-orders-short] of in-link-neighbors
    set b-demand sum[i-appetite-to-trade ]  of in-link-neighbors
    let population count investors with [ color = blue ]
    if population = 0 [ set  population 1]
    set b-commission ( b-max-investment * broker-initial-commision * b-demand / population ) ;; commission x% of max investment
    set b-commissionx precision b-commission 4
    if color = red [set b-appetite-to-trade 1 show-turtle]

  ]

;; set up market makers lnks
update-strategy-market-makers

;; ask market makers to set parameters
ask market-makers [
    show-turtle
    let spread 0
    set mm-spread calculate-bid-ask-spread ;;;spread calculated
    if color = pink [ set mm-spread 0 if show-agents = false [hide-turtle]]
    set mb-commissionx sum[b-commissionx]  of in-link-neighbors
    set mm-spreadx precision mm-spread 4
    set mm-max-investment sum[b-max-investment]  of in-link-neighbors
    set mm-market-orders-investment sum[b-market-orders-investment]  of in-link-neighbors
    set mm-limit-orders-investment  sum[b-limit-orders-investment]  of in-link-neighbors
    set mm-market-orders-long  sum[b-market-orders-long]  of in-link-neighbors
    set mm-market-orders-short sum[b-market-orders-short]  of in-link-neighbors
    set mm-limit-orders-long  sum[b-limit-orders-long]  of in-link-neighbors
    set mm-limit-orders-short sum[b-limit-orders-short]  of in-link-neighbors
    set mm-demand sum[b-appetite-to-trade] of in-link-neighbors
    let count-brokers count brokers with [ color = red ]
    if count-brokers = 0 [ set  count-brokers 1]
    set mm-adjusted-charge (( mm-demand / count-brokers) * mm-spreadx * mm-max-investment  + mb-commissionx  ) ;; weighted mm spread depends on the number of active investors
    set mm-adjusted-chargex  precision mm-adjusted-charge 5
  ]

  ;; mean of the total charge plus broker commission weighted by demand in terms of the number of connections to a market maker
  ;; print when exceeding investors threshold for weighted total fees

  ifelse any? market-makers with  [color = green]
    [set mean-fee-threshold  mean [ mm-adjusted-chargex ] of market-makers  with [color = green] ] ;; mean of amrket makers + brokers cost demand adjusted
    [set mean-fee-threshold 0] ;; only green otherwise set to zero

  if mean-fee-threshold > investor-threshold   [ ;; it is convenient to print out stop values
    print "mean-fee-threshold" ;; information out put
    print mean-fee-threshold   ;; information out put
    print "investor-threshold" ;; information out put
    print investor-threshold   ;; information out put
    stop ;; stop
  ]

tick ;; update tick
end

;; Bid-Ask Spread = Ask Price − Bid Price
;; Market Bid-Ask Spread = Best Ask Price − Best Bid Price
;; Ask/offer price (or ask) is the price at which the dealer sells and bid price (or bid) is the price at which it is purchased.
;; bid price (x-) <  ask price (x+). To prevent arbitrage
to-report calculate-bid-ask-spread ;; spread calculated this is a routine call
 let mm-askx  precision (random-normal 1 0.25) 5 ;; ask is random normal with std 0.25 precision 5. Could replace with algo
 let bidx   precision (mm-askx - ask-reduction-spread-percent * mm-askx / 100 ) 5 ;; mm-ask randomly generated
 set mm-bid bidx
 set mm-ask mm-askx
 report (mm-askx - bidx)  ;;; spread
end
@#$#@#$#@
GRAPHICS-WINDOW
659
-3
1197
536
-1
-1
16.061
1
10
1
1
1
0
0
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
18
137
84
170
NIL
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

BUTTON
175
137
238
170
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
15
10
227
43
population-of-investorsx
population-of-investorsx
1
100
18.0
1
1
NIL
HORIZONTAL

SLIDER
16
54
229
87
number-of-brokersx
number-of-brokersx
1
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
232
54
441
87
number-of-market-makers
number-of-market-makers
1
10
6.0
1
1
NIL
HORIZONTAL

TEXTBOX
427
191
577
209
NIL
11
0.0
1

PLOT
16
176
368
296
Active Participants
tick time
Agents
0.0
1.0
0.0
0.0
true
true
"" ""
PENS
"Investors" 1.0 0 -14439633 true "" "set-plot-x-range (ticks - 20) ticks\nplotxy ticks (count investors with [ color = blue ])\n\n"
"Market Makers" 1.0 0 -14454117 true "" "plot count market-makers with [color = green]"
"Brokers" 1.0 0 -955883 true "" "plot count brokers with [color = red]"

BUTTON
86
137
171
170
Go Once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
413
130
520
175
active-investors
count investors with [color = blue]
10
1
11

PLOT
372
176
655
296
Bid-Ask spread distribution
Calculated Spread
Count
0.0
0.0
0.0
0.0
true
false
" " " "
PENS
"MM-Dist" 0.0 1 -12087248 true "" "set-plot-x-range 0.0  max [mm-spreadx] of market-makers\nset-histogram-num-bars ceiling ( count market-makers )\nhistogram [mm-spreadx] of market-makers"

SLIDER
442
54
629
87
broker-initial-commision
broker-initial-commision
0
1
0.63
0.01
1
NIL
HORIZONTAL

PLOT
451
431
651
581
Broker fee distribution
Fee
Count
0.0
0.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 1 -10022847 true "" "set-plot-x-range 0.0001 (max [b-commissionx]of brokers with [color = red])\nset-histogram-num-bars ceiling (count brokers)\nhistogram [b-commissionx] of brokers\n\n"

SLIDER
230
10
402
43
number-of-stock
number-of-stock
1
100
73.0
1
1
NIL
HORIZONTAL

PLOT
15
429
447
617
Aggregated Cost Distribution
Aggregate Cost
Active Market Makers
0.0
0.0
0.0
0.0
true
true
"" ""
PENS
"Total fee distrubution" 0.005 1 -955883 true "" "set-plot-x-range (precision 0.00001 5) (precision (max[mm-adjusted-chargex] of market-makers with [color = green] + 0.001) 5)\nset-histogram-num-bars ceiling (count market-makers with [color = green])\nhistogram [mm-adjusted-chargex] of market-makers with [color = green]"
"Investor STOP threshold" 0.0 0 -15040220 true "" "plot-pen-reset\nplot-pen-up\n;;plotxy mean ([mm-adjusted-chargex] of market-makers with [color = green]) 0\n;;plot-pen-down\n;;plotxy mean ([mm-adjusted-chargex] of market-makers with [color = green]) 4\n\nplotxy mean-fee-threshold 0\nplot-pen-down\nplotxy mean-fee-threshold 4"

SLIDER
405
10
629
43
ask-reduction-spread-percent
ask-reduction-spread-percent
0.0
100
46.0
1
1
NIL
HORIZONTAL

SLIDER
16
94
619
127
investor-threshold
investor-threshold
0
300
42.0
1
1
NIL
HORIZONTAL

MONITOR
249
129
412
174
Investor STOP threshold
precision mean-fee-threshold 4
17
1
11

PLOT
14
298
655
425
Market Maker STOP threshold
tick time
Threshold
0.0
0.0
0.0
0.0
true
false
"" ""
PENS
"Mean STOP threshold " 1.0 0 -7858858 true "" "set-plot-x-range (ticks - 20) ticks\nplot mean-fee-threshold"

SWITCH
523
136
646
169
show-agents
show-agents
0
1
-1000

@#$#@#$#@
##WHAT IS IT?

This is a model of Investors interacting with Brokers and Brokers interacting with Market Makers. This is a study of the relationship of Brokers and Market Makers behaviour within this ecosystem - in terms of how Investors react to Market Maker bid ask spread, defined later and broker fees. We are trying to understand how Market Maker behavior influences investors’ appetite to trade - Market Maker behavior means the fees a market maker charges a broker to trade and notwithstanding the fees or commission a Broker charges an Investor. There are a number of influencing factors namely, number of brokers requesting trading activity via a Market Maker. This could be a one-to-one or many-to-one relationship.

The questiion Why?
The modelling of interacting agents is important because market regulators are especially interested in strategies that have not yet been discovered by players in the real market, motivated by their goal of designing a regulatory structure with as few loopholes as possible, in order to prevent abuses by devious agent players.
Although no reference is made to the Glosten-Milgrom model, where market dynamics converges to an analytically tractable equilibrium. the model aspires to demonstrate an equilibrium state.

What are the agents? Agents are: Investors “Blue” people; Brokers “RED” boxes; Market Makers “Green” triangles; Pink agents are momentarily not participating - explained later.

The approach allows us to investigate scenarios where market dynamics may deviate from equilibrium and situations where the market changes suddenly, or undergoes a phase transition, or other dramatic change.

There are three types of agent. 1) Investors, 2) Brokers and 3) Market Makers ( the dynamic links also posess agent properties which illustrate the dynamic configuration of graph links ). We want to understand the behavior of Market Makers under certain trading conditions. Investors interact with Brokers and Brokers interact with Market Makers, the loop is closed via feed-back through total cost to trade back to Investors who have a threshold set by a slider - by the user.

The bid ask spread features significantly in this model and an understanding of it is important. I will refer to a textbook definition taken from the references below in “credits and references”.

A bid-ask spread is the amount by which the ask price exceeds the bid price for an asset in the market.

The bid-ask spread is essentially the difference between the highest price that a buyer is willing to pay for an asset and the lowest price that a seller is willing to accept to sell it.

The bid-ask spread is a reflection of the supply and demand for a particular asset. The bids represent the demand, and the asks represent the supply for the asset. The depth of the bids and the asks can have a significant impact on the bid-ask spread, making it widen significantly if one outweighs the other or if both are not robust. Market makers and traders make money by exploiting the bid-ask spread and the depth of bids and asks to net the spread difference as a profit.

The example here is like the El Farol problem in that investors rely on global information - for exanple average market maker threshold and to some extent broker fees or commission.

Finally, what is an agent? See reference below. Minimum properties: autonomy, reactivity, proactivity, sociability.

##HOW IT WORKS

Agents are coloured Pink, Green, Red and Blue. Pink agents do not participate in trading; Green, Red and Blue agents are trading participants - all agents are selected randomly. For a particular agent type their colour or selection changes tick by tick (tick time is the cycle time of the model).

The user selects the population of agent Investors ( population-of-investorsx ). The system randomly selects a subset (coloured blue person) - these agents are active Investors and will now participate in trading in terms of interacting with Brokers (red box).

The blue Investor agents have a trading charge/fees threshold (called investor-threshold) if the charges or fees exceed this threshold the program STOPS!
Investors randomly connect to Broker agents (red), multiple Investors can connect to the same Broker - the more agents connected to a broker indicates a higher demand for that 

Broker. Broker fees are related to Broker demand.
Brokers randomly connect to Market Maker agents (green triangles). Market Maker demand depends on the number of Broker connections to a Market Maker.

The bid-ask spread is weighted by Market Maker demand and broker commission. This means that there is a feedback mechanism as follows.

For a given Investor threshold (in terms of total fees and commissions that an investor is prepaired to accept). Investor, Broker, Market Maker interaction will take place. If the mean market threshold exceeds that of the Investor threshold, the program then stops because the Investor is not prepaired to pay the fees.

Let’s suppose that we pre-select 10 investors, 5 brokers and 2 market makers, clicking go-once randomly selects say 8 investors, 2 brokers and 1 market maker. We want to find 

what arrangement with what interface settings causes this agent model to STOP - which indicates the threshold appetite of investors before they effectively say we are not paying anymore fees ( broker plus market maker fees).

The command centre prints the final STOP parameters for reference.

##HOW TO USE IT

population-of-investors: sets the population of investors, investors are then selected randomly from this population. Non-selected investors are coloured pink. Press setup and Go-Once.

number-of-brokers: set the number of brokers; investors are then connected randomly to brokers. Non-connected brokers are coloured pink. Press setup Go-Once.
number-of-market-makers: set the number of market makers; brokers are then connected to market makers. Non-connected market makers are colored pink. Press setup Go-once.
number-of-stock: set up initial stock size. This is a driver to work out broker fees. 

Fees are proportional to stock size ( supply and demand).
broker-initial-commission: this determines the broker commission as a fraction of the broker maximum investment which is the sum of max investment of all Linked-in neighbors, randomly determined from the initial stock setting size of number-of-stocks.
bid-ask-spread-percentage: See bid ask spread definition described in this info page.
investor-threshold: This is the driver for setting the STOP threshold. It sets the cost threashold.

set-up: set up agents: investors, brokers, market makers, and initialise agent parameters set to zero and randomly set from interface settings.
market-maker-STOP-threhold: An information tracker of the STOP threashold through tick time - how it dynamically changes.
go-once: execute program once.
go: Repeat execution of program.
market-maker-mean-stop-threshold and market-maker-STOP-threshold provide history information regarding threshold history and current value.
bid-ask-spread-distribution: An informative distribution relating to the bid-ask spread.
decision-threshold (vertical line): An informative distribution of fee distribution across agents with an important vertical line showing how the mean threshold is changing when “go” is pressed. If this value exceeds the investor threshold the program STOPS - the vertical line is the mean value.
broker-fee-distribution: An informative distribution of broker fees across red broker agents - how fees are distributed.

First set up the agents Investors, Briokers, Market Makers. Watch the interactions taking place and observe behaviour changes when varying number-of-stock, bid-ask-spread-percent, broker-initial-commission and investor-threshold. Press “go”. Stop and re start under a differet portfolios of agents. Also, find the STOP value for a given configuration and compare across configurations.

##THINGS TO NOTICE

Note that some scenarios could end up with all agents pink therefore not participating.
Notice agents can have many to one relationships.
Notice tick time behaviour and how the system executes fora given interface settings. observe settings that show wide variation through tick time.

##THINGS TO TRY

Ajust broker initial commission and bid-ask-spread and investor-threshold for a given set of agents.
Count number of ticks till it stops.
Click go once…repeat to see opperation in slow motion - and the difference combinations of linked agents.

Explore and investigate the balance between bid ask spread and commission. for a given STOP threshold how do you balance profit to brokers and mearket makers? Using broker commission and bid-ask spread sliders? bid-ask spread is how Market Makers make profit vs Broker comission for Broker profit!.

##EXTENDING THE MODEL

Add data feeds to the model and analysing the agents with R
Currently this is a basic model where a number of parameters are selected randomly. 

Replace random with an algorithmic methods.

Some agent parameters have been set up but not used in the final model - this is currently work in progress and some parameters are place holders.
Include more input features - linked to daily prices.
Build learning strategies for the agents.

##NETLOGO FEATURES

Using “links”, in particular “in-link-neighbors”: aggregating attached Investors and 

Brokers; used to determine demand of a Broker and Market Maker.
Using “precision”: Calculations summarised to 4 or 5 decimal places.

Graph time-base set up as a moving plot along the time (tick) axes. This ensures that the graph does not get squashed at one end.
example code “set-plot-x-range (ticks - 20) ticks plotxy ticks (count investors with [color = green ])”

This model is version 1.0

##RELATED MODELS

El Farol - competing for a resource, the bar on entertainment night can be considered a resource and optimising size.
CREDITS AND REFERENCES

Financial Market Complexity Neil. F. Johnson et al. Oxford Finance
Read more: Bid-Ask Spread http://www.investopedia.com/terms/b/bid-askspread.asp#ixzz4oQa8NCvE
Read more: Bid-Ask Spread http://www.investopedia.com/terms/b/bid-askspread.asp#ixzz4pMnYr05O
From Ferber J., Les systemes multi-agents Informatique, Intelligence Artificielle, Intereditions, 1995.     
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
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="social-influence-experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [adopted?]</metric>
    <metric>count regulars with [ adopted? ]</metric>
    <metric>count influentials with [ adopted? ]</metric>
    <enumeratedValueSet variable="density">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-influence">
      <value value="0.1"/>
      <value value="0.1"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="broadcast-influence">
      <value value="0.45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influential-weight">
      <value value="0.35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="frac-influencial">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cumul-fraction">
      <value value="46"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_agents">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count turtles with [color = red]</metric>
    <metric>count turtles with [ color = green ]</metric>
    <metric>count turtles with [ color = blue ]</metric>
    <enumeratedValueSet variable="population-of-investorsx">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ask-reduction-spread-percent">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-market-makers">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investor-threshold">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-stock">
      <value value="74"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-brokersx">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="broker-initial-commision">
      <value value="0.09"/>
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
