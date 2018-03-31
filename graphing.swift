import Foundation
import PlaygroundSupport

// fetch json(s) of data values
var prcpJson = try String(contentsOf:  playgroundSharedDataDirectory.appendingPathComponent("wa_annual_prcp_buf.json"))
var prcpJsonData = prcpJson.data(using: .utf8)

var tempJson = try String(contentsOf:  playgroundSharedDataDirectory.appendingPathComponent("wa_quarterly_temp.json"))
var tempJsonData = tempJson.data(using: .utf8)

// serialising the json(s) into an object
var parsedPrcpJson = try JSONSerialization.jsonObject(with: prcpJsonData!, options: JSONSerialization.ReadingOptions()) as! [String: [String: Float]]
var parsedTempJson = try JSONSerialization.jsonObject(with: tempJsonData!, options: JSONSerialization.ReadingOptions()) as! [[String: [String: Float]]]

// Precipitation
var pptXValues = [String]()
var pptYValues = [Float]()
for (_, dataDict) in parsedPrcpJson {
    for record in dataDict.sorted(by: <) {
        pptXValues.append(record.key)
        pptYValues.append(record.value)
    }
}
pptXValues
pptYValues

// Temperature
var allTempXValues = [[String]]()
var allTempYValues = [[Float]]()

for item in parsedTempJson {
    for (_, dataDict) in item {
        var xValues = [String]()
        var yValues = [Float]()
        
        for record in dataDict.sorted(by: <) {
            xValues.append(record.key)
            yValues.append(record.value)
        }
        
        allTempXValues.append(xValues)
        allTempYValues.append(yValues)
    }
}
allTempXValues
allTempYValues

// BUF Quarterly Mean Temperature
let graph1 = GraphView(frame: CGRect(x: 0, y: 0, width: 1000, height: 700))
graph1.currents = allTempYValues[0]
graph1.labels = allTempXValues[0]
graph1.lvalue = -10
graph1.hvalue = 50
graph1.backgroundColor = .white
graph1.setNeedsDisplay()
graph1

// DEL Quarterly Mean Temperature
let graph2 = GraphView(frame: CGRect(x: 0, y: 0, width: 1000, height: 700))
graph2.currents = allTempYValues[1]
graph2.labels = allTempXValues[1]
graph2.lvalue = 0
graph2.hvalue = 50
graph2.backgroundColor = .white
graph2.setNeedsDisplay()
graph2

// CCU Quarterly Mean Temperature
let graph3 = GraphView(frame: CGRect(x: 0, y: 0, width: 1000, height: 700))
graph3.currents = allTempYValues[2]
graph3.labels = allTempXValues[2]
graph3.lvalue = 0
graph3.hvalue = 50
graph3.backgroundColor = .white
graph3.setNeedsDisplay()
graph3

// BUF Annual Precipitation
let graph4 = GraphView(frame: CGRect(x: 0, y: 0, width: 1000, height: 700))
graph4.currents = pptYValues
graph4.labels = pptXValues
graph4.lvalue = 0
graph4.hvalue = 50
graph4.backgroundColor = .white
graph4.setNeedsDisplay()
graph4
