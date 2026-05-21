import Foundation
import Combine

class SpeedLimitManager: ObservableObject {
    @Published var currentSpeedLimit: Int = 0
    private var timer: Timer?
    
    // Added to prevent auto-start from overriding a manual stop
    var isManuallyStopped: Bool = false

    func startTracking(isAuto: Bool = false) {
        // If the user manually stopped it, don't let CoreMotion auto-start it
        if isAuto && isManuallyStopped {
            print("Auto-start blocked because tracking was manually stopped.")
            return
        }
        
        if timer == nil {
            generateRandomSpeedLimit()
            timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
                self?.generateRandomSpeedLimit()
            }
            print(isAuto ? "🚗 Auto-Tracking Started." : "▶️ Manual Tracking Started.")
        }
    }

    func stopTracking(isManual: Bool = false) {
        timer?.invalidate()
        timer = nil
        currentSpeedLimit = 0
        
        if isManual {
            isManuallyStopped = true
            print("⏹ Manual Tracking Stopped. Auto-start paused.")
        } else {
            print("🛑 Auto-Tracking Stopped (No longer driving).")
        }
    }

    // Reset the manual override state (e.g., when the user presses start again)
    func resetManualOverride() {
        isManuallyStopped = false
    }

    private func generateRandomSpeedLimit() {
        let newLimit = Int.random(in: 35...75)
        if newLimit != currentSpeedLimit {
            currentSpeedLimit = newLimit
            triggerEvent()
        }
    }

    private func triggerEvent() {
        print("Speed limit changed to \(currentSpeedLimit) mph!")
        AudioEngine.shared.playChime(isHigh: currentSpeedLimit >= 50)
    }
}
