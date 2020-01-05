//
//  PQLabel.swift
//  PQLabel
//
//  Created by harry on 3/1/20.
//

import UIKit

@IBDesignable
open class PQLabel: UILabel {

    // MARK: Private members
    internal lazy var textStorage = NSTextStorage()
    fileprivate lazy var layoutManager = NSLayoutManager()
    fileprivate lazy var textContainer = NSTextContainer()
    var up: Bool = false
    var unchanged: Bool = true
    var prevPrice = Double.nan

    let preBlink = 0.15
    let inBlink = 0.2
    let postBlink = 0.15

    // MARK: Inits
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    // MARK: Properties
    @IBInspectable open var lowerPriceColor: UIColor = UIColor.red
    
    @IBInspectable open var higherPriceColor: UIColor = UIColor.green
    
    @IBInspectable open var onlyFlashFractional: Bool = true
    
    @IBInspectable open var fractionalFontFactor: CGFloat = 0.8
    
    @IBInspectable open var floatFormatter: String = "%.2f"
    
    open var price: Double = Double.nan {
        willSet(newVal) {
            unchanged = (newVal == self.price)
            up = newVal > self.price
        }
        didSet {
            didSetPrice()
        }
    }
    
    // MARK: Private functions
    fileprivate func setupLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
    }
    
    fileprivate func didSetPrice() {
        let newString = String(format: self.floatFormatter, self.price)
        self.text = newString
        updateTextStorage(true && (!unchanged))
        self.layer.animateFade(duration: self.preBlink)
        DispatchQueue.main.asyncAfter(deadline: .now() + inBlink) { [unowned self] in
            self.updateTextStorage(false)
            self.layer.animateFade(duration: self.postBlink)
            self.unchanged = true
        }
    }
    
    fileprivate func processDecimal(_ input: NSAttributedString, changeColor: Bool) -> NSAttributedString {
        let mutAttrString = NSMutableAttributedString(attributedString: input)
        if let i = mutAttrString.string.range(of: ".") {
            let nsr = NSRange(i, in: mutAttrString.string)
            let fractionalRange = NSMakeRange(nsr.location+1, mutAttrString.string.count - nsr.location-1)
            let wholeRange = NSMakeRange(0, mutAttrString.string.count)
            if self.fractionalFontFactor < 1.0,
                let nf = UIFont(name: self.font.fontName, size: self.font.pointSize * self.fractionalFontFactor) {
                mutAttrString.addAttribute(.font, value: nf, range: fractionalRange)
            }
            if changeColor {
                mutAttrString.addAttribute(.foregroundColor, value: up ? self.higherPriceColor : self.lowerPriceColor, range: self.onlyFlashFractional ? fractionalRange : wholeRange)
            }
        }
        return mutAttrString
    }

    fileprivate func updateTextStorage(_ changeColor: Bool = true) {
        guard let attributedText = attributedText, attributedText.length > 0 else {
            textStorage.setAttributedString(NSAttributedString())
            setNeedsDisplay()
            return
        }
        let mutAttrString = processDecimal(attributedText, changeColor: changeColor)
        textStorage.setAttributedString(mutAttrString)
        setNeedsDisplay()
    }
    
    open override func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)

        textContainer.size = rect.size

        layoutManager.drawBackground(forGlyphRange: range, at: rect.origin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: rect.origin)
    }
}

extension CALayer {

    func animateFade(duration: CFTimeInterval) {
        let animation = CATransition()
        animation.beginTime = CACurrentMediaTime()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = duration
        animation.type = CATransitionType.fade
        self.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
