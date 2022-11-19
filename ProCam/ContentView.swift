//
//  ContentView.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

struct ContentView: View {
    @State private var isInManualfocus = false
    @State private var focusAmount = 0.0
    var body: some View {
        VStack(spacing: 0) {
            // The histogram view and button to toggle between auto/manual modes.
            HStack {
                histogram
                
                Spacer()
                
                autoManualModeButton
            }
            .padding()
            
            // The camera preview and bottom controls background,
            // with the controls overlaid in a `ZStack`.
            ZStack(alignment: .bottom) {
                VStack {
                    cameraPreview
                        .overlay {
                            balanceIndicator
                        }
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(height: 272)
                }
                
                VStack {
                    Spacer()
                    CameraControlsGrid()
                        .padding(.bottom, isInManualfocus ? 232 : 208)
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    Divider()
                   
                    VStack {
                        if isInManualfocus {
                            
                            ZStack(alignment: .bottom) {
                                VStack {
                                    HStack {
                                        focusPeakingButton
                                        
                                        Spacer()
                                        
                                        portraitModeButton
                                        focusLoupeButton
                                    }
                                    HStack {
                                        Spacer()
                                    }
                                    HStack {
                                        macroModeButton
                                        Spacer()
                                        autoManualFocusButton
                                    }
                                }
                                .padding(.bottom, 10)
                                .zIndex(2)
                                
                                SegmentedSlider(value: $focusAmount, lowerBound: 0, upperBound: 1, strideLength: 0.02)
                                    .zIndex(1)
                                
                            }
                            .padding(.horizontal, 8)
                        } else {
                            
                            HStack {
                                Spacer()
                            }
                            
                            // The Autofocus button and Portrait mode button
                            HStack {
                                
                                autoManualFocusButton
                                
                                Spacer(minLength: 0)
                                
                                portraitModeButton
                            }
                            .padding([.horizontal, .top], 8)
                        }
                        // The last image in the user's library,
                        // capture button and
                        // button for switching between the different rear cameras.
                        HStack(alignment: .bottom) {
                            lastImageInLibrary
                            
                            Spacer()
                            
                            capturePhotoButton
                            
                            Spacer()
                            
                            switchBetweenRearCamerasButton
                        }
                    }
                    .background {
                        Color.white.opacity(0.05)
                            .background(Color.black)
                    }
                }
            }
            .animation(.default, value: isInManualfocus)
        }
        .ignoresSafeArea()
    }
    
    #warning("Show histogram")
    /// The histogram view.
    var histogram: some View {
        Text("Histogram")
            .font(.caption)
    }
    
    /// The button to toggle between auto and manual camera modes.
    var autoManualModeButton: some View {
        Button {
            #warning("Toggle Auto/Manual mode")
        } label: {
            Image("AFTriangle")
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 12)
                .tint(.gray)
        }
        .padding(.trailing)
        .accessibilityLabel("Show menu to switch between auto and manual modes.")
    }
    
    #warning("Show camera preview")
    /// The preview of what the camera sees.
    var cameraPreview: some View {
        Rectangle()
            .foregroundColor(.cyan.opacity(0.2))
            .accessibilityLabel("Camera preview.")
    }
    
    /// The indicator for device position, either horizontal or vertical.
    var balanceIndicator: some View {
        Circle()
            .stroke()
            .foregroundColor(.gray)
            .frame(width: 32, height: 32)
            .accessibilityHidden(true)
    }
    
    /// The button to toggle between autofocus and manual focus.
    var autoManualFocusButton: some View {
        Button {
            #warning("Toggle Auto/Manual Focus")
            isInManualfocus.toggle()
        } label: {
            Text("AF")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(isInManualfocus ? .white : .yellow)
                .background {
                    CircleBackground(color: isInManualfocus ? .gray : .yellow)
                }
        }
        .padding([.horizontal])
        .accessibilityLabel("Switch between autofocus and manual focus.")
    }
    
    /// The button to toggle focus peaking on or off.
    var focusPeakingButton: some View {
        Button {
            #warning("Toggle Focus Peaking")
        } label: {
            Image(systemName: "circle.dashed")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(.white)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding([.horizontal])
        .accessibilityLabel("Turn on focus peaking.")
    }
    
    /// The button to toggle focus peaking on or off.
    var macroModeButton: some View {
        Button {
            #warning("Toggle Macro Mode")
        } label: {
            Image(systemName: "camera.macro")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(.white)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding([.horizontal])
        .accessibilityLabel("Turn on macro mode.")
    }
    
    /// The button to toggle focus peaking on or off.
    var focusLoupeButton: some View {
        Button {
            #warning("Toggle focus loupe")
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(8)
                .foregroundColor(.white)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding([.horizontal])
        .accessibilityLabel("Turn on focus loupe.")
    }
    
    /// The button to turn on or off Portrait Mode.
    var portraitModeButton: some View {
        Button {
            #warning("(De)Activate Portrait Mode")
        } label: {
            Image("PortraitMode")
                .renderingMode(.template)
                .resizedToFit()
                .frame(width: 16, height: 16)
                .padding(8)
                .foregroundColor(.white)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding([.horizontal, .vertical])
        .accessibilityLabel("Activate portrait mode.")
    }
    
#warning("Show last image in library")
    /// The preview of the last image in the user's photo library.
    var lastImageInLibrary: some View {
        Rectangle()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(8)
            .frame(width: 96, height: 96)
            .padding(.horizontal, 8)
            .accessibilityLabel("Show last photo taken.")
    }
    
    /// The button to capture the photo.
    var capturePhotoButton: some View {
        Button {
            #warning("Capture photo")
        } label: {
            LinearGradient(colors: [.gray.opacity(0.7), .white], startPoint: .top, endPoint: .bottom)
                .clipShape(Circle())
                .background {
                    Circle().foregroundColor(.white)
                }
                .padding(4)
                .frame(width: 80, height: 80)
                .background {
                    Circle()
                        .stroke(lineWidth: 3)
                        .foregroundColor(.white)
                }
        }
        .padding([.horizontal, .bottom], 32)
        .accessibilityLabel("Capture photo.")
    }
    
    /// The button to switch between the different rear cameras.
    var switchBetweenRearCamerasButton: some View {
        Button {
            #warning("Switch between rear cameras")
        } label: {
            Text("1x")
                .padding(10)
                .background {
                    Circle().stroke(lineWidth: 2)
                }
                .foregroundColor(.white)
            
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 32)
        .accessibilityLabel("Switch between rear cameras. Currently at 1x")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
