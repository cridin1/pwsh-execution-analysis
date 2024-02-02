import pandas as pd
from functools import reduce
from event_analysis import parse_folder, compare_df
import os
import numpy as np

dfs1 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\ground-truth-output", "xml"))
dfs2 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\ground-truth-output2", "xml"))
dfs3 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\ground-truth-output3", "xml"))
dfs4 = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\ground-truth-output4", "xml"))

dfs_out = []
i = 0
for i in range(len(dfs1.keys())):
    df1 = dfs1[i+1]
    df2 = dfs2[i+1]
    df3 = dfs3[i+1]
    df4 = dfs4[i+1]
    
    p,r, df_comm = compare_df(df1,df2)
    p,r, df_comm = compare_df(df_comm,df3)
    p,r, df_comm = compare_df(df_comm,df4)
    
    df_list = [df1, df2, df3, df4]
    
    df_union = reduce(lambda left,right: pd.merge(left,right, how='outer'), df_list).drop_duplicates()
    
    print("\n {} \n df1: {} \n df2: {} \n df3: {} \n df4: {} \n common: {} \n Union: {}".format(i+1,df1.shape[0], df2.shape[0], df3.shape[0], df4.shape[0], df_comm.shape[0], df_union.shape[0]))
    
    df_union.to_csv(f"./out_gt/{i+1}.csv", index=False)
    
    
