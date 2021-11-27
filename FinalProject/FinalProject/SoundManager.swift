import Foundation
import AVFoundation

enum Sound : String, CaseIterable {
    case home="home-music"
    case game="game-music"
    case selection="selection"
    case laser="laser_sound"
    case hitmarker="hitmarker"
    case explosion="explosion"
}

class SceneMute {
    static var muted = false
}

class SoundManager : ObservableObject {
    var backgroundMusicPlayer: AVAudioPlayer?
    var soundEffectsPlayer: AVAudioPlayer?
    
    @Published var muted = false
        
    func playBackgroundMusic(sound: Sound) {
        guard let path = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: path)
            backgroundMusicPlayer?.volume = muted ? 0 : 1
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.numberOfLoops = -1
                        
            self.backgroundMusicPlayer?.play()
        } catch {
            // ERROR
        }
    }
    
    func playSoundEffect(sound: Sound) {
        guard let fileURL = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        
        do {
            soundEffectsPlayer = try AVAudioPlayer(contentsOf: fileURL)
            soundEffectsPlayer?.volume = muted ? 0 : 1
            soundEffectsPlayer?.prepareToPlay()
        
            soundEffectsPlayer?.play()
        } catch {
            // ERROR
        }
    }
    
    func preload(sound: Sound) {
        guard let fileURL = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        
        do {
            soundEffectsPlayer = try AVAudioPlayer(contentsOf: fileURL)
            soundEffectsPlayer?.prepareToPlay()
        } catch {
            // ERROR
        }
    }
    
    func mute() {
        muted = true
        SceneMute.muted = true
        
        soundEffectsPlayer?.volume = 0
        backgroundMusicPlayer?.volume = 0
    }
    
    func unmute() {
        muted = false
        SceneMute.muted = false
        
        soundEffectsPlayer?.volume = 1
        backgroundMusicPlayer?.volume = 1
    }
}
