import xml.etree.ElementTree as etree
import pandas as pd

def parse_xml(path):
    tree = etree.parse(path)
    root = tree.getroot()
    ns = "{http://schemas.microsoft.com/win/2004/08/events/event}"

    data = []
    keys = ["ProcessId", "Image", "ParentProcessId", "CommandLine", "TargetFilename", "ImageLoaded", "PipeName", "QueryName", "EventType", "UtcTime"]
    for eventID in root.findall(".//"):
        row = {}
        if eventID.tag == f"{ns}EventData":
            for attr in eventID.iter():
                if attr.tag == f'{ns}Data':
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


    
    

# import json, xmltodict

# with open("xml\output1.xml") as xml_file:
#     data_dict = xmltodict.parse(xml_file.read())
    
# json_data = json.dumps(data_dict)
# print(json_data)

# with open("data.json", "w") as json_file:
#         json_file.write(json_data)