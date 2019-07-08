//
//  WWCommandSetSequence.h
//  APIObjectiveC
//
//  Created by Kevin Liang on 3/31/14.
//  Copyright (c) 2014 Wonder Workshop inc. (https://www.makewonder.com/) All rights reserved.
//

#import "WWEventDataSource.h"

// keys used to instruct how robots should process the command sequence
extern NSString *const WWCommandSequenceStartFrameIndexKey; // which frame to start with (defaults to 0, which references to the first frame)
extern NSString *const WWCommandSequenceStartFrameTimeOffsetKey; // the time during the first frame to start processing.

@class WWCommandSet, WWCommandSetSequenceFrame;

/**
 Here is an example of an animation expressed through file (JSON format):
 {
     "data": [{
         "duration": 0.033,
         "commands": {
             // this sets WW_COMMAND_LIGHT_RGB_LEFT_EAR to red
             "102": {
                 "r": 1,
                 "g": 0,
                 "b": 0
             },
             // this sets WW_COMMAND_LIGHT_MONO_TAIL to off
             "105": {
                 "brightness": 0
             },
             // this sets WW_COMMAND_BODY_WHEELS to rotate left
             "211": {
                 "left_cm/s": -20,
                 "right_cm/s": 20
             },
             // this sets WW_COMMAND_HEAD_POSITION_PAN to look straight
             "203": {
                 "degree": 0
             },
             // this sets WW_COMMAND_EYE_RING to alternating pattern representing a clock face (0 represents 12, 1 is 1, 2 is 2, so on)
             "100": {
                 "index": [1,0,1,0,1,0,1,0,1,0,1,0]
                 "brightness": 1
             }
         }
     }]
 }
 */

/**
 *  `WWCommandSetSequence` represents a sequence of commands that can be executed serially.  Each sequence has 1 or more `WWCommandSetSequenceFrame`
 *  objects, which describes a `WWCommandSet` to execute for the duration of that frame.  This class is best for creating a robot animation
 *  sequence.
 */

@interface WWCommandSetSequence : WWEventDataSource

/**---------------------------------------------------------------------------------------
 *  @name Create and initialize Sequences
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns an initialized `WWCommandSetSequence` object from a JSON-formatted sequence, represented by `NSData`.
 *
 *  @param data An `NSData` object containing sequence described in JSON.
 *
 *  @return A `WWCommandSetSequence` described by the data.  Returns nil if the data is malformatted.
 */
+ (WWCommandSetSequence *) sequenceFromData:(NSData *)data;

/**
 *  Returns an initialized `WWCommandSetSequence` object from a JSON-formatted sequence currently stored in a file.
 *
 *  @param fileName Location of the file that contains the sequence in JSON.
 *
 *  @return A `WWCommandSetSequence` that is described by the file content.  Returns nil if data is malformatted.
 */
+ (WWCommandSetSequence *) sequenceFromFile:(NSString *)fileName;

/**
 *  Returns an initialized `WWCommandSetSequence` object from a JSON-formatted sequence currently stored in a file.  This is a helper function to 
 *  locate files within the main bundle.
 *
 *  @param relativeName Name of the file that resides in the main bundle.
 *  @param type The file extension format.
 *
 *  @return A `WWCommandSetSequence` that is described by the file content.  Returns nil if data is malformatted.
 */
+ (WWCommandSetSequence *) sequenceFromFileInBundle:(NSString *)relativeName fileType:(NSString *)type;

/**
 *  Parses through structured data that represents a `WWCommandSetSequence`.  The data format is proprietary and the index values are specified
 *  in WWConstant.h.
 *
 *  @param data Structured data that represents a sequence of `WWCommandSetSequenceFrame` objects, indexed appropriately.
 *
 *  @return Yes if data is loaded into this object successfully, false otherwise (e.g. malformed data).
 */
- (BOOL) parseData:(NSDictionary *)data;


/**---------------------------------------------------------------------------------------
 *  @name Adding `WWCommandSet`
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Insert a given `WWCommandSet` object at the end of this sequence.
 *
 *  @param commandSet The object to add to the end of the sequence. No-op if the object is empty/nil.
 *  @param duration   Duration for how long to execute `WWCommandSet`, in seconds.  The duration must be greater than 30ms.
 */
- (void) addCommandSet:(WWCommandSet *)commandSet withDuration:(double)duration;

/**
 *  Insert a given `WWCommandSetSequenceFrame` at the end of this sequence.
 *
 *  @param frame The frame object to add to the end of the sequence. No-op if object is empty/nil.
 */
- (void) addFrame:(WWCommandSetSequenceFrame *)frame;


/**---------------------------------------------------------------------------------------
 *  @name Get sequence information
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Retrieves the associated `WWCommandSetSequenceFrame` object at the given index.  
 *
 *  @param index The index from which to retrieve the frame in the sequence.
 *
 *  @return The corresponding `WWCommandSetSequenceFrame` object or nil, if the index is erroneous (e.g., index >= size of sequence).
 */
- (WWCommandSetSequenceFrame *) frameAtIndex:(NSUInteger)index;

/**
 *  Returns an array copy (shallow) of all the `WWCommandSetSequenceFrame` objects associated with this sequence, in the correct order.
 *
 *  @return The array of `WWCommandSetSequenceFrame` objects or an empty array if no frames are associated.
 */
- (NSArray *) frames;

/**
 *  Returns the count of all the `WWCommandSetSequenceFrame` objects in this sequence.
 *
 *  @return The count of frames in this sequence.
 */
- (NSUInteger)count;

/**
 *  Returns the total duration of this sequence when executed from start to finish, in seconds.
 *
 *  @return The total duration of this sequence when executed from start to finish, in seconds.
 */
- (double) duration;

@end
