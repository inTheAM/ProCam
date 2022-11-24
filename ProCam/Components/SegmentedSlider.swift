//
//  SegmentedSlider.swift
//  ProCam
//
//  Created by Ahmed Mgua on 19/11/22.
//

import CoreHaptics
import SwiftUI

struct SegmentedSlider: View {
    @Binding var value: Double
    let lowerBound: Double
    let upperBound: Double
    let strideLength: Double
    private var range: [Double] {
        Array(stride(from: lowerBound, through: upperBound, by: strideLength))
    }
    @State private var minX = 0.0
    @EnvironmentObject var hapticFeedback: HapticFeedback
    
    func opacity(index: Int) -> Double {
        if range[index] <= value {
            return (1 - (value - range[index])*3)
        } else {
            return (1 - (range[index] - value)*3)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom) {
                    ForEach(range.indices, id: \.self) { index in
                        let rangeValue = range[index]
                        VStack(spacing: 4) {
                            if isSignificant(index: index) {
                                Text("\(rangeValue, specifier: "%.1f")")
                                    .font(.caption2.bold())
                                    .foregroundColor(.gray)
                                    .fixedSize()
                            }
                            RoundedRectangle(cornerRadius: 2)
                                .frame(width: 1, height: 12)
                                .foregroundColor(isSignificant(index: index) ? .gray : .gray.opacity(0.6))
                            
                        }
                        .frame(width: 3)
                        .onChange(of: value.roundedTo(places: 2)) { newValue in
                            if newValue == rangeValue.roundedTo(places: 2) {
                                hapticFeedback.playTick(isEmphasized: isSignificant(index: index))
                            }
                        }
                        .opacity(opacity(index: index))
                    }
                    
                }
                .background {
                    GeometryReader { geo in
                        let offset = (geo.frame(in: .named("scrollSpace")).maxX - minX - 2) / geo.size.width
                        
                        Color.clear
                            .preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                            .onAppear {
                                minX = geo.frame(in: .named("scrollSpace")).minX
                            }
                    }
                }
                .padding(.horizontal, geometry.size.width/2 - 1)
            }
            .coordinateSpace(name: "scrollSpace")
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                let offset = (1 - value)
                let allowedValue = max(min(offset, 1.0), 0.0)
                self.value = allowedValue * (upperBound - lowerBound)
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 4) {
                    Text("\(value.roundedTo(places: 1), specifier: "%.1f")")
                        .fontWeight(.medium)
                        .fixedSize()
                    RoundedRectangle(cornerRadius: 1)
                        .frame(width: 2, height: 44)
                        .foregroundColor(.white)
                }
            }
        }
        .frame(height: 30, alignment: .bottom)
        
    }
    func isSignificant(index: Int) -> Bool {
        if index == 0 {
            return true
        } else  {
            return index%5==0
        }
    }
}
