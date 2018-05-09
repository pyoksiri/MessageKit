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
    open lazy var imageView: UIImageView = {
        let assetBundle = Bundle.messageKitAssetBundle()
        let imageView = UIImageView.init(image: UIImage.init(contentsOfFile: assetBundle.path(forResource: "waves", ofType: "png", inDirectory: "Images")!))
        return imageView
    }()
    
    open lazy var label: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    open lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.stopAnimating()
        return loadingIndicator
    }()
    
    open lazy var playButton: UIButton = {
        let playButton = UIButton()
        let assetBundle = Bundle.messageKitAssetBundle()
        playButton.setImage(UIImage.init(contentsOfFile: assetBundle.path(forResource: "ic_play", ofType: "png", inDirectory: "Images")!), for: .normal)
        playButton.setImage(UIImage.init(contentsOfFile: assetBundle.path(forResource: "ic_pause", ofType: "png", inDirectory: "Images")!), for: .selected)
        return playButton
    }()
    
    open var messageId: String! {
        didSet {
            NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAudioMessage(notification:)), name: NSNotification.Name(rawValue: kDidUpdateAudioMessageNotification.rawValue + messageId), object: nil)
        }
    }
    
    var baseURL: URL!
    // MARK: - Methods
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        if let messageId = messageId {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kDidUpdateAudioMessageNotification.rawValue + messageId), object: nil)
        }
    }
    
    open func setupConstraints() {
        playButton.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10.0, bottomConstant: 0, rightConstant: 0, widthConstant: 24.0, heightConstant: 24.0)
        loadingIndicator.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10.0, bottomConstant: 0, rightConstant: 0, widthConstant: 24.0, heightConstant: 24.0)
        imageView.addConstraints(messageContainerView.topAnchor, left: playButton.rightAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 8.0, bottomConstant: 0, rightConstant: 0, widthConstant: 102.0, heightConstant: 13.0)
        label.addConstraints(messageContainerView.topAnchor, left: imageView.rightAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 8.0, bottomConstant: 0, rightConstant: 0, widthConstant: 40.0, heightConstant: 20.0)
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(playButton)
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(label)
        messageContainerView.addSubview(loadingIndicator)
        setupConstraints()
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        switch message.data {
        case .audio(let url):
            self.messageId = message.messageId
            self.baseURL = url
        default: break
        }
    }
    
    @objc func didUpdateAudioMessage(notification: Notification) {
        if notification.object is String {
            let audioStatus = notification.object as? String
            DispatchQueue.main.async {
                switch audioStatus {
                case "play":
                    self.playButton.isSelected = true
                    self.loadingIndicator.stopAnimating()
                    break
                case "pause":
                    self.playButton.isSelected = false
                    self.loadingIndicator.stopAnimating()
                    break
                case "loading":
                    self.loadingIndicator.startAnimating()
                    break
                case "failed":
                    self.loadingIndicator.stopAnimating()
                    self.playButton.isSelected = false
                    break
                case "stop":
                    self.loadingIndicator.stopAnimating()
                    self.playButton.isSelected = false
                    break
                default: break
                }
            }
        }
    }
    
    public func playAction() {
        AudioManager.shared.start(with: baseURL, label: label, messageId: messageId)
        playButton.isSelected = !playButton.isSelected
    }

}
