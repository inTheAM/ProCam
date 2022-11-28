//
//  SegmentedSlider.swift
//  ProCam
//
//  Created by Ahmed Mgua on 19/11/22.
//

import CoreHaptics
import SwiftUI

/// A custom slider using ticks as measurement
struct SegmentedSlider: View {
    
    /// The current value of the slider.
    @Binding var value: Double
    
    /// The minimum value of the range of the slider.
    let lowerBound: Double
    
    /// The maximum value measureable in the slider.
    let upperBound: Double
    
    /// The size of the segments in the slider.
    let strideLength: Double
    
    /// The range of values accommodated in the slider.
    /// Calculated using the lowerbound, upperbound, and strideLength.
    private var range: [Double] {
        Array(stride(from: lowerBound, through: upperBound, by: strideLength))
    }
    
    /// The position of the leading edge of the slider on the screen.
    /// Updated by reading the leading edge of the geometry reader containing the slider.
    @State private var minX = 0.0
    
    /// Haptic feedback for scrolling through the ticks in the slider.
    @EnvironmentObject var hapticFeedback: HapticFeedback
    
    var body: some View {
        
        // GeometryReader for reading the size of the slider in the parent view.
        GeometryReader { geometry in
            
            // All ticks will be presented in a horizontal ScrollView.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom) {
                    
                    // Iterating over the range of values
                    ForEach(range.indices, id: \.self) { index in
                        let rangeValue = range[index]
                        VStack(spacing: 4) {
                            
                            // If the index is a significant value, show the value above the tick.
                            if isSignificant(index: index) {
                                Text("\(rangeValue, specifier: "%.1f")")
                                    .font(.caption2.bold())
                                    .foregroundColor(.gray)
                                    .fixedSize()
                            }
                            
                            // The tick for the value in the current index in the range array.
                            RoundedRectangle(cornerRadius: 2)
                                .frame(width: 1, height: 12)
                                // Setting an opacity for the tick; every significant index is more visible than the others.
                                .foregroundColor(isSignificant(index: index) ? .white : .white.opacity(0.6))
                            
                        }
                        .frame(width: 3)
                        
                        // Observing the current value for changes, corrected to two decimal places.
                        // If the current value is contained in the range of values, play a short haptic feedback.
                        // If the value is a significant one, emphasize the haptic feedback.
                        .onChange(of: value.roundedTo(places: 2)) { newValue in
                            if newValue == rangeValue.roundedTo(places: 2) {
                                hapticFeedback.playTick(isEmphasized: isSignificant(index: index))
                            }
                        }
                        
                        // Set the opacity for the tick based on where value is compared to the current value being read by the slider.
                        // Thus values on either side of the current value decrease in opacity.
                        .opacity(opacity(index: index))
                    }
                    
                }
                // Setting a background to read how much the user has scrolled through the slider.
                .background {
                    GeometryReader { geo in
                        // Calculating the offset of the scrollview inside its designated coordinate space.
                        let offset = (geo.frame(in: .named("scrollSpace")).maxX - minX - 2) / geo.size.width
                        
                        // Using the offset to update the ScrollViewPreference,
                        // which is used to update the current value read by the slider.
                        Color.clear
                            .preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                            .onAppear {
                                // Setting the position of the leading edge of the scrollview
                                minX = geo.frame(in: .named("scrollSpace")).minX
                            }
                    }
                }
                // Adding space on either side of the slider to position the current value at the center of the parent view.
                .padding(.horizontal, geometry.size.width/2 - 1)
            }
            // Setting the coordinate space of the scrollview.
            .coordinateSpace(name: "scrollSpace")
            
            // Observing the scrollview for changes in offset, and using the offset to update the current value of the slider.
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                let offset = (1 - value)
                
                // Setting the value with minimum and maximum values.
                let allowedValue = max(min(offset, 1.0), 0.0)
                self.value = allowedValue * (upperBound - lowerBound)
            }
            
            // The current value of the scrollview shown using a longer tick overlaid on the slider itself.
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
    
    /// Checks for a significant index in the range of values covered by the slider.
    /// Uses every fifth element as a significant element.
    func isSignificant(index: Int) -> Bool {
        if index == 0 {
            return true
        } else  {
            return index%5==0
        }
    }
    
    /// Calculates the opacity of a tick in the slider based on the position of the current value.
    /// This allows the leftmost and rightmost ticks to be slightly less visible while keeping the center of the slider fully visible.
    func opacity(index: Int) -> Double {
        if range[index] <= value {
            return (1 - (value - range[index])*3)
        } else {
            return (1 - (range[index] - value)*3)
        }
    }
}
