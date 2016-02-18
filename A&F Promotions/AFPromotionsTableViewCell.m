//
//  AFPromotionsTableViewCell.m
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#import "AFPromotionsTableViewCell.h"
#import "AFPromotion.h"
#import "UIKit+AFNetworking.h"

@interface AFPromotionsTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *promoTitle;
@property (nonatomic, weak) IBOutlet UIImageView *promoImage;

@end

@implementation AFPromotionsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public

- (void)configureWithPromotion:(AFPromotion *)promotion {
    [self.promoTitle setText:promotion.promotionTitle];
    NSURL *url = [NSURL URLWithString:promotion.imageUrl];
    //TODO:Load a default placeholder image asset here.
    [self.promoImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@""]];
}

@end
