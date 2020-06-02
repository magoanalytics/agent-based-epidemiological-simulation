# Comparing COVID-19 Interventions Through Agent-Based Modeling (Part 2)
By Johnny, Gab, and Anj

Most of the Philippines is now under general community quarantine, which means increased movement across borders and increased interaction. In part two of our series, we'll be focusing more on the field epidemiology strategy of testing-tracing-isolation. 

Testing-tracing-isolation has been quite a popular call in social media and news articles. It is based on the field epidemiology strategy of contact tracing. It is a tool used to stop the local spread of disease by backtracking the contacts of a known positive individual to isolate, test, and treat. This cycle is repeated until all the contacts are isolated so the spread of infection ends with that last contact. 

## Parameters of Interest
We used agent-based modeling through (Netlogo)[https://ccl.northwestern.edu/netlogo/]. More info about our model is part I of this series and is available (here)[https://magoanalytics.github.io/2020/05/19/covid19-sim-1-methodology/]. Part II, which explores social distancing and lockdown environments, is available (here)[https://magoanalytics.github.io/2020/05/19/covid-sim-1/]. 
 
We modelled mass testing intensity as the probability of an agent to get randomly tested every 24 hours. The more intense the parameter, the more likely an agent is tested within 24 hours. An important note is that this is different from the targeted testing of suspected or probable individuals and we assume these cases to have been isolated and monitored. This parameter captures random testing of freely moving agents.

Additionally, since testing did not necessarily imply immediate isolation, we identified another intervention that was linked to mass testing: quarantine delay. We defined quarantine delay as the number of days quarantine or isolation is delayed after being tested positive.

## Outcomes of Interest