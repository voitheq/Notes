//
//  Note.swift
//  Notes
//
//  Created by Wojciech Karaś on 19/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit

class Note: NSObject, Codable {
    var title: String?
    var content: String?
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
}
