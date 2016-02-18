//
//  AFPromotionsTableViewCell.h
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AFPromotion;

@interface AFPromotionsTableViewCell : UITableViewCell

- (void)configureWithPromotion:(AFPromotion *)promotion;

@end
