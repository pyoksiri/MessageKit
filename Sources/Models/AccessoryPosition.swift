//
//  AccessoryPosition.swift
//  MessageKit
//
//  Created by Phanuwat Yoksiri on 4/5/2561 BE.
//  Copyright © 2561 MessageKit. All rights reserved.
//

import Foundation

/// Used to determine the `Horizontal` and `Vertical` position of
// an `AvatarView` in a `MessageCollectionViewCell`.
public struct AccessoryPosition {
    
    /// An enum representing the horizontal alignment of an `AvatarView`.
    public enum Horizontal {
        
        /// Positions the `AvatarView` on the side closest to the cell's leading edge.
        case cellLeading
        
        /// Positions the `AvatarView` on the side closest to the cell's trailing edge.
        case cellTrailing
        
        /// Positions the `AvatarView` based on whether the message is from the current Sender.
        /// The cell is positioned `.cellTrailling` if `isFromCurrentSender` is true
        /// and `.cellLeading` if false.
        case natural
    }
    
    /// An enum representing the verical alignment for an `AvatarView`.
    public enum Vertical {
        
        /// Aligns the `AvatarView`'s top edge to the cell's top edge.
        case cellTop
        
        /// Aligns the `AvatarView`'s bottom edge to the cell's bottom edge.
        case cellBottom
        
        /// Aligns the `AvatarView`'s top edge to the `MessageContainerView`'s top edge.
        case messageTop
        
        /// Aligns the `AvatarView`'s bottom edge to the `MessageContainerView`s bottom edge.
        case messageBottom
        
        /// Aligns the `AvatarView` center to the `MessageContainerView` center.
        case messageCenter
    }
    
    // MARK: - Properties
    
    // The vertical position
    public var vertical: Vertical
    
    // The horizontal position
    public var horizontal: Horizontal
    
    // MARK: - Initializers
    
    public init(horizontal: Horizontal, vertical: Vertical) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    public init(vertical: Vertical) {
        self.init(horizontal: .natural, vertical: vertical)
    }
    
}
