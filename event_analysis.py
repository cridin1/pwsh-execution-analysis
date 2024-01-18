import xml.etree.ElementTree as etree
import pandas as pd
import os
import re
import argparse

def filter_entries(text) -> bool:
    raw_text = r"{}".format(text)
    patterns = r"(output\d+\.txt$)|(__PSScriptPolicyTest)"
    found = re.search(patterns,raw_text)
    if(found == None): return True
    else: return False

def parse_xml(path) -> pd.DataFrame:
    tree = etree.iterparse(path)
    ns = "{http://schemas.microsoft.com/win/2004/08/events/event}"

    data = []
    keys = ["Task", "Image", "CommandLine", "TargetFilename", 
            "ImageLoaded", "PipeName", "QueryName", "EventType",
            "TargetObject", "DestinationIp" ,"DestinationPort" ]
    
    common_events = pd.read_csv("common_event_filter.csv")
    images = list(common_events["ImageLoaded"].unique())[1:] #skipping "-"
    
    #for debug
    # keys.append("ProcessId","UtcTime", "ParentProcessId")

    for _,eventID in tree:
        row = {}
        skip = False
        if eventID.tag == f"{ns}System":
            for attr in eventID.iter():
                if attr.tag == f'{ns}Task':
                    row['Task'] = attr.text
            
            #iterate until EventData
            _,next_element = next(tree)
            while(next_element.tag != f"{ns}EventData"):
                _,next_element = next(tree)

            if next_element.tag == f"{ns}EventData":
                for attr in next_element.iter():
                    if attr.tag == f'{ns}Data' and attr.get('Name') in keys:
                        if(filter_entries(attr.text)):
                            if(attr.get('Name') == "ImageLoaded" and attr.text in images):
                                skip = True
                                break
                            else:
                                row[attr.get('Name')] = attr.text
                        else:
                            skip = True
                            break
            
            #check if row is equal to a row in common_events
            if(skip == False and row != {}):
                data.append(row)

    output = []
    for row in data:
        row_out = []
        for key in keys:
            if key not in row:
                row[key] = "-"
            row_out.append(row[key])
        output.append(row_out)

    df = pd.DataFrame(output, columns=keys)
    df = df[df["CommandLine"] != common_events["CommandLine"][0]]
    return df

def compare_df(df1,df2):
    df_intersection = pd.merge(df1, df2, how='inner')
    
    #precision is the fraction of relevant instances among the retrieved instances
    p = df_intersection.shape[0]/df1.shape[0]
    #recall is the fraction of relevant instances that were retrieved.
    r = df_intersection.shape[0]/df2.shape[0]
    
    f1_score = round(2*(p*r)/(p+r),2)
    
    return f1_score, df_intersection

def parse_folder(path):
    elems = os.listdir(path)
    dfs = []

    for elem in elems:
        path_elem = os.path.join(path,elem)
        print(path_elem)
        dfs.append(parse_xml(path_elem))
    
    return dfs 

if __name__ == "__main__":
    
    argparse = argparse.ArgumentParser()
    argparse.add_argument("--folder1", help="path to first folder")
    argparse.add_argument("--folder2", help="path to second folder")
    argparse.add_argument("--output", help="path to output folder")
    args = argparse.parse_args()
    
    dfs1 = parse_folder(os.path.join(args.folder1, "xml"))
    dfs2 = parse_folder(os.path.join(args.folder2, "xml"))
    
    commands_1,commands_2 = open(os.path.join(args.folder1, "input.txt")).readlines(), open(os.path.join(args.folder2, "input.txt")).readlines()
    
    print("dfs extracted : ",len(dfs1), len(dfs2))
    lista = list(zip(dfs1,dfs2))
    
    i = 0
    for df1,df2 in lista:
        metric, df_comm = compare_df(df1,df2)
        
        print(f"command1: {commands_1[i].strip()}")
        print(f"command2: {commands_2[i].strip()}")
        print(metric, df_comm.shape[0], df1.shape[0], df2.shape[0])
        print("\n")
        #df_comm.to_csv(f"./out_common_{metric}.csv", index=False)

        i +=1
        
# final_df = reduce(lambda  left,right: pd.merge(left,right,
#                                             how='inner'), dfs).drop_duplicates()
# final_df.to_csv(f"./out_common.csv", index=False)

    