//
//  IBGUserStep.h
//  Instabug
//
//  Created by Ahmed Ashraf on 16/01/2024.
//  Copyright © 2024 Instabug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBGTypes.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(UserStep)
@interface IBGUserStep: NSObject

- (instancetype) init __attribute__((unavailable("use initWithEvent: instead")));
- (instancetype)initWithEvent:(IBGUIEventType)event;
- (instancetype _Nullable)initWithEvent:(IBGUIEventType)event automatic:(BOOL)automatic;
- (IBGUserStep *)setMessage:(NSString *)message;
- (IBGUserStep *)setViewType:(IBGInteractionViewType)viewType;
- (void)logUserStep;

@end

NS_ASSUME_NONNULL_END
