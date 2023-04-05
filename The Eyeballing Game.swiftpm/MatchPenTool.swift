import SwiftUI

struct MatchPenTool: View {
    @State private var targetControlPoint: CGPoint
    @State private var currentControlPoint: CGPoint = CGPoint(x: 150, y: 150)
    @State private var madeGuess = 0
    @Binding var score: Int
    @Binding var shouldSwitchView: Bool
    @State private var isActive = false
    @ObservedObject var player = AudioPlayer(name: "whistle", type: "mp3")

    private var PointWidth: CGFloat {
        isActive ? 30 : 20
    }
    
    init(score: Binding<Int>, shouldSwitchView: Binding<Bool>) {
        self._score = score
        self._shouldSwitchView = shouldSwitchView
        _targetControlPoint = State(initialValue: CGPoint(x: Int.random(in: 100...200), y: Int.random(in: 100...200)))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(madeGuess != 0 ? 
                 madeGuess == 1 ? "Not quite!" :
                    "Congratulations, you nailed it! 🎉" :
                    "Match the bezier-curve"
            )
            .font(.system(size: 24.0, weight: .bold, design: .rounded))
            .animation(.easeInOut, value: madeGuess)
            
            Text("Tip: Drag the gray circle to adjust the curve.")
                .font(.system(size: 14.0, weight: .regular, design: .rounded))
                .opacity(0.5)
        
            drawBezier(controlPoint: targetControlPoint)
                .stroke(Color.red, lineWidth: 2)
                .frame(height: 200)
                .padding()
            
            ZStack {
                drawBezier(controlPoint: currentControlPoint)
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(height: 200)
                    .padding()
                
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: PointWidth, height: PointWidth)
                    .animation(.easeInOut, value: PointWidth)
                    .position(currentControlPoint)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isActive = true
                                currentControlPoint = value.location
                            }
                            .onEnded { _ in
                                isActive = false
                            }
                    )
            }
            
            Button(action: {
                if comparePoints(point1: currentControlPoint, point2: targetControlPoint, threshold: 20) && madeGuess == 0 {
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
                    .font(.system(size: 24.0, weight: .bold, design: .rounded))
            }
            .padding()
        }
        .confettiCannon(counter: $score, num: 50)
    }
    
    func drawBezier(controlPoint: CGPoint) -> Path {
        Path { path in
            let startPoint = CGPoint(x: 50, y: 150)
            let endPoint = CGPoint(x: 250, y: 150)
            
            path.move(to: startPoint)
            path.addQuadCurve(to: endPoint, control: controlPoint)
        }
    }
}
