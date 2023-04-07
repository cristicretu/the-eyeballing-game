import SwiftUI

struct WelcomeScreen: View {
    @Binding var highScore: Int
    @State var scale = 1.0

    var onStartGame: () -> Void
    
    let text = Text("The Eyeballing game").font(.system(size: 36.0, weight: .bold, design: .rounded))


    var body: some View {
        VStack {
            AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)
                .clipShape(Circle())
                .frame(width: 100.0, height: 100.0)
                .padding()
                .shadow(color: scale < 1.25 ? .orange : .blue, radius: 16)
                .rotationEffect(scale < 1.25 ? .degrees(0) : .degrees(512))
                .blur(radius: scale < 1.25 ? 0.0 : 3.0)
                .scaleEffect(scale)
                .onAppear {
                    let baseAnimation = Animation.easeInOut(duration: 1)
                    let repeated = baseAnimation.repeatForever(autoreverses: true)
                    
                    withAnimation(repeated) {
                        scale = 1.4
                    }
                }

            text
                .foregroundColor(.clear)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .red, .purple, .blue]),
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                    .mask(text))
            
            Text("Are you a real designer?")
                .font(.system(size: 24.0, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button() {
                onStartGame()
            }
            label: {
              HStack {
                  Image(systemName: "star.fill")
                  Text("New Game") 
                  Divider()
                  Text("\(highScore)")
              }
              .fixedSize()
            }
            .padding(.all)
            .buttonStyle(.borderedProminent)
        }.padding(.all)
    }
}
