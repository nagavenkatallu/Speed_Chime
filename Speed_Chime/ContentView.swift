import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speedManager = SpeedLimitManager()
    
    // This state controls whether the app is actively working
    @State private var isTracking: Bool = false

    var body: some View {
        VStack(spacing: 40) {
            Text("Speed_Chime")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
            
            // Current Speed Display (Driven by GPX Simulator)
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
                // Show dashes if tracking is stopped
                Text(isTracking ? "\(speedManager.currentSpeedLimit) mph" : "-- mph")
                    .font(.system(size: 70, weight: .black))
                    .foregroundColor(isTracking ? .red : .gray)
            }
            
            Spacer()
            
            // The Start/Stop Manual Override Button
            Button(action: {
                // Toggle the tracking state
                isTracking.toggle()
                
                // Trigger the logic based on the new state
                if isTracking {
                    speedManager.startTracking()
                } else {
                    speedManager.stopTracking()
                }
            }) {
                Text(isTracking ? "Stop Tracking" : "Start Tracking")
                    .font(.title)
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
        }
    }
}
