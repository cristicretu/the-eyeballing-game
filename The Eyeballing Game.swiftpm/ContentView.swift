import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false
    @State private var highScore = 0
    @ObservedObject var menuPlayer = AudioPlayer(name: "Menu", type: "mp3", volume: 0.10)
    @ObservedObject var gamePlayer = AudioPlayer(name: "Game", type: "mp3", volume: 0.03)

    
    var body: some View {
        ZStack {
            if isPlaying {
                Game(highScore: $highScore, isPlaying: $isPlaying)
                    .onAppear(perform: {
                        gamePlayer.start()
                        menuPlayer.pause()
                    })
                    .onDisappear(perform: {
                        gamePlayer.pause()
                    })
            } else {
                WelcomeScreen(highScore: $highScore) {
                    isPlaying = true
                }
                .onAppear(perform: {
//                    menuPlayer.start()
                    gamePlayer.pause()
                })
                .onDisappear(perform: {
                    menuPlayer.pause()
                })
            }
        }
        .frame(width: 400, height: 600)
//        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    }
}
