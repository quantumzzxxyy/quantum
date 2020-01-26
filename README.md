# Quantum
**Quantum Physics**
<br>
<br>
https://www.youtube.com/watch?v=Usu9xZfabPM
<br>
<br>
https://www.youtube.com/watch?v=Usu9xZfabPM
<br>
# ABM
Download NetLogo to run the ABM model
<br>
https://ccl.northwestern.edu/netlogo/index.shtml
<br>
<br>

**RELATED MODELS**\
El Farol - competing for a resource, the bar on entertainment night can be considered a resource and optimising size.<br>
<br>**CREDITS AND REFERENCES**\
Financial Market Complexity Neil. F. Johnson et al. Oxford Finance <br><br> **Read more**: <br>Bid-Ask Spread<br> http://www.investopedia.com/terms/b/bid-askspread.asp#ixzz4oQa8NCvE <br>**Read more**:<br> Bid-Ask Spread<br> http://www.investopedia.com/terms/b/bid-askspread.asp#ixzz4pMnYr05O From Ferber J., Les systemes multi-agents Informatique, Intelligence Artificielle, Intereditions, 1995.

<br><br>
**WHAT IS IT?**<br><br>
This is a model of Investors interacting with Brokers and Brokers interacting with Market Makers. This is a study of the relationship of Brokers and Market Makers behaviour within this ecosystem - in terms of how Investors react to Market Maker bid ask spread, defined later and broker fees. We are trying to understand how Market Maker behavior influences investors’ appetite to trade - Market Maker behavior means the fees a market maker charges a broker to trade and notwithstanding the fees or commission a Broker charges an Investor. There are a number of influencing factors namely, number of brokers requesting trading activity via a Market Maker. This could be a one-to-one or many-to-one relationship.<br><br>
**THE QUESTION WHY?**
<br>
<br>
The modelling of interacting agents is important because market regulators are especially interested in strategies that have not yet been discovered by players in the real market, motivated by their goal of designing a regulatory structure with as few loopholes as possible, in order to prevent abuses by devious agent players. Although no reference is made to the Glosten-Milgrom model, where market dynamics converges to an analytically tractable equilibrium. the model aspires to demonstrate an equilibrium state.<br><br>
What are the agents? Agents are: Investors “Blue” people; Brokers “RED” boxes; Market Makers “Green” triangles; Pink agents are momentarily not participating - explained later.<br>
The approach allows us to investigate scenarios where market dynamics may deviate from equilibrium and situations where the market changes suddenly, or undergoes a phase transition, or other dramatic change.<br>
There are three types of agent. 1) Investors, 2) Brokers and 3) Market Makers ( the dynamic links also posess agent properties which illustrate the dynamic configuration of graph links ). We want to understand the behavior of Market Makers under certain trading conditions. Investors interact with Brokers and Brokers interact with Market Makers, the loop is closed via feed-back through total cost to trade back to Investors who have a threshold set by a slider - by the user.
The bid ask spread features significantly in this model and an understanding of it is important. I will refer to a textbook definition taken from the references below in “credits and references”.<br><br>
A bid-ask spread is the amount by which the ask price exceeds the bid price for an asset in the market.
The bid-ask spread is essentially the difference between the highest price that a buyer is willing to pay for an asset and the lowest price that a seller is willing to accept to sell it.<br><br>
The bid-ask spread is a reflection of the supply and demand for a particular asset. The bids represent the demand, and the asks represent the supply for the asset. The depth of the bids and the asks can have a significant impact on the bid-ask spread, making it widen significantly if one outweighs the other or if both are not robust. Market makers and traders make money by exploiting the bid-ask spread and the depth of bids and asks to net the spread difference as a profit.
The example here is like the El Farol problem in that investors rely on global information - for exanple average market maker threshold and to some extent broker fees or commission.<br>
Finally, what is an agent? See reference below. Minimum properties: autonomy, reactivity, proactivity, sociability.<br>
<br>**HOW IT WORKS**<br><br>
Agents are coloured Pink, Green, Red and Blue. Pink agents do not participate in trading; Green, Red and Blue agents are trading participants - all agents are selected randomly. For a particular agent type their colour or selection changes tick by tick (tick time is the cycle time of the model).
The user selects the population of agent Investors ( population-of-investorsx ). The system randomly selects a subset (coloured blue person) - these agents are active Investors and will now participate in trading in terms of interacting with Brokers (red box).<br><br>
The blue Investor agents have a trading charge/fees threshold (called investor-threshold) if the charges or fees exceed this threshold the program STOPS! Investors randomly connect to Broker agents (red), multiple Investors can connect to the same Broker - the more agents connected to a broker indicates a higher demand for that
Broker. Broker fees are related to Broker demand. Brokers randomly connect to Market Maker agents (green triangles). Market Maker demand depends on the number of Broker connections to a Market Maker.<br>
The bid-ask spread is weighted by Market Maker demand and broker commission. This means that there is a feedback mechanism as follows.<br><br>
For a given Investor threshold (in terms of total fees and commissions that an investor is prepaired to accept). Investor, Broker, Market Maker interaction will take place. If the mean market threshold exceeds that of the Investor threshold, the program then stops because the Investor is not prepaired to pay the fees.<br>
Let’s suppose that we pre-select 10 investors, 5 brokers and 2 market makers, clicking go-once randomly selects say 8 investors, 2 brokers and 1 market maker. We want to find
what arrangement with what interface settings causes this agent model to STOP - which indicates the threshold appetite of investors before they effectively say we are not paying anymore fees ( broker plus market maker fees).
The command centre prints the final STOP parameters for reference.<br><br>
