//
//  Image.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

extension Image {
    
    /// Makes an `Image` resizable and sets the content mode to `fit`.
    func resizedToFit() -> some View {
        self
            .resizable()
            .scaledToFit()
    }
}
