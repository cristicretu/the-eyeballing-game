import SwiftUI

struct ConfettiCannonModifier: ViewModifier {
    @Binding var counter: Int
    let num: Int
    
    @State private var animate: [Bool] = []
    @State private var finishedAnimationCounter = 0
    @State private var firstAppear = false
    @State private var animationKey: UUID = UUID()
    
    func body(content: Content) -> some View {
        ZStack {
            content
            ForEach(finishedAnimationCounter..<animate.count, id: \.self) { i in
                ConfettiView(num: num)
                    .id(animationKey)
            }
        }
        .onAppear {
            firstAppear = true
        }
        .onChange(of: counter) { value in
            if firstAppear {
                animate.append(false)
                if value > 0 && value < animate.count {
                    animate[value - 1].toggle()
                    animationKey = UUID()
                }
            }
        }
    }
}

extension View {
    func confettiCannon(counter: Binding<Int>, num: Int = 50) -> some View {
        self.modifier(ConfettiCannonModifier(counter: counter, num: num))
    }
}

/*
 * Adapted from here
 * https://stackoverflow.com/questions/64956392/swiftui-confetti-animation
*/

struct ConfettiPiece3D: View {
    @State var shape: AnyView
    @State var color: Color
    @State var spinDirX: CGFloat
    @State var spinDirZ: CGFloat
    @State var firstAppear = true
    
    @State var move = false
    @State var xSpeed:Double = Double.random(in: 0.501...2.201)
    @State var zSpeed = Double.random(in: 0.501...2.201)
    
    var body: some View {
        shape
            .frame(width: 10, height: 10)
            .foregroundColor(color)
            .animation(Animation.linear(duration: xSpeed).repeatCount(10, autoreverses: false), value: move)
            .rotation3DEffect(.degrees(move ? 360: 0), axis: (x: 0, y: 0, z: spinDirZ))
            .animation(Animation.linear(duration: zSpeed).repeatCount(10, autoreverses: false), value: move)
            .onAppear() {
                if firstAppear {
                    move = true
                    firstAppear = true
                }
            }
    }
}

struct ConfettiPiece: View {
    let shapes: [AnyView]
    let colors: [Color]
    
    @State private var location: CGPoint = .zero
    @State private var opacity: Double = 0.0
    @State private var angle: Double = .random(in: 0...360)
    @State private var spinDirectionX: CGFloat = CGFloat.random(in: -1.0...1.0)
    @State private var spinDirectionZ: CGFloat = CGFloat.random(in: -1.0...1.0)
    
    private var piece: some View {
        Group {
            if let shape = shapes.randomElement(), let color = colors.randomElement() {
                ConfettiPiece3D(shape: shape, color: color, spinDirX: spinDirectionX, spinDirZ: spinDirectionZ)
            } else {
                EmptyView()
            }
        }
    }
    
    private func getRandomAnimation() -> Animation {
        Animation.timingCurve(0.1, 0.8, 0, 1, duration: Double.random(in: 0.5...1.0))
    }

    
    private func getDistance() -> CGFloat {
        let radius: CGFloat = 300
        return pow(CGFloat.random(in: 0.01...1), 2.0 / 7.0) * radius
    }
    
    var body: some View {
        piece
            .rotation3DEffect(.degrees(angle), axis: (x: spinDirectionX, y: 0, z: spinDirectionZ))
            .offset(x: location.x, y: location.y)
            .opacity(opacity)
            .onAppear {
                withAnimation(getRandomAnimation()) {
                    opacity = 1
                    
                    let randomAngle: CGFloat = CGFloat.random(in: 60...120)
                    let distance = getDistance()
                    
                    location.x = distance * cos(degreesToraddians(randomAngle))
                    location.y = -distance * sin(degreesToraddians(randomAngle))
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(Animation.timingCurve(0.12, 0, 0.39, 0, duration: 1)) {
                        location.y += 300
                        opacity = 0
                    }
                }
            }
    }
}

struct ConfettiView: View {
    let num: Int
    let colors: [Color] = [.blue, .red, .green, .yellow, .pink, .purple, .orange]
    let shapes: [AnyView] = [
        AnyView(Circle()),
        AnyView(Rectangle()),
        AnyView(Triangle())
    ]
    
    var body: some View {
        ZStack {
            ForEach(0..<num, id: \.self) { _ in
                ConfettiPiece(shapes: shapes, colors: colors)
            }
        }
    }
}

enum ConfettiShape {
    case circle, square, triangle, zigzag
    
    func path(in rect: CGRect) -> Path {
        switch self {
        case .circle:
            return Circle().path(in: rect)    
        case .square:
            return Rectangle().path(in: rect)
        case .triangle:
            return Triangle().path(in: rect)
        case .zigzag:
            return ZigZag().path(in: rect)
        }
    }
    
}


/* 
 * Triangle from here:
 * https://www.hackingwithswift.com/books/ios-swiftui/paths-vs-shapes-in-swiftui
 */
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

public struct ZigZag: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let height = rect.height / 3
        let width = rect.width
        
        path.move(to: CGPoint(x: 0, y: height))
        
        for i in 0..<6 {
            let x = width / 5 * CGFloat(i)
            let y = height * (i % 2 == 0 ? 2 : 1)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        
        return path
    }
}
