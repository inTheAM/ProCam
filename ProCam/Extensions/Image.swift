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

extension CIImage {
    /// A SwiftUI `Image` from a `CIImage` for use in SwiftUI Views.
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 3, orientation: .up)
    }
}
