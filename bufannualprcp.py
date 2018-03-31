#!/usr/bin/env python3

filePath = './old_1261071.csv'
outFilePath = './wa_annual_prcp_buf.json'

def csvLineToList(csvLine):
    dataList = csvLine.strip('\n').split(',')
    # return list of data items stripping the quotes
    return list(map(lambda data: data.strip('"').strip(' '), dataList))

def listToDict(values, keys):
    return {keys[index].lower(): values[index] for index in range(len(values))}

csvFile = open(filePath)

labels = csvLineToList(csvFile.readline())

pptData = []
for line in iter(lambda: csvFile.readline(), ''):
    dataDict = listToDict(csvLineToList(line), labels)
    try: 
        pptData.append({ 'station': dataDict['station'], 'date': dataDict['date'], 'prcp': dataDict['prcp'] })
    except:
        pass

stationCode = pptData[0]['station']

pptData = filter(lambda record: record['station'] == stationCode, pptData)
pptData = {stationCode: list(map(lambda record: { 'date': record['date'], 'prcp': record['prcp'] }, pptData))}

yearlyPptData = {}

for year in range(2008, 2018):
    yearlyData = list(filter(lambda record: record['date'].startswith(str(year)), pptData[stationCode]))
    prcpSum = 0
    for data in yearlyData:
        try:
            prcpSum = prcpSum + float(data['prcp'])
        except ValueError:
            pass
    yearlyPptData[str(year)] = prcpSum

# import matplotlib.pyplot as pyplot
# pyplot.plot(yearlyPptData.keys(), yearlyPptData.values(), 'r.-')
# pyplot.show()

import json

print(json.dumps({stationCode: yearlyPptData}))

with open(outFilePath, 'w') as outFile:
    print(json.dumps({stationCode: yearlyPptData}), end = '',  file = outFile)

