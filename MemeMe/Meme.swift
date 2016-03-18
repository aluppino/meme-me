//
//  Meme.swift
//  MemeMe
//
//  Created by Angelo Luppino on 3/17/16.
//  Copyright © 2016 Angelo Luppino. All rights reserved.
//

import Foundation
import UIKit

class Meme {
    
    var topText: String
    var bottomText: String
    var image: UIImage
    var memedImage: UIImage
    
    init(topText: String, bottomText: String, image: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.memedImage = memedImage
    }
    
}