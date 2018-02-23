//
//  SKYMessage.h
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

#import <SKYKit/SKYKit.h>

#import "SKYChatRecord.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const SKYMessageTypeMetadataKey;

@class SKYReference;

typedef NS_ENUM(NSInteger, SKYMessageConversationStatus) {
    SKYMessageConversationStatusDelivering,
    SKYMessageConversationStatusDelivered,
    SKYMessageConversationStatusSomeRead,
    SKYMessageConversationStatusAllRead
};

@interface SKYMessage : SKYChatRecord

@property (strong, nonatomic, nullable) SKYReference *conversationRef;
@property (copy, nonatomic, nullable) NSString *body;
@property (copy, nonatomic, nullable) NSDictionary<NSString *, id> *metadata;
@property (strong, nonatomic, readwrite, nullable) SKYAsset *attachment;
@property (assign, nonatomic, readonly) bool deleted;
@property (assign, nonatomic, readonly) NSInteger seq;
@property (strong, nonatomic, nullable) NSDate *sendDate;

@property (assign, nonatomic, readonly) SKYMessageConversationStatus conversationStatus;

+ (instancetype _Nullable)message;
+ (instancetype)recordWithRecord:(SKYRecord *)record;
@end

NS_ASSUME_NONNULL_END
