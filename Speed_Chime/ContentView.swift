import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speedManager = SpeedLimitManager()
    @StateObject private var activityManager = ActivityDetectionManager()
    
    @State private var isTracking: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Speed_Chime")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
            
            // Motion Activity Display
            HStack {
                Text("Detected Activity:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(activityManager.currentActivity)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.purple)
            }
            .padding(.top, -10)
            
            // Current Speed Display
            VStack {
                Text("Current Speed")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("\(Int(locationManager.currentSpeed)) mph")
                    .font(.system(size: 70, weight: .black))
                    .foregroundColor(.blue)
            }
            
            // Mocked Speed Limit Display
            VStack {
                Text("Speed Limit")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(isTracking ? "\(speedManager.currentSpeedLimit) mph" : "-- mph")
                    .font(.system(size: 70, weight: .black))
                    .foregroundColor(isTracking ? .red : .gray)
            }
            
            Spacer()
            
            // The Start/Stop Manual Override Button
            Button(action: {
                isTracking.toggle()
                
                if isTracking {
                    speedManager.resetManualOverride()
                    speedManager.startTracking(isAuto: false)
                } else {
                    speedManager.stopTracking(isManual: true)
                }
            }) {
                Text(isTracking ? "Stop Tracking" : "Force Start Tracking")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isTracking ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .onAppear {
            AudioEngine.shared.setupAudioSession()
            
            // Start listening for activity changes
            activityManager.startMonitoring()
            
            // React to automatic driving detection
            activityManager.onDrivingStateChanged = { isDriving in
                // Only change state if we aren't manually overriding
                if isDriving && !isTracking {
                    isTracking = true
                    speedManager.startTracking(isAuto: true)
                } else if !isDriving && isTracking {
                    isTracking = false
                    speedManager.stopTracking(isManual: false)
                }
            }
        }
    }
}
