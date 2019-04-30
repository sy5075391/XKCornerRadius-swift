//
//  radiusExtention.swift
//  XKCornerRadius-swift
//
//  Created by Jamesholy on 2019/4/29.
//Copyright © 2019 Jamesholy. All rights reserved.
//

import UIKit


public struct XKCornerClipType : OptionSet {
    
    public let rawValue: UInt
    public static var none = XKCornerClipType(rawValue: 1 << 0)
    public static var topLeft =  XKCornerClipType(rawValue: 1 << 1)
    public static var topRight = XKCornerClipType(rawValue: 1 << 2)
    public static var bottomLeft = XKCornerClipType(rawValue: 1 << 3)
    public static var bottomRight = XKCornerClipType(rawValue: 1 << 4)
    public static var allCorners = XKCornerClipType(rawValue: 1 << 5)

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

extension UIView {
    
    //MARK: 视图是否开启圆角裁剪
    public var xk_openClip: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.xk_openClip) as? Bool ?? false
        }
        set {
            UIView.allowClipTool
            objc_setAssociatedObject(self, &AssociatedKeys.xk_openClip, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //MARK: 圆角大小
    public var xk_radius: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.xk_radius) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.xk_radius, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //MARK: 圆角类型
    public var xk_clipType: XKCornerClipType {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.xk_clipType) as? XKCornerClipType ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.xk_clipType, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //MARK: 此分类重写view的layoutsubviews，进行切割圆角
    /*当视图显示出来后，如果视图frame没有变化或者没有添加子视图等，不触发layoutsubviews方法，
    所以后续再进行的圆角设置会不起作用（复用cell除外，复用时会再次调用layoutsubviews），
    此时为了圆角生效可调用forceClip*/
    public func xk_forceClip() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private struct AssociatedKeys {
        static var xk_openClip: Void?
        static var xk_radius: Void?
        static var xk_clipType: Void?
        static var xk_shapeLayer: Void?
        
    }

    private var maskLayer: CAShapeLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.xk_shapeLayer) as? CAShapeLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.xk_shapeLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func sy_layoutSubviews() {
        self.sy_layoutSubviews()
        if self.xk_openClip {
            if self.xk_clipType.contains(.none) {
                self.layer.mask = nil
            } else {
                let rectCorner = self.getRectCorner()
                if (self.maskLayer == nil) {
                    self.maskLayer = CAShapeLayer.init()
                }
                var maskPath:UIBezierPath
                maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize.init(width: self.xk_radius, height: self.xk_radius))
                self.maskLayer?.frame = self.bounds
                self.maskLayer?.path = maskPath.cgPath
                self.layer.mask = self.maskLayer
            }
        }
    }
    
    func getRectCorner() -> UIRectCorner {
        var rectCorner:UIRectCorner = []
        if self.xk_clipType.contains(.topLeft) {
            rectCorner.insert(.topLeft)
        }
        if self.xk_clipType.contains(.topRight) {
            rectCorner.insert(.topRight)
        }
        if self.xk_clipType.contains(.bottomLeft) {
            rectCorner.insert(.bottomLeft)
        }
        if self.xk_clipType.contains(.bottomRight) {
            rectCorner.insert(.bottomRight)
        }
        if self.xk_clipType.contains(.allCorners)   {
            rectCorner = .allCorners
        }
        return rectCorner
    }
    
    //MARK: 允许工具使用
    private static let allowClipTool:() = {
        UIView.xk_swizzleMethod(UIView.self, originalSelector: #selector(UIView.layoutSubviews), swizzleSelector: #selector(UIView.sy_layoutSubviews))
    }()

}



extension NSObject {
    
    static func xk_swizzleMethod(_ cls: AnyClass, originalSelector: Selector, swizzleSelector: Selector){
        
        let originalMethod = class_getInstanceMethod(cls, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(cls, swizzleSelector)!
        let didAddMethod = class_addMethod(cls,
                                           originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(cls,
                                swizzleSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
