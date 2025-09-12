

import Foundation
import SwiftUI
import Combine


// MARK: - Tiny Game State
class TinyGameState: ObservableObject {
    @Published var tinyPosition = TinyPosition(x: 2, y: 2)
    @Published var tinyDirection: TinyDirection = .right
    @Published var dragons: [TinyDragon] = []
    @Published var score = 0
    @Published var timeRemaining = 120
    @Published var isGameOver = false
    @Published var isGameActive = false
    @Published var showInstructions = true
    
    private var gridSize = 5
    private var timer: AnyCancellable?
    
    func tinyStartGame() {
        score = 0
        timeRemaining = 120
        isGameOver = false
        isGameActive = true
        tinyPosition = TinyPosition(x: 2, y: 2)
        tinyDirection = .right
        dragons.removeAll()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tinyUpdateTimer()
            }
    }
    
    private func tinyUpdateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            isGameOver = true
            isGameActive = false
            timer?.cancel()
        }
    }
    
    func tinyMove(direction: TinyDirection) {
        guard isGameActive else { return }
        
        tinyDirection = direction
        
        var newPosition = tinyPosition
        switch direction {
        case .up:
            newPosition.y = max(0, tinyPosition.y - 1)
        case .down:
            newPosition.y = min(gridSize - 1, tinyPosition.y + 1)
        case .left:
            newPosition.x = max(0, tinyPosition.x - 1)
        case .right:
            newPosition.x = min(gridSize - 1, tinyPosition.x + 1)
        }
        
        if newPosition != tinyPosition {
            tinyPosition = newPosition
        }
    }
    
    func tinyFire() {
        guard isGameActive else { return }
        
        // Spawn a new dragon at random edge
        tinySpawnDragon()
        
        // Check if any dragon is in the line of fire
        for index in dragons.indices {
            var dragon = dragons[index]
            
            switch tinyDirection {
            case .up:
                if dragon.position.x == tinyPosition.x && dragon.position.y < tinyPosition.y && dragon.direction == .down {
                    dragon.isHit = true
                    score += 10
                }
            case .down:
                if dragon.position.x == tinyPosition.x && dragon.position.y > tinyPosition.y && dragon.direction == .up {
                    dragon.isHit = true
                    score += 10
                }
            case .left:
                if dragon.position.y == tinyPosition.y && dragon.position.x < tinyPosition.x && dragon.direction == .right {
                    dragon.isHit = true
                    score += 10
                }
            case .right:
                if dragon.position.y == tinyPosition.y && dragon.position.x > tinyPosition.x && dragon.direction == .left {
                    dragon.isHit = true
                    score += 10
                }
            }
            
            dragons[index] = dragon
        }
        
        // Remove hit dragons after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dragons.removeAll(where: { $0.isHit })
        }
    }
    
    private func tinySpawnDragon() {
        let edge = Int.random(in: 0..<4)
        var position: TinyPosition
        var direction: TinyDirection
        
        switch edge {
        case 0: // top
            position = TinyPosition(x: Int.random(in: 0..<gridSize), y: 0)
            direction = .down
        case 1: // bottom
            position = TinyPosition(x: Int.random(in: 0..<gridSize), y: gridSize - 1)
            direction = .up
        case 2: // left
            position = TinyPosition(x: 0, y: Int.random(in: 0..<gridSize))
            direction = .right
        default: // right
            position = TinyPosition(x: gridSize - 1, y: Int.random(in: 0..<gridSize))
            direction = .left
        }
        
        let dragon = TinyDragon(position: position, direction: direction)
        dragons.append(dragon)
    }
}
