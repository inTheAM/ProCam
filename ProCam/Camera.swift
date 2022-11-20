//
//  Camera.swift
//  ProCam
//
//  Created by Ahmed Mgua on 20/11/22.
//

import SwiftUI

@MainActor
final class Camera: ObservableObject {
    private let service = CameraService()
    @Published var preview: Image?
    @Published var thumbnailImage: Image?
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = service.previewStream
            .map { $0.image }

        for await image in imageStream {
            preview = image
        }
    }
    
    func start() async {
        await service.start()
    }
    
    func capture() {
        service.capturePhoto()
    }
}
