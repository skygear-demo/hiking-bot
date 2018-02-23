//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "UIView+JSQMessages.h"

@implementation UIView (JSQMessages)

- (NSLayoutConstraint *)jsq_pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:subview
                                                                  attribute:attribute
                                                                 multiplier:1.0f
                                                                   constant:0.0f];
    [self addConstraint:constraint];

    return constraint;
}

- (void)jsq_pinAllEdgesOfSubview:(UIView *)subview
{
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeBottom];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTop];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeLeading];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTrailing];
}

@end
