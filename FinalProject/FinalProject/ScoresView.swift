import SwiftUI
import Foundation

struct ScoresView: View {
    @EnvironmentObject var scoreManager : ScoreManager
    
    var body: some View {
        ZStack {
            BackgroundHome()
            
            let columnNames = ["Rank", "Name", "Score", "Date"]
                        
            VStack {
                NavigationBack()
                
                Text("Scores")
                    .font(Font.custom("Sharpshooter", size: 30))
                
                HStack(spacing: 45) {
                    ForEach(columnNames, id: \.self) { colName in
                        Text("\(colName)")
                            .frame(width: 50)
                    }
                }
                .font(Font.custom("Sharpshooter", size: 15))
                .padding()
                
                ScrollView {
                    VStack(spacing: 15) {
                        let scores = scoreManager.sortedScoresArray
                        let length = scores.count
                        
                        ForEach(0..<length, id: \.self) { index in
                            let score = scores[index]
                            
                            HStack(spacing: 45) {
                                Text("\(index + 1)")
                                    .frame(width: 50)
                                Text("\(score.name)")
                                    .frame(width: 50)
                                Text("\(score.score)")
                                    .frame(width: 50)
                                Text("\(getShortDate(date: score.date))")
                                    .frame(width: 50)
                            }
                        }
                    }
                }
                .frame(maxHeight: 460)
                .font(Font.custom("Sharpshooter", size: 15))
            }
            .offset(y: -70)
            
            HomeFooter()
                .offset(y: 365)
        }
    }
    
    func getShortDate(date: String) -> String {
        let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return formatter
        }()
        
        let shortDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            return formatter
        }()
        
        if let d = dateFormatter.date(from: date) {
            return shortDateFormatter.string(from: d)
        }
        
        return "???"
    }
}


struct ScoresView_Previews: PreviewProvider {
    static var previews: some View {
        ScoresView()
            .environmentObject(ScoreManager())
            .environmentObject(SoundManager())
    }
}
