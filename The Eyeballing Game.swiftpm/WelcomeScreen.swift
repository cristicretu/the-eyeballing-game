import SwiftUI

struct WelcomeScreen: View {
    @Binding var highScore: Int
    @State private var isActive: Bool = false  

    var onStartGame: () -> Void

    var body: some View {
        VStack {
            AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .frame(width: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/)
                .scaleEffect(isActive ? 1.4 : 1)
                .shadow(color: isActive ? .red : .blue, radius: 16)
                .rotationEffect(isActive ? .degrees(0) : .degrees(360))
                .animation(.spring(), value: isActive)
                .onTapGesture {
                    isActive.toggle()
                }

            Text("The Eyeballing Game")
                .font(.system(size: 36.0, weight: .bold, design: .rounded))
            
            Text("Are you a real designer?")
                .font(.system(size: 24.0, weight: .medium, design: .rounded))
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
            .buttonStyle(.borderedProminent)
            .padding(.all)
        }.padding(.all)
    }
}
