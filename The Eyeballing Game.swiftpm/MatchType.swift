import SwiftUI

extension UIFont {
    func withOptions(weight: Double, width: Double) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: weight,
            UIFontDescriptor.TraitKey.width: width,
        ]
        ])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}

struct MatchType: View {
    @State private var targetWeight: Double
    @State private var targetWidth: Double
    @State private var currentWidth: Double = 0.0
    @State private var currentWeight: Double = 0.0
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")

    init (score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        self._targetWeight = State(initialValue: Double.random(in: -0.8...0.8))
        self._targetWidth = State(initialValue: Double.random(in: -0.8...0.8))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Not quite!" :
                    "Congratulations, you nailed it! 🎉" :
                    "Nudge the font width and weight"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .animation(.easeInOut, value: madeGuess)
            
            Text("“Stay foolish.”")
                .font(Font(UIFont.systemFont(ofSize: 24.0).withOptions(weight: targetWeight, width: targetWidth)))  
                
            Text("”Stay foolish.”")
                .font(Font(UIFont.systemFont(ofSize: 24.0).withOptions(weight: currentWeight, width: currentWidth)))                
                .animation(.linear(duration: 0.07), value: [currentWeight])
            
            RadialPad(x: $currentWidth, y: $currentWeight)
            
            Button(action: {
                if compareValuesDouble(value1: currentWeight, value2: targetWeight, threshold: 0.1)
                    && compareValuesDouble(value1: currentWidth, value2: targetWidth, threshold: 0.1)
                    && madeGuess == 0 {
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
    }   
   }


struct RadialPad: View {
    @Binding var x: Double
    @Binding var y: Double
    
    let outerCircleRadius: CGFloat = 100
    let innerCircleRadius: CGFloat = 50
    
    @State private var location: CGPoint = CGPoint(x: 100, y: 100)
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1

    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = constrainPointToCircle(center: CGPoint(x: outerCircleRadius, y: outerCircleRadius), radius: outerCircleRadius, point: newLocation)
                x = (Double(self.location.x) / 100) - 1.0
                y = (Double(self.location.y) / 100) - 1.0
                
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location // 2
            }
    }
    
    var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerLocation) { (value, fingerLocation, transaction) in
                fingerLocation = value.location
            }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.black)
                .opacity(0.5)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .opacity(0.2)
                )
            Circle()
                .fill(.black)
                .opacity(0.5)
                .frame(width: 100, height: 100)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .opacity(0.2)
                )
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .position(location)
                .gesture(
                    simpleDrag.simultaneously(with: fingerDrag)
                )
        }
        .frame(width: 200, height: 200)
        
    }
}
