import xml.etree.ElementTree as etree
import pandas as pd
import os
import re

def filter_entries(text) -> bool:
    raw_text = r"{}".format(text)
    patterns = r"(output\d+\.txt$)|(__PSScriptPolicyTest)"
    found = re.search(patterns,raw_text)
    if( found == None): return True
    else: return False

def parse_xml(path) -> pd.DataFrame:
    tree = etree.iterparse(path)
    ns = "{http://schemas.microsoft.com/win/2004/08/events/event}"

    data = []
    
    keys = ["Task", "Image", "CommandLine", "TargetFilename", 
            "ImageLoaded", "PipeName", "QueryName", "EventType"]
    
    #for debug
    # keys.append("ProcessId","UtcTime", "ParentProcessId")

    for _,eventID in tree:
        row = {}
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
                    if attr.tag == f'{ns}Data':
                        if(filter_entries(attr.text)):
                            row[attr.get('Name')] = attr.text
            if(row != {}):
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
    return df

def compare_df(df1,df2):
    df_diff=pd.concat([df1,df2]).drop_duplicates(keep=False)
    print(df_diff.shape[0], df1.shape[0], df2.shape[0])
    df_diff.to_csv("out_diff.csv", index=False)
    return(df_diff.shape[0]/(df1.shape[0] + df2.shape[0]))
    

def parse_folder(path):
    elems = os.listdir(path)
    dfs = []

    for elem in elems:
        path_elem = os.path.join(path,elem)
        dfs.append(parse_xml(path_elem))
    
    print(compare_df(dfs[0], dfs[3]))
    print(compare_df(dfs[1], dfs[4]))
    print(compare_df(dfs[2], dfs[5]))
   
parse_folder("xml1")




    
    

# import json, xmltodict

# with open("xml\output1.xml") as xml_file:
#     data_dict = xmltodict.parse(xml_file.read())
    
# json_data = json.dumps(data_dict)
# print(json_data)

# with open("data.json", "w") as json_file:
#         json_file.write(json_data)