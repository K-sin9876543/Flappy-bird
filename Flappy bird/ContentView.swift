//
//  ContentView.swift
//  Flappy bird
//
//  Created by Kabir on 6/3/24.
//

import SwiftUI


struct ContentView: View {
    @State private var birdPosition = CGSize.zero
    @State private var pipes = [CGSize]()
    @State private var score = 0
    @State private var gameOver = false
    @State private var birdVelocity: CGFloat = 0.0
    @State private var isPlaying = false

    let birdSize: CGFloat = 30
    let pipeWidth: CGFloat = 50
    let gapHeight: CGFloat = 150
    let gravity: CGFloat = 1.0
    let jumpHeight: CGFloat = 15.0
    let pipeSpeed: CGFloat = 5.0

    var body: some View {
        ZStack {
            // Background
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            // Bird
            Bird()
                .offset(x: -100, y: birdPosition.height)
            
            // Pipes
            ForEach(0..<pipes.count, id: \.self) { index in
                let pipePosition = pipes[index]
                Pipe(height: pipePosition.height)
                    .offset(x: pipePosition.width, y: -UIScreen.main.bounds.height / 2 + pipePosition.height / 2)
                
                Pipe(height: UIScreen.main.bounds.height - pipePosition.height - gapHeight)
                    .offset(x: pipePosition.width, y: UIScreen.main.bounds.height / 2 - (UIScreen.main.bounds.height - pipePosition.height - gapHeight) / 2)
            }

            // Score
            Text("Score: \(score)")
                .font(.largeTitle)
                .foregroundColor(.white)
                .position(x: UIScreen.main.bounds.width / 2, y: 50)
            
            // Game Over
            if gameOver {
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Button(action: {
                        startGame()
                    }) {
                        Text("Restart")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }

            // Jump Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if !isPlaying {
                            startGame()
                        }
                        birdJump()
                    }) {
                        Text("Jump")
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            resetGame()
        }
    }

    func resetGame() {
        birdPosition = .zero
        birdVelocity = 0.0
        pipes = []
        score = 0
        gameOver = false
        isPlaying = false
    }

    func startGame() {
        isPlaying = true

        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            if gameOver {
                timer.invalidate()
            } else {
                let newHeight = CGFloat.random(in: 100...UIScreen.main.bounds.height - gapHeight - 100)
                pipes.append(CGSize(width: UIScreen.main.bounds.width, height: newHeight))
            }
        }

        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if gameOver {
                timer.invalidate()
            } else {
                updateGame()
            }
        }
    }

    func birdJump() {
        birdVelocity = -jumpHeight
    }

    func updateGame() {
        if !isPlaying {
            return
        }

        // Apply gravity to the bird
        birdVelocity += gravity
        birdPosition.height += birdVelocity

        // Move pipes
        for index in pipes.indices {
            pipes[index].width -= pipeSpeed
        }

        // Collision detection
        if birdPosition.height > UIScreen.main.bounds.height / 2 || birdPosition.height < -UIScreen.main.bounds.height / 2 {
            gameOver = true
        }

        for pipe in pipes {
            if pipe.width < -UIScreen.main.bounds.width / 2 && pipe.width > -UIScreen.main.bounds.width / 2 - pipeWidth {
                if birdPosition.height < pipe.height - UIScreen.main.bounds.height / 2 + birdSize / 2 || birdPosition.height > pipe.height + gapHeight - UIScreen.main.bounds.height / 2 - birdSize / 2 {
                    gameOver = true
                } else {
                    score += 1
                }
            }
        }

        // Remove off-screen pipes
        if let firstPipe = pipes.first, firstPipe.width < -UIScreen.main.bounds.width {
            pipes.removeFirst()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Pipe: View {
    var height: CGFloat
    var body: some View {
        Rectangle()
            .fill(Color.green)
            .frame(width: 50, height: height)
    }
}


struct Bird: View {
    var body: some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: 30, height: 30)
    }
}
#Preview {
    ContentView()
}
