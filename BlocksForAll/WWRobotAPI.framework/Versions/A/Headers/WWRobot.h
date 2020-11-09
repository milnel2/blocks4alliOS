//
//  WWRobot.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWConstants.h"
#import "WWEventDataSource.h"

typedef enum {
    ROBOT_CONNECTION_UNKNOWN = 900, // transient state
    ROBOT_CONNECTION_LOST, // seen before, but is not associated at the moment
    ROBOT_CONNECTION_DISCOVERED, // ready to be connected
    ROBOT_CONNECTION_CONNECTING, // trying to establish connection with robot
    ROBOT_CONNECTION_CONNECTED, // ready to take action, now the robot is in user control
    ROBOT_CONNECTION_DISCONNECTING, // waiting for sent commands to reach the robot
} WWRobotConnectionState;

@class WWRobotManager, WWCommandSetSequence, WWCommandSet, WWSensorSet, WWCommandSetSequenceExecution, WWComponentSet, WWSensorHistory;
@protocol WWRobotObserver;


/**
 *  `WWRobot` is a subclass of the `WWEventDataSource` object; it has a 1-to-1
 *  mapping to a physical Wonder Workshop robot.  
 *
 *  Caller can execute robot commands (via `WWCommandSet`) and analyze robot state data 
 *  (via `WWSensorSet`) to control robots as desired.
 */
@interface WWRobot : WWEventDataSource

/**
 *  Returns the human-readable name of the robot (read-only).
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  Returns the entire history of received `WWSensor` objects.
 */
@property (nonatomic, readonly) WWSensorHistory *history;

/**
 *  Returns the personality color of this robot (read-only).
 */
@property (nonatomic, readonly) WWPersonalityColorIndex personalityColorIndex;

/**
 *  Returns the type of this robot (read-only).
 */
@property (nonatomic, readonly) WWRobotType robotType;

/**
 *  Returns the connection status of this robot (read-only).
 */
@property (nonatomic, readonly) WWRobotConnectionState connectionState;

/**
 *  Returns the unique identifier of this robot (read-only).
 */
@property (nonatomic, readonly) NSString *uuId;

/**
 *  Returns the factory serial number of this robot (read-only).
 */
@property (nonatomic, strong, readonly) NSString *serialNumber;

/**
 *  Returns the hardware revision of this robot (read-only).
 */
@property (nonatomic, readonly) uint8_t hardwareRevision;

/**
 *  Returns the firmware version that is currently running on this robot (read-only).
 */
@property (nonatomic, strong, readonly) NSString *firmwareVersion;

/**
 *  Returns the resource version that is currently on this robot (read-only).
 */
@property (nonatomic, strong, readonly) NSNumber *resourceVersion;

/**
 *  Returns the signal strength of this robot (read-only).
 */
@property (nonatomic, strong, readonly) NSNumber *signalStrength;

- (void) addRobotObserver:(id<WWRobotObserver>)observer;
- (void) removeRobotObserver:(id<WWRobotObserver>)observer;

/**---------------------------------------------------------------------------------------
 *  @name Querying robot
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns true if robot is not properly configured by the Wonder Workshop Go app.
 *
 *  @return Returns true if unconfigured, false otherwise.
 */
- (BOOL) isUnconfigured;

/**
 *  Returns true if robot is connected and ready to receive commands (and currently 
 *  emitting sensor).  
 *
 *  Robot is connected if connectionState == ROBOT_CONNECTION_CONNECTED, false otherwise.
 *
 *  @return Returns true if connected, false otherwise.
 */
- (BOOL) isConnected;

/**
 *  Returns true if this robot is the same as the provided robot.
 *
 *  Comparison is done using [uuId isEqualToString:].
 *
 *  @param robot The robot with which to be compared.
 *
 *  @return Returns true if this robot is the same as the specified robot.
 */
- (BOOL) isEqualToRobot:(WWRobot *)robot;


/**---------------------------------------------------------------------------------------
 *  @name Sending commands
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Sends the given `WWCommandSet` to the physical robot to execute.
 * 
 *  The given command might not be sent immediately, but will be sent within 50ms.  If sendRobotCommandSet: is called multiple times immediately, the
 *  `WWRobot` might aggregate and send them as a single command set. If
 *  there are collisions during command aggregation, the latest command might
 *  override earlier commands.
 *
 *  @param command The desired command set to send to the robot.
 */
- (void) sendRobotCommandSet:(WWCommandSet *)command;


/**---------------------------------------------------------------------------------------
 *  @name Executing command sequences
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Starts to execute the given `WWCommandSetSequence` immediately, while respecting the options passed in.  Caller can specify the
 *  WWCommandSequenceStartFrameIndexKey and WWCommandSequenceStartFrameTimeOffsetKey values or nil to execute the sequence from
 *  the very beginning.
 * 
 *  Multiple sequences can be executed at once, although the results may be unpredictable as the robots will attempt to merge
 *  the execution commands together.
 *
 *  @param sequence `WWCommandSetSequence` object to execute on.
 *  @param options  A set of option to respect during execution.  If nil, execution will start at the beginning of the sequence.
 */
- (void) executeCommandSequence:(WWCommandSetSequence *)sequence withOptions:(NSDictionary *)options;

/**
 *  Stops execution of the given `WWCommandSetSequence` object. If this robot is not currently executing 
 *  this sequence, then this is a no-op.
 *
 *  @param sequence `WWCommandSetSequence` object to stop execution on.
 */
- (void) stopCommandSequence:(WWCommandSetSequence *)sequence;

/**
 *  Returns the current execution result for this given sequence.  If the sequence isn't being executed
 *  currently, nil will be returned instead.
 *
 *  @param sequence `WWCommandSetSequence` object that is currently being executed.
 *
 *  @return Execution result of the `WWcommandSetSequence`.
 */
- (NSDictionary *) commandSequenceResults:(WWCommandSetSequence *)sequence;

/**
 *  Returns all the `WWCommandSetSequence` objects that the robots are currently executing.  Returns nil
 *  if robot is not currently executing any sequence.
 *
 *  @return Array of current sequences that are being executed.
 */
- (NSArray *) allExecutingCommandSequences;

/**
 *  Returns YES if the given `WWCommandSetSequence` object is being executed by this robot. Otherwise, returns NO.
 *
 *  @param sequence `WWCommandSetSequence` object that is being tested for execution.
 *
 *  @return YES if the given `WWCommandSetSequence` object is being executed by this robot. Otherwise, returns NO.
 */
- (BOOL) isExecutingCommandSequence:(WWCommandSetSequence *)sequence;



/**---------------------------------------------------------------------------------------
 *  @name Modifying robot
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Power cycles the physical robot and clears any queued commands.
 */
- (void) reboot;

/**
 *  Resets the robot to its initial state.
 *
 *  Initial state means:
 *  - Lights will reflect its personality color.
 *  - All movements are stopped.
 *  - The head faces center and is level.
 *  - The eye blinks.
 */
- (void) resetState;

@end




/**
 *  The `WWRobotObserver` protocol defines the methods that an observer of a `WWRobot`
 *  object must adopt.  The optional methods of the protocol allows the observer to react
 *  to the current state of the physical robot.
 */
@protocol WWRobotObserver <NSObject>

@optional
/**
 *  Invoked when 1+ `WWEvent` was triggered for the last `WWSensor` received.
 *
 *  @param robot  The robot on which the event(s) triggered.
 *  @param events The set of events that were triggered.
 */
- (void) robot:(WWRobot *)robot eventsTriggered:(NSArray *)events;

/**
 *  Invoked when new `WWSensorSet` data is received.
 *
 *  @param robot The robot from which the sensor data came.
 *  @param state The set of sensor data that was received from the robot.
 */
- (void) robot:(WWRobot *)robot didReceiveRobotState:(WWSensorSet *)state;

/**
 *  Invoked when a robot stopped execution of a `WWCommandSetSequence`.  This callback is usually triggered when caller stops
 *  the execution with `stopCommandSequence:` method call.  
 *  
 *  The execution result will be returned, which can be passed in when invoking the `executeCommandSequence:withOptions:` method to
 *  resume execution (if needed).
 *
 *  @param robot    The robot that was executing the `WWCommandSetSequence` object.
 *  @param sequence The `WWCommmandSetSequence` object that was being executed on.
 *  @param results  The execution result at the time that sequence stopped executing.
 */
- (void) robot:(WWRobot *)robot didStopExecutingCommandSequence:(WWCommandSetSequence *)sequence withResults:(NSDictionary *)results;

/**
 *  Invoked when a robot finished executing a `WWCommandSetSequence` object to the end.  This callback is not
 *  triggered if the caller stops the sequence execution prematurely.
 *
 *  @param robot    The robot that was executing the `WWCommandSetSequence` object.
 *  @param sequence The `WWCommmandSetSequence` object that was being executed on.
 */
- (void) robot:(WWRobot *)robot didFinishCommandSequence:(WWCommandSetSequence *)sequence;

@end
