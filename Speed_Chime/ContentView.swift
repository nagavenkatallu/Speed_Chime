import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speedManager = SpeedLimitManager()
    @StateObject private var activityManager = ActivityDetectionManager()

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

            // Live Speed Limit Display
            VStack {
                Text("Speed Limit")
                    .font(.headline)
                    .foregroundColor(.gray)

                Text(speedManager.isTracking ? "\(speedManager.currentSpeedLimit) mph" : "-- mph")
                    .font(.system(size: 70, weight: .black))
                    .foregroundColor(speedManager.isTracking ? .red : .gray)
            }

            Spacer()

            // Manual Start/Stop Button
            Button(action: {
                if speedManager.isTracking {
                    speedManager.stopTracking(isManual: true)
                } else {
                    speedManager.resetManualOverride()
                    speedManager.startTracking(isAuto: false)
                }
            }) {
                Text(speedManager.isTracking ? "Stop Tracking" : "Force Start Tracking")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(speedManager.isTracking ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .onAppear {
            AudioEngine.shared.setupAudioSession()

            activityManager.startMonitoring()

            activityManager.onDrivingStateChanged = { isDriving in
                if isDriving && !speedManager.isTracking {
                    speedManager.startTracking(isAuto: true)
                } else if !isDriving && speedManager.isTracking {
                    speedManager.stopTracking(isManual: false)
                }
            }
        }
    }
}
