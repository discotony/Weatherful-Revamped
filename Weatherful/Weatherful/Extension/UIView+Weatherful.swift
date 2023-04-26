//
//  UIView+Weatherful.swift
//  Weatherful
//
//  Created by Antony Bluemel on 4/22/23.
//

import UIKit

extension UIView {
    
    // MARK: - Rounded Corners
    func circularize() {
        self.layer.cornerRadius = self.frame.width / 2.0
        self.clipsToBounds = true
    }

    func uncircularize() {
        self.layer.cornerRadius = 0
    }

    func roundCorners(cornerRadius: CGFloat = 25.0) {
        self.layer.cornerRadius = cornerRadius
    }

    // MARK: - Shadow Effect
    func applyShadow(width: CGFloat = 0, height: CGFloat = 3.0) {
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.weatherfulLightGrey.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.3
    }

    func applyDarkShadow(width: CGFloat = 0, height: CGFloat = 3.0) {
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.weatherfulDarkGrey.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.3
    }
    
    // MARK: - Blur Effect
    func applyBlurEffect() {
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
//        self.insertSubview(blurEffectView, at: 0)
        self.addSubview(blurEffectView)
    }

    // MARK: - Animation
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 2, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 2, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    func showBlurLoader() {
        let blurLoader = BlurLoader(frame: frame)
        self.addSubview(blurLoader)
    }

    func removeBluerLoader() {
        if let blurLoader = subviews.first(where: { $0 is BlurLoader }) {
            blurLoader.removeFromSuperview()
        }
    }
}

// MARK: - Custom UIView
class ExpandableView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}


class BlurLoader: UIView {

    var blurEffectView: UIVisualEffectView?

    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView = blurEffectView
        super.init(frame: frame)
        addSubview(blurEffectView)
        addLoader()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLoader() {
        guard let blurEffectView = blurEffectView else { return }
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .weatherfulWhite
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        activityIndicator.startAnimating()
    }
}
