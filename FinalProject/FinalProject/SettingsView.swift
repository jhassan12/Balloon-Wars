import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State var chosenDifficulty = "Hard"
    @State var colorsState = [Color.green: false, Color.blue: false, Color.red: false]
    
    let difficulties = ["Easy", "Medium", "Hard"]
    let colors = [Color.green, Color.blue, Color.red]
    
    var pickerColor: Color {
        switch chosenDifficulty {
        case "Easy":
            return Color.green
        case "Medium":
            return Color.yellow
        case "Hard":
            return Color.red
        default:
            return Color.white
        }
    }
    
    var playerColor: Color {
        return settingsManager.getCurrentPlayerColor()!
    }
    
    var body: some View {
        ZStack {
            BackgroundHome()
            
            VStack(spacing: 40) {
                NavigationBack()
                    .offset(y: 30)
                
                Text("Settings")
                    .font(Font.custom("Sharpshooter", size: 30))
                
                HStack {
                    Text("Difficulty:")
                        .font(Font.custom("Sharpshooter", size: 20))
                        .padding()
                    
                    Spacer()
                    
                    Picker("Difficulty", selection: $chosenDifficulty) {
                        ForEach(difficulties, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .colorMultiply(pickerColor)
                    .padding()
                    .onChange(of: chosenDifficulty, perform: { value in
                        settingsManager.setDifficulty(newDifficulty: value)
                    })
                }
                
                HStack {
                    Text("Player Color:")
                        .font(Font.custom("Sharpshooter", size: 20))
                        .padding()
                                
                    ForEach(colors, id: \.self) { color in
                        
                        let borderColor = colorsState[color]! ? Color.yellow : Color.black
                        
                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                            .frame(width: 40, height: 40)
                            .foregroundColor(color)
                            .overlay(
                            
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(borderColor, lineWidth: 2)
                            )
                            .onTapGesture {
                                for c in colors {
                                    colorsState[c] = false
                                }
                                
                                colorsState[color] = true
                                
                                settingsManager.setPlayerColor(newColor: color)
                            }
                    }
                    
                    Spacer()
                }
            }
            .offset(y: -245)
            
            HomeFooter()
                .offset(y: 370)
        }
        .onAppear {
            colorsState[playerColor] = true
            chosenDifficulty = settingsManager.getCurrentDifficulty()!
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ScoreManager())
            .environmentObject(SoundManager())
            .environmentObject(SettingsManager())
    }
}
