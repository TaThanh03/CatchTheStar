//
//  GameOverView.swift
//  CatchTheStar
//
//  Created by TA Trung Thanh on 19/12/2018.
//  Copyright © 2018 TA Trung Thanh. All rights reserved.
//
import UIKit

class GameOverView: UIView, UIPickerViewDelegate{
    var blurView = UIVisualEffectView()
    
    let gameOverLabel = UILabel()
    var scrollLabel = UILabel()
    let restartButton = UIButton()
    var restartImageView = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let blurEffect = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: blurEffect)
        gameOverLabel.text = "game over"
        gameOverLabel.textAlignment = .center
        let restartImage = UIImage(named: "Refesh")
        restartButton.setImage(restartImage, for: .normal)
        restartButton.addTarget(self.superview, action: #selector(GameViewController.actionSettingButtonRestartTouched), for: .touchUpInside)
        
        //scrollLabel = model control this
        
        self.addSubview(blurView)
        self.addSubview(gameOverLabel)
        self.addSubview(scrollLabel)
        self.addSubview(restartButton)
        
        self.drawInFormat(format: frame.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawInFormat (format: CGSize) {
        let centre_width = CGFloat(format.width/2)
        let centre_height = CGFloat(format.height/2)
        blurView.frame = CGRect(x: centre_width - format.width*2/1.5, y: format.height*2/3, width: format.width/1.5, height: format.height/3)
        gameOverLabel.frame = CGRect(x: centre_width - 100, y: centre_height - 30, width: 200, height: 60)
        scrollLabel.frame = CGRect(x: centre_width - 100, y: centre_height - 100, width: 200, height: 30)
    }
    
}
