import SwiftUI

struct MatchCornerRadius: View {
    @State private var targetCornerRadius: Int
    @State private var currentCornerRadius: Int = 0
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")

    init (score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        _targetCornerRadius = State(initialValue: Int.random(in: 8...48))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Your guess was \(currentCornerRadius)px" :
                    "Congratulations, you nailed it! 🎉" :
                    "Tweak the corner radius to \(targetCornerRadius)px"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .animation(.easeInOut, value: madeGuess)
            
            RoundedRectangle(cornerRadius: CGFloat(currentCornerRadius), style: .continuous)
                .frame(width: 200, height: 100)
                .foregroundColor(.blue)
            
            IntSlider(
                value: $currentCornerRadius,
                range: 8...48,
                step: 1,
                onSubmit: {
                    if madeGuess == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            shouldSwitchView = true
                        }
                    }
                    
                    if compareValuesInt(value1: currentCornerRadius, value2: targetCornerRadius, threshold: 2) && madeGuess == 0 {
                        score += 1
                        madeGuess = 2
                        self.player.toggle()
                    } else {
                        madeGuess = 1
                    }
                }
            )
            .padding()
        }
        .confettiCannon(counter: $score, num: 50)
    }
}
