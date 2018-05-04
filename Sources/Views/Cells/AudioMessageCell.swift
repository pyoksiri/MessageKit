//
//  AudioMessageCell.swift
//  MessageKit
//
//  Created by Phanuwat Yoksiri on 4/5/2561 BE.
//  Copyright © 2561 MessageKit. All rights reserved.
//

import UIKit

open class AudioMessageCell: MessageCollectionViewCell {
    
    open override class func reuseIdentifier() -> String { return "messagekit.cell.audiomessage" }
    
    // MARK: - Properties
    
    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        return playButtonView
    }()
    
    // MARK: - Methods
    
    open func setupConstraints() {
        playButtonView.centerInSuperview()
        playButtonView.addConstraints(nil, left: messageContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8.0, bottomConstant: 0, rightConstant: 0, widthConstant: 24.0, heightConstant: 24.0)
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(playButtonView)
        setupConstraints()
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        switch message.data {
        case .audio(_):
            playButtonView.isHidden = false
        default:
            break
        }
    }
}
