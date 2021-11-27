import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    init() {
        let difficulty = getCurrentDifficulty()
        
        if difficulty == nil {
            setDifficulty(newDifficulty: "Easy")
        }
        
        let playerColor = getCurrentPlayerColor()
        
        if playerColor == nil {
            setPlayerColor(newColor: Color.green)
        }
    }
    
    func setDifficulty(newDifficulty: String) {
        UserDefaults.standard.set(newDifficulty, forKey: "Difficulty")
    }
    
    func setPlayerColor(newColor: Color) {
        let encoding = getEncodingOfColor(color: newColor)
        UserDefaults.standard.set(encoding, forKey: "Color")
    }
    
    func getCurrentDifficulty() -> String? {
        return UserDefaults.standard.string(forKey: "Difficulty")
    }
    
    func getCurrentPlayerColor() -> Color? {
        let encoding = UserDefaults.standard.integer(forKey: "Color")
        let color = getColorFromEncoding(encoding: encoding)
        
        return color
    }
    
    func getEncodingOfColor(color: Color) -> Int {
        switch color {
        case Color.green:
            return 0
        case Color.blue:
            return 1
        case Color.red:
            return 2
        default:
            return 3
        }
    }
    
    func getColorFromEncoding(encoding: Int) -> Color? {
        switch encoding {
        case 0:
            return Color.green
        case 1:
            return Color.blue
        case 2:
            return Color.red
        default:
            return nil
        }
    }
}
