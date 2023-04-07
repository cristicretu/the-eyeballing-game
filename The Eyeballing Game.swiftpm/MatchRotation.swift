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
                 madeGuess == 1 ? "Your guess was \(Int(currentRotation)) degrees" :
                    "Congratulations, you nailed it! 🎉" :
                    "Rotate the rectangle to \(Int(targetRotation)) degrees"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .animation(.easeInOut, value: madeGuess)
            
            Text("Tip: Rotate your device.")
                .font(.system(size: 14.0, weight: .regular, design: .rounded))
                .opacity(0.5)
            
            RoundedRectangle(cornerRadius: 24.0, style: .continuous)
                .frame(width: 200, height: 100)
                .foregroundColor(.blue)
                .animation(.easeInOut, value: currentRotation)
                .rotationEffect(.degrees(CGFloat(currentRotation)))
                .padding(24)
            
            Button(action: {
                motionManager.stopGyroUpdates()
                
                if madeGuess == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        shouldSwitchView = true
                    }
                }
                
                if compareValuesInt(value1: abs(currentRotation), value2: targetRotation, threshold: 35) && madeGuess == 0 {
                    // Use a higher threshold as this is a harder challenge
                    score += 1
                    madeGuess = 2
                    self.player.toggle()
                } else {
                    madeGuess = 1
                }
            }) {
                Text("Submit")
                    .font(.system(size: 24.0, weight: .bold, design: .rounded))
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
                        currentRotation = (currentRotation + Int(radiansToDegrees(deltaRotation))) % 360
                    }
                }
            }
        }
        .onDisappear {
            motionManager.stopGyroUpdates()
        }
        
    }
}
