//
//  Queue.swift
//  GreedySnake
//
//  Created by 劉峻岫 on 2019/9/18.
//  Copyright © 2019 Addcn. All rights reserved.
//

import Foundation

struct Queue<T> {
    
    private(set) var array: [T] = []
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    mutating func dequeue() -> T? {
        guard !isEmpty else { return nil }
        let element = array.first
        array.remove(at: 0)
        return element
    }
    
    func peek() -> T? {
        return array.first
    }
}
