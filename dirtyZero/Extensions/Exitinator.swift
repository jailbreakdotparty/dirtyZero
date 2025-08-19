//
//  Exitinator.swift
//  dirtyZero
//
//  Created by Skadz on 8/6/25.
//

import Foundation
import UIKit

// nice func to exit the app nicely
// skidded from stack overflow :3
func exitinator() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
        exit(0)
    }
}
