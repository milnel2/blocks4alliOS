//  WWRobotManager.h
//  APIObjectiveC
//
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWError.h"
#import "WWObject.h"
#import "WWRobot.h"

typedef enum {
    WW_ROBOT_MANAGER_STATE_UNKNOWN = 0,
    WW_ROBOT_MANAGER_STATE_RESETTING,
    WW_ROBOT_MANAGER_STATE_UNSUPPORTED,
    WW_ROBOT_MANAGER_STATE_UNAUTHORIZED,
    WW_ROBOT_MANAGER_STATE_POWERED_OFF,
    WW_ROBOT_MANAGER_STATE_POWERED_ON
} WWRobotManagerState;

@class WWError;
@protocol WWRobotManagerObserver;

/**
 *  `WWRobotManager` objects are used to manage a discovered or connected Wonder Workshop `WWRobot` (represented by `WWRobot`), including scanning for,
 *  discovering, connecting, and disconnecting operations.
 *
 *  The delegate pattern in order to report robot connection states to its caller.
 */
@interface WWRobotManager : WWObject

/** ---------------------------------------------------------------------------------------
 *  @name Monitoring properties
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns the current state of the manager
 */
@property (nonatomic, readonly) WWRobotManagerState state;

/**
 *  Specifies the scan period (in seconds) during periodic scan.
 *
 *  @see startScanningForRobots:
 */
@property (nonatomic, readonly) float scanPeriod;

/**
 *  Indicates whether `WWRobotManager` is currently scanning for `WWRobot`.
 */
@property (nonatomic, readonly) bool isScanning;


/**---------------------------------------------------------------------------------------
 *  @name Retrieving robots by connection state
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns the current set of `WWRobot` robots that are in `ROBOT_CONNECTION_DISCOVERED` state.
 */
@property (nonatomic, readonly) NSArray *allDiscoveredRobots;

/**
 *  Returns the current set of `WWRobot` robots that are in `ROBOT_CONNECTION_CONNECTING` state.
 */
@property (nonatomic, readonly) NSArray *allConnectingRobots;

/**
 *  Returns the current set of `WWRobot` robots that are in `ROBOT_CONNECTION_CONNECTED` state.
 */
@property (nonatomic, readonly) NSArray *allConnectedRobots;

/**
 *  Returns the current set of `WWRobot` robots that are in `ROBOT_CONNECTION_LOST` state.
 */
@property (nonatomic, readonly) NSArray *allLostRobots;

/**
 *  Returns the current set of `WWRobot` robots that are in `ROBOT_CONNECTION_DISCONNECTING` state.
 */
@property (nonatomic, readonly) NSArray *allDisconnectingRobots;

/**
 *  Returns the current set of `WWRobot` robots that have been found, irrespective of robot state.
 */
@property (nonatomic, readonly) NSArray *allKnownRobots;

/**
 *  Returns the current set of `WWRobot` robots based on the robot state.
 *
 *  @param state Robot connection state.
 *
 *  @return Set of `WWRobot` robots with the specified state or an empty array if none are found.
 */
- (NSArray *) robotsWithConnectionState:(WWRobotConnectionState)state;


/**---------------------------------------------------------------------------------------
 *  @name Scanning or stopping scan of robots
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes the robot manager.  This is a singleton class.
 *
 *  @return a singleton `WWRobotManager` object (1 object per app).
 */
+ (WWRobotManager *)manager;


/**---------------------------------------------------------------------------------------
 *  @name Scanning or stopping scan of robots
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Scans for `WWRobot` periodically based on the given scan period.
 *
 *  If scanPeriod is > 0, this method scans until a robot is found. Then, it will pause scanning until the specified
 *  scanPeriod elapses before scanning again.  This operation will continue until `stopScanningForRobots` is called.
 *  If scanPeriod <= 0, then this method will perform the same action as `startScanningForRobotsImmediately`.
 *
 *  @see startScanningForRobotsImmediately
 *  @see stopScanningForRobots
 *  @param scanPeriod scan period (in seconds).
 */
- (void) startScanningForRobots:(float)scanPeriod;

/**
 *  Scans for `WWRobot` immediately.
 *
 *  Scan operation continues until `stopScanningForRobots` is called.
 *
 *  @see startScanningForRobots:
 *  @see stopScanningForRobots
 */
- (void) startScanningForRobotsImmediately;
- (void) stopScanningForRobots;


/**---------------------------------------------------------------------------------------
 *  @name Establishing or canceling connections with robots
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Establishes connection to a robot.
 *
 *  If a connection to robot is successfully established (or if the robot is already connected), the robot manager calls the
 *  `manager:didConnectRobot:` method of its delegate object. If the connection attempt fails, the robot manager calls the
 *  `manager:didFailToConnectRobot:error:` method of its delegate object instead.
 *
 *  @param robot The robot to which the manager is attempting to connect.
 */
- (void) connectToRobot:(WWRobot *)robot;

/**
 *  Disconnects an active connection from a robot.
 *
 *  This method is nonblocking and does not fail, so caller should consider the robot disconnected once this method finishes. Once
 *  the robot is successfully disconnected, the robot manager calls the `manager:didDisconnect:` delegate method.
 *
 *  @param robot The robot to which the maanger is attempting to disconnect.
 */
- (void) disconnectFromRobot:(WWRobot *)robot;

- (void) addManagerObserver:(id<WWRobotManagerObserver>)observer;
- (void) removeManagerObserver:(id<WWRobotManagerObserver>)observer;

@end




/**
 *  The `WWRobotManagerDelegate` protocol defines the methods that a delegate of a `WWRobotManager` object must adopt.  The optional methods of the protocol allows the
 *   delegate to monitor state changes of known robots.
 */
@protocol WWRobotManagerObserver <NSObject>

/**---------------------------------------------------------------------------------------
 *  @name Discovering and Connecting robots
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Invoked when the robot manager discovers a robot while scanning.
 *
 *  The discovered robot can also be accessed through `allDiscoveredRobots`. At this point, caller can safely invoke `connectToRobot:`
 *  method on the robot.
 *
 *  @param manager The robot manager providing the update.
 *  @param robot   The discovered robot.
 */
- (void) manager:(WWRobotManager *)manager didDiscoverRobot:(WWRobot *)robot;

/**
 *  Invoked when the robot manager is connected to a robot.
 *
 *  The connected robot can also be accessed through `allConnectedRobots`.  It is recommended that the caller keeps a pointer reference
 *  to the robot to perform robot commands and/or analyze sensor data.
 *
 *  @param manager The robot manager providing the update.
 *  @param robot   The connected robot.
 */
- (void) manager:(WWRobotManager *)manager didConnectRobot:(WWRobot *)robot;

@optional

- (void) manager:(WWRobotManager *)manager didUpdateState:(WWRobotManagerState)state;

/**
 *  Invoked when the robot manager receives update robot information during scanning.
 *
 *  The robot should be in ROBOT_CONNECTION_DISCOVERED state, and any of the potential information can be updated (name, greeting color/animation,
 *  battery level, signal strength). These updated information will be reflected in the corresponding robot property.
 *
 *  @param manager The robot manager providing the update.
 *  @param robot   The updated discovered robot.
 */
- (void) manager:(WWRobotManager *)manager didUpdateDiscoveredRobots:(WWRobot *)robot;

/**
 *  Invoked when the robot manager lost a robot while scanning.
 *
 *  A robot can only be "lost" when it is discovered in the previous scan, but not discovered in the current scan.  This means that false-positives
 *  can happen more often as scans intervals get larger, so it is best to respond to this method when calling `startScanningForRobots:`.
 *
 *  @param manager The robot manager providing the update.
 *  @param robot   The lost robot.
 */
- (void) manager:(WWRobotManager *)manager didLoseRobot:(WWRobot *)robot;

/**
 *  Invoked when the robot manager successfully disconnected from a robot.
 *
 *  This method is invoked when a disconnect is issued via `disconnectFromRobot:`.  After this method is called, no more commands or sensor data
 *  can be executed/received from the robot.
 *
 *  @param manager The robot manager providing the update.
 *  @param robot   The disconnected robot.
 */
- (void) manager:(WWRobotManager *)manager didDisconnectRobot:(WWRobot *)robot;

/**
 *  Invoked when the robot manager fails to create a connection with a robot.
 *
 *  This method is invoked when a connection initiated via `connectToRobot:` method fails to complete. The failure reasons will be detailed in the
 *  `WWError` class.
 *
 *  @param manager The robot manager providing the update.
 *  @param robot   The robot that failed to connect.
 *  @param error   The cause of the failure.
 */
- (void) manager:(WWRobotManager *)manager didFailToConnectRobot:(WWRobot *)robot error:(WWError *)error;

@end
