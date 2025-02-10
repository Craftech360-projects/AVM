//
//  IBGFeatureFlag.h
//  InstabugCoreInternal
//
//  Created by Ahmed Salah on 14/04/2024.
//  Copyright © 2024 Instabug. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(FeatureFlag)
@interface IBGFeatureFlag : NSObject
@property (atomic, copy, readonly) NSString *name;
@property (atomic, copy, readonly, nullable) NSString *variant;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name
                     variant:(nullable NSString *)variant;
- (instancetype)initWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
