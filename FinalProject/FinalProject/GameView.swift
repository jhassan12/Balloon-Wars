import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var soundManager: SoundManager
    
    static func getScene() -> GameScene {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 400)
        scene.scaleMode = .fill
        return scene
    }
    
    @StateObject var game = GameView.getScene()
    @State var isPaused = false
    @Binding var isGameShowing: Bool
    
    var body: some View {
        ZStack {                
            SpriteView(scene: game, isPaused: isPaused)
                .ignoresSafeArea()
                        
            GameHeader(pauseMenuShowing: $isPaused, game: game)
                .offset(y: -150)
            
            if isPaused {
                PauseMenu(showing: $isPaused, isGameShowing: $isGameShowing, game: game)
            }
            
            if game.isGameOver {
                GameOverMenu(game: game, isGameShowing: $isGameShowing)
            }
            
            Lives(game: game)
                .offset(x: 250, y: 160)
        }
    }
}

struct GameHeader: View {
    @EnvironmentObject var soundManager: SoundManager
    @Binding var pauseMenuShowing: Bool 
    @ObservedObject var game: GameScene
    
    var body: some View {
        HStack {
            MuteButton()
            
            Spacer()
            
            Text("Score: \(game.score)")
                .font(Font.custom("Sharpshooter", size: 25))
                .frame(maxWidth: 200)
            
            Spacer()
            
            PauseButton(pauseMenuShowing: $pauseMenuShowing)
        }
        .foregroundColor(Color.white)
    }
}

struct PauseButton: View {
    @Binding var pauseMenuShowing: Bool
    
    var body: some View {
        Image(systemName: "pause.circle")
            .font(.system(size: 48))
            .padding()
            .onTapGesture {
                pauseMenuShowing = true
            }
    }
}

struct GameOverMenu: View {
    @EnvironmentObject var scoreManager: ScoreManager
    @ObservedObject var game: GameScene
    @Binding var isGameShowing: Bool
    @State var name: String = ""
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white, lineWidth: 3)
            )
            .overlay(
                VStack {
                    Text("Game Over")
                        .font(Font.custom("Sharpshooter", size: 45))
                        .padding()
                    
                    Text("Your score: \(game.score)")
                        .font(Font.custom("Sharpshooter", size: 30))
                        .padding()
                    
                    ZStack {
                        if name.isEmpty {
                            Text("Enter name...")
                                .foregroundColor(.white)
                                .offset(x: -60)
                        }
                    
                        TextField("Enter name", text: $name)
                            .frame(width: 225, height: 25)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white, lineWidth: 3)
                            )
                    }
                
                    Button(action: {
                        let dateFormatter: DateFormatter = {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                return formatter
                        }()
                        
                        let date = dateFormatter.string(from: Date())
                        
                        var score = Score(id: "blah", date: date, name: name, score: game.score)
                        scoreManager.addScore(score: &score)
                        
                        game.isGameOver = false
                        isGameShowing = false
                    }) {
                        Text("Save")
                            .font(Font.custom("Sharpshooter", size: 28))
                            .padding()
                    }
                }
                .foregroundColor(.white)
            )
            .frame(width: 400, height: 300)
            .transition(AnyTransition.opacity.animation(.linear(duration: 0.5)))
    }
}


struct Lives: View {
    @ObservedObject var game: GameScene
    
    var body: some View {
        ZStack {
            Text("Lives: ")
                .font(Font.custom("Sharpshooter", size: 25))
                .foregroundColor(.white)
                .padding()
                .offset(x: -20)
            
            ForEach((0..<game.numberOfLives), id: \.self) { index in
                Image("heart")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .offset(x: CGFloat(index*25 + index*5))
                    .padding(50)
                    .transition(AnyTransition.opacity.animation(.linear(duration: 0.5)))
            }
            .offset(x: 40)
        }
        .frame(width:300, height: 25)
        .offset(x: -50)
       
    }
}

struct PauseMenu: View {
    @Binding var showing: Bool
    @Binding var isGameShowing: Bool
    @ObservedObject var game: GameScene
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white, lineWidth: 3)
            )
            .overlay(
                VStack {
                    ZStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .offset(x: 135, y: -60)
                            .overlay(
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 45))
                                    .offset(x: 135, y: -60)
                                    .foregroundColor(.black)
                                
                            )
                            .onTapGesture {
                                showing = false
                            }
                            
                            
                        Text("Paused")
                            .font(Font.custom("Sharpshooter", size: 45))
                            .padding()
                    }
                    
                    
                    HStack {
                        Button(action: {
                            showing = false
                            isGameShowing = false
                        }) {
                            Text("Exit")
                                .font(Font.custom("Sharpshooter", size: 28))
                                .padding()
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            game.newGame()
                            showing = false
                        }) {
                            Text("New Game")
                                .font(Font.custom("Sharpshooter", size: 28))
                                .padding()
                                .foregroundColor(.red)
                        }
                    }
                    
                
                }
                .foregroundColor(.white)
            )
            .frame(width: 300, height: 200)
            .transition(AnyTransition.opacity.animation(.linear(duration: 0.5)))

    }
}

struct GameView_Previews: PreviewProvider {
    @State static var isGameShowing = true
    
    static var previews: some View {
        GameView(isGameShowing: $isGameShowing)
            .environmentObject(ScoreManager())
            .environmentObject(SoundManager())
            .environmentObject(SettingsManager())
            .previewLayout(.fixed(width: 812, height: 375))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
    }
}
