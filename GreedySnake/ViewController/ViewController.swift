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
    var displayLnk: CADisplayLink!
    
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
        
        displayLnk = CADisplayLink(target: self, selector: #selector(move))
        displayLnk.preferredFramesPerSecond = 120
        displayLnk.add(to: RunLoop.current, forMode: .default)
        
    }
    
    @objc func move() {
        viewModel.inputs.move()
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
        
        outputs.updateObject = { [weak self] (object) in
            guard let self = self else { return }
            let objectView = self.createView(x: CGFloat(object.x), y: CGFloat(object.y))
            objectView.tag = object.tag

            // if tag is -1, it should be apple, otherwise it should be snake body
            objectView.backgroundColor = (object.tag == -1) ? .red : .black
            self.view.addSubview(objectView)
        }
        
        outputs.removeBody = { [weak self] (tag) in
            guard let self = self else { return }
            if let subview = self.view.viewWithTag(tag) {
                subview.removeFromSuperview()
            }
        }
        
        outputs.showMessage = { [weak self] (message) in
            self?.displayLnk.invalidate()
            
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
    
    private func createView(x: CGFloat, y: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: x, y: y, width: 10, height: 10))
        return view
    }
}

