import Foundation
import Combine
import CoreLocation
// 1. Import Mapbox Core
import MapboxNavigationCore

class SpeedLimitManager: ObservableObject {
    @Published var currentSpeedLimit: Int = 0
    @Published var isTracking: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var mapboxNavigation: CoreNavigation?
    
    // Inject the Audio Engine from Phase 1 so we can trigger chimes
    private let audioEngine = AudioEngine()

    init() {
        setupMapbox()
    }
    
    private func setupMapbox() {
        // 2. Initialize the Mapbox Navigation Core configuration
        let config = CoreConfig(
            routingConfig: RoutingConfig(),
            profile: .automobile // Ensures we snap to roads, not sidewalks
        )
        
        // 3. Instantiate the core engine
        Task { @MainActor in
            self.mapboxNavigation = await MapboxNavigationProvider.core(config: config)
        }
    }

    func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }

    private func startTracking() {
        guard let mapboxNavigation = mapboxNavigation else {
            print("Mapbox Engine not initialized yet.")
            return
        }
        
        isTracking = true
        
        // 4. Start Free Drive (Passive Navigation)
        // This tracks the user on the road graph without a destination
        mapboxNavigation.tripSession().startFreeDrive()
        
        // 5. Subscribe to Mapbox's live navigation status stream
        mapboxNavigation.tripSession().navigationStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                self?.handleNavigationStatus(status)
            }
            .store(in: &cancellables)
    }

    private func stopTracking() {
        isTracking = false
        cancellables.removeAll()
        
        // 6. Stop the Mapbox session to save battery
        mapboxNavigation?.tripSession().stop()
        currentSpeedLimit = 0
    }
    
    private func handleNavigationStatus(_ status: NavigationStatus) {
        // 7. Extract the live speed limit from the current road segment
        // Mapbox returns this as a Measurement<UnitSpeed>
        guard let speedLimitMeasurement = status.speedLimit?.value else {
            // No speed limit data available for this exact coordinate
            return
        }
        
        // Convert to Miles Per Hour (mph) safely
        let mphLimit = Int(speedLimitMeasurement.converted(to: .milesPerHour).value)
        
        // 8. Phase 1 Core Logic Check: Has the limit changed?
        if mphLimit != currentSpeedLimit && mphLimit > 0 {
            let previousLimit = currentSpeedLimit
            currentSpeedLimit = mphLimit
            
            print("Live Data Update: Speed Limit changed from \(previousLimit) to \(mphLimit) mph")
            
            // Trigger the Phase 1 audio ducking/chime logic
            if currentSpeedLimit > previousLimit {
                audioEngine.playHighChime()
            } else {
                audioEngine.playLowChime()
            }
        }
    }
}
