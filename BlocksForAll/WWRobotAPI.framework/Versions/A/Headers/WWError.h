//
//  WWError.h
//  APIObjectiveC
//
//  Created by Orion Elenzil on 20140813.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWErrorCode.h"

extern NSString* const WWRobotErrorDomain;
extern NSString* const WWSystemError;


@interface WWError : NSError

+ (WWError*) errorWithCode:(NSUInteger)code description:(NSString*)string underlyingError:(NSError*)underlyingError;

@end
