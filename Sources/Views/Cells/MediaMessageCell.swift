/*
 MIT License

 Copyright (c) 2017-2018 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class MediaMessageCell: MessageCollectionViewCell {

    open override class func reuseIdentifier() -> String { return "messagekit.cell.mediamessage" }

    // MARK: - Properties

    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        return playButtonView
    }()

    open override func prepareForReuse() {
        super.prepareForReuse()
        if let message = message {
            switch message.data {
            case .photo(_), .networkPhoto(_):
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kDidUpdatePhotoMessageNotification.rawValue + message.messageId), object: nil)
            case .video(_, _):
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kDidUpdateVideoMessageNotification.rawValue + message.messageId), object: nil)
            default:
                break
            }
        }
    }
    
    open lazy var progressView: UICircularProgressRingView = {
        let progressView = UICircularProgressRingView()
        progressView.fontColor = UIColor.white
        progressView.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        progressView.innerRingColor = UIColor.white
        progressView.innerRingWidth = 2.0
        progressView.outerRingColor = UIColor.lightGray.withAlphaComponent(0.25)
        progressView.outerRingWidth = 1.0
        return progressView
    }()
    
    open lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.25
        return overlayView
    }()
    
    open var imageView = UIImageView()
    
    open var message: MessageType! {
        didSet {
            switch message.data {
            case .photo(_), .networkPhoto(_):
                NotificationCenter.default.addObserver(self, selector: #selector(didUpdatePhotoMessage(notification:)), name: NSNotification.Name(rawValue: kDidUpdatePhotoMessageNotification.rawValue + message.messageId), object: nil)
            case .video(_, _):
                NotificationCenter.default.addObserver(self, selector: #selector(didUpdateVideoMessage(notification:)), name: NSNotification.Name(rawValue: kDidUpdateVideoMessageNotification.rawValue + message.messageId), object: nil)
            default:
                break
            }
        }
    }
    
    open func setupConstraints() {
        imageView.fillSuperview()
        playButtonView.centerInSuperview()
        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
        progressView.centerInSuperview()
        progressView.constraint(equalTo: CGSize(width: 40, height: 40))
        overlayView.fillSuperview()
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(overlayView)
        messageContainerView.addSubview(playButtonView)
        messageContainerView.addSubview(progressView)
        self.playButtonView.isHidden = true
        self.progressView.isHidden = true
        self.overlayView.isHidden = true
        setupConstraints()
    }

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        DispatchQueue.main.async {
            self.message = message
            switch message.data {
            case .photo(let image):
                self.imageView.image = image
                self.overlayView.isHidden = false
                self.playButtonView.isHidden = true
                self.progressView.isHidden = false
            case .video(_, _):
                self.overlayView.isHidden = false
                self.playButtonView.isHidden = false
                self.progressView.isHidden = true
            case .networkPhoto(_):
                self.overlayView.isHidden = true
                self.playButtonView.isHidden = true
                self.progressView.isHidden = true
            default:
                break
            }
        }
    }
    
    @objc func didUpdatePhotoMessage(notification: Notification) {
        if let progress = notification.object as? Progress {
            let progressValue = (Double(progress.completedUnitCount) / Double(progress.totalUnitCount)) * 100.0
            progressView.setProgress(to: CGFloat(progressValue), duration: 0.25)
        }
    }
    
    @objc func didUpdateVideoMessage(notification: Notification) {
        if let progress = notification.object as? Progress {
            let progressValue = (Double(progress.completedUnitCount) / Double(progress.totalUnitCount)) * 100.0
            progressView.setProgress(to: CGFloat(progressValue), duration: 0.25)
            if progressValue < 100.0 {
                self.progressView.isHidden = false
                self.playButtonView.isHidden = true
            } else {
                self.progressView.isHidden = true
                self.playButtonView.isHidden = false
            }
        }
    }
}
