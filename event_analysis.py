import xml.etree.ElementTree as etree
import pandas as pd
import os
import re

def parse_xml(path) -> pd.DataFrame:
    tree = etree.iterparse(path)
    ns = "{http://schemas.microsoft.com/win/2004/08/events/event}"

    data = []
    
    keys = ["Task", "Image", "ParentProcessId", "CommandLine", "TargetFilename", 
            "ImageLoaded", "PipeName", "QueryName", "EventType"]
    
    #for debug
    # keys.append("ProcessId","UtcTime")

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
                        text = r"{}".format(attr.text)
                        pattern = r"output\d+\.txt$"
                        if(re.search(pattern,text) == None): #skipping output.txt events
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
    return

def parse_folder(path):
    elems = os.listdir(path)
    dfs = []

    for elem in elems:
        path_elem = os.path.join(path,elem)
        dfs.append(parse_xml(path_elem))
    
    dfs[0].to_csv("out1.csv", index=False)
    dfs[1].to_csv("out2.csv", index=False)
    df_diff=pd.concat([dfs[0],dfs[1]]).drop_duplicates(keep=False)
    df_diff.to_csv("out_diff.csv", index=False)
parse_folder("xml")




    
    

# import json, xmltodict

# with open("xml\output1.xml") as xml_file:
#     data_dict = xmltodict.parse(xml_file.read())
    
# json_data = json.dumps(data_dict)
# print(json_data)

# with open("data.json", "w") as json_file:
#         json_file.write(json_data)