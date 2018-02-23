/*
*  MagicKit.m
*  MagicKit
*
*  Copyright (c) 2010 Aidan Steele, Glass Echidna
* 
*  Permission is hereby granted, free of charge, to any person obtaining a copy
*  of this software and associated documentation files (the "Software"), to deal
*  in the Software without restriction, including without limitation the rights
*  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*  copies of the Software, and to permit persons to whom the Software is
*  furnished to do so, subject to the following conditions:
*  
*  The above copyright notice and this permission notice shall be included in
*  all copies or substantial portions of the Software.
*  
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
*  THE SOFTWARE.
*/
#import "GEMagicKit.h"
#import "GEMagicResult.h"
#import "magic.h"

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE)
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif

@interface GEMagicKit ()

+ (magic_t)sharedMagicCookie;
+ (GEMagicResult *)magicForObject:(id)object decompress:(BOOL)decompress;
+ (NSString *)rawMagicOutputForObject:(id)dataOrFilePath cookie:(magic_t)cookie flags:(int)flags;
+ (NSArray *)typeHierarchyForType:(NSString *)uniformType;

@end

@implementation GEMagicKit

+ (magic_t)sharedMagicCookie {
    static magic_t sharedCookie = NULL;
    
    if (sharedCookie == NULL) {
        sharedCookie = magic_open(MAGIC_NONE);

        const char *magicFile = [[[NSBundle bundleForClass:[self class]] pathForResource:@"magic" ofType:@"mgc"] fileSystemRepresentation];
        
        if (sharedCookie == NULL || magic_load(sharedCookie, magicFile) == -1) {
            [NSException raise:@"MagicKit" format:@"There was an error opening the magic database: %s", strerror(errno)];
        }
    }
    
    return sharedCookie;
}

+ (GEMagicResult *)magicForObject:(id)object decompress:(BOOL)decompress {
    int baseFlags = MAGIC_NONE;
    if (decompress) baseFlags |= MAGIC_COMPRESS;

    magic_t cookie = [GEMagicKit sharedMagicCookie];
    
    NSString *description = [self rawMagicOutputForObject:object cookie:cookie flags:baseFlags];
    NSString *mimeType = [self rawMagicOutputForObject:object cookie:cookie flags:(baseFlags | MAGIC_MIME)];
    if (!description || !mimeType)
        return nil;
    
    NSString *plainMimeType = [mimeType componentsSeparatedByString:@";"][0];
    CFStringRef typeIdentifierRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)plainMimeType, NULL);

    NSString *typeIdentifier = (__bridge NSString *)typeIdentifierRef;
    NSArray *typeHierarchy = [@[typeIdentifier] arrayByAddingObjectsFromArray:[GEMagicKit typeHierarchyForType:typeIdentifier]];

    NSString *fileExtension;

    if (UTTypeIsDeclared(typeIdentifierRef)) {
        CFDictionaryRef typeDeclaration = UTTypeCopyDeclaration(typeIdentifierRef);
        CFDictionaryRef specification = CFDictionaryGetValue(typeDeclaration, kUTTypeTagSpecificationKey);

        CFArrayRef fileExtensions = NULL;
        Boolean hasExtensions = CFDictionaryGetValueIfPresent(specification, kUTTagClassFilenameExtension, (const void **)&fileExtensions);

        if (hasExtensions && CFArrayGetCount(fileExtensions) > 0) {
            fileExtension = CFBridgingRelease(CFArrayGetValueAtIndex(fileExtensions, 0));
        }

        CFRelease(typeDeclaration);
    }

    GEMagicResult *result = [[GEMagicResult alloc] initWithMimeType:mimeType
                                                        description:description
                                                      fileExtension:fileExtension
                                                      typeHierarchy:typeHierarchy];

    CFRelease(typeIdentifierRef);

    return result;
}

+ (NSString *)rawMagicOutputForObject:(id)dataOrFilePath cookie:(magic_t)cookie flags:(int)flags {
    const char *rawOutput = NULL;

    magic_setflags(cookie, flags);
    if ([dataOrFilePath isKindOfClass:[NSData class]]) {
        rawOutput = magic_buffer(cookie, [dataOrFilePath bytes], [dataOrFilePath length]);
    } else if ([dataOrFilePath isKindOfClass:[NSString class]]) {
        rawOutput = magic_file(cookie, [dataOrFilePath fileSystemRepresentation]);
    } else {
        [NSException raise:@"MagicKit" format:@"Invalid object (expected data or path string): %@", dataOrFilePath];
    }

    return rawOutput ? [NSString stringWithUTF8String:rawOutput] : nil;
}

+ (NSArray *)typeHierarchyForType:(NSString *)uniformType {
    NSArray *typeHierarchy = nil;

    NSDictionary *typeDeclaration = CFBridgingRelease(UTTypeCopyDeclaration((__bridge CFStringRef)uniformType));
    id superTypes = typeDeclaration[(NSString *) kUTTypeConformsToKey];
    
    if ([superTypes isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableTypeHierarchy = [NSMutableArray arrayWithArray:superTypes];
        
        for (NSString *superType in superTypes)
            [mutableTypeHierarchy addObjectsFromArray:[GEMagicKit typeHierarchyForType:superType]];

        typeHierarchy = mutableTypeHierarchy;
    } else if ([superTypes isKindOfClass:[NSString class]]) {
        typeHierarchy = @[superTypes];
    }
    
    return typeHierarchy;
}

#pragma mark -
#pragma mark Convenience methods

+ (GEMagicResult *)magicForFileAtPath:(NSString *)path {
    return [GEMagicKit magicForFileAtPath:path decompress:NO];
}

+ (GEMagicResult *)magicForFileAtURL:(NSURL *)aURL {
    return [GEMagicKit magicForFileAtURL:aURL decompress:NO];
}

+ (GEMagicResult *)magicForData:(NSData *)data {
    return [GEMagicKit magicForData:data decompress:NO];
}

+ (GEMagicResult *)magicForFileAtPath:(NSString *)path decompress:(BOOL)decompress {
    return [GEMagicKit magicForObject:path decompress:decompress];
}

+ (GEMagicResult *)magicForFileAtURL:(NSURL *)aURL decompress:(BOOL)decompress {
	if ([aURL isFileURL]) {
		return [GEMagicKit magicForFileAtPath:[aURL path] decompress:decompress];
	} else {
		return nil;
	}
}

+ (GEMagicResult *)magicForData:(NSData *)data decompress:(BOOL)decompress {
    return [GEMagicKit magicForObject:data decompress:decompress];
}

@end
