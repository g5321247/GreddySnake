//
//  ViewModel.swift
//  GreedySnake
//
//  Created by George Liu on 2019/9/20.
//  Copyright © 2019 Addcn. All rights reserved.
//

import Foundation

protocol ViewModelInputs {
    func updateDirection(direction: ViewModel.Direction)
    func start(startPoint: ViewModel.Point)
}

protocol ViewModelOutputs {
    var updateObject: ((Object) -> Void)? { get set }
    var removeBody: ((Int) -> Void)? { get set }
    var showMessage: ((String) -> Void)? { get set }
}

class ViewModel: ViewModelInputs, ViewModelOutputs {
    
    var inputs: ViewModelInputs { return self }
    var outputs: ViewModelOutputs { return self }
    
    var updateObject: ((Object) -> Void)?
    var removeBody: ((Int) -> Void)?
    var showMessage: ((String) -> Void)?
    
    private var lastBodyTag = 1
    private var direction: Direction = .left
    private var currentPoint: Point!
    private var boundPoint: Point
    private var snakeBodyQueue = Queue<Object>()
    private var timer: Timer!
    private var currentApple: Object!
    
    init(bound: Point) {
        boundPoint = bound
    }
    
    func start(startPoint: Point) {
        currentPoint = startPoint
        setAsDefault()
        move()
    }
    
    private func move() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            let firstTag = self.removeFirstBody()
            self.updatePosition()
            self.addBody(with: firstTag)
            
            self.isEattenApple() ? self.eatApple() : nil
        }
        
        timer.fire()
    }
    
    private func isEattenApple() -> Bool {
        return snakeBodyQueue.array.contains {
            let rangeOfX = self.currentApple.x - 10 ... self.currentApple.x + 10
            let rangeOfY = self.currentApple.y - 10 ... self.currentApple.y + 10
            
            return rangeOfX.contains($0.x) && rangeOfY.contains($0.y)
        }
    }
    
    private func setAsDefault() {
        snakeBodyQueue.clearQueue()
        direction = .left
        currentApple = createNewApple()
    }
    
    private func removeFirstBody() -> Int {
        guard let snakebody = snakeBodyQueue.dequeue() else { return 1 }
        removeBody?(snakebody.tag)
        return snakebody.tag
    }
    
    private func createNewApple() -> Object {
        let x = Int.random(in: 0 ... (boundPoint.x - 50))
        let y = Int.random(in: 0 ... (boundPoint.y - 50))
        
        // if the place where apple grow places snake body already, it should find other random place
        guard !isHittingBody(next: x, y: y) else {
            return createNewApple()
        }
        
        let apple = Object(x: x, y: y, tag: -1)
        updateObject?(apple)
        
        return apple
    }
    
    private func eatApple() {
        lastBodyTag += 1
        removeBody?(-1)
        addBody(with: lastBodyTag)
        currentApple = createNewApple()
    }
    
    private func addBody(with tag: Int) {
        let snakeBody = Object(x: currentPoint.x, y: currentPoint.y, tag: tag)
        
        // Check self body hitting
        guard !isHittingBody(next: snakeBody.x, y: snakeBody.y) else {
            timer.invalidate()
            showMessage?("Your score is \(snakeBodyQueue.array.count)")
            return
        }
        
        snakeBodyQueue.enqueue(snakeBody)
        updateObject?(snakeBody)
    }
    
    private func isHittingBody(next x: Int, y: Int) -> Bool {
        return snakeBodyQueue.array.contains {
            if $0 == snakeBodyQueue.array.last {
                return false
            } else {
                return $0.x == x && $0.y == y
            }
        }
    }
    
    private func updatePosition() {
        switch direction {
        case .up:
            currentPoint.y <= 0 ? currentPoint.y = (boundPoint.y - 10) : (currentPoint.y -= 10)
        case .left:
            currentPoint.x <= 0 ? currentPoint.x = (boundPoint.x - 10) : (currentPoint.x -= 10)
        case .down:
            currentPoint.y >= boundPoint.y ? (currentPoint.y = 10) : (currentPoint.y += 10)
        case .right:
            currentPoint.x >= boundPoint.x ? (currentPoint.x = 10) : (currentPoint.x += 10)
        }
    }
    
    func updateDirection(direction: Direction) {
        if !isOppositeDirection(direction) {
            self.direction = direction
        }
    }
    
    private func isOppositeDirection(_ direction: Direction) -> Bool {
        switch self.direction {
        case .down:
            return direction == .up
        case .up:
            return direction == .down
        case .left:
            return direction == .right
        case .right:
            return direction == .left
        }
    }
}

extension ViewModel {
    
    enum Direction {
        case right
        case up
        case left
        case down
    }
    
    struct Point {
        var x: Int
        var y: Int
    }
}
