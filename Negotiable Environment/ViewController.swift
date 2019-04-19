//
//  ViewController.swift
//  Negotiable Environment
//
//  Created by Sarah Mautsch on 20.03.19.
//  Copyright © 2019 Sarah Mautsch. All rights reserved.
//

import UIKit
import GradientView
import FirebaseDatabase

class ViewController: UIViewController {
    var ref: DatabaseReference!
    
    let brightnessSlider = SMBrightnessSlider()
    let containerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        containerView.backgroundColor = UIColor.appropriateOrange
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.everythingEqualToSuperView()
        }
        
        ref = Database.database().reference()

        
        ref.child("values").observe(.value, with: { (snapshot) in
            
            
            if let data = snapshot.value as? [String : Float] {
                
                let sum = data.values.reduce(0, +)
                let average = sum/Float(data.values.count)
                
                self.brightnessSlider.configureFor(minValue: data.values.min() ?? 0, maxValue: data.values.max() ?? 1, midValue: average)
            }
        })

        
        brightnessSlider.addTarget(self, action: #selector(self.sliderValueChanged(slider:)), for: .valueChanged)
        
        containerView.addSubview(brightnessSlider)
        
        brightnessSlider.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(320)

        }
        

    }
    
    @objc func sliderValueChanged (slider : SMBrightnessSlider) {
        
        self.containerView.backgroundColor = UIColor.appropriateOrange.withAlphaComponent(CGFloat(slider.currentValue))
        
        if let identifier = UIDevice.current.identifierForVendor {
            self.ref.child("values").child(identifier.uuidString).setValue(slider.currentValue)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }


}

class SMBrightnessSlider : UIControl {
    let thumb = AAView()
    let track = AAView()
    let brightnessIcon = UIImageView()
    
    let gradientView = GradientView()
    
    var currentValue : Float = 0

    
    init(){
        super.init(frame: .zero)
        
        self.addSubview(track)
        
        track.cornerRadius = 26
        track.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        track.snp.makeConstraints { make in
            make.pinAllEdgesToSuperView()
        }
        
        gradientView.backgroundColor = UIColor.clear
        gradientView.colors = [UIColor.white.withAlphaComponent(0), UIColor.white.withAlphaComponent(0.75), UIColor.white.withAlphaComponent(0)]
        gradientView.locations = [0, 0.5, 1.0]
        gradientView.direction = .vertical
        
        track.contentView.addSubview(gradientView)
        
        gradientView.snp.makeConstraints { make in
            make.pinAllEdgesToSuperView()
        }
        
        brightnessIcon.image = UIImage(named: "brightness-icon")
        brightnessIcon.tintColor = UIColor.appropriateOrange
        
    
        thumb.addSubview(brightnessIcon)
        
        brightnessIcon.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        
        track.addSubview(thumb)
        thumb.contentView.backgroundColor = UIColor.white
        thumb.cornerRadius = 20
        thumb.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().inset(5).priority(.high)
            make.bottom.lessThanOrEqualToSuperview().inset(5).priority(.high)
            make.height.equalTo(track.snp.width).inset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(5)
        }
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.sliderIsBeingPanned(recognizer:)))
        thumb.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func configureFor (minValue : Float, maxValue : Float, midValue : Float) {
        
        let percentage = (midValue-minValue)/(maxValue-minValue)
        print(percentage)
        
        gradientView.snp.remakeConstraints { make in
            if minValue > 0 {
                make.bottom.equalTo(track.snp.bottom).inset((track.frame.height) * CGFloat(minValue))
            } else {
                make.bottom.equalTo(track.snp.bottom)
            }
            
            if maxValue > 0 {
                make.top.equalTo(track.snp.bottom).inset((track.frame.height) * CGFloat(maxValue))
            } else {
                make.top.equalTo(track.snp.top)
            }
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        gradientView.locations = [0, CGFloat(1-percentage), 1.0]
        
    }
    
    @objc func sliderIsBeingPanned (recognizer : UIPanGestureRecognizer) {
        
        let insetValue : CGFloat = 5
        
        thumb.snp.remakeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().inset(insetValue).priority(.high)
            make.bottom.lessThanOrEqualToSuperview().inset(insetValue).priority(.high)
            make.centerY.equalTo(recognizer.location(in: track).y).priority(.low)
            make.centerX.equalToSuperview()
            make.height.equalTo(track.snp.width).inset(5)
            make.width.equalToSuperview().inset(5)
        }
        
        self.layoutIfNeeded()
        
        currentValue = Float(1 - (thumb.frame.minY-5)/(track.frame.height-insetValue*2-thumb.frame.height))
        
        self.sendActions(for: UIControl.Event.valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




