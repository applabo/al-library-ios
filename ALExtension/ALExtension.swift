import UIKit

protocol ALScope { }

extension ALScope {
	func apply(closure: (Self) -> Void) -> Self {
		closure(self)
		
		return self
	}
	
	func run(closure: (Self) -> Void) {
		closure(self)
	}
}

extension NSObject: ALScope { }

extension UIColor {
	convenience init(hex: Int, alpha: CGFloat = 1.0) {
		let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
		let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
		let b = CGFloat(hex & 0x0000FF) / 255.0
		
		self.init(red: r, green: g, blue: b, alpha: alpha)
	}
	
	convenience init(hex1: Int, hex2: Int, blend: CGFloat, alpha: CGFloat = 1.0) {
		let r1 = CGFloat((hex1 & 0xFF0000) >> 16) / 255.0
		let g1 = CGFloat((hex1 & 0x00FF00) >> 8) / 255.0
		let b1 = CGFloat(hex1 & 0x0000FF) / 255.0
		
		let r2 = CGFloat((hex2 & 0xFF0000) >> 16) / 255.0
		let g2 = CGFloat((hex2 & 0x00FF00) >> 8) / 255.0
		let b2 = CGFloat(hex2 & 0x0000FF) / 255.0
		
		let r = r1 * (1.0 - blend) + r2 * blend
		let g = g1 * (1.0 - blend) + g2 * blend 
		let b = b1 * (1.0 - blend) + b2 * blend
		
		self.init(red: r, green: g, blue: b, alpha: alpha)
	}
}

extension UIImage {
    func resize(ratio: CGFloat) -> UIImage {
        var image = self
        
		let size = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
		
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		
		image.draw(in: CGRect(origin: .zero, size: size))
		
        if let currentImageContext = UIGraphicsGetImageFromCurrentImageContext() {
            image = currentImageContext
        }
        
		UIGraphicsEndImageContext()
		
		return image
	}
	
	func change(color: UIColor) -> UIImage {
		var image = withRenderingMode(.alwaysTemplate)
		
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		
		color.set()
		
		image.draw(in: CGRect(origin: .zero, size: self.size))
		
		if let currentImageContext = UIGraphicsGetImageFromCurrentImageContext() {
			image = currentImageContext
		}
		
		UIGraphicsEndImageContext()
		
		return image
	}
}

extension UIViewController {
	@objc var heightNavigationBar: CGFloat {
		return self.navigationController?.navigationBar.frame.size.height ?? 0.0
	}
	
	@objc var heightTabBar: CGFloat {
		if #available(iOS 11.0, *) {
			return self.view.safeAreaInsets.bottom
		}
		
		return self.tabBarController?.tabBar.frame.size.height ?? 0.0
	}
	
	@objc var heightToolBar: CGFloat {
		if #available(iOS 11.0, *) {
			return self.view.safeAreaInsets.bottom
		}
		
		return self.navigationController?.toolbar.frame.size.height ?? 0.0
	}
	
	@objc var contentInsetTop: CGFloat {
		return 0.0
	}
	
	@objc var contentInsetBottom: CGFloat {
		return 0.0
	}
	
	@objc var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition? {
		get {
			return nil
		}
		
		set(value) {
		}
	}
	
	@objc var panGestureRecognizer: UIPanGestureRecognizer? {
		get {
			return nil
		}
		
		set(value) {
		}
	}
	
	@objc func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
		let percent = max(panGesture.translation(in: view).x, 0) / self.view.frame.width
		
		switch panGesture.state {
		case .began:
			self.navigationController?.delegate = self as? UINavigationControllerDelegate
			_ = self.navigationController?.popViewController(animated: true)
			
		case .changed:
			if let transition = self.percentDrivenInteractiveTransition {
				transition.update(percent)
			}
			
			self.view.layer.shadowOpacity = Float((1.0 - percent) * 0.2)
			
		case .ended:
			let velocity = panGesture.velocity(in: view).x
			
			if percent >= 0.3 || velocity > 500 {
				self.percentDrivenInteractiveTransition?.finish()
			} else {
				self.percentDrivenInteractiveTransition?.cancel()
			}
			
		case .cancelled,
			 .failed:
			self.percentDrivenInteractiveTransition?.cancel()
			
		default:
			break
		}
	}
}
