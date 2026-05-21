//
//  ActivityDetectionManager.swift
//  Speed_Chime
//

import CoreMotion
import Combine

class ActivityDetectionManager: ObservableObject {
    private let motionActivityManager = CMMotionActivityManager()
    
    @Published var isDriving: Bool = false
    @Published var currentActivity: String = "Unknown"
    
    // We use a callback to tell the rest of the app when driving starts/stops automatically
    var onDrivingStateChanged: ((Bool) -> Void)?

    func startMonitoring() {
        // Check if motion data is available on this device
        guard CMMotionActivityManager.isActivityAvailable() else {
            self.currentActivity = "Motion Data Unavailable"
            return
        }
        
        motionActivityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self = self, let activity = activity else { return }
            
            // Determine the activity string for the UI
            if activity.automotive {
                self.currentActivity = "Driving 🚗"
            } else if activity.walking {
                self.currentActivity = "Walking 🚶‍♂️"
            } else if activity.running {
                self.currentActivity = "Running 🏃‍♂️"
            } else if activity.cycling {
                self.currentActivity = "Cycling 🚴"
            } else if activity.stationary {
                self.currentActivity = "Stationary 🛑"
            } else {
                self.currentActivity = "Unknown ❓"
            }
            
            // Handle Automotive State Change
            let newlyDetectedDriving = activity.automotive
            
            // Only trigger updates if the state actually changed to avoid spamming
            if newlyDetectedDriving != self.isDriving {
                self.isDriving = newlyDetectedDriving
                self.onDrivingStateChanged?(newlyDetectedDriving)
                print("Activity changed: isDriving = \(self.isDriving)")
            }
        }
    }
    
    func stopMonitoring() {
        motionActivityManager.stopActivityUpdates()
        print("Stopped monitoring motion activity.")
    }
}
