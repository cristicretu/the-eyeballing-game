import SwiftUI

struct MatchBlur: View {
    @State private var targetBlur: Int
    @State private var currentBlur: Int = 0
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")
    
    init (score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        self._targetBlur = State(initialValue: Int.random(in: 4...25))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Your guess was \(currentBlur)" :
                                  "Congratulations, you nailed it! 🎉" :
                "Blur the rectangle with \(targetBlur)px"
            )
                .font(.system(size: 24.0, weight: .bold, design: .rounded))
                .animation(.easeInOut, value: madeGuess)
            
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .frame(width: 300, height: 200)
                .background(RadialGradient(gradient: Gradient(colors: [Color.red, Color.blue]), center: .center, startRadius: 5, endRadius: 500))
                .blur(radius: CGFloat(currentBlur))
            
            IntSlider(
                value: $currentBlur,
                range: 4...25,
                step: 1,
                onSubmit: {
                    if compareValuesInt(value1: currentBlur, value2: targetBlur, threshold: 2) && madeGuess == 0 {
                        score += 1
                        madeGuess = 2
                        self.player.toggle()
                    } else {
                        madeGuess = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        shouldSwitchView = true
                    }
                }
            )
            .padding()
            
        }
        .confettiCannon(counter: $score, num: 50)
    }
}
