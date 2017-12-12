import UIKit
import AlamofireImage

public class ALImageArticleTableViewCellSetting : ALArticleTableViewCellSetting {
	public var paddingInfo = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
	public var paddingTitle = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
	public var radiusWebsiteImage = CGFloat(10)
	public var colorBottom = UIColor(hex: 0xa0a0a0, alpha: 1.0)
	
	public override init() {
		super.init()
		
        self.borderRadiusImage = CGFloat(4.0)
		self.paddingImage = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
		self.fontWebsite = UIFont.systemFont(ofSize: 14)
		self.fontDate = UIFont.systemFont(ofSize: 14)
		self.colorBackground = UIColor.clear
		self.colorTitle = UIColor(hex: 0x000000, alpha: 1.0)
		self.colorRead = UIColor(hex: 0x707070, alpha: 1.0)
        self.colorWebsite = UIColor(hex: 0xa0a0a0, alpha: 1.0)
        self.colorDate = UIColor(hex: 0xa0a0a0, alpha: 1.0)
		
		if let path = Bundle.main.path(forResource: "Resource/Image/Thumbnail1024x576", ofType: "png") {
			self.urlThumbnail = URL(fileURLWithPath: path)
		}
	}
}

public class ALImageArticleTableViewCell: ALArticleTableViewCell {
	public var settingImage: ALImageArticleTableViewCellSetting {
		return self.setting as! ALImageArticleTableViewCellSetting
	}
	
	private let imageViewWebsite = UIImageView()
	private let imageViewThumbnail = UIImageView()
	private let stackViewInfo = UIStackView()
	
	public init(article: ALArticle, setting: ALImageArticleTableViewCellSetting, isRead: @escaping () -> Bool) {
		super.init(article: article, setting: setting, reuseIdentifier: "ALImageArticleTableViewCell", isRead: isRead)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override public func initView() {
		self.titleLabel.font = .boldSystemFont(ofSize: 20)
		self.titleLabel.numberOfLines = 2
		self.titleLabel.textAlignment = .left
		self.titleLabel.textColor = self.setting.colorTitle
		self.titleLabel.text = article.title
		
		self.initStackView(info: self.stackViewInfo)
		
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.imageViewThumbnail)
		self.view.addSubview(self.stackViewInfo)
		
		if self.article.isRead == true {
			self.read()
		}
	}
	
	private func initStackView(info: UIStackView) {
		let labelWebsite = UILabel()
		labelWebsite.text = self.article.website
		labelWebsite.font = self.setting.fontWebsite
		labelWebsite.textAlignment = .left
		labelWebsite.textColor = self.setting.colorWebsite
		labelWebsite.setContentHuggingPriority(0, for: .horizontal)
		labelWebsite.setContentCompressionResistancePriority(0, for: .horizontal)
		
		let labelDate = UILabel()
		labelDate.text = self.article.date
		labelDate.font = self.setting.fontDate
		labelDate.textAlignment = .right
		labelDate.textColor = self.setting.colorDate
		
		info.axis = .horizontal
		info.alignment = .center
		info.distribution = .fill
		info.spacing = 4
		
		info.addArrangedSubview(self.imageViewWebsite)
		info.addArrangedSubview(labelWebsite)
		info.addArrangedSubview(labelDate)
	}
	
	override func layout() {
        let widthThumbnail = self.view.frame.width - self.setting.paddingImage.left - self.setting.paddingImage.right
		let heightThumbnail = widthThumbnail / 16 * 9
		
		self.titleLabel.frame = UIEdgeInsetsInsetRect(CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64), self.settingImage.paddingTitle)
		self.imageViewThumbnail.frame = UIEdgeInsetsInsetRect(CGRect(x: 0, y: 64, width: self.view.frame.width, height: heightThumbnail), self.setting.paddingImage)
		self.stackViewInfo.frame = UIEdgeInsetsInsetRect(CGRect(x: 0, y: 64 + heightThumbnail, width: self.view.frame.width, height: 44), self.settingImage.paddingInfo)
		
		let imagePlaceholder = UIImage()
		
		let filterWebsiteImage = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: self.settingImage.radiusWebsiteImage * 2, height: self.settingImage.radiusWebsiteImage * 2), radius: self.settingImage.radiusWebsiteImage)
		let urlWebsiteImage = URL(string: self.article.websiteImage)!
		self.imageViewWebsite.af_setImage(withURL: urlWebsiteImage, placeholderImage: imagePlaceholder, filter: filterWebsiteImage)
		
		let filterArticleImage = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: widthThumbnail, height: heightThumbnail), radius: self.settingImage.borderRadiusImage)
		var urlThumbnail = self.setting.urlThumbnail
		
		if let string = self.article.img?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: string) {
			urlThumbnail = url
		}
		
		self.imageViewThumbnail.af_setImage(withURL: urlThumbnail, placeholderImage: imagePlaceholder, filter: filterArticleImage)
		
		self.setting.height = 64 + widthThumbnail / 16 * 9 + 44
	}
}
