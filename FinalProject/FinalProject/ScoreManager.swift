import Foundation
import Firebase

struct Score : Codable, Identifiable {
    var id: String
    var date: String
    var name: String
    var score: Int
    
    var dict: NSDictionary {
        let d = NSDictionary(dictionary: [ "date": date, "name": name, "score": score ])
        return d
    }
    
    static func fromDict(_ d: NSDictionary, id: String) -> Score? {
        guard let date = d["date"] as? String else { return nil }
        guard let name = d["name"] as? String else { return nil }
        guard let score = d["score"] as? Int else { return nil }
                
        return Score(id: id, date: date, name: name, score: score)
    }
}

class ScoreManager : ObservableObject {
    @Published var scores = [String : Score]()
    @Published var sortedScoresArray = [Score]()
    
    init() {
        let rootRef = Database.database().reference()
        
        rootRef.child("scores").getData { err, snapshot in            
            DispatchQueue.main.async {
                for child in snapshot.children {
                    if let item = child as? DataSnapshot {
                        if let val = item.value as? NSDictionary {
                            let id = item.key
                                                                                    
                            if let score = Score.fromDict(val, id: id) {
                                self.scores[id] = score
                            }
                        }
                    }
                }
            }
        }
        
        rootRef.child("scores").observe(.childAdded) { snapshot in
            if let v = snapshot.value as? NSDictionary,
               let score = Score.fromDict(v, id: snapshot.key) {
                self.scores[snapshot.key] = score
                
                self.updateSortedVideos()
            }
        }
        
        rootRef.child("scores").observe(.childChanged) { snapshot in
            if let v = snapshot.value as? NSDictionary,
                let score = Score.fromDict(v, id: snapshot.key) {
                    self.scores[score.id] = score
                
                self.updateSortedVideos()
                }
        }
        
        rootRef.child("scores").observe(.childRemoved) { snapshot in
            self.scores.removeValue(forKey: snapshot.key)
            
            self.updateSortedVideos()
        }
    }
    
    func updateSortedVideos() {
        let scores = Array(scores.values)
        sortedScoresArray = scores.sorted(by: { ($1.score, $0.date) < ($0.score, $1.date) })
    }
    
    func addScore(score : inout Score) {
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("scores").childByAutoId()
        
        if let key = childRef.key {
            score.id = key
            childRef.setValue(score.dict)
        }
    }
}
