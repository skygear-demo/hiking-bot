//
//  SKYChatTypingIndicator_Private.h
//  SKYKitChat
//
//  Copyright 2016 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SKYChatTypingIndicator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKYChatTypingIndicator ()

/**
 Returns whether the specified string is the name of the event type for typing indicator.

 App developer should not call this method.
 */
+ (BOOL)isTypingIndicatorEventType:(NSString *_Nullable)typingIndicator;

@end

NS_ASSUME_NONNULL_END
