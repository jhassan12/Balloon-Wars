import SwiftUI

struct HomeView : View {
    @EnvironmentObject var soundManager: SoundManager
    @State var showMenu = false
    @Binding var isGameShowing: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundHome()
                                
                VStack(spacing: 120) {
                    Text("Balloon Wars")
                        .font(Font.custom("Sharpshooter", size: 45))
                        .foregroundColor(Color(red: 0/255, green: 0/255, blue: 100/255))
                    
                    VStack(spacing: 70) {
                        Button(action: {
                                isGameShowing = true
                        }) {
                            Text("Play")
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            Text("Settings")
                        }.simultaneousGesture(TapGesture().onEnded{
                            soundManager.playSoundEffect(sound: .selection)
                        })
                       
                        NavigationLink(destination: ScoresView()) {
                            Text("Scores")
                        }.simultaneousGesture(TapGesture().onEnded{
                            soundManager.playSoundEffect(sound: .selection)
                        })
                    }
                    .offset(y: !showMenu ? 500 : -50)
                    .foregroundColor(.black)
                    .font(Font.custom("Sharpshooter", size: 40))
                    .animation(.easeInOut(duration: 1.75), value: showMenu)
                    .onAppear {
                        showMenu = true
                    }
                }
                .offset(y: -50)
            
                HomeFooter()
                    .offset(y: 320)
                
            }
        }
    }
}

struct BackgroundHome: View {
    var body: some View {
        GeometryReader { geometry in
            Image("clouds_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: geometry.size.width,
                       maxHeight: geometry.size.height)
        }
    }
}

struct NavigationBack: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack {
            
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrowtriangle.left.circle")
                    .font(.system(size: 30))
                    .padding()
                    .navigationBarHidden(true)
            }
            .foregroundColor(.black)
            
            Spacer()
        }
        
    }
}

struct MuteButton: View {
    @EnvironmentObject var soundManager: SoundManager
    
    var body: some View {
        Image(systemName: !soundManager.muted ? "speaker" : "speaker.slash")
            .font(.system(size: 48))
            .padding()
            .onTapGesture {
                if soundManager.muted {
                    soundManager.unmute()
                } else {
                    soundManager.mute()
                }
            }
    }
}

struct HomeFooter: View {
    @EnvironmentObject var soundManager: SoundManager
    
    var body: some View {
        HStack {
            Spacer()
            MuteButton()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var isGameShowing = true
    
    static var previews: some View {
        HomeView(isGameShowing: $isGameShowing)
            .environmentObject(ScoreManager())
            .environmentObject(SoundManager())
    }
}
