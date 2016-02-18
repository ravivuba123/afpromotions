//
//  AFPromotion.h
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFPromotion : NSObject

@property (nonatomic, strong) NSString *promotionTitle;
@property (nonatomic, strong) NSString *promotionDescription;
@property (nonatomic, strong) NSString *promotionButtonTarget;
@property (nonatomic, strong) NSString *promotionButtonTitle;
@property (nonatomic, strong) NSString *footerText;
@property (nonatomic, strong) NSString *imageUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
