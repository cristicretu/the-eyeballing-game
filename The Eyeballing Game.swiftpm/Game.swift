import SwiftUI
import ConfettiSwiftUI

let timeLimit = 75
let games = 9

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
        remainingTime = timeLimit
        isPlaying = false
    }
    
    var body: some View {
        VStack {
            ForEach(0..<games, id: \.self) { index in
                if index == currentViewIndex {
                    switch gameOrder[index] {
                    case 0: MatchPenTool(score: $score, shouldSwitchView: $shouldSwitchView)
                    case 8: MatchSize(score: $score, shouldSwitchView: $shouldSwitchView)
                    case 7: MatchColor(score: $score, shouldSwitchView: $shouldSwitchView)
                    case 6: MatchType(score: $score, shouldSwitchView: $shouldSwitchView)
                    case 5: MatchBrightness(score: $score, shouldSwitchView: $shouldSwitchView)
                    case 4: MatchRotation(score: $score, shouldSwitchView: $shouldSwitchView)
                    case 2: MatchBlur(score: $score, shouldSwitchView: $shouldSwitchView) 
                    case 1: MatchCornerRadius(score: $score, shouldSwitchView: $shouldSwitchView)
                    case 3: MatchSpacing(score: $score, shouldSwitchView: $shouldSwitchView)
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
