//
//  SpeedLimitManager.swift
//  Speed_Chime
//
//  Created by Venkat Allu on 5/21/26.
//

import Foundation
import Combine

class SpeedLimitManager: ObservableObject {
    @Published var currentSpeedLimit: Int = 0
    private var timer: Timer?

    // Called when the user presses "Start Tracking"
    func startTracking() {
        // Generate an initial random speed immediately
        generateRandomSpeedLimit()
        
        // Start a timer to change the limit every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.generateRandomSpeedLimit()
        }
        print("▶️ Tracking Started: Generating mock speeds every 10 seconds.")
    }

    // Called when the user presses "Stop Tracking"
    func stopTracking() {
        timer?.invalidate() // Stop the timer
        timer = nil
        currentSpeedLimit = 0 // Reset the display
        print("⏹ Tracking Stopped.")
    }

    // The temporary mock logic to replace with Mapbox later
    private func generateRandomSpeedLimit() {
        let newLimit = Int.random(in: 35...75)
        
        // Foundational rule: If NewSpeedLimit != CurrentSpeedLimit -> Trigger Event
        if newLimit != currentSpeedLimit {
            currentSpeedLimit = newLimit
            triggerEvent()
        }
    }

    private func triggerEvent() {
        print("Speed limit changed to \(currentSpeedLimit) mph! Triggering event.")
        
        // Pass 'true' for a high chime if the limit is 50 or above
        AudioEngine.shared.playChime(isHigh: currentSpeedLimit >= 50)
    }
}
