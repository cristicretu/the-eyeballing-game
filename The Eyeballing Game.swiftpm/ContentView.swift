import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false
    @State private var highScore = 0
    @ObservedObject var menuPlayer = AudioPlayer(name: "Menu", type: "mp3", volume: 0.10, repeatSound: true)
    @ObservedObject var gamePlayer = AudioPlayer(name: "Game", type: "mp3", volume: 0.03, repeatSound: true)

    var body: some View {
        ZStack {
            if isPlaying {
                Game(highScore: $highScore, isPlaying: $isPlaying)
                    .onAppear(perform: {
                        gamePlayer.start()
                    })
                    .onDisappear(perform: {
                        gamePlayer.pauseSmoothly(duration: 0.5)
                    })
                   
            } else {
                WelcomeScreen(highScore: $highScore) {
                    isPlaying = true
                }
                .onAppear(perform: {
                    menuPlayer.start()
                })
                .onDisappear(perform: {
                    menuPlayer.pauseSmoothly(duration: 0.5)
                })
               
            }
        }
        .frame(width: 400, height: 600)
    }
}
