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
//
//  Ideas for keyboard controller taken from Daniel Amitay
//  DAKeyboardControl
//  https://github.com/danielamitay/DAKeyboardControl
//

#import "JSQMessagesKeyboardController.h"

#import "UIDevice+JSQMessages.h"


NSString * const JSQMessagesKeyboardControllerNotificationKeyboardDidChangeFrame = @"JSQMessagesKeyboardControllerNotificationKeyboardDidChangeFrame";
NSString * const JSQMessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame = @"JSQMessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame";

static void * kJSQMessagesKeyboardControllerKeyValueObservingContext = &kJSQMessagesKeyboardControllerKeyValueObservingContext;

typedef void (^JSQAnimationCompletionBlock)(BOOL finished);



@interface JSQMessagesKeyboardController ()

@property (assign, nonatomic) BOOL jsq_isObserving;

@property (strong, nonatomic) UIView *keyboardView;

@end



@implementation JSQMessagesKeyboardController

#pragma mark - Initialization

- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
                        delegate:(id<JSQMessagesKeyboardControllerDelegate>)delegate

{
    NSParameterAssert(textView != nil);
    NSParameterAssert(contextView != nil);

    self = [super init];
    if (self) {
        _textView = textView;
        _contextView = contextView;
        _delegate = delegate;
        _jsq_isObserving = NO;
    }
    return self;
}

- (void)dealloc
{
    [self jsq_removeKeyboardFrameObserver];
    [self jsq_unregisterForNotifications];
    _delegate = nil;
}

#pragma mark - Setters

- (void)setKeyboardView:(UIView *)keyboardView
{
    if (_keyboardView) {
        [self jsq_removeKeyboardFrameObserver];
    }

    _keyboardView = keyboardView;

    if (keyboardView && !_jsq_isObserving) {
        [_keyboardView addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(frame))
                           options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                           context:kJSQMessagesKeyboardControllerKeyValueObservingContext];

        _jsq_isObserving = YES;
    }
}

#pragma mark - Getters

- (BOOL)keyboardIsVisible
{
    return self.keyboardView != nil;
}

- (CGRect)currentKeyboardFrame
{
    if (!self.keyboardIsVisible) {
        return CGRectNull;
    }

    return self.keyboardView.frame;
}

#pragma mark - Keyboard controller

- (void)beginListeningForKeyboard
{
    if (self.textView.inputAccessoryView == nil) {
        self.textView.inputAccessoryView = [[UIView alloc] init];
    }

    [self jsq_registerForNotifications];
}

- (void)endListeningForKeyboard
{
    [self jsq_unregisterForNotifications];

    [self jsq_setKeyboardViewHidden:NO];
    self.keyboardView = nil;
}

#pragma mark - Notifications

- (void)jsq_registerForNotifications
{
    [self jsq_unregisterForNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveKeyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveKeyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveKeyboardDidChangeFrameNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveKeyboardDidHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)jsq_unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)jsq_didReceiveKeyboardDidShowNotification:(NSNotification *)notification
{
    UIView *keyboardViewProxy = self.textView.inputAccessoryView.superview;
    if ([UIDevice jsq_isCurrentDeviceAfteriOS9]) {
        NSPredicate *windowPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", NSClassFromString(@"UIRemoteKeyboardWindow")];
        UIWindow *keyboardWindow = [[UIApplication sharedApplication].windows filteredArrayUsingPredicate:windowPredicate].firstObject;

        for (UIView *subview in keyboardWindow.subviews) {
            for (UIView *hostview in subview.subviews) {
                if ([hostview isMemberOfClass:NSClassFromString(@"UIInputSetHostView")]) {
                    keyboardViewProxy = hostview;
                    break;
                }
            }
        }
        self.keyboardView = keyboardViewProxy;
    }

    [self jsq_setKeyboardViewHidden:NO];
    [self jsq_handleKeyboardNotification:notification completion:nil];
}

- (void)jsq_didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification
{
    [self jsq_handleKeyboardNotification:notification completion:nil];
}

- (void)jsq_didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification
{
    [self jsq_setKeyboardViewHidden:NO];

    [self jsq_handleKeyboardNotification:notification completion:nil];
}

- (void)jsq_didReceiveKeyboardDidHideNotification:(NSNotification *)notification
{
    self.keyboardView = nil;

    [self jsq_handleKeyboardNotification:notification completion:nil];
}

- (void)jsq_handleKeyboardNotification:(NSNotification *)notification completion:(JSQAnimationCompletionBlock)completion
{
    NSDictionary *userInfo = [notification userInfo];

    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }

    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);

    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    CGRect keyboardEndFrameConverted = [self.contextView convertRect:keyboardEndFrame fromView:nil];

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         [self jsq_notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

#pragma mark - Utilities

- (void)jsq_setKeyboardViewHidden:(BOOL)hidden
{
    self.keyboardView.hidden = hidden;
    self.keyboardView.userInteractionEnabled = !hidden;
}

- (void)jsq_notifyKeyboardFrameNotificationForFrame:(CGRect)frame
{
    [self.delegate keyboardController:self keyboardDidChangeFrame:frame];

    [[NSNotificationCenter defaultCenter] postNotificationName:JSQMessagesKeyboardControllerNotificationKeyboardDidChangeFrame
                                                        object:self
                                                      userInfo:@{ JSQMessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame : [NSValue valueWithCGRect:frame] }];
}

- (void)jsq_resetKeyboardAndTextView
{
    [self jsq_setKeyboardViewHidden:YES];
    [self jsq_removeKeyboardFrameObserver];
    [self.textView resignFirstResponder];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesKeyboardControllerKeyValueObservingContext) {

        if (object == self.keyboardView && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {

            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];

            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }

            CGRect keyboardEndFrameConverted = [self.contextView convertRect:newKeyboardFrame
                                                                    fromView:self.keyboardView.superview];
            [self jsq_notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
        }
    }
}

- (void)jsq_removeKeyboardFrameObserver
{
    if (!_jsq_isObserving) {
        return;
    }

    @try {
        [_keyboardView removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(frame))
                              context:kJSQMessagesKeyboardControllerKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }

    _jsq_isObserving = NO;
}

@end
