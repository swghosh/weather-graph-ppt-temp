#!/usr/bin/env python3

# defining values

filePath = './1263442.csv'
stations = {
    'USW00014733': 'BUFFALO NIAGARA INTERNATIONAL NY US',
    'IN022023000': 'NEW DELHI PALAM IN',
    'IN024141500': 'CALCUTTA DUM DUM IN'
}
outFilePath = './wa_quarterly_temp.json'

# parse csv

def csvLineToList(csvLine):
    dataList = csvLine.strip('\n').split(',')
    # return list of data items stripping the quotes
    return list(map(lambda data: data.strip('"').strip(' '), dataList))

def listToDict(values, keys):
    # return a dictionary looping the key and value lists
    return {keys[index].lower(): values[index] for index in range(len(values))}

csvFile = open(filePath)

labels = csvLineToList(csvFile.readline())

csvFile.readline()

# create mean periods and respective months per quarter year

meanPeriods = ['{}Q{}'.format(year, quarter) for year in range(2008, 2018) for quarter in range(1, 5)]

months = {}
for meanPeriod in meanPeriods:
    (year, quarter) = meanPeriod.split('Q')
    quarter = int(quarter)
    months[meanPeriod] = ['%s-%02d' % (year, month) for month in range((quarter - 1) * 3 + 1, quarter * 3 + 1)]

# record for each station
quarterlyCityTemperatures = {}

for stationCode in stations:
    quarterlyCityTemperatures[stationCode] = {}
    weatherRecords = []

    for line in iter(lambda: csvFile.readline(), ''):
        weatherData = listToDict(csvLineToList(line), labels)
        if weatherData['station'] != stationCode:
            break
        weatherRecords.append(weatherData)
  
    for meanPeriod in meanPeriods:
        currentMonths = months[meanPeriod]
        quarterlyRecords = []
        for month in currentMonths:
            quarterlyRecords = quarterlyRecords + list(filter(lambda record: record['date'].startswith(month), weatherRecords))

        tempMax = -9999.99
        tempMin = 1000.00
        for record in quarterlyRecords:
            try: 
                if float(record['tmax']) > tempMax:
                    tempMax = float(record['tmax'])
            except ValueError:
                pass
            try:
                if float(record['tavg']) > tempMax:
                    tempMax = float(record['tavg'])
            except ValueError:
                pass
            try:
                if float(record['tmin']) < tempMin:
                    tempMin = float(record['tmin'])
            except ValueError:
                pass
            try:
                if float(record['tavg']) < tempMin:
                    tempMin = float(record['tavg'])
            except ValueError:
                pass
            
        tempMean = (tempMax + tempMin) / 2
        quarterlyCityTemperatures[stationCode][meanPeriod] = tempMean

# import matplotlib.pyplot as pyplot

# for city in quarterlyCityTemperatures:
#     cityWeather = quarterlyCityTemperatures[city]
#     pyplot.plot(cityWeather.keys(), cityWeather.values())

# pyplot.show()

import json

quarterlyCityWiseMeanTemperatures = [{city: quarterlyCityTemperatures[city]} for city in quarterlyCityTemperatures]
print(json.dumps(quarterlyCityWiseMeanTemperatures))

with open(outFilePath, 'w') as outFile:
    print(json.dumps(quarterlyCityWiseMeanTemperatures), end = '',  file = outFile)
