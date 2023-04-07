import SwiftUI
import AVFoundation

struct MatchOpacity: View {
    @State private var targetOpacity: Double
    @State private var currentOpacity: Double = 0.5
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")
    @ObservedObject private var volObserver = VolumeObserver()
        
    init (score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        // Multiply by 0.5 so that we end up with
        // values that end with 0 or 5
        _targetOpacity = State(initialValue: Double(Int.random(in: 0...10)) / 10.0 * 0.5)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Your guess was \(Int(currentOpacity * 100))%" :
                    "Congratulations, you nailed it! 🎉" :
                    "Tweak the opacity to \(Int(targetOpacity * 100))%"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .animation(.easeInOut, value: madeGuess)
            
            Text("Tip: Adjust your volume.")
                .font(.system(size: 14.0, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .opacity(0.5)
                        
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .frame(width: 200, height: 100)
                .foregroundColor(.blue.opacity(currentOpacity))
            
            Button(action: {
                if madeGuess == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        shouldSwitchView = true
                    }
                }
                
                if compareValuesDouble(value1: currentOpacity, value2: targetOpacity, threshold: 0.05) && madeGuess == 0 {
                    // Use a threshold of 0.05
                    // ex: 0.80 ~= 0.85
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
            self.volObserver.subscribe()
            currentOpacity = self.volObserver.volume
        }
        .onDisappear {
            self.volObserver.unsubscribe()
        }
        .onChange(of: self.volObserver.volume, perform: { value in
            currentOpacity = value
        })
    }
}

final class VolumeObserver: ObservableObject {
    @Published var volume: Double = Double(AVAudioSession.sharedInstance().outputVolume)
    private let session = AVAudioSession.sharedInstance()
    private var progressObserver: NSKeyValueObservation!
    
    func subscribe() {
        do {
            try session.setCategory(.ambient, mode: .default, options: [])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Cannot activate session")
        }
        
        progressObserver = session.observe(\.outputVolume) { [self] (session, value) in
            DispatchQueue.main.async {
                self.volume = Double(session.outputVolume)
            }
        }
    }
    
    func unsubscribe() {
        self.progressObserver.invalidate()
    }
    
    init() {
        subscribe()
    }
}
