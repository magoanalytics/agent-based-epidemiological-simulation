import pandas as pd

def process_netlogo(file_name,total_runs, columns, metrics,skip_rows,day, output_name):
    df = pd.DataFrame()
    
    fname = file_name
    oname = output_name
    runs = total_runs #20
    col = columns #5
    met = metrics #19
    skip = skip_rows #32
    days = 24 * (day + 1) #65

    run_no = 1
    n = 0
    
    while run_no <= (runs - 1):

        metrics_df = pd.read_csv(fname,header = None,skiprows = 6, nrows = met, usecols =[0, 1+n])
        metrics_df.columns = (['metric', 'value'])

        sim_df = pd.read_csv(fname,header=0,skiprows = skip, nrows = days, 
                             usecols =[1+n, 2+n, 3+n, 4+n, 5+n, 6+n, 7+n, 8+n, 9+n][0:col])
        sim_df = sim_df.reset_index()
        sim_df = sim_df[(sim_df['index'] % 24) == 0].reset_index(drop = True)
        sim_df.index = sim_df.index.set_names(['day'])
        sim_df = sim_df.reset_index()

        for index, row in metrics_df.iterrows():
            sim_df['placeholder'] = row['value']
            sim_df = sim_df.rename(columns = {'placeholder':row['metric']})

        if n > 0:
            sim_df.columns = df.columns
        df = df.append(sim_df)

        n += col
        run_no = int(sim_df['[run number]'].max())
        print(sim_df['[run number]'].max(), end=" ")
    
    df = df.rename(columns = {'[run number]':'run number'})
    df.to_csv(oname, index = False)
    return df