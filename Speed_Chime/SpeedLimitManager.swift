import Foundation
import Combine
import CoreLocation
import MapboxNavigationCore

class SpeedLimitManager: ObservableObject {
    @Published var currentSpeedLimit: Int = 0
    @Published var isTracking: Bool = false

    private var cancellables = Set<AnyCancellable>()

    // Retain the provider to keep the Mapbox engine alive in memory
    private var mapboxNavigationProvider: MapboxNavigationProvider?

    // Use the shared AudioEngine instance from the app
    private let audioEngine = AudioEngine.shared

    // Prevent CoreMotion auto-start after the user manually stops tracking
    private var isManuallyStopped: Bool = false

    init() {
        setupMapbox()
    }

    private func setupMapbox() {
        let coreConfig = CoreConfig()
        self.mapboxNavigationProvider = MapboxNavigationProvider(coreConfig: coreConfig)
    }

    func toggleTracking() {
        if isTracking {
            stopTracking(isManual: true)
        } else {
            resetManualOverride()
            startTracking(isAuto: false)
        }
    }

    func resetManualOverride() {
        isManuallyStopped = false
    }

    func startTracking(isAuto: Bool = false) {
        if isAuto && isManuallyStopped {
            print("Auto-start blocked because tracking was manually stopped.")
            return
        }

        guard let mapboxNavigation = mapboxNavigationProvider?.mapboxNavigation else {
            print("Mapbox Engine not initialized yet.")
            return
        }

        guard !isTracking else {
            return
        }

        isTracking = true

        // Start Free Drive / Passive Navigation
        mapboxNavigation.tripSession().startFreeDrive()

        // Subscribe to Mapbox's live location matching stream for speed limits
        mapboxNavigation.navigation().locationMatching
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }

                guard let speedLimitMeasurement = state.speedLimit.value else {
                    return
                }

                let mphLimit = Int(speedLimitMeasurement.converted(to: .milesPerHour).value)

                if mphLimit != self.currentSpeedLimit && mphLimit > 0 {
                    let previousLimit = self.currentSpeedLimit
                    self.currentSpeedLimit = mphLimit

                    print("Live Data Update: Speed Limit changed from \(previousLimit) to \(mphLimit) mph")

                    if mphLimit > previousLimit {
                        self.audioEngine.playChime(isHigh: true)
                    } else {
                        self.audioEngine.playChime(isHigh: false)
                    }
                }
            }
            .store(in: &cancellables)

        print(isAuto ? "🚗 Auto-Tracking Started." : "▶️ Manual Tracking Started.")
    }

    func stopTracking(isManual: Bool = false) {
        isTracking = false
        cancellables.removeAll()

        mapboxNavigationProvider?.mapboxNavigation.tripSession().setToIdle()

        currentSpeedLimit = 0

        if isManual {
            isManuallyStopped = true
            print("⏹ Manual Tracking Stopped. Auto-start paused.")
        } else {
            print("🛑 Auto-Tracking Stopped.")
        }
    }
}
