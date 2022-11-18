//
//  HapticFeedback.swift
//  ProCam
//
//  Created by Ahmed Mgua on 18/11/22.
//

import SwiftUI

enum HapticFeedback {
    static func play(_ notification: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(notification)
    }
}
