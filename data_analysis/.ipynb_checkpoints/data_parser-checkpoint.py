import pandas as pd

def summarize_runs():
    runs_df =  pd.DataFrame(columns = ['run_no',
                           'avg_susceptibility',
                           'avg_recovery_time',
                           'initial_population',
                           'initial_infected',
                           'average_death_rate',
                           'average_recovery_rate',
                           'quarantine_delay',
                           'mass_testing_intensity',
                           'social_distancing_intensity',
                           'lockdown_intensity',
                           'final_pop',
                           'day_max_infected',
                           'day_max_infetion',
                           'total_infected',
                           'total_recovered',
                           'total_deaths',
                           'total_quarantined',
                           'max_infected',
                           'max_variance',
                           'max_mean'])

    run_no = 1
    n = 0
    while run_no <= 383:
        metrics_df = pd.read_csv('../raw_data/phase1_results.csv',header = None,skiprows = 6, nrows = 11, usecols =[0, 1+n])
        metrics_df.columns = (['metric', 'value'])
        metrics_df

        sim_df = pd.read_csv('../raw_data/phase1_results.csv',header=0,skiprows = 24, nrows = 1564, usecols =[1+n, 2+n, 3+n, 4+n, 5+n, 6+n, 7+n, 8+n, 9+n])
        sim_df = sim_df.reset_index()
        sim_df.columns = (['hour','alive', 'uninfected', 'infected', 'recovered', 'deaths', 'quarantined', 'max_infected', 'variance_infected','mean_infected'])
        sim_df = sim_df[(sim_df['hour'] % 24) == 0].reset_index(drop = True)
        sim_df.index = sim_df.index.set_names(['day'])
        sim_df = sim_df.reset_index()

        #Metrics -------------------

        run_no = metrics_df['value'][0]
        avg_susceptibility = metrics_df['value'][1]
        avg_recovery_time = metrics_df['value'][2]
        initial_population = metrics_df['value'][3]
        initial_infected = metrics_df['value'][4]
        average_death_rate = metrics_df['value'][5]
        average_recovery_rate = metrics_df['value'][6]
        quarantine_delay = metrics_df['value'][7]
        mass_testing_intensity = metrics_df['value'][8]
        social_distancing_intensity = metrics_df['value'][9]
        lockdown_intensity = metrics_df['value'][10]

        #Results -------------------

        #final population
        final_pop = min(sim_df['alive'])
        #day_mostly_infected
        day_max_infected = min(sim_df[sim_df['uninfected'] == min(sim_df['uninfected'])]['day'])
        #day_peak_infection
        day_max_infetion = min(sim_df[sim_df['infected'] == max(sim_df['infected'])]['day'])
        #total infected
        total_infected = max(sim_df['infected'])
        #total recovered
        total_recovered = max(sim_df['recovered'])
        #total deaths
        total_deaths = max(sim_df['deaths'])
        #total quarantined
        total_quarantined = max(sim_df['quarantined'])
        #peak number infected by person
        max_infected = max(sim_df['max_infected'])
        #max_variance
        max_variance = max(sim_df['variance_infected'])
        #max mean
        max_mean = max(sim_df['mean_infected'])

        #Append to DF

        runs_df = runs_df.append(pd.Series([run_no,
                                           avg_susceptibility,
                                           avg_recovery_time,
                                           initial_population,
                                           initial_infected,
                                           average_death_rate,
                                           average_recovery_rate,
                                           quarantine_delay,
                                           mass_testing_intensity,
                                           social_distancing_intensity,
                                           lockdown_intensity,
                                           final_pop,
                                           day_max_infected,
                                           day_max_infetion,
                                           total_infected,
                                           total_recovered,
                                           total_deaths,
                                           total_quarantined,
                                           max_infected,
                                           max_variance,
                                           max_mean], index = runs_df.columns ), ignore_index=True)

        n += 9
        print(run_no, end=" ")

    runs_df.to_csv('../processed_data/phase1_sim_sum.csv', index = False)

def process_raw_runs():
    raw_sim_data = pd.DataFrame(columns = ['day', 'hour', 'alive', 'uninfected', 'infected', 'recovered', 'deaths',
       'quarantined', 'max_infected', 'variance_infected', 'mean_infected',
       'run_no', 'avg_susceptibility', 'avg_recovery_time',
       'initial_population', 'initial_infected', 'average_death_rate',
       'average_recovery_rate', 'quarantine_delay', 'mass_testing_intensity',
       'social_distancing_intensity', 'lockdown_intensity'])

    run_no = 1
    n = 0
    while run_no <= 383:
        metrics_df = pd.read_csv('../raw_data/phase1_results.csv',header = None,skiprows = 6, nrows = 11, usecols =[0, 1+n])
        metrics_df.columns = (['metric', 'value'])
        metrics_df

        sim_df = pd.read_csv('../raw_data/phase1_results.csv',header=0,skiprows = 24, nrows = 1564, usecols =[1+n, 2+n, 3+n, 4+n, 5+n, 6+n, 7+n, 8+n, 9+n])
        sim_df = sim_df.reset_index()
        sim_df.columns = (['hour','alive', 'uninfected', 'infected', 'recovered', 'deaths', 'quarantined', 'max_infected', 'variance_infected','mean_infected'])
        sim_df = sim_df[(sim_df['hour'] % 24) == 0].reset_index(drop = True)
        sim_df.index = sim_df.index.set_names(['day'])
        sim_df = sim_df.reset_index()

        #Metrics -------------------
        
        run_no = metrics_df['value'][0]
        
        sim_df['run_no'] = metrics_df['value'][0]
        sim_df['avg_susceptibility'] = metrics_df['value'][1]
        sim_df['avg_recovery_time'] = metrics_df['value'][2]
        sim_df['initial_population'] = metrics_df['value'][3]
        sim_df['initial_infected'] = metrics_df['value'][4]
        sim_df['average_death_rate'] = metrics_df['value'][5]
        sim_df['average_recovery_rate'] = metrics_df['value'][6]
        sim_df['quarantine_delay'] = metrics_df['value'][7]
        sim_df['mass_testing_intensity'] = metrics_df['value'][8]
        sim_df['social_distancing_intensity'] = metrics_df['value'][9]
        sim_df['lockdown_intensity'] = metrics_df['value'][10]

        
        raw_sim_data = raw_sim_data.append(sim_df)
        
        n += 9
        print(run_no, end=" ")
        
    raw_sim_data.to_csv('../processed_data/phase1_sim_raw.csv', index = False)

    