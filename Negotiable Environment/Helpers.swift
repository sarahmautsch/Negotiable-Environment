//
//  Helpers.swift
//
//  Created by Aaron Abentheuer on 16/01/2019.
//  Copyright © 2019 Aaron Abentheuer. All rights reserved.
//

import Foundation
import SnapKit

extension ConstraintMaker {
    func everythingEqualToSuperView () {
        self.size.equalToSuperview()
        self.center.equalToSuperview()
    }
    
    func pinAllEdges (withInsets insets: UIEdgeInsets?, respectingSafeAreaLayoutGuidesOfView view : UIView?) {
        let insets = insets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        if let v = view {
            self.top.equalTo(v.safeAreaLayoutGuide.snp.top).inset(insets)
            self.bottom.equalTo(v.safeAreaLayoutGuide.snp.bottom).inset(insets)
            self.leading.equalTo(v.safeAreaLayoutGuide.snp.leading).inset(insets)
            self.trailing.equalTo(v.safeAreaLayoutGuide.snp.trailing).inset(insets)
        } else {
            self.top.equalToSuperview().inset(insets)
            self.bottom.equalToSuperview().inset(insets)
            self.left.equalToSuperview().inset(insets)
            self.right.equalToSuperview().inset(insets)
        }
    }
}


extension ConstraintMaker {
    func pinAllEdgesToSuperView () {
        self.top.equalToSuperview()
        self.left.equalToSuperview()
        self.right.equalToSuperview()
        self.bottom.equalToSuperview()
    }
}

extension CGFloat {
    
    func mapProgress (from fromValue: CGFloat, to toValue: CGFloat, multiplier : CGFloat?, shouldOvershoot : Bool) -> CGFloat {
        
        var progressMultiplier : CGFloat!
        
        if multiplier == 0 || multiplier == nil {
            progressMultiplier = 1
        } else {
            progressMultiplier = multiplier!
        }
        
        let progress = self * progressMultiplier
        return progress.mapValue(initialMin: 0, initialMax: 1, mappedMin: fromValue, mappedMax: toValue, constrained: shouldOvershoot)
    }
    
    func mapValue (initialMin : CGFloat, initialMax : CGFloat, mappedMin : CGFloat, mappedMax : CGFloat, constrained : Bool) -> CGFloat {
        
        let initialRange = initialMax - initialMin
        var percentage = self/initialRange
        
        if constrained {
            percentage = percentage.constrained(betweenMin: 0, andMax: 1)
        }
        
        let mappedRange = mappedMax - mappedMin
        
        return mappedMin + mappedRange * percentage
    }
    
    func constrained (betweenMin min : CGFloat, andMax max : CGFloat) -> CGFloat {
        if self <= min {
            return min
        } else if self >= max {
            return max
        } else {
            return self
        }
    }
}

extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(CGPoint(x: view.frame.origin.x, y: view.frame.midY), to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x: childStartPoint.x, y: childStartPoint.y, width: self.frame.width, height: self.frame.height), animated: animated)
        }
    }
}

public extension Int {
    public static func random (from fromValue : Int, to toValue : Int) -> Int {
        return Int(fromValue + Int(arc4random_uniform(UInt32(toValue-fromValue+1))))
    }
}

extension UIStackView {
    func addArrangedSubviews (views : [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
    
    func insertVerticalSpacerView(ofHeight height : CGFloat) {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        self.addArrangedSubview(spacerView)
        
        spacerView.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width)
            make.height.equalTo(height)
        }
    }
    
    func insertHorizontalSpacerView(ofWidth width : CGFloat) {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        self.addArrangedSubview(spacerView)
        
        spacerView.snp.makeConstraints { make in
            make.height.equalTo(self.snp.height)
            make.width.equalTo(width)
        }
    }
    
    func insertVerticalDivider(strokeWidth : CGFloat, color : UIColor, insets : UIEdgeInsets) {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        self.addArrangedSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.height.equalTo(strokeWidth + insets.top + insets.bottom)
            make.width.equalToSuperview()
        }
        
        let dividerView = UIView()
        dividerView.backgroundColor = color
        containerView.addSubview(dividerView)
        
        dividerView.snp.makeConstraints { make in
            make.height.equalTo(strokeWidth)
            make.left.equalToSuperview().inset(insets)
            make.right.equalToSuperview().inset(insets)
            make.top.equalToSuperview().inset(insets)
            make.bottom.equalToSuperview().inset(insets)
        }
    }
}

class CellButton: UIButton {
    var indexPathTag : IndexPath?
}

class CellTapGestureRecognizer: UITapGestureRecognizer {
    var indexPathTag : IndexPath = []
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
}

extension UIImageView {
    convenience init(withIcon icon : UIImage, tintColor : UIColor) {
        self.init()
        let glyph = icon.withRenderingMode(.alwaysTemplate)
        self.image = glyph
        self.contentMode = .scaleAspectFit
        self.tintColor = tintColor
    }
}

protocol CustomStringProtocol {}
extension String: CustomStringProtocol {}
extension Dictionary where Key:CustomStringProtocol {
    func prettyPrint() -> String{
        let data = try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return string! as String
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

extension UIFont {
    
    func fontWithFeature(key: Int, value:Int) -> UIFont {
        let originalDesc = self.fontDescriptor
        let features:[UIFontDescriptor.AttributeName: Any] = [
            UIFontDescriptor.AttributeName.featureSettings : [
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: key,
                    UIFontDescriptor.FeatureKey.typeIdentifier: value
                ]
            ]
        ]
        let newDesc = originalDesc.addingAttributes(features)
        return UIFont(descriptor: newDesc, size: 0.0)
    }
    
    func fontWithSlashedZero() -> UIFont {
        return self.fontWithFeature(key: kTypographicExtrasType, value: kSlashedZeroOnSelector)
    }
    
    func fontWithMonospacedNumbers() -> UIFont {
        return self.fontWithFeature(key: kNumberSpacingType, value: kMonospacedNumbersSelector)
    }
}

func formatPoints(num: Double) -> String {
    let thousandNum = num / 1_000
    let millionNum = num / 1_000_000
    if  (num >= 1_000 && num < 1_000_000) || (num <= -1_000 && num >= -1_000_000) {
        if  round(thousandNum) == thousandNum {
            return("\(Int(thousandNum))TSD")
        }
        return "\(Int(thousandNum)) TSD"
    }
    
    if  (num > 1_000_000) || (num < -1_000_000){
        if  round(millionNum) == millionNum {
            return "\(Int(thousandNum)) TSD"
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        
        return "\(numberFormatter.string(from: NSNumber(value: millionNum)) ?? "") MIL"
    }
        
    else{
        if  floor(num) == num {
            return "\(Int(num))"
        }
        return "\(num)"
    }
}

extension Double {
    // Rounds the double to decimal places value
    mutating func roundToPlaces(_ places : Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self.rounded() * divisor) / divisor
    }
}

extension Float {
    func formattedCurrencyString (forLocale locale : Locale) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = locale
        numberFormatter.generatesDecimalNumbers = false
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: self))
    }
}


extension UISpringTimingParameters {
    public convenience init(dampingRatio: CGFloat, frequencyResponse: CGFloat) {
        precondition(dampingRatio >= 0)
        precondition(frequencyResponse > 0)
        
        let mass = 1 as CGFloat
        let stiffness = pow(2 * .pi / frequencyResponse, 2) * mass
        let damping = 4 * .pi * dampingRatio * mass / frequencyResponse
        
        self.init(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: .zero)
    }
}

class AALabel : UILabel {
    
    var lineHeightMultiple : Float = 1 {
        didSet {
            self.setTextWithAttributes(text: self.text)
        }
    }
    
    var letterSpacing : Float = 1 {
        didSet {
            self.setTextWithAttributes(text: self.text)
        }
    }
    
    var uppercased : Bool = false {
        didSet {
            self.setTextWithAttributes(text: self.text)
        }
    }
    
    override var text: String? {
        didSet {
            self.setTextWithAttributes(text: self.text)
        }
    }
    
    init () {
        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setTextWithAttributes (text : String?) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = CGFloat(lineHeightMultiple)
        
        let t = uppercased ? text?.uppercased() : text;
        
        let attributedString = NSMutableAttributedString(string: t ?? "")
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle, NSAttributedString.Key.kern : CGFloat(letterSpacing)], range: NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
        self.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AAButton : UIControl {
    
    enum AAButtonConfiguration {
        case normal
        case loading
        case success
    }
    
    var label = AALabel()
    var icon : UIImage? {
        didSet {
            iconView.isHidden = false
            iconView.image = icon?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var contentView = AAView()
    
    var insets : UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12) {
        didSet {
            contentStack.spacing = insets.left * 0.75
            contentStack.snp.remakeConstraints { make in
                make.pinAllEdges(withInsets: insets, respectingSafeAreaLayoutGuidesOfView: nil)
            }
        }
    }
    
    private var contentStack = UIStackView()
    var iconView = UIImageView()
    
    var loadingAccessory = UIActivityIndicatorView()
    var doneAccessory = UIImageView()
    
    init () {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .clear
        
        contentView.isUserInteractionEnabled = false
        self.addSubview(contentView)
        contentView.backgroundMaterial = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        contentView.snp.makeConstraints { make in
            make.pinAllEdgesToSuperView()
        }
        
        contentStack.spacing = insets.left * 0.75
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        
        contentView.contentView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.pinAllEdges(withInsets: insets, respectingSafeAreaLayoutGuidesOfView: nil)
        }
        
        iconView.contentMode = .scaleAspectFit
        iconView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        contentStack.addArrangedSubview(iconView)
        iconView.isHidden = true
        iconView.snp.makeConstraints { make in
            make.height.equalToSuperview().priority(.high)
            make.width.equalTo(contentStack.snp.height).priority(.high)
        }
        
        contentStack.addArrangedSubview(label)
        
        let targetView = UIButton()
        targetView.alpha = 1
        targetView.backgroundColor = .clear
        self.addSubview(targetView)
        targetView.snp.makeConstraints { make in
            make.pinAllEdgesToSuperView()
        }

        targetView.addTarget(self, action: #selector(self.invoked), for: .touchUpInside)
        targetView.addTarget(self, action: #selector(self.active), for: .touchDown)
        targetView.addTarget(self, action: #selector(self.active), for: .touchDragEnter)
        targetView.addTarget(self, action: #selector(self.inactive), for: .touchUpOutside)
        targetView.addTarget(self, action: #selector(self.inactive), for: .touchCancel)
        targetView.addTarget(self, action: #selector(self.inactive), for: .touchDragExit)
        
        loadingAccessory.hidesWhenStopped = false
        loadingAccessory.style = .gray
        contentStack.addArrangedSubview(loadingAccessory)
        loadingAccessory.startAnimating()
        loadingAccessory.isHidden = true
        loadingAccessory.snp.makeConstraints { make in
            make.height.equalToSuperview().priority(.high)
            make.width.equalTo(contentStack.snp.height).priority(.high)
        }
        
        contentStack.addArrangedSubview(doneAccessory)
        doneAccessory.contentMode = .scaleAspectFit
        doneAccessory.image = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate)
        doneAccessory.isHidden = true
        doneAccessory.alpha = 0
        doneAccessory.snp.makeConstraints { make in
            make.height.equalToSuperview().priority(.high)
            make.width.equalTo(contentStack.snp.height).priority(.high)
        }
    }
    
    func configureButton (forConfiguration configuration : AAButtonConfiguration) {
        
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: UISpringTimingParameters(dampingRatio: 0.5, frequencyResponse: 0.5))
        animator.addAnimations {
            switch configuration {
            case .loading:
                self.doneAccessory.alpha = 0
                self.doneAccessory.isHidden = true
                self.loadingAccessory.alpha = 1
                self.loadingAccessory.isHidden = false
            case .normal:
                self.doneAccessory.alpha = 0
                self.doneAccessory.isHidden = true
                self.loadingAccessory.alpha = 0
                self.loadingAccessory.isHidden = true
            case .success:
                self.doneAccessory.alpha = 1
                self.doneAccessory.isHidden = false
                self.loadingAccessory.alpha = 0
                self.loadingAccessory.isHidden = true
            }        }
        animator.startAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.inactive()
    }
    
    @objc private func active () {
        print("active")
        highlight(isHighlighted: true)
    }

    @objc private func inactive () {
        print("inactive")
        highlight(isHighlighted: false)
    }

    @objc private func invoked () {
        self.inactive()
        self.sendActions(for: .touchUpInside)
    }
    
    private func highlight (isHighlighted highlight : Bool) {
        
        if highlight {
            
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: UISpringTimingParameters(dampingRatio: 1, frequencyResponse: 0.5))
            animator.addAnimations {
                self.contentView.contentView.layer.transform = CATransform3DMakeScale(0.96, 0.96, 1)
            }
            animator.startAnimation()
            
        } else {
            
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: UISpringTimingParameters(dampingRatio: 0.7, frequencyResponse: 0.2))
            animator.addAnimations {
                self.contentView.contentView.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }
            animator.startAnimation()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AAView : UIView {
    
    var contentView = UIView()
    var backgroundView = UIVisualEffectView()
    var backgroundVibrancyView = UIVisualEffectView()
    var cornerRadius : Float? {
        didSet {
            if let radius = cornerRadius {
                self.adjustCornerRadius(forRadius: radius)
            } else {
                if cornerPercentage == 0 || cornerPercentage == nil {
                    self.contentView.layer.masksToBounds = false
                    self.contentView.layer.cornerRadius = 0
                }
            }
        }
    }
    
    var cornerPercentage : Float? {
        didSet {
            if let percentage = cornerPercentage {
                self.adjustCornerRadius(forPercentage: percentage)
            } else {
                if cornerRadius == 0 || cornerRadius == nil {
                    self.contentView.layer.masksToBounds = false
                    self.contentView.layer.cornerRadius = 0
                }
            }
        }
    }
    
    func position () -> CGPoint {
        return self.convert(self.center, to: nil)
    }
    
    func size () -> CGSize {
        return self.frame.size
    }
    
    private var savedContentViewBackgroundColor : UIColor?
    
    var backgroundMaterial : UIBlurEffect? {
        
        didSet {
            backgroundView.effect = backgroundMaterial
            if let material = backgroundMaterial {
                if let bgColor = contentView.backgroundColor {
                    savedContentViewBackgroundColor = bgColor
                } else {
                    savedContentViewBackgroundColor = nil
                }
                contentView.backgroundColor = .clear
                backgroundVibrancyView.effect = UIVibrancyEffect(blurEffect: material)
            } else {
                contentView.backgroundColor = savedContentViewBackgroundColor
            }
        }
        
    }
    
    init () {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .clear
        
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.everythingEqualToSuperView()
        }
        
        contentView.addSubview(backgroundView)
        backgroundView.backgroundColor = .clear
        backgroundView.snp.makeConstraints { make in
            make.everythingEqualToSuperView()
        }
        
        backgroundView.contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.contentView.snp.makeConstraints { make in
            make.everythingEqualToSuperView()
        }
        
        backgroundView.contentView.addSubview(backgroundVibrancyView)
        backgroundVibrancyView.snp.makeConstraints { make in
            make.everythingEqualToSuperView()
        }
        
        backgroundVibrancyView.contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundVibrancyView.contentView.snp.makeConstraints { make in
            make.everythingEqualToSuperView()
        }
    }
    
    private func adjustCornerRadius (forPercentage percentage : Float?) {
        if let p = percentage {
            if p == 1 {
                self.contentView.layer.masksToBounds = true
                self.contentView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
            } else {
                self.contentView.layer.masksToBounds = true
                self.contentView.layer.cornerRadius = min(bounds.width, bounds.height) * (CGFloat(p)/2)
            }
        } else {
            self.contentView.layer.masksToBounds = false
            self.contentView.layer.cornerRadius = 0
        }
    }

    
    private func adjustCornerRadius (forRadius radius : Float?) {
        if let r = radius {
            if r == Float.infinity {
                self.contentView.layer.masksToBounds = true
                self.contentView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
            } else {
                self.contentView.layer.masksToBounds = true
                self.contentView.layer.cornerRadius = CGFloat(r)
            }
        } else {
            self.contentView.layer.masksToBounds = false
            self.contentView.layer.cornerRadius = 0
        }
    }
    
    func configureShadow (withColor color: UIColor, radius : CGFloat, andOpacity opacity: Float) {
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let r = cornerRadius {
            self.adjustCornerRadius(forRadius: r)
        }
        
        if let p = cornerPercentage {
            self.adjustCornerRadius(forPercentage: p)
        }
    }
}

extension Float {
    var degreesToRadians: Float { return self * .pi / 180 }
    var radiansToDegrees: Float { return self * 180 / .pi }
}
