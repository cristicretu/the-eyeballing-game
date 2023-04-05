import SwiftUI
import CoreMotion

struct MatchSize: View {
    let motionManager = CMMotionManager()

    @State private var targetSize: CGSize
    @State private var currentSize: CGSize = CGSize(width: 100, height: 100)
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")

    init(score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        _targetSize = State(initialValue: CGSize(width: Int.random(in: 30...200), height: Int.random(in: 30...200)))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Not quite!" :
                    "Congratulations, you nailed it! 🎉" :
                    "Match the size of the red rectangle"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .animation(.easeInOut, value: madeGuess)
            
            Text("Tip: Tilt your device.")
                .font(.system(size: 14.0, weight: .regular, design: .rounded))
                .opacity(0.5)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: targetSize.width, height: targetSize.height)
                .foregroundColor(.red)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: currentSize.width, height: currentSize.height)
                .foregroundColor(.blue)   
            
            Button(action: {
                if compareSizes(size1: currentSize, size2: targetSize, threshold: 15) && madeGuess == 0 {
                    score += 1
                    madeGuess = 2
                    self.player.toggle()
                } else {
                    madeGuess = 1
                }
                
                motionManager.stopAccelerometerUpdates()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    shouldSwitchView = true
                }
            }) {
                Text("Submit")
                    .font(.system(size: 24.0, weight: .bold, design: .rounded))
            }
            .padding()
        }
        .confettiCannon(counter: $score, num: 50)
        .onAppear {
            startAccelerometerUpdates()
        }
        .onDisappear {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { data, error in
            guard let data = data, error == nil else {
                return
            }
            
            let widthChange = CGFloat(data.acceleration.y * 10)
            let heightChange = CGFloat(data.acceleration.x * 10)
            let newWidth = currentSize.width + widthChange
            let newHeight = currentSize.height - heightChange
            
            currentSize.width = clamp(value: newWidth, lower: 40, upper: 200)
            currentSize.height = clamp(value: newHeight, lower: 40, upper: 200)
        }
    }
}
