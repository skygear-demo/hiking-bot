//
//  SKYChatRecordChange_Private.h
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

#import "SKYChatRecordChange.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKYChatRecordChange ()

/**
 Returns whether the specified string is the name of the event type for record change.

 App developer should not call this method.
 */
+ (BOOL)isRecordChangeEventType:(NSString *)eventType;

- (instancetype)initWithEvent:(SKYChatRecordChangeEvent)event record:(SKYRecord *)record;

@end

NS_ASSUME_NONNULL_END
