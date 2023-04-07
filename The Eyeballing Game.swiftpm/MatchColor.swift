import SwiftUI

let gradient: Gradient = {
    Gradient(colors: Array(0...255).map {
        Color(hue: Double($0)/255, saturation: 1, brightness: 1)
    })
}()


struct MatchColor: View {
    @State private var targetColor: Color
    @State private var currentColor = Color.white
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")
    
    init(score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        let randomHue = Double.random(in: 0...1)
        _targetColor = State(initialValue: Color(hue: randomHue, saturation: 1, brightness: 1))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Your guess was \(currentColor.description)" :
                    "Congratulations, you nailed it! 🎉" :
                    "Match the color"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .animation(.easeInOut, value: madeGuess)
            
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .frame(width: 200, height: 100)
                .foregroundColor(targetColor)
            
            ColorWheel(selection: $currentColor)
            
            Button(action: {
                if madeGuess == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        shouldSwitchView = true
                    }
                }
                
                if compareColors(color1: currentColor, color2: targetColor, threshold: 0.2) && madeGuess == 0 {
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
    }
    
    func compareColors(color1: Color, color2: Color, threshold: Double) -> Bool {
        let color1Components = color1.cgColor!.components!.map { Double($0) }
        let color2Components = color2.cgColor!.components!.map { Double($0) }
        
        let delta = zip(color1Components, color2Components).map { abs($0 - $1) }.reduce(0, +)
        
        return delta <= threshold
    }
}

struct Wheel: View {
    @Binding var selection: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(AngularGradient(gradient: gradient, center: .center))
                .blur(radius: 5.0)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.3),lineWidth: 5.0)
                )
                .clipShape(Circle())
        }
        .frame(width: 200, height: 200)
    }
}

struct Knob: View {
    @Binding var selection:Color
    @State private var isDragging: Bool = false
    
    private var KnobWidth: CGFloat {
        isDragging ? 30 : 20
    }
    
    let outerCircleRadius: CGFloat = 100
    let innerCircleRadius: CGFloat = 50
    
    @State private var location: CGPoint = CGPoint(x: 100, y: 100)
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil
    
    /*
     * Seamless drag gesture adapted from here:
     * https://sarunw.com/posts/move-view-around-with-drag-gesture-in-swiftui/
    */
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                var newLocation = startLocation ?? location
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = constrainPointToCircle(center: CGPoint(x: outerCircleRadius, y: outerCircleRadius), radius: outerCircleRadius, point: newLocation)
                
                let angle = angleBetweenPoints(center: CGPoint(x: outerCircleRadius, y: outerCircleRadius), point: location)
                self.selection = Color(hue: angle / (2 * Double.pi), saturation: 1, brightness: 1)
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
            }.onEnded { _ in
                isDragging = false
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
                .fill(selection)
            Circle()
                .strokeBorder(
                    Color.white,
                    lineWidth: 3
                )
        }
        .frame(width: KnobWidth, height: KnobWidth)
        .position(location)
        .gesture(
            simpleDrag.simultaneously(with: fingerDrag)
        )
        .shadow(color: Color.gray.opacity(0.2), radius: 2)
        .animation(.easeInOut, value: KnobWidth)
    }
    
}

struct ColorWheel: View {
    @Binding var selection: Color
    
    var body: some View {
        ZStack{
            Wheel(selection: $selection)
                .overlay(
                    Knob(selection: $selection)
                )
        }.edgesIgnoringSafeArea(.all)
    }
}
