//  /*
//
//  Project: Pingpong
//  File: ContentView.swift
//  Created by: Elaidzha Shchukin
//  Date: 25.05.2023
//
//
//
//  */

import SwiftUI

struct Tile: Identifiable {
    let id = UUID()
    var destroyed = false
}

struct ContentView: View {
    @State private var tiles: [[Tile]] = Array(repeating: Array(repeating: Tile(), count: 6), count: 10)
    @State private var ballPosition: CGPoint = .zero
    @State private var ballVelocity: CGVector?
    @State private var missedBalls: Int = 0
    
    private let tileSize: CGFloat = 40
    private let platformHeight: CGFloat = 20
    private let rows = 10
    private let columns = 6
    
    private let maxMissedBalls = 3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ForEach(0..<rows) { row in
                    ForEach(0..<columns) { column in
                            Tile(tile: tiles[row][column], size: tileSize)
                            .position(
                                x: tileSize/2 + CGFloat(column) * tileSize,
                                y: tileSize/2 + CGFloat(row) * tileSize
                            )
                    }
                }
                
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: tileSize, height: platformHeight)
                    .position(x: ballPosition.x, y: geometry.size.height - platformHeight/2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let x = value.location.x
                                ballPosition.x = x
                            }
                    )
                    .onChange(of: ballPosition) { _ in
                        checkCollision()
                    }
                
                if let velocity = ballVelocity {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 10, height: 10)
                        .position(ballPosition)
                        .onAppear {
                            startBall(velocity: velocity)
                        }
                }
            }
            .onAppear {
                resetGame()
            }
        }
    }
    
    private func resetGame() {
        missedBalls = 0
        resetTiles()
        resetBall()
    }
    
    private func resetTiles() {
        for row in 0..<rows {
            for column in 0..<columns {
                tiles[row][column].destroyed = false
            }
        }
    }
    
    private func resetBall() {
        ballPosition = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.height - platformHeight - 10)
        ballVelocity = nil
    }
    
    private func startBall(velocity: CGVector) {
        if ballVelocity == nil {
            ballVelocity = velocity
        }
    }
    
    private func checkCollision() {
        guard let velocity = ballVelocity else { return }
        
        let nextPosition = CGPoint(
            x: ballPosition.x + velocity.dx,
            y: ballPosition.y + velocity.dy
        )
        
        if nextPosition.x < tileSize / 2 || nextPosition.x > UIScreen.main.bounds.width - tileSize / 2 {
            ballVelocity = CGVector(dx: -velocity.dx, dy: velocity.dy)
        }
        
        if nextPosition.y < tileSize / 2 {
            ballVelocity = CGVector(dx: velocity.dx, dy: -velocity.dy)
        }
        
        let collidingRow = Int(nextPosition.y / tileSize)
        let collidingColumn = Int(nextPosition.x / tileSize)
        
        if collidingRow >= 0 && collidingRow < rows && collidingColumn >= 0 && collidingColumn < columns {
            if !tiles[collidingRow][collidingColumn].destroyed {
                tiles[collidingRow][collidingColumn]
            }
        }
    }
}

