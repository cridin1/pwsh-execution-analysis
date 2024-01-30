import xml.etree.ElementTree as etree
import pandas as pd
import os
import re
import argparse

def filter_entries(text) -> bool:
    raw_text = r"{}".format(text)
    patterns = r"(output\d+\.txt$)|(__PSScriptPolicyTest)|(C:\\Users\\unina\\AppData\\Local\\Temp)|(\\dotnet-diagnostic-\d+)|(\\PSHost.\d+.\d+.DefaultAppDomain)"
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
    
    common_events = pd.read_csv("common_events_filter.csv")
    images = list(common_events["ImageLoaded"].unique())[1:] #skipping "-"
    
    #for debug
    #keys+=["ProcessId","UtcTime", "ParentProcessId"]

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

    df = pd.DataFrame(output, columns=keys).drop_duplicates()
    df = df[df["CommandLine"] != common_events["CommandLine"][0]]
    return df

def compare_df(df1,df2):
    df_intersection = pd.merge(df1, df2, how='inner')
    
    if(df_intersection.shape[0] == 0):
        return 0,0, df_intersection
    
    #precision is the fraction of relevant instances among the retrieved instances
    p = df_intersection.shape[0]/df1.shape[0]
    #recall is the fraction of relevant instances that were retrieved.
    r = df_intersection.shape[0]/df2.shape[0]
    
    return round(p,2), round(r,2), df_intersection

def parse_folder(path):
    elems = os.listdir(path)
    dfs = {}

    for elem in elems:
        path_elem = os.path.join(path,elem)
        #print(path_elem)
        number = int(re.search(r"\d+",elem).group())
        dfs[number] = parse_xml(path_elem)
    
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
    
    overall_p = 0
    overall_r = 0
    
    i = 0
    for i in range(len(commands_1)):
        df1 = dfs1[i+1]
        df2 = dfs2[i+1]
        
        p,r, df_comm = compare_df(df1,df2)
        
        print(i+1)
        print(f"command1: {commands_1[i].strip()}")
        print(f"command2: {commands_2[i].strip()}")
        print("\n precision: {} recall: {} \ncommon entries: {} \ntarget entries: {} \nground truth entries: {}".format(p,r,df_comm.shape[0], df1.shape[0], df2.shape[0]))
        
        print("\n")
        # df_comm.to_csv(f"./test2/out_common_{i}.csv", index=False)
        # df1.to_csv(f"./test2/out_{i}_1.csv", index=False)
        # df2.to_csv(f"./test2/out_{i}_2.csv", index=False)
        
        i+=1
        
        overall_p += p
        overall_r += r
    
    overall_p = round(overall_p/len(commands_1),2)
    overall_r = round(overall_r/len(commands_1),2)
    
    overall_f1 = round(2*(overall_p)*(overall_r)/((overall_p)+(overall_r)),2)
    
    print("overall precision: {} overall recall: {}".format(overall_p, overall_r))
    print("overall f1 score: {}".format(overall_f1))

    
    