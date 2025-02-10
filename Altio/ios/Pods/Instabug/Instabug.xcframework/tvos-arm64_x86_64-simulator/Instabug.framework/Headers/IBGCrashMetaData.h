/*
 File:       InstabugCrashReporting/IBGCrashMetaData.h

 Contains:   API for using Instabug's SDK.

 Copyright:  (c) 2013-2022 by Instabug, Inc., all rights reserved.

 Version:    0.0.0
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CrashMetaData)
@interface IBGCrashMetaData : NSObject

/// The ID for the crash occurrence.
@property (atomic, copy, nonnull, readonly) NSString* occurrenceID;

/// The error code for the crash.
@property (atomic, copy, nonnull, readonly) NSString *errorCode;

/// The error type for the crash.
@property (atomic, copy, nonnull, readonly) NSString *errorType;

/// A brief description of the error.
@property (atomic, copy, nonnull, readonly) NSString *errorDescription;

/// The user attributes that will be attached to the report.
@property (atomic, copy, readonly) NSDictionary<NSString *, NSString *> *userAttributes;

/// The Crash metadata that added by `onCrashHandler` callback
@property (atomic, copy, nullable, readonly) NSDictionary<NSString *, id> *additionalCrashData;

- (instancetype)initWithOccurrnceID:(NSString *)occurrenceID
                          errorCode:(NSString *)errorCode
                          errorType:(NSString *)errorType
                   errorDescription:(NSString *)errorDescription
                     userAttributes:(NSDictionary<NSString *, NSString *> *)userAttributes
                additionalCrashData:(nullable NSDictionary<NSString *, id> *)additionalCrashData;
@end

NS_ASSUME_NONNULL_END
