//
//  ViewController.swift
//  GreedySnake
//
//  Created by 劉峻岫 on 2019/9/16.
//  Copyright © 2019 Addcn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        
        var x = Int(UIScreen.main.bounds.midX)
        let y = Int(UIScreen.main.bounds.midY)
        
        viewModel.inputs.updatePoint(x: x, y: y)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            self.viewModel.inputs.removePoint(x: x, y: y)
            
            if x >= Int(UIScreen.main.bounds.maxX) {
                x = -25
            } else {
                x += 10
            }
            self.viewModel.inputs.updatePoint(x: x, y: y)
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
        
        outputs.removeBody = { [weak self] (body) in
            guard let self = self else { return }
            if let subview = self.view.viewWithTag(1) {
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
    func updatePoint(x: Int, y: Int)
    func removePoint(x: Int, y: Int)
}

protocol ViewModelOutputs {
    var updateBody: ((SnakeBody) -> Void)? { get set }
    var removeBody: ((SnakeBody) -> Void)? { get set }
}

class ViewModel: ViewModelInputs, ViewModelOutputs {
    
    var inputs: ViewModelInputs { return self }
    var outputs: ViewModelOutputs { return self }
    
    var updateBody: ((SnakeBody) -> Void)?
    var removeBody: ((SnakeBody) -> Void)?
    
    private var tag = 1
    
    func updatePoint(x: Int, y: Int) {
        let snakeBody = SnakeBody(x: x, y: y, tag: tag)
        
        updateBody?(snakeBody)
    }
    
    func removePoint(x: Int, y: Int) {
        let snakeBody = SnakeBody(x: x, y: y, tag: tag)
        
        removeBody?(snakeBody)
    }
}
