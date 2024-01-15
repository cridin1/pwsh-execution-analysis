import xml.etree as etree
import pandas as pd

def read_xml(FILENAME):
    parser = etree.XMLParser(recover=True)
    with open(FILENAME) as file:
        data = file.readlines()
    # ignore XML documentation's tag (1st line), 
    # so taking only data[1:]
    raw = etree.fromstring(data[1:], parser=parser)
    return raw

def events_to_df(eventlist):
    df = pd.DataFrame()
    # you may need to tune this tag according to your XML format
    tag = '{http://schemas.microsoft.com/win/2004/08/events/event}'
    for idx, event in enumerate(eventlist):
        edict = {}
        for element in event.iterdescendants():
            # filter out empty fields
            if any(x in element.tag for x in ["Provider",
                                              "System",
                                              "Correlation"]):
                pass
            elif any(x in element.tag for x in ['TimeCreated',\
                                                'Execution',\
                                                'Security']):
                for item in element.items():
                    edict[item[0]] = item[1]
            elif 'Data' in element.tag:
                for item in element.items():
                    edict[item[1]] = element.text
            else:
                edict[element.tag.replace(tag,'')] = element.text
        
        # add raw text event to have ability 
        # always access full value of eventlog
        edict['raw'] = etree.tostring(event,\
                             pretty_print=True).decode()
    
        edf = pd.DataFrame(edict, index=[idx])
        df = df.append(edf, sort=True)    
    return df

