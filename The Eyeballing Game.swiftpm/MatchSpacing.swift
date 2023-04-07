import SwiftUI


struct MatchSpacing: View {
    @State private var targetSpacing: Int
    @State private var currentSpacing: Int = 0
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @State private var isActive: Bool = false
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")
    
    init (score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        _targetSpacing = State(initialValue: Int.random(in: 0...32))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Your guess was \(currentSpacing)px" :
                    "Congratulations, you nailed it! 🎉" :
                    "Adjust the spacing to \(targetSpacing)px"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .animation(.easeInOut, value: madeGuess)
            
            Text("Tip: Drag the second rectangle.")
                .font(.system(size: 14.0, weight: .regular, design: .rounded))
                .opacity(0.5)
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 24.0, style: .continuous)
                    .fill(Color.purple)
                    .frame(width: 100.0, height: 100.0)
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isActive ? .green : .yellow)
                    .animation(.easeInOut, value: isActive)
                    .frame(width: 100.0, height: 100.0)
                    .offset(CGSize(width: 0.0, height: CGFloat(currentSpacing)))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                currentSpacing = max(0, min(Int(value.translation.height), 32))
                                if !isActive {
                                    isActive.toggle()
                                }
                            }
                            .onEnded { _ in 
                                if madeGuess == 0 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        shouldSwitchView = true
                                    }
                                }
                                
                                if compareValuesInt(value1: currentSpacing, value2: targetSpacing, threshold: 5) && madeGuess == 0 {
                                    score += 1
                                    madeGuess = 2
                                    self.player.toggle()
                                } else {
                                    madeGuess = 1
                                }
                            }
                    )
            }
        }
        .confettiCannon(counter: $score, num: 50)
    }
}
