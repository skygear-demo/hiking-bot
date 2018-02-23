//
//  SKYContainer+Chat.m
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

#import "SKYContainer+Chat.h"

#import <objc/runtime.h>

#import "SKYChatExtension_Private.h"

@implementation SKYContainer (Chat)

- (SKYChatExtension *)chatExtension
{
    SKYChatExtension *extension = objc_getAssociatedObject(self, @selector(chatExtension));
    if (!extension) {
        extension =
            [[SKYChatExtension alloc] initWithContainer:self
                                        cacheController:[SKYChatCacheController defaultController]];
        objc_setAssociatedObject(self, @selector(chatExtension), extension,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return extension;
}

@end
