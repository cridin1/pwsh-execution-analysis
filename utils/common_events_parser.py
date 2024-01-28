import pandas as pd
from functools import reduce
from utils.event_analysis import parse_folder
import os

dfs = parse_folder(os.path.join(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\ground_truth_output_new", "xml"))
final_df = reduce(lambda  left,right: pd.merge(left,right,
                                            how='inner'), dfs).drop_duplicates()

final_df.to_csv(f"./common_events_filter2.csv", index=False)