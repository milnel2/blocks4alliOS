//
//  WWSensorBodyPose.h
//  APIObjectiveC
//
//  Created by Orion Elenzil on 20140926.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

// Coordinate-System:
// Forward           = +X
// Left              = +Y
// Counter-Clockwise = +Theta
//
//         +X  (Forward)
//          ^
//          |         <-
//          |            \
// +Y <-----*     +Theta |
// (Left)                /

#import "WWSensor.h"

@interface WWSensorBodyPose : WWSensor

@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double radians;


@end
