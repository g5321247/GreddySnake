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
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        switch gesture.direction {
        case .up:
            viewModel.inputs.updateDirection(direction: .up)
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
    private var direction: Direction = .right
    private var currentPoint: Point
    private var boundPoint: Point
    
    init(startPoint: Point, bound: Point) {
        currentPoint = startPoint
        boundPoint = bound
    }
    
    func start() {

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            self.removeBody?(self.tag)
            
            switch self.direction {
            case .up:
                if self.currentPoint.y <= 0 {
                    self.currentPoint.y = self.boundPoint.y + 25
                } else {
                    self.currentPoint.y -= 10
                    print(self.currentPoint.y)
                }
            case .right:
                self.currentPoint.x >= self.boundPoint.x ? (self.currentPoint.x = -25) : (self.currentPoint.x += 10)
            default:
                break
            }
            
            let snakeBody = SnakeBody(x: self.currentPoint.x, y: self.currentPoint.y, tag: self.tag)
            
            self.updateBody?(snakeBody)
        }.fire()
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
