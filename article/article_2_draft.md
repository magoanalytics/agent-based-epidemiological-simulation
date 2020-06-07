# Comparing COVID-19 Interventions Through Agent-Based Modeling (Part 2)
By Johnny, Gab, and Anj

Most of the Philippines is now under general community quarantine, which means increased movement across borders and increased interaction. In part two of our series, we'll be focusing more on the field epidemiology strategy of testing-tracing-isolation. 

Testing-tracing-isolation has been quite a popular call in social media and news articles. It is based on the field epidemiology strategy of contact tracing. It is a tool used to stop the local spread of disease by backtracking the contacts of a known positive individual to isolate, test, and treat. This cycle is repeated until all the contacts are isolated so the spread of infection ends with that last contact. 

## Parameters of Interest
We used agent-based modeling through (Netlogo)[https://ccl.northwestern.edu/netlogo/]. More info about our model is part I of this series and is available (here)[https://magoanalytics.github.io/2020/05/19/covid19-sim-1-methodology/]. Part II, which explores social distancing and lockdown environments, is available (here)[https://magoanalytics.github.io/2020/05/19/covid-sim-1/]. 

We modelled `mass testing intensity` as the probability of an agent to get randomly tested every 24 hours. The more intense the parameter, the more likely an agent is tested within 24 hours. An important note is that this is different from the targeted testing of suspected or probable individuals and we assume these cases to have been isolated and monitored. This parameter captures the random testing of freely moving agents in the community.

Since testing did not necessarily imply immediate isolation, we identified another intervention that was linked to mass testing, `quarantine delay`. We defined `quarantine delay` as the number of days quarantine or isolation is delayed after being tested positive. 

We modelled `contact tracing` by identifying agents that were in the path of other agents. Specifically, 1.5 units close to an agent. When `contact tracing` is turned on, a positive test result for an infected agent will lead to the testing of all the agents within 1.5 units of that infected agent along its path. Similarly, `contact tracing` does not imply immediate testing and isolation of contacts. Thus, we added a `contact tracing delay` parameter as the number of days testing and isolation is delayed.

Additionally, we added a `health facility capacity` parameter, which is the ceiling of agents allowed inside the quarantine facility. This parameter aims to describe the limitation of resources available.

## Outcomes of Interest
For the first part of this series, we looked entirely at the effect of interventions on infection rates. For this article, we'll look into a few additional outcomes:
1. Death Rates
2. Recovery Rates
3. Length of Recovery (in days)

## Findings
1. 