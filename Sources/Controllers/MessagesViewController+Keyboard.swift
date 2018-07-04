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

import Foundation

extension MessagesViewController {

    // MARK: - Register / Unregister Observers

    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.keypadWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.keypadWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.keypadDidHide), name: .UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.handleKeyboardDidChangeState(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.handleTextViewDidBeginEditing(_:)), name: .UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.adjustScrollViewInset), name: .UIDeviceOrientationDidChange, object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }

    // MARK: - Notification Handlers

    @objc
    private func handleTextViewDidBeginEditing(_ notification: Notification) {
        if scrollsToBottomOnKeybordBeginsEditing {
            guard let inputTextView = notification.object as? InputTextView, inputTextView === messageInputBar.inputTextView else { return }
            messagesCollectionView.scrollToBottom(animated: true)
        }
    }

    @objc
    private func handleKeyboardDidChangeState(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        if (keyboardEndFrame.origin.y + keyboardEndFrame.size.height) > UIScreen.main.bounds.height {
            // Hardware keyboard is found
            if view.frame.size.height - keyboardEndFrame.origin.y == 0 {
            } else {
                let afterBottomInset = keyboardEndFrame.height > keyboardOffsetFrame.height ? (keyboardEndFrame.height - iPhoneXBottomInset) : keyboardOffsetFrame.height
                let differenceOfBottomInset = afterBottomInset - beforeCollectionViewBottomInset
                let contentOffset = CGPoint(x: messagesCollectionView.contentOffset.x, y: messagesCollectionView.contentOffset.y + differenceOfBottomInset)
                messagesCollectionView.setContentOffset(contentOffset, animated: false)
            }
        } else {
            //Software keyboard is found
            let afterBottomInset = keyboardEndFrame.height > keyboardOffsetFrame.height ? (keyboardEndFrame.height - iPhoneXBottomInset) : keyboardOffsetFrame.height
            let differenceOfBottomInset = afterBottomInset - beforeCollectionViewBottomInset
            if maintainPositionOnKeyboardFrameChanged && differenceOfBottomInset != 0 {
                let contentOffset = CGPoint(x: messagesCollectionView.contentOffset.x, y: messagesCollectionView.contentOffset.y + differenceOfBottomInset)
                messagesCollectionView.setContentOffset(contentOffset, animated: false)
            }
            beforeCollectionViewBottomInset = afterBottomInset
        }
        
        if self.isListeningKeypadChange {
            self.maxKeypadHeight = keyboardEndFrame.height
            var options = UIViewAnimationOptions.beginFromCurrentState
            if let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
                options = options.union(UIViewAnimationOptions(rawValue: animationCurve))
            }
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration ?? 0, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc
    func adjustScrollViewInset() {
        if #available(iOS 11.0, *) {
            // No need to add to the top contentInset
        } else {
            let navigationBarInset = navigationController?.navigationBar.frame.height ?? 0
            let statusBarInset: CGFloat = UIApplication.shared.isStatusBarHidden ? 0 : 20
            let topInset = navigationBarInset + statusBarInset
            messagesCollectionView.contentInset.top = topInset
            messagesCollectionView.scrollIndicatorInsets.top = topInset
        }
    }

    // MARK: - Helpers

    var keyboardOffsetFrame: CGRect {
        guard let inputFrame = inputAccessoryView?.frame else {
            return .zero
        }
        return CGRect(origin: inputFrame.origin, size: CGSize(width: inputFrame.width, height: inputFrame.height - iPhoneXBottomInset))
    }

    /// On the iPhone X the inputAccessoryView is anchored to the layoutMarginesGuide.bottom anchor
    /// so the frame of the inputAccessoryView is larger than the required offset
    /// for the MessagesCollectionView.
    ///
    /// - Returns: The safeAreaInsets.bottom if its an iPhoneX, else 0
    private var iPhoneXBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            guard UIScreen.main.nativeBounds.height == 2436 else { return 0 }
            return view.safeAreaInsets.bottom
        }
        return 0
    }
}

extension MessagesViewController: UIGestureRecognizerDelegate {
    @objc func keypadWillShow(_ notification: Notification) {
        guard !self.isListeningKeypadChange, let userInfo = notification.userInfo as? [String : Any],
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
            let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            else {
                return
        }
        self.maxKeypadHeight = value.cgRectValue.height
        let options = UIViewAnimationOptions.beginFromCurrentState.union(UIViewAnimationOptions(rawValue: animationCurve))
        UIView.animate(withDuration: animationDuration, delay: 0, options: options, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            }, completion: { finished in
                guard finished else { return }
                // Some delay of about 500MS, before ready to listen other keypad events
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.beginListeningKeypadChange()
                }
        })
    }
    
    @objc func keypadWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : Any] else { return }
        
        self.maxKeypadHeight = 0
        
        var options = UIViewAnimationOptions.beginFromCurrentState
        if let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            options = options.union(UIViewAnimationOptions(rawValue: animationCurve))
        }
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
        UIView.animate(withDuration: duration ?? 0, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keypadDidHide() {
        self.messagesCollectionView.panGestureRecognizer.removeTarget(self, action: nil)
        self.isListeningKeypadChange = false
        self.maxKeypadHeight = 0
        beforeCollectionViewBottomInset = 0
    }
    
    private func beginListeningKeypadChange() {
        self.isListeningKeypadChange = true
        self.messagesCollectionView.panGestureRecognizer.addTarget(self, action: #selector(self.handlePanGestureRecognizer(_:)))
    }
    
    func updateCollectionViewInsets(_ value: CGFloat) {
        if iPhoneXBottomInset > 0 {
            if maxKeypadHeight > iPhoneXBottomInset {
                let newValue = maxKeypadHeight - iPhoneXBottomInset
                bottomInset.constant = -newValue
                messageCollectionViewBottomInset = value - iPhoneXBottomInset
                return
            }
        }
        messageCollectionViewBottomInset = maxKeypadHeight + messageBarHeight
        self.bottomInset.constant = -maxKeypadHeight
    }
    
    @objc func handlePanGestureRecognizer(_ pan: UIPanGestureRecognizer) {
        guard self.isListeningKeypadChange, let windowHeight = self.view.window?.frame.height else { return }
        let barHeight = self.messageInputBar.frame.height
        let keypadHeight = abs(self.bottomInset.constant)
        let usedHeight = keypadHeight + barHeight
        let dragY = windowHeight - pan.location(in: self.view.window).y
        let newValue = min(dragY < usedHeight ? max(dragY, 0) : dragY, self.maxKeypadHeight - iPhoneXBottomInset)
        guard keypadHeight != newValue else { return }
        self.updateCollectionViewInsets(newValue)
        self.bottomInset.constant = -newValue
    }
}
