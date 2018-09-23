import UIKit

class ALScrollImageViewController: UIViewController {
	private let scrollView = UIScrollView()
	private let activityIndicatorView = UIActivityIndicatorView()
	fileprivate let imageView = UIImageView()
	
	var image: UIImage? {
		return self.imageView.image
	}
	
	init(url: URL) {
		super.init(nibName: nil, bundle: nil)
		
		self.scrollView.run {
			$0.delegate = self
			$0.minimumZoomScale = 1.0
			$0.maximumZoomScale = 2.0
			$0.isScrollEnabled = true
			$0.isUserInteractionEnabled = true
			
			let tapGestureSingle = UITapGestureRecognizer(target: self, action:#selector(tapSingle(_:))).apply {
				$0.numberOfTapsRequired = 1
			}
			let tapGestureDouble = UITapGestureRecognizer(target: self, action:#selector(tapDouble(_:))).apply {
				$0.numberOfTapsRequired = 2
			}
			
			$0.addGestureRecognizer(tapGestureSingle)
			$0.addGestureRecognizer(tapGestureDouble)
			
			$0.addSubview(self.imageView)
		}
		self.activityIndicatorView.run {
			$0.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
			$0.center = self.view.center
			$0.hidesWhenStopped = true
			$0.activityIndicatorViewStyle = .white
			$0.startAnimating()
		}
		
		self.view.addSubview(self.scrollView)
		self.view.addSubview(self.activityIndicatorView)
		
		self.load(url: url)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		print("PageInnerViewController:deinit")
	}
	
	override func viewDidLoad() {
		if #available(iOS 11.0, *) {
			self.scrollView.contentInsetAdjustmentBehavior = .never
		} else {
			self.automaticallyAdjustsScrollViewInsets = false
		}
		
		super.viewDidLoad()
		
		self.scrollView.run {
			$0.frame = self.view.frame
			$0.showsHorizontalScrollIndicator = true
			$0.showsVerticalScrollIndicator = true
		}
	}
	
	func load(url: URL) {
		let configuration = URLSessionConfiguration.default.apply {
			$0.requestCachePolicy = .returnCacheDataElseLoad
		}
		
		URLSession(configuration: configuration).dataTask(with: url) { data, response, error in
			DispatchQueue.main.async {
				self.activityIndicatorView.stopAnimating()
			}
			
			if let error = error {
				print("failed get data")
				print(error)
				
				return
			}
			
			guard let data = data else {
				return
			}
			
			DispatchQueue.main.async {
				self.setImage(data: data)
			}
		}.resume()
	}
	
	func setImage(data: Data) {
		guard let image = (autoreleasepool {
			return UIImage.animatedImage(withAnimatedGIFData: data)
		}) else {
			print("failed create image")
			
			return
		}
		
		self.imageView.run {
			$0.image = image
			
			let rate = min(self.scrollView.frame.width / image.size.width, self.scrollView.frame.height / image.size.height, 1)
			
			$0.frame.size = CGSize(width: image.size.width * rate, height: image.size.height * rate)
		}
		
		self.scrollView.contentSize = self.imageView.frame.size
		
		self.updateContentInset()
	}
	
	func updateContentInset() {
		let vertical = max((self.scrollView.frame.height - self.imageView.frame.height) / 2, 0)
		let horizontal = max((self.scrollView.frame.width - self.imageView.frame.width) / 2, 0)
		
		self.scrollView.contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
	}
	
	func tapSingle(_ gesture: UITapGestureRecognizer) {
		self.scrollView.setZoomScale(1.0, animated: true)
		
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		self.navigationController?.setToolbarHidden(false, animated: true)
	}
	
	func tapDouble(_ gesture: UITapGestureRecognizer) {
		if self.scrollView.zoomScale < self.scrollView.maximumZoomScale {
			let center = gesture.location(in: gesture.view)
			
			let width = self.scrollView.frame.size.width / self.scrollView.maximumZoomScale
			let height = self.scrollView.frame.size.height / self.scrollView.maximumZoomScale
			
			let rect = CGRect(x: center.x - width / 2.0, y: center.y - height / 2.0, width: width, height: height)
			
			self.scrollView.zoom(to: rect, animated: true)
			
			self.navigationController?.setNavigationBarHidden(true, animated: true)
			self.navigationController?.setToolbarHidden(true, animated: true)
		} else {
			self.scrollView.setZoomScale(1.0, animated: true)
			
			self.navigationController?.setNavigationBarHidden(false, animated: true)
			self.navigationController?.setToolbarHidden(false, animated: true)
		}
	}
}

extension ALScrollImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.imageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.updateContentInset()
	}
}
