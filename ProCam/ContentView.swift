//
//  ContentView.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                histogram
                
                Spacer()
                
                autoManualModeButton
            }
            .padding()
            
            ZStack(alignment: .bottom) {
                cameraPreview
                    .overlay {
                        balanceIndicator
                    }
                
                Rectangle()
                    .foregroundColor(.black)
                    .frame(height: 80)
            }
            
            Group {
                Divider()
                Divider()
            }
            
            Group {
                HStack {
                    autoManualFocusButton
                    
                    Spacer(minLength: 0)
                    
                    portraitModeButton
                }
                .padding(.horizontal)
                
                HStack(alignment: .bottom) {
                    lastImageInLibrary
                    
                    Spacer()
                    
                    capturePhotoButton
                    
                    Spacer()
                    
                    switchBetweenRearCamerasButton
                }
                .padding(.top)
            }
            .background {
                Color.white.opacity(0.05)
            }
        }
        .ignoresSafeArea()
    }
    
    #warning("Show histogram")
    var histogram: some View {
        Text("Histogram")
            .font(.caption)
    }
    
    var autoManualModeButton: some View {
        Button {
            #warning("Toggle Auto/Manual mode")
        } label: {
            Image("AFTriangle")
                .renderingMode(.template)
                .resizedToFit()
                .frame(width: 16, height: 16)
                .tint(.gray)
        }
        .padding(.trailing)
    }
    
    #warning("Show camera preview")
    var cameraPreview: some View {
        Rectangle()
            .foregroundColor(.cyan.opacity(0.2))
    }
    
    var balanceIndicator: some View {
        Circle()
            .stroke()
            .foregroundColor(.gray)
            .frame(width: 32, height: 32)
    }
    
    var autoManualFocusButton: some View {
        Button {
            #warning("Toggle Auto/Manual Focus")
        } label: {
            Text("AF")
                .padding(10)
                .foregroundColor(.yellow)
                .background {
                    CircleBackground(color: .yellow)
                }
        }
        .padding()
    }
    
    var portraitModeButton: some View {
        Button {
            #warning("(De)Activate Portrait Mode")
        } label: {
            Image("PortraitMode")
                .renderingMode(.template)
                .resizedToFit()
                .frame(width: 24, height: 24)
                .padding(10)
                .foregroundColor(.gray)
                .background {
                    CircleBackground(color: .gray)
                }
        }
        .padding()
    }
    
    #warning("Show last image in library")
    var lastImageInLibrary: some View {
        Rectangle()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(8)
            .frame(width: 96, height: 96)
            .padding(.horizontal, 8)
    }
    
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
                    Circle().stroke(lineWidth: 3)
                        .foregroundColor(.white)
                }
        }
        .padding([.horizontal, .bottom], 32)
    }
    
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
        .padding([.horizontal, .bottom], 32)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
