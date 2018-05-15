//
//  EkoImage.swift
//  DBFM2
//
//  Created by addcn on 2018/5/11.
//  Copyright © 2018年 addcn. All rights reserved.
//

import UIKit

class EkoImage: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width / 2

        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).cgColor
    }
    
    
    func onRotation() {
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotation.fromValue = 0.0
        rotation.toValue = Double.pi * 2.0
        
        rotation.duration = 20
        
        rotation.repeatCount = 10000
        self.layer.add(rotation, forKey: nil)
    }

}
