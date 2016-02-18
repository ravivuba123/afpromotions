//
//  WebServiceManager.h
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFPromotion;

@interface WebServiceManager : NSObject

+ (instancetype)sharedManager;

- (void)getPromotionsWithCompletion:(void(^)(NSArray <AFPromotion *> *promotions, BOOL isCachedLocally, NSError *error))completion;

@end
