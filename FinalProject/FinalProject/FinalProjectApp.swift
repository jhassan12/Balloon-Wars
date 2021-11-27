import SwiftUI
import Firebase

@main
struct FinalProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var scoreManager = ScoreManager()
    @StateObject var soundManager = SoundManager()
    @StateObject var settingsManager = SettingsManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scoreManager)
                .environmentObject(soundManager)
                .environmentObject(settingsManager)
        }
    }
}
