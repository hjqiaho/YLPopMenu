//
//  PopMenuAction.swift
//  PopMenu
//
//  Created by Cali Castle  on 4/13/18.
//  Copyright © 2018 PopMenu. All rights reserved.
//

import UIKit

/// Customize your own action and conform to `PopMenuAction` protocol.
@objc public protocol PopMenuAction: NSObjectProtocol {
    
    /// Title of the action.
    @objc var title: String? { get }
    
    /// Image of the action.
    @objc var image: UIImage? { get }
    
    /// Container view of the action.
    @objc var view: UIView { get }
    
    /// The initial color of the action.
    @objc var color: Color? { get }
    
    /// The handler of action.
    @objc var didSelect: PopMenuActionHandler? { get }
    
    /// The handler of action. after viewcontroller dismiss
    @objc var didSelectAfterDismiss: PopMenuActionHandler? { get }
    
    /// Left padding when texts-only.
    @objc static var textLeftPadding: CGFloat { get }
    
    /// Icon left padding when icons are present.
    @objc static var iconLeftPadding: CGFloat { get }
    
    /// Icon sizing.
    @objc var iconWidthHeight: CGFloat { get set }
    
    /// The color to set for both label and icon.
    @objc var tintColor: UIColor { get set }
    
    /// The font for label.
    @objc var font: UIFont { get set }
    
    /// The corner radius of action view.
    @objc var cornerRadius: CGFloat { get set }
    
    /// Is the view highlighted by gesture.
    @objc var highlighted: Bool { get set }
    
    /// Render the view for action.
    @objc func renderActionView()

    /// Called when the action gets selected.
    @objc optional func actionSelected(animated: Bool)
    
    /// Called when the action gets selected. after viewcontroller dismiss
    @objc optional func actionSelectedAfterDismiss(animated: Bool)

    /// Type alias for selection handler.
    typealias PopMenuActionHandler = (PopMenuAction) -> Void
    
}

/// The default PopMenu action class.
@objc public class PopMenuDefaultAction: NSObject, PopMenuAction {
    
    /// Title of action.
    @objc public let title: String?
    
    /// Icon of action.
    @objc public let image: UIImage?
    
    /// Image rendering option.
    @objc public var imageRenderingMode: UIImage.RenderingMode = .alwaysTemplate
    
    /// Renderred view of action.
    @objc public let view: UIView
    
    /// Color of action.
    @objc public let color: Color?
    
    /// Handler of action when selected.
    @objc public let didSelect: PopMenuActionHandler?
    
    /// Handler of action when selected. after viewcontroller dissmis
    @objc public let didSelectAfterDismiss: PopMenuActionHandler?

    /// Icon sizing.
    @objc public var iconWidthHeight: CGFloat = 27
    
    // MARK: - Computed Properties
    
    /// Text color of the label.
    @objc public var tintColor: Color {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
            iconImageView.tintColor = newValue
            backgroundColor = newValue.blackOrWhiteContrastingColor()
        }
    }
    
    /// Font for the label.
    @objc public var font: UIFont {
        get {
            return titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }
    
    /// Rounded corner radius for action view.
    @objc public var cornerRadius: CGFloat {
        get {
            return view.layer.cornerRadius
        }
        set {
            view.layer.cornerRadius = newValue
        }
    }
    
    /// Inidcates if the action is being highlighted.
    @objc public var highlighted: Bool = false {
        didSet {
            guard highlighted != oldValue else { return }
            
            highlightActionView(highlighted)
        }
    }
    
    /// Background color for highlighted state.
    @objc private var backgroundColor: Color = .white

    // MARK: - Subviews
    
    /// Title label view instance.
    @objc private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.text = title
        
        return label
    }()
    
    /// Icon image view instance.
    @objc private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image?.withRenderingMode(imageRenderingMode)
        
        return imageView
    }()
    
    // MARK: - Constants
    
    @objc public static let textLeftPadding: CGFloat = 25
    @objc public static let iconLeftPadding: CGFloat = 18
    
    // MARK: - Initializer
    
    /// Initializer.
    @objc public init(title: String? = nil, image: UIImage? = nil, color: Color? = nil,didSelect: PopMenuActionHandler? = nil,didSelectAfterDismiss: PopMenuActionHandler? = nil) {
        self.title = title
        self.image = image
        self.color = color
        self.didSelect = didSelect
        self.didSelectAfterDismiss = didSelectAfterDismiss
        
        view = UIView()
    }
    
    /// Setup necessary views.
    fileprivate func configureViews() {
        var hasImage = false

        if let _ = image {
            hasImage = true
            view.addSubview(iconImageView)
            
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: iconWidthHeight),
                iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
                iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PopMenuDefaultAction.iconLeftPadding),
                iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: hasImage ? iconImageView.trailingAnchor : view.leadingAnchor, constant: hasImage ? 8 : PopMenuDefaultAction.textLeftPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    /// Load and configure the action view.
    @objc public func renderActionView() {
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        
        configureViews()
    }
    
    /// Highlight the view when panned on top,
    /// unhighlight the view when pan gesture left.
    @objc public func highlightActionView(_ highlight: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.26, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 9, options: self.highlighted ? UIView.AnimationOptions.curveEaseIn : UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.transform = self.highlighted ? CGAffineTransform.identity.scaledBy(x: 1.09, y: 1.09) : .identity
                self.view.backgroundColor = self.highlighted ? self.backgroundColor.withAlphaComponent(0.25) : .clear
            }, completion: nil)
        }
    }
    
    /// When the action is selected.
    @objc public func actionSelected(animated: Bool) {
        // Trigger handler.
        didSelect?(self)
        
        // Animate selection
        guard animated else { return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.175, animations: {
                self.view.transform = CGAffineTransform.identity.scaledBy(x: 0.915, y: 0.915)
                self.view.backgroundColor = self.backgroundColor.withAlphaComponent(0.18)
            }, completion: { _ in
                UIView.animate(withDuration: 0.175, animations: {
                    self.view.transform = .identity
                    self.view.backgroundColor = .clear
                })
            })
        }
    }
    /// When the action is selected.AfterDismiss
    @objc public func actionSelectedAfterDismiss(animated: Bool) {
        // Trigger handler.
        didSelectAfterDismiss?(self)
        
        // Animate selection
        guard animated else { return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.175, animations: {
                self.view.transform = CGAffineTransform.identity.scaledBy(x: 0.915, y: 0.915)
                self.view.backgroundColor = self.backgroundColor.withAlphaComponent(0.18)
            }, completion: { _ in
                UIView.animate(withDuration: 0.175, animations: {
                    self.view.transform = .identity
                    self.view.backgroundColor = .clear
                })
            })
        }
    }
}
