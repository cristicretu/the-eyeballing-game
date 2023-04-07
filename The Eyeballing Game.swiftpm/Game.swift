import SwiftUI
//import ConfettiSwiftUI

let timeLimit = 75
let games = 10

struct Game: View {
    @State private var score = 0
    @Binding var highScore: Int
    @Binding var isPlaying: Bool
    @State private var remainingTime = timeLimit
    @State private var currentViewIndex = 0
    @State private var shouldSwitchView = false
    @State private var gameOrder: [Int] = Array(0..<games)
    
    func startGame() {
        score = 0
        remainingTime = timeLimit
        // Change the order of the games each time
        gameOrder.shuffle()

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            remainingTime -= 1
            if remainingTime <= 0 {
                timer.invalidate()
                endGame()
            }
        }
    }
    
    func endGame() {
        if score > highScore {
            highScore = score
        }
        // Reset the remainingTime for the next session
        remainingTime = timeLimit
        isPlaying = false
    }
    
    var body: some View {
        VStack {
            ForEach(0..<games, id: \.self) { index in
                if index == currentViewIndex {
                    switch gameOrder[index] {
                        case 0: MatchPenTool(score: $score, shouldSwitchView: $shouldSwitchView)
                        case 1: MatchSize(score: $score, shouldSwitchView: $shouldSwitchView)
                        case 2: MatchColor(score: $score, shouldSwitchView: $shouldSwitchView)
                        case 3: MatchType(score: $score, shouldSwitchView: $shouldSwitchView)
                        case 4: MatchBrightness(score: $score, shouldSwitchView: $shouldSwitchView)
                        case 5: MatchRotation(score: $score, shouldSwitchView: $shouldSwitchView)
                        case 6: MatchBlur(score: $score, shouldSwitchView: $shouldSwitchView) 
                        case 7: MatchCornerRadius(score: $score, shouldSwitchView: $shouldSwitchView)
                        case 8: MatchOpacity(score: $score, shouldSwitchView: $shouldSwitchView)
                        case 9: MatchSpacing(score: $score, shouldSwitchView: $shouldSwitchView)
                        default: Text("Finished!")
                    }
                }
            }
            
            Text("Score: \(score)")
                .font(.system(size: 28.0, weight: .bold, design: .rounded))
                .padding()
            
            Text("Time remaining: \(remainingTime)")
                .foregroundColor(remainingTime > 15 ? Color.primary : Color.red)
                .font(.system(size: 24.0, weight: .medium, design: .rounded))
        }
        .padding()
        .onChange(of: shouldSwitchView, perform: { value in
            if shouldSwitchView {
                shouldSwitchView = false
                currentViewIndex += 1
                
                if (currentViewIndex >= games) {
                    endGame()
                }
            }
        })
        .onAppear(perform: startGame)
    }
}
