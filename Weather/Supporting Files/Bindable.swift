//
//  Bindable.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

class Bindable<T> {
    typealias Listener = (T) -> Void

    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: Listener?

    init(_ value: T) {
        self.value = value
    }

    /**
     - Important:
       Best practice is to only set any UI attribute in a single binding. Failing to follow
       that suggestion can result in hard-to-track bugs where the order that values are set results in
       different UI outcomes.

     - Parameters:
          - listener: The *closure* to execute when responding to value changes.
     */
    func bind(_ listener: Listener?) {
        
        self.listener = { value in
            Task { @MainActor in
                listener?(value)
            }
        }
        
        listener?(value)
    }
}

