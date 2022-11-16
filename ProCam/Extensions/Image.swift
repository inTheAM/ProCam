//
//  Image.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

extension Image {
    func resizedToFit() -> some View {
        self
            .resizable()
            .scaledToFit()
    }
}
