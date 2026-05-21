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
    
    // Inject the Audio Engine from Phase 1 so we can trigger chimes
    private let audioEngine = AudioEngine()

    init() {
        setupMapbox()
    }
    
    private func setupMapbox() {
        // Initialize with default core configuration
        let coreConfig = CoreConfig()
        
        // Synchronously instantiate the Mapbox engine provider
        self.mapboxNavigationProvider = MapboxNavigationProvider(coreConfig: coreConfig)
    }

    func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }

    private func startTracking() {
        // Access the underlying mapboxNavigation engine
        guard let mapboxNavigation = mapboxNavigationProvider?.mapboxNavigation else {
            print("Mapbox Engine not initialized yet.")
            return
        }
        
        isTracking = true
        
        // Start Free Drive (Passive Navigation)
        mapboxNavigation.tripSession().startFreeDrive()
        
        // Subscribe to Mapbox's live location matching stream for speed limits
        mapboxNavigation.navigation().locationMatching
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                // Extract the live speed limit.
                // .value safely unwraps the Measurement<UnitSpeed> if the road has a known limit.
                guard let speedLimitMeasurement = state.speedLimit.value else {
                    return
                }
                
                // Convert to Miles Per Hour (mph) safely
                let mphLimit = Int(speedLimitMeasurement.converted(to: .milesPerHour).value)
                
                // Phase 1 Core Logic Check: Has the limit changed?
                if mphLimit != self.currentSpeedLimit && mphLimit > 0 {
                    let previousLimit = self.currentSpeedLimit
                    self.currentSpeedLimit = mphLimit
                    
                    print("Live Data Update: Speed Limit changed from \(previousLimit) to \(mphLimit) mph")
                    
                    // Trigger the Phase 1 audio ducking/chime logic
                    if self.currentSpeedLimit > previousLimit {
                        self.audioEngine.playChime(isHigh: true, )
                    } else {
                        self.audioEngine.playChime(isHigh: true, )
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func stopTracking() {
        isTracking = false
        cancellables.removeAll()
        
        // Stop the Mapbox session to save battery
//        mapboxNavigationProvider?.mapboxNavigation.tripSession().stop()
        mapboxNavigationProvider?.mapboxNavigation.tripSession().pauseFreeDrive()
        currentSpeedLimit = 0
    }
}
