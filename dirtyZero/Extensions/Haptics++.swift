//  
//  Haptics++.swift
//  SSC25
//
//  Created by Skadz on 2/18/25.
//

import Foundation
import UIKit

class Haptic: ObservableObject {
    static let shared = Haptic()
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        Task { @MainActor in
            UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
        }
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        Task { @MainActor in
            UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
        }
    }
}
