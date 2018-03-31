//
//  GraphView.swift
//
//  Created by SwG Ghosh on 25/04/17.
//  Copyright © 2017. All rights reserved.
//

//  Last modified on 29/03/18.

import UIKit
import CoreGraphics

@IBDesignable
class GraphView: UIView {
    
    // IB defines the colors to be used for various elements in the line graph
    @IBInspectable var graphAxisColor: UIColor = .black
    @IBInspectable var graphPointColor: UIColor = .blue
    @IBInspectable var graphLineColor: UIColor = .blue
    @IBInspectable var graphLegendPointColor: UIColor = .gray
    @IBInspectable var graphLegendLabelColor: UIColor = .gray
    @IBInspectable var graphLegendLineColor: UIColor = .gray
    
    // sample y values whose graph is to be plotted
    var currents: [Float] = [Float]()
    // lowest and highest values in the actual graph used for calibrating the scale in the graph
    var lvalue = 0
    var hvalue = 10
    
    // sample x values in the form of 
    var labels = [String]()
    
    var allGoodToGo: Bool = false
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // defines an offset to place the axes of the graph with respect to rect
        let axisOffset: CGFloat = 20.0
        // defines the point of origin of graph in terms of rect position
        let origin: CGPoint = CGPoint(x: axisOffset, y: rect.height - axisOffset)
        // defines an offset for allowing a small border and to ensure plotted points do not get out of screen
        let borderOffset: CGFloat = 10.0
        // defines the radius of each point that is to be drawn
        let pointRadius: CGFloat = 5.0
        
        // only draw when a certain flag is set to true
//        if(self.allGoodToGo) {
            // draws the x and y axis of the graph with the specified offset
            drawAxes(axisOffset: axisOffset)
        
            // draws the scale for the graph to facilitate ease of understanding values
            drawScale(originPoint: origin, borderOffset: borderOffset, pointRadius: pointRadius, yLowest: lvalue, yHighest: hvalue, numberOfValues: currents.count - 1)
        
            // plots a graph based on the integral values provide and highest and lowest values
            plotGraph(originPoint: origin, borderOffset: borderOffset, pointRadius: pointRadius, yValues: currents, yLowest: lvalue, yHighest: hvalue)
//        }
    }
    
    func drawAxes(axisOffset: CGFloat) {
        // refers to current rect
        let rect = self.bounds
        
        // draw the axes for the graph
        
        // draws the x axis line for the graph
        let xAxisLine = UIBezierPath()
        xAxisLine.move(to: CGPoint(x: axisOffset, y: rect.height - axisOffset))
        xAxisLine.addLine(to: CGPoint(x: rect.width, y: rect.height - axisOffset))
        xAxisLine.close()
        
        // draws the y axis line for the graph
        let yAxisLine = UIBezierPath()
        yAxisLine.move(to: CGPoint(x: axisOffset, y: 0.0))
        yAxisLine.addLine(to: CGPoint(x: axisOffset, y: rect.height - axisOffset))
        yAxisLine.close()
        
        // uses the color specified in IB to stroke the axes lines
        graphAxisColor.setStroke()
        
        xAxisLine.stroke()
        yAxisLine.stroke()
    }
    
    func drawScale(originPoint: CGPoint, borderOffset: CGFloat, pointRadius: CGFloat, yLowest lvalue: Int, yHighest hvalue: Int, numberOfValues: Int) {
        // refers to the current rect
        let rect = self.bounds
        
        // defines a constant float value to help in drawing points on screen with rects
        let originOffsetForPoint: CGFloat = pointRadius / 2;
        
        // sets the colors for the line graph that is to be plotted based on colours specified in IB
        graphLegendPointColor.setFill()
        // sets the color for the legend line that is specified in IB
        graphLegendLineColor.setStroke()
        
        // defines the x, y positions on rect of the origin of the graph
        let xOrigin: CGFloat = originPoint.x
        let yOrigin: CGFloat = originPoint.y
        
        // defines the difference in x, y from highest postion of graph to lowest position on graph along x, y respectively as per points on the rect
        let xDiff: CGFloat = (rect.width - xOrigin - borderOffset)
        let yDiff: CGFloat = (yOrigin - 0.0 - borderOffset)
        
        // defines the difference in highest and lowest of the actual graph values
        let valDiff = CGFloat(hvalue - lvalue)
        // defines a scaling calibration value useful for plotting of y points on graph, differenceInActualValuesOfGraph/differenceInYLimitOfRect
        let yDiffScale = valDiff / yDiff
        
        // defines a scaling calibration value useful for plotting of x points on graph, provided that x incremennts by one for each consecutive value of y
        let xDiffScale = (xDiff / CGFloat(numberOfValues))
        
        // loop to draw the legend points and legend text labels along y axis
        var i = 0
        while(i <= 10) {
            // actual rect point for the legend graph point that is to be plotted on the graph
            let point = CGPoint(x: xOrigin, y: yOrigin - (CGFloat(hvalue - lvalue) * CGFloat(i) / 10.0) / yDiffScale)
            // defining a rect with an origin offset at that point
            let pointRect = CGRect(x: point.x - originOffsetForPoint, y: point.y - originOffsetForPoint, width: pointRadius, height: pointRadius)
            // drawing a oval/circle in that rect to represent a point on the actual graph
            let pointPath = UIBezierPath(ovalIn: pointRect)
            // fill the oval with color
            pointPath.fill()
            
            // draw labels for legend texts
            let label = UILabel(frame: CGRect(x: xOrigin - xOrigin, y: point.y - (yDiff / 11.0) + (yDiff / 11.0 / 4.0) , width: originPoint.x - 2.0, height: yDiff / 11.0))
            // make font in label to adjust to fit width
            label.adjustsFontSizeToFitWidth = true
            // set legend text color as specified in IB
            label.textColor = graphLegendLabelColor
            label.backgroundColor = .clear
            label.textAlignment = .center
            // assign appropriate valua as text to the legend label
            label.text = "\(((hvalue - lvalue) * i / 10) + lvalue)"
            
            // add the label to the current view
            self.addSubview(label)
            
            if (i != 0) {
                // draw a line for graph legend
                let line = UIBezierPath()
                // point upto which line is to be drawn
                let toPoint = CGPoint(x: rect.width, y: point.y)
                // line to start from current defined point
                line.move(to: point)
                // line to end at
                line.addLine(to: toPoint)
                line.close()
                
                // line is stroked with color set
                line.stroke()
            }
            
            // increment loop counter
            i = i + 1
        }
        
        // loop to draw the legend points and legend text labels along x axis
        i = 0
        while(i <= numberOfValues) {
            // actual rect point for the legend graph point that is to be plotted on the graph
            let point = CGPoint(x: xOrigin + (CGFloat(i) * xDiffScale), y: yOrigin)
            // defining a rect with an origin offset at that point
            let pointRect = CGRect(x: point.x - originOffsetForPoint, y: point.y - originOffsetForPoint, width: pointRadius, height: pointRadius)
            // drawing a oval/circle in that rect to represent a point on the actual graph
            let pointPath = UIBezierPath(ovalIn: pointRect)
            // fill the oval with color
            pointPath.fill()
            
            // draw labels for legend texts
            let label = UILabel(frame: CGRect(x: point.x - (xDiffScale / 2.0), y: originPoint.y , width: xDiffScale, height: rect.height - originPoint.y))
            // set font in label
            label.font = .systemFont(ofSize: 8.0)
            // set legend text color as specified in IB
            label.textColor = graphLegendLabelColor
            label.backgroundColor = .clear
            label.textAlignment = .center
            // assign appropriate value as text to the legend label
            label.text = "\(labels[i])"
            
            // add the label to the current view
            self.addSubview(label)
            
            if(i != 0) {
                // draw a line for graph legend
                let line = UIBezierPath()
                // point upto which line is to be drawn
                let toPoint = CGPoint(x: point.x, y: 0.0)
                // line to start from current defined point
                line.move(to: point)
                // line to end at
                line.addLine(to: toPoint)
                line.close()
                
                // line is stroked with color set
                line.stroke()
            }
            
            // increment loop counter
            i = i + 1
        }
    }
    
    func plotGraph(originPoint: CGPoint, borderOffset: CGFloat, pointRadius: CGFloat, yValues values: [Float], yLowest lvalue: Int, yHighest hvalue: Int) {
        // refers to the current rect
        let rect = self.bounds
        
        // defines a constant float value to help in drawing points on screen with rects
        let originOffsetForPoint: CGFloat = pointRadius / 2;
        
        // sets the colors for the line graph that is to be plotted based on colours specified in IB
        graphPointColor.setFill()
        graphLineColor.setStroke()
        
        // defines the x, y positions on rect of the origin of the graph
        let xOrigin: CGFloat = originPoint.x
        let yOrigin: CGFloat = originPoint.y
        
        // defines the difference in x, y from highest postion of graph to lowest position on graph along x, y respectively as per points on the rect
        let xDiff: CGFloat = (rect.width - xOrigin - borderOffset)
        let yDiff: CGFloat = (yOrigin - 0.0 - borderOffset)
        
        // defines the difference in highest and lowest of the actual graph values
        let valDiff = CGFloat(hvalue - lvalue)
        // defines a scaling calibration value useful for plotting of y points on graph, differenceInActualValuesOfGraph/differenceInYLimitOfRect
        let yDiffScale = valDiff / yDiff
        
        // defines a scaling calibration value useful for plotting of x points on graph, provided that x incremennts by one for each consecutive value of y
        let xDiffScale = (xDiff / CGFloat(values.count - 1))
        
        // counter to run a loop to plot points and lines on the graph for each of the values
        var i = 0
        while(i < values.count) {
            // actual rect point for the graph point that is to be plotted on the graph
            let point = CGPoint(x: xOrigin + (CGFloat(i) * xDiffScale), y: yOrigin - ((CGFloat(values[i]) - CGFloat(lvalue)) / yDiffScale))
            // defining a rect with an origin offset at that point
            let pointRect = CGRect(x: point.x - originOffsetForPoint, y: point.y - originOffsetForPoint, width: pointRadius, height: pointRadius)
            // drawing a oval/circle in that rect to represent a point on the actual graph
            let pointPath = UIBezierPath(ovalIn: pointRect)
            // fill the oval with color
            pointPath.fill()
            
            // draw a line between this point and the next point on the graph that is to plotted on next iteration of the loop
            if(i + 1 != values.count) {
                // bezier path to draw the line
                let line = UIBezierPath()
                
                // point to
                let nextPoint = CGPoint(x: xOrigin + (CGFloat(i + 1) * xDiffScale), y: yOrigin - ((CGFloat(values[i + 1]) - CGFloat(lvalue)) / yDiffScale))
                
                // line to start from current defined point
                line.move(to: point)
                // line to be drawn upto the next defined point
                line.addLine(to: nextPoint)
                line.close()
                
                // stroke the line with color
                line.stroke()
            }
            
            // increment loop counter
            i = i + 1
        }
        
    }
    
}