import SwiftUI

struct MatchBrightness: View {
    @State private var targetBrightness: Double
    @State private var currentBrightness: Double = 0.5
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")
    
    init (score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        self._targetBrightness = State(initialValue: Double.random(in: 0.0...1.0))
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Your guess was \(currentBrightness * 100)%" :
                    "Congratulations, you nailed it! 🎉" :
                    "Tweak the brightness to \(Int(targetBrightness * 100))%"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .animation(.easeInOut, value: madeGuess)
            
            Text("Tip: Change your device brightness.")
                .font(.system(size: 14.0, weight: .regular, design: .rounded))
                .opacity(0.5)
            
            Image("ApplePark")
                .resizable()
                .scaledToFit()
                .brightness(currentBrightness)
            
            Button(action: {
                if compareValuesDouble(value1: currentBrightness, value2: targetBrightness, threshold: 0.05) && madeGuess == 0 {
                    score += 1
                    madeGuess = 2
                    self.player.toggle()
                } else {
                    madeGuess = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    shouldSwitchView = true
                }
            }) {
                Text("Submit")
            }
            .padding()
            
        }
        .confettiCannon(counter: $score, num: 50)
        .onAppear(perform: {
            currentBrightness = UIScreen.main.brightness
        })
        .onChange(of: UIScreen.main.brightness, perform: { value in
            currentBrightness = UIScreen.main.brightness
        })
    }    
}
