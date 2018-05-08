//
//  StickerMessageCell.swift
//  MessageKit
//
//  Created by Phanuwat Yoksiri on 4/5/2561 BE.
//

import UIKit

let kStickerPath = kLibraryPath.appending("Stickers")

open class StickerMessageCell: MessageCollectionViewCell {
    
    open override class func reuseIdentifier() -> String { return "messagekit.cell.sticker" }
    
    // MARK: - Properties
    open var imageView = UIImageView()
    // MARK: - Methods
    
    open func setupConstraints() {
        imageView.fillSuperview()
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(imageView)
        setupConstraints()
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        switch message.data {
        case .sticker(let image):
            imageView.image = UIImage.init(contentsOfFile: kStickerPath.appending("/\(image)"))
        default:
            break
        }
    }
}
