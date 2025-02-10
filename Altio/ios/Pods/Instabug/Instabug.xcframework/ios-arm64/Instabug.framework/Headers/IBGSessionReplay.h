//
//  IBGSessionReplay.h
//  InstabugSessionReplay
//
//  Created by Ahmed Salah on 27/08/2023.
//  Copyright © 2023 Instabug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBGSessionMetadata.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SessionReplay)
@interface IBGSessionReplay : NSObject

typedef void (^SessionEvaluationCompletion)(BOOL shouldSendSessionReplay);
typedef void (^MetadataHandler)(IBGSessionMetadata *metadataObject, SessionEvaluationCompletion completion);
/**
 @brief Enable/Disable Session Replay.
 
 Session Replay is enabled by default.
 @discussion Enabling Session Replay allows you to record and replay user sessions for better understanding of user interactions and issue resolutions.

 @code
 SessionReplay.enabled = true
 @endcode
 
 */
@property (class, atomic, assign) BOOL enabled;

/**
 @brief Enable/Disable recording network logs for Session Replay.
 
 Network log recording is enabled by default. It allows capturing network activity during Session Replay for better debugging and analysis.
 
 @code
 SessionReplay.networkLogsEnabled = true
 @endcode
 */
@property (class, atomic, assign) BOOL networkLogsEnabled;

/**
 @brief Enable/Disable recording Instabug logs for Session Replay.
 
 Instabug log recording is enabled by default. It allows capturing Instabug SDK logs during Session Replay, aiding in identifying issues.
 
 @code
 SessionReplay.IBGLogsEnabled = true
 @endcode
 */
@property (class, atomic, assign) BOOL IBGLogsEnabled;

/**
 @brief Enable/Disable recording user steps for Session Replay.
 
 User step recording is enabled by default. It allows capturing user interactions and navigation paths during Session Replay for comprehensive analysis.
 
 @code
 SessionReplay.userStepsEnabled = true
 @endcode
 */
@property (class, atomic, assign) BOOL userStepsEnabled;

/**
 @brief Export Current Session Replay Link. Current session Replay Link if found as optional String
 */
@property (class, atomic, assign, readonly, nullable) NSString *sessionReplayLink;

/**
@brief A callback function that instructs Instabug to sync Session Replay or not. This callback is designed to enhance user control by giving them the option to sync or drop the Session Replay, ensuring a more transparent and user-centric experience.
 
This callback is called at the beginning of the next session returning SessionMetadata object that contains:
 
    device → Device make and model.
 
    appVersion → Application’s App Version.
 
    sessionDurationInSeconds → The previous session duration in Seconds.

    hasLinkToAppReview → Boolean that returns true if in-app review occurred in the previous session.

    metadata.networkLogs → Array of Network logs that occurred in the previous session.
 
    network.url → Network request URL.
     
    network.duration → Network request duration in millis.

    network.statusCode → Network request status code.

Objective c Example usage:
@code
 [IBGSessionReplay setSyncCallbackWithHandler:^(IBGSessionMetadata *metadataObject, SessionEvaluationCompletion completion) {
         BOOL shouldSendSessionReplay =
         ([metadataObject.device isEqualToString:@"iOS"]) &&
         ([metadataObject.os isEqualToString:@"16.3"])
 
         completion(shouldSendSessionReplay);
     }];
}
@endcode

Swift Example usage:
@code
 SessionReplay.syncCallbackWithHandler = { metadataObject, completion in
             var shouldSendSessionReplay: Bool =
             (metadataObject.appVersion == "3.0.4") &&
             (metadataObject.sessionDuration > 300)
 
             completion(shouldSendSessionReplay)
         }
@endcode
 */
@property (class, atomic, copy, nullable) MetadataHandler syncCallbackWithHandler;

@end

NS_ASSUME_NONNULL_END
