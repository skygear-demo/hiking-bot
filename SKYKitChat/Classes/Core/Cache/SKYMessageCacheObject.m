//
//  SKYMessageCacheObject.m
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

#import "SKYMessageCacheObject.h"
#import "SKYMessage.h"

@implementation SKYMessageCacheObject

+ (NSString *)primaryKey
{
    return @"recordID";
}

@end

@implementation SKYMessageCacheObject (SKYRecord)

- (SKYMessage *)messageRecord
{
    SKYRecord *record = [NSKeyedUnarchiver unarchiveObjectWithData:self.recordData];
    SKYMessage *message = [SKYMessage recordWithRecord:record];
    message.sendDate = self.sendDate;
    return message;
}

+ (SKYMessageCacheObject *)cacheObjectFromMessage:(SKYMessage *)message
{
    SKYMessageCacheObject *cacheObject = [[SKYMessageCacheObject alloc] init];

    cacheObject.recordID = message.recordID.recordName;
    cacheObject.conversationID = message.conversationRef.recordID.recordName;
    cacheObject.creationDate = message.record.creationDate;

    // creationDate of the record originally respresents the message creation date on server
    // this overloads the meaning of creationDate, to also represents local creation date
    // then creationDate can also be used to sort messages even not uploaded to server yet
    //
    // this will not affect the SKYMessage created from cache object
    // because the deserializtion of message record data is based on recordData only
    if (!cacheObject.creationDate && message.sendDate) {
        cacheObject.creationDate = message.sendDate;
    }

    cacheObject.editionDate = [message.record objectForKey:@"edited_at"];
    cacheObject.deleted = message.deleted;
    cacheObject.sendDate = message.sendDate;
    cacheObject.recordData = [NSKeyedArchiver archivedDataWithRootObject:message.record];
    cacheObject.seq = message.seq;
    return cacheObject;
}

@end
