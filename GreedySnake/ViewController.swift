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
            startPoint: .init(x: Int(UIScreen.main.bounds.midX), y: Int(UIScreen.main.bounds.midY)), bound: .init(x: Int(UIScreen.main.bounds.maxX), y: Int(UIScreen.main.bounds.maxY))
        )
        bindViewModel()
        
        viewModel.inputs.start()
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
    }
    
    private func createSnakeBody(x: CGFloat, y: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: x, y: y, width: 30, height: 30))
        view.backgroundColor = .black
        return view
    }
}

protocol ViewModelInputs {
    func updateDirection(direction: ViewModel.Direction)
    func start()
}

protocol ViewModelOutputs {
    var updateBody: ((SnakeBody) -> Void)? { get set }
    var removeBody: ((Int) -> Void)? { get set }
}

class ViewModel: ViewModelInputs, ViewModelOutputs {
    
    var inputs: ViewModelInputs { return self }
    var outputs: ViewModelOutputs { return self }
    
    var updateBody: ((SnakeBody) -> Void)?
    var removeBody: ((Int) -> Void)?
    
    private var tag = 1
    private var direction: Direction = .left
    private var currentPoint: Point
    private var boundPoint: Point
    
    init(startPoint: Point, bound: Point) {
        currentPoint = startPoint
        boundPoint = bound
    }
    
    func start() {

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            self.removeBody?(self.tag)
            self.updatePosition()
            
            let snakeBody = SnakeBody(x: self.currentPoint.x, y: self.currentPoint.y, tag: self.tag)
            self.updateBody?(snakeBody)
        }.fire()
    }
    
    private func updatePosition() {
        switch direction {
        case .up:
            currentPoint.y <= 0 ? currentPoint.y = (boundPoint.y + 25) : (currentPoint.y -= 10)
        case .left:
            currentPoint.x <= 0 ? currentPoint.x = (boundPoint.x + 25) : (currentPoint.x -= 10)
        case .down:
            currentPoint.y >= boundPoint.y ? (currentPoint.y = -25) : (currentPoint.y += 10)
        case .right:
            currentPoint.x >= boundPoint.x ? (currentPoint.x = -25) : (currentPoint.x += 10)
        }
    }
    
    func updateDirection(direction: Direction) {
        self.direction = direction
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
