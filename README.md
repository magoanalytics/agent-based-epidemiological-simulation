## Agent-Based Epidemiological Simulation Using Netlogo
This project aims to determine and quantify the effects of implementing lockdown, mass testing, quarantine delays, and social distancing in controlling the spread of the disease. In particular, we focus on the effects of these interventions to the recovery and death rates. 

### What is Agent-Based Modelling?
Agent-based modelling (ABM) is a technique that models a complex system by reducing it to the interactions between agents and their environment. Here, agents can possess properties such as age and gender, and can perform actions based on pre-defined set of conditions. The environment possesses properties as well, and can affect the behavior of agents and vice versa. Obervables such as population growth can then be measured to infer relationships between agent behavior and the overall behavior of the system. This makes ABMs powerful in that it can be used to observe and quantify the macroscopic behavior of many complex systems over time just by knowing how individual agents behave. This can be achieved without the need to construct differential equations that requires pre-existing knowledge of the relationships between observables. 

Currently, there are a number of platforms that provide users with tools needed to build an ABM simulation. For this project, we'll be using Netlogo. 

### Why Netlogo?
Netlogo is an open source, cross-platform multi-agent programmable modeling environment. Its user-friendly language allows users to quickly draft prototypes and visualize the results through an interactive customizable interface. In addition, Netlogo also includes dozens of pre-built models ranging from tumor growth simulation, to modelling behavior of gas particles. For more information, visit the official Netlogo site: https://ccl.northwestern.edu/netlogo/.

### Getting Started
Download the latest version using the following link: https://ccl.northwestern.edu/netlogo/download.shtml. When unpacked, a folder containing all the necessary files will be created. Open the Netlogo application file to launch. 

### Usage
The following parameters can be adjusted in the interface tab:

|Model Parameter|Description|Value|
|-|-|-|
|initial-populatin|Initial number of agents at the start of the simulation (t = t<sub>0</sub>)|[10,5000]|
|initial-infected|Initial number of infected agents at the start of the simulation (t = t<sub>0</sub>)|[1, 10]|
|average-susceptibility|Average probability of a person being infected when near infected agent(s)|[0, 100]|
|average-recovery-rate|Average probability of an infected agent to recover|[0, 100]|
|average-recovery-time|Average time needed for an agent to have a chance to recover after being infected|{336, 504, 672}|
|average-death-rate|Average probability of an infected agent dying|[0, 1]|
|lockdown-intensity|Average probability of an agent attempting to cross border to cross successfully|[0, 100]|
|mass-testing-intensity|Probability of an agent being tested every 24 hours|[0, 100]|
|quarantine-delay|Number of days before infected agent is quarantined after being tested positve|[1, 7]|
|social-distancing-intensity|Probability of an agent to observe social distancing|[0, 100]|
### Contributing 
https://ccl.northwestern.edu/netlogo/
