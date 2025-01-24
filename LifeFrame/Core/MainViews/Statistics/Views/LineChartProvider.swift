//
//  LineChartProvider.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

struct LineChartProvider {
    let data: [StepCount]
    var lineRadius: CGFloat = 0.5
    
    private var maxYValue: CGFloat {
        10
    }
    
    private var maxXValue: CGFloat {
        CGFloat(data.count - 1)
    }

    func path(for geometry: GeometryProxy) -> Path {
        Path { path in
            drawData(path: &path, size: geometry.size)
        }
    }
    
    func closedPath(for geometry: GeometryProxy) -> Path {
        Path { path in
            drawData(path: &path, size: geometry.size)
            
            path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height))
            path.addLine(to: .init(x: 0, y: geometry.size.height))
            path.closeSubpath()
        }
    }
    
    private func drawData(path: inout Path, size: CGSize) {
        if !data.isEmpty {
            if data.count == 1 {
                let x = size.width
                let y = size.height - (data.first!.value / self.maxYValue) * size.height
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: x, y: y))
            } else {
                var previousPoint = CGPoint(x: 0, y: self.data.first!.value)
                self.data.enumerated().forEach { index, point in
                    let x = (CGFloat(index) / self.maxXValue) * size.width
                    let y = size.height - (point.value / self.maxYValue) * size.height
                    
                    let deltaX = x - previousPoint.x
                    let curveXOffset = deltaX * self.lineRadius
                    
                    if point == self.data.first {
                        path.move(to: .init(x: 0, y: y))
                    } else {
                        path.addCurve(to: .init(x: x, y: y),
                                      control1: .init(x: previousPoint.x + curveXOffset, y: previousPoint.y),
                                      control2: .init(x: x - curveXOffset, y: y ))
                    }
                    previousPoint = .init(x: x, y: y)
                }
            }
        }
    }
}
