//
//  AFPromotionsDetailViewController.m
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#import "AFPromotionsDetailViewController.h"
#import "AFPromotion.h"
#import "UIKit+AFNetworking.h"

@interface AFPromotionsDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *promoTitle;
@property (nonatomic, weak) IBOutlet UILabel *promoDescription;
@property (nonatomic, weak) IBOutlet UIImageView *promoImage;
@property (nonatomic, weak) IBOutlet UIButton *promoOfferButton;

@end

@implementation AFPromotionsDetailViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)configureUI {
    NSURL *url = [NSURL URLWithString:self.promotion.imageUrl];
    //TODO:Assign an image asset to set the placeholder image
    [self.promoImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@""]];
    [self.promoTitle setText:self.promotion.promotionButtonTitle];
    [self.promoDescription setText:self.promotion.promotionDescription];
    [self.promoOfferButton setTitle:self.promotion.promotionButtonTitle forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)onClickPromoOfferButton:(UIButton *)sender {
    NSURL *targetURL = [NSURL URLWithString:self.promotion.promotionButtonTarget];
    if ([[UIApplication sharedApplication] canOpenURL:targetURL]) {
        [[UIApplication sharedApplication] openURL:targetURL];
    }
    else {
        NSLog(@"Cannot open %@ url. Probably not in the right format.", self.promotion.promotionButtonTarget);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!"
                                                                       message:@"Cannot open this promo at this time. Please try again later."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
