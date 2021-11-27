import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject var soundManager: SoundManager
    @State var isGameShowing = false
    
    var body: some View {
        if isGameShowing {
            GameView(isGameShowing: $isGameShowing)
                .onAppear {
                    soundManager.playBackgroundMusic(sound: .game)
                    
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                    AppDelegate.orientationLock = .landscapeLeft
                    UINavigationController.attemptRotationToDeviceOrientation()
                }.onDisappear {
                    AppDelegate.orientationLock = .portrait
                }
        } else {
            HomeView(isGameShowing: $isGameShowing)
                .onAppear {
                    preloadSounds()
                    
                    soundManager.playBackgroundMusic(sound: .home)
                    
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    AppDelegate.orientationLock = .portrait
                    UINavigationController.attemptRotationToDeviceOrientation()
                }
                .onDisappear {
                    AppDelegate.orientationLock = .landscapeLeft
                }
        }
    }
    
    func preloadSounds() {
        for sound in Sound.allCases {
            soundManager.preload(sound: sound)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ScoreManager())
            .environmentObject(SoundManager())
            .environmentObject(SettingsManager())
    }
}
