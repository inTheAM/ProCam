//
//  Double.swift
//  ProCam
//
//  Created by Ahmed Mgua on 19/11/22.
//

import Foundation

extension Double {
    func roundedTo(places: Int, rule: FloatingPointRoundingRule = .down) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(rule) / divisor
    }
}
