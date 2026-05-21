//
//  AudioEngine.swift
//  Speed_Chime
//
//  Created by Venkat Allu on 5/21/26.
//

import AVFoundation

class AudioEngine: NSObject, AVAudioPlayerDelegate {
    // Singleton instance for easy access across the app
    static let shared = AudioEngine()
    
    // The player that will actually play your sound files
    var audioPlayer: AVAudioPlayer?
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // Program the app to temporarily lower (duck) the volume of active background music
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.duckOthers]
            )
            try session.setActive(true)
            print("Audio session setup successful.")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    func playChime(isHigh: Bool) {
        // IMPORTANT: Change these strings to match the EXACT names of your files!
        let fileName = isHigh ? "high_chime" : "low_chime"
        let fileExtension = "mp3" // Change to "wav" if your files are .wav
        
        // Safely locate the audio file in the Xcode project bundle
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("❌ Error: Could not find \(fileName).\(fileExtension) in the project bundle. Check spelling!")
            return
        }
        
        do {
            // Load the file into the audio player and play it
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self // Optional, allows us to track when the sound finishes
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            if isHigh {
                print("🔊 PLAYING HIGH CHIME: \(fileName).\(fileExtension)")
            } else {
                print("🔉 PLAYING LOW CHIME: \(fileName).\(fileExtension)")
            }
            
        } catch {
            print("❌ Error playing chime: \(error.localizedDescription)")
        }
    }
}
