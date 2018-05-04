//
//  SystemMessageCell.swift
//  MessageKit
//
//  Created by Phanuwat Yoksiri on 4/5/2561 BE.
//  Copyright © 2561 MessageKit. All rights reserved.
//

import UIKit

open class SystemMessageCell: MessageCollectionViewCell {
    
    open override class func reuseIdentifier() -> String { return "messagekit.cell.system" }
    
    // MARK: - Properties
    
    open var messageLabel = UILabel()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        messageLabel.textAlignment = .center
        messageContainerView.addSubview(messageLabel)
        messageLabel.centerInSuperview()
        messageLabel.constraint(equalTo: CGSize(width: 200, height: 24))
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
        switch message.data {
        case .system(let text):
            messageLabel.text = text
        default:
            break
        }
        // Needs to be set after the attributedText because it takes precedence
        messageLabel.textColor = textColor
    }
}
