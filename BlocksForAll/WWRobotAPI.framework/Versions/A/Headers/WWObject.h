//
//  WWObject.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/28/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#ifndef _WWOBJECT_H_
#define _WWOBJECT_H_

#import <Foundation/Foundation.h>

/**
 *  Parent class to all API objects, similar to NSObject for iOS.
 */
@interface WWObject : NSObject

/**
 *  Setup method that will be invoked by init.  
 *  
 *  To be overriden by child classes to standardize on how to initialize object.
 */
- (void) setup;

@end

#endif // _WWOBJECT_H_
