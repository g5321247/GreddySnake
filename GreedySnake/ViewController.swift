//
//  ViewController.swift
//  GreedySnake
//
//  Created by 劉峻岫 on 2019/9/16.
//  Copyright © 2019 Addcn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var viewModel: ViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ViewModel(
           bound: .init(x: Int(UIScreen.main.bounds.maxX), y: Int(UIScreen.main.bounds.maxY))
        )
        bindViewModel()
        
        viewModel.inputs.start(startPoint:
            .init(x: Int(UIScreen.main.bounds.midX), y: Int(UIScreen.main.bounds.midY))
        )
        setupUI()
    }
    
    private func setupUI() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
        
        // 測試
        let touch = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(touch)

    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            viewModel.inputs.updateDirection(direction: .up)
        case .down:
            viewModel.inputs.updateDirection(direction: .down)
        case .right:
            viewModel.inputs.updateDirection(direction: .right)
        case .left:
            viewModel.inputs.updateDirection(direction: .left)
        default:
            break
        }
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        viewModel.inputs.eatApple()
    }

    private func bindViewModel() {
        var outputs = viewModel.outputs
        
        outputs.updateBody = { [weak self] (body) in
            guard let self = self else { return }
            let snakeBodyView = self.createSnakeBody(x: CGFloat(body.x), y: CGFloat(body.y))
            snakeBodyView.tag = body.tag
            self.view.addSubview(snakeBodyView)
        }
        
        outputs.removeBody = { [weak self] (tag) in
            guard let self = self else { return }
            if let subview = self.view.viewWithTag(tag) {
                subview.removeFromSuperview()
            }
        }
        
        outputs.showMessage = { [weak self] (message) in
            let alertVc = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default, handler: { (_) in
                self?.restart(x: Int(UIScreen.main.bounds.midX), y: Int(UIScreen.main.bounds.midY))
            })
            
            alertVc.addAction(action)
            self?.present(alertVc, animated: true, completion: nil)
        }
    }
    
    private func restart(x: Int, y: Int) {
        view.subviews.forEach { $0.removeFromSuperview()}
        viewModel.inputs.start(startPoint: .init(x: x, y: y))
    }
    
    private func createSnakeBody(x: CGFloat, y: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: x, y: y, width: 10, height: 10))
        view.backgroundColor = .black
        return view
    }
}

protocol ViewModelInputs {
    func updateDirection(direction: ViewModel.Direction)
    func start(startPoint: ViewModel.Point)
    func eatApple()
}

protocol ViewModelOutputs {
    var updateBody: ((SnakeBody) -> Void)? { get set }
    var removeBody: ((Int) -> Void)? { get set }
    var showMessage: ((String) -> Void)? { get set }
}

class ViewModel: ViewModelInputs, ViewModelOutputs {
    
    var inputs: ViewModelInputs { return self }
    var outputs: ViewModelOutputs { return self }
    
    var updateBody: ((SnakeBody) -> Void)?
    var removeBody: ((Int) -> Void)?
    var showMessage: ((String) -> Void)?
    
    private var lastBodyTag = 1
    private var direction: Direction = .left
    private var currentPoint: Point!
    private var boundPoint: Point
    private var snakeBodyQueue = Queue<SnakeBody>()
    private var timer: Timer!
    
    init(bound: Point) {
        boundPoint = bound
    }
    
    func start(startPoint: Point) {
        currentPoint = startPoint
        setDefault()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            let firstTag = self.removeFirstBody()
            self.updatePosition()
            self.addBody(with: firstTag)
        }
        
        timer.fire()
    }
    
    private func setDefault() {
        snakeBodyQueue.clearQueue()
        direction = .left
    }
    
    private func removeFirstBody() -> Int {
        guard let snakebody = snakeBodyQueue.dequeue() else { return 1 }
        removeBody?(snakebody.tag)
        return snakebody.tag
    }
    
    func eatApple() {
        lastBodyTag += 1
        addBody(with: lastBodyTag)
    }
    
    private func addBody(with tag: Int) {
        let snakeBody = SnakeBody(x: currentPoint.x, y: currentPoint.y, tag: tag)
        
        // Check self body hitting
        guard !isHittingBody(nextBody: snakeBody) else {
            timer.invalidate()
            showMessage?("Your score is \(snakeBodyQueue.array.count)")
            return
        }
        
        snakeBodyQueue.enqueue(snakeBody)
        updateBody?(snakeBody)
    }
    
    private func isHittingBody(nextBody: SnakeBody) -> Bool {
        return snakeBodyQueue.array.contains {
            if $0 == snakeBodyQueue.array.last {
                return false
            } else {
                return $0.x == nextBody.x && $0.y == nextBody.y
            }
        }
    }
    
    private func updatePosition() {
        switch direction {
        case .up:
            currentPoint.y <= 0 ? currentPoint.y = (boundPoint.y + 5) : (currentPoint.y -= 10)
        case .left:
            currentPoint.x <= 0 ? currentPoint.x = (boundPoint.x + 5) : (currentPoint.x -= 10)
        case .down:
            currentPoint.y >= boundPoint.y ? (currentPoint.y = -5) : (currentPoint.y += 10)
        case .right:
            currentPoint.x >= boundPoint.x ? (currentPoint.x = -5) : (currentPoint.x += 10)
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
