/*
 File:       Instabug/IBGCrashReporting.h
 
 Contains:   API for using Instabug's SDK.
 
 Copyright:  (c) 2013-2019 by Instabug, Inc., all rights reserved.
 
 Version:    14.1.0
 */

#import <Foundation/Foundation.h>
#import "IBGNonFatal.h"
#import "IBGCrashMetaData.h"
#import "IBGTypes.h"
#import "IBGCrashReportWriter.h"

NS_SWIFT_NAME(CrashReporting)
@interface IBGCrashReporting : NSObject

/**
 @brief Enable/Disable crash reporting.
 
 Crash reporting is enabled by default. If you need to disable it, It's recommended to call it before startWithToken.
 */
@property (class, atomic, assign) BOOL enabled;

/**
 @brief Enable/Disable out of memory crash reporting.
 
 Out of memory crash reporting is enabled by default. OOM will be disabled if crash reporting is disabled.
 */
@property (class, atomic, assign) BOOL OOMEnabled;

/**
@brief Controls the reporting of application hangs.

@discussion
This feature is forcibly disabled if Crash Reporting is disabled.

The default value is true.
*/
@property (class, atomic, assign) BOOL appHangEnabled;

/**
 @brief Controls the reporting of application force restart .

 @discussion
This feature is forcibly disabled if Crash Reporting is disabled.

The default value is true.
 */
@property (class, atomic, assign) BOOL forceRestartEnabled;

/**
 @brief Sets a block of code to be executed when a crash happens.

 @discussion This block of code will be executed on the \b main thread after a crash is reported to the dashboard.

 */
@property (class, atomic, copy) void(^didSendCrashReportHandler)(IBGCrashMetaData *);

/**
 * Defines a completion type for handling crash report consent.
 *
 * This completion type takes an IBGCrashReportConsent parameter and does not return a value.
 *
 * @param consent An IBGCrashReportConsent value representing the user's consent for crash reporting.
 */
typedef void (^IBGCrashReportConsentReplyHandler)(IBGCrashReportConsent consent);
/**
 @brief A callback function that instructs Instabug to await user confirmation before sending crash reports. This callback specifically applies
 to fatal errors (crashes), force restart and out-of-memory (OOM) reports, excluding app hangs and non-fatals errors.

 If no response is received within a 2-minute window, the callback triggers a timeout mechanism, preventing the automatic sending of the crash report.
 
 @Note This callback is designed to enhance user privacy and control by giving them the option to approve or decline the submission of crash reports, ensuring a more transparent and user-centric experience.

 @property onWillSendCrashReportHandler
   A class property that accepts an IBGCrashType representing the crash type and
   an IBGCrashReportConsentReplyHandler block for managing crash report consent.

 Objective c Example usage:
 @code
   IBGCrashReporting.onWillSendCrashReportHandler = ^(IBGCrashType crashType, IBGCrashReportConsentReplyHandler completionHandler) {
       // Your implementation to handle crash report consent and sending mechanism
   };
 @endcode

 Swift Example usage:
 @code
     CrashReporting.onWillSendCrashReportHandler = { (crashType, completionHandler) in
         // Your implementation to handle crash report consent and sending mechanism
     }
 @endcode
 */
@property (class, atomic, copy) void (^onWillSendCrashReportHandler)(IBGCrashType crashType, IBGCrashReportConsentReplyHandler completionHandler);

typedef void (*OnCrashCallback)(struct IBGCrashReportWriter *);
/**
 @brief C callback function that called when Instabug caught a crash and wait user to add crash metadata
 */
@property (class, atomic, assign) OnCrashCallback onCrashHandler;

/**
 @brief Enable/Disable unhandled crash reporting.
 
 Unhandled crash reporting is enabled by default. If you need to disable it, you need to call it before startWithToken, And It will disable OOM as well.
 */
@property (class, atomic, assign) BOOL unhandledEnabled;

/**
 @brief Enable/Disable collecting user identification data in crash reports. It's recommended to set this variable after the `startWithToken` method call

 Crash reporting collects the user identification data by default.
 */
@property (class, atomic, assign) BOOL userIdentificationDataCollectionEnabled;

/**
 @brief Returns true if the last session ended with a fatal crash (not including OOM crashes).
 */
@property (class, nonatomic, readonly) BOOL didLastSessionCrash;

/**
 @brief Creates a new NonFatalException object to report a handled exception with customizable metadata.

 @param exception exception to be reported
 @returns NonFatalException object
 */
+ (IBGNonFatalException *)exception:(NSException *)exception;

/**
 @brief Creates a new NonFatalError object to report a handled error with customizable metadata.

 @param error error to be reported
 @returns NonFatalError object
 */
+ (IBGNonFatalError *)error:(NSError *)error;

@end
