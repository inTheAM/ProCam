//
//  CircleBackground.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

/// A circular background for a view.
/// Adds two circles, one with a stroke design and another filled, with some level of opacity.
struct CircleBackground: View {
    let color: Color
    var body: some View {
        Circle().stroke(lineWidth: 2)
            .foregroundColor(color)
            .background {
                Circle()
                    .foregroundColor(color.opacity(0.2))
            }
    }
}
