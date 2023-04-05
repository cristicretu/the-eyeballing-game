import SwiftUI
import CoreMotion

struct MatchRotation: View {
    let motionManager = CMMotionManager()
    
    @State private var targetRotation: Int
    @State private var currentRotation: Int = 0
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")

    init (score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        _targetRotation = State(initialValue: Int.random(in: 25...345))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Your guess was \(Int(currentRotation))" :
                    "Congratulations, you nailed it! 🎉" :
                    "Rotate the rectangle to \(Int(targetRotation)) degrees"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .animation(.easeInOut, value: madeGuess)
            
            Text("Tip: Rotate your device.")
                .font(.system(size: 14.0, weight: .regular, design: .rounded))
                .opacity(0.5)
            
            Rectangle()
                .frame(width: 200, height: 100)
                .foregroundColor(.blue)
                .rotationEffect(.degrees(CGFloat(currentRotation)))
                .padding(24)
            
            Button(action: {
                if compareValuesInt(value1: currentRotation, value2: targetRotation, threshold: 20) && madeGuess == 0 {
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
        .onAppear {
            if motionManager.isGyroAvailable {
                motionManager.gyroUpdateInterval = 0.1
                motionManager.startGyroUpdates(to: .main) { (data, error) in
                    if let rotation = data?.rotationRate {
                        let deltaRotation = rotation.z * motionManager.gyroUpdateInterval
                        currentRotation += abs(Int(radiansToDegrees(deltaRotation)))
                    }
                }
            }
        }
        .onDisappear {
            motionManager.stopGyroUpdates()
        }
        
    }
}
