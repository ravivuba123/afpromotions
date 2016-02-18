//
//  AFPromotion.m
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#import "AFPromotion.h"
#import "Constants.h"

@implementation AFPromotion

#pragma mark - Initialization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (!IS_EMPTY(dictionary)) {
            id buttonObj = [dictionary objectForKey:kPROMO_BUTTON_KEY];
            if (!IS_EMPTY(buttonObj)) {
                NSDictionary *buttonDict = [NSDictionary new];
                if ([buttonObj isKindOfClass:[NSDictionary class]]) {
                    buttonDict = (NSDictionary *)buttonObj;
                }
                else if ([buttonObj isKindOfClass:[NSArray class]]) {
                    id arrayObject = [(NSArray *)buttonObj firstObject];
                    if ([arrayObject isKindOfClass:[NSDictionary class]]) {
                        buttonDict = (NSDictionary *)arrayObject;
                    }
                }
                if (!IS_EMPTY(buttonDict)) {
                    if (!IS_EMPTY(buttonDict[kPROMO_BUTTON_TITLE]))
                        self.promotionButtonTitle = [buttonDict objectForKey:kPROMO_BUTTON_TITLE];
                    
                    if (!IS_EMPTY(buttonDict[kPROMO_BUTTON_TARGET]))
                        self.promotionButtonTarget = [buttonDict objectForKey:kPROMO_BUTTON_TARGET];
                }
            }
            
            if (!IS_EMPTY(dictionary[kPROMO_TITLE]))
                self.promotionTitle = dictionary[kPROMO_TITLE];
            
            if (!IS_EMPTY(dictionary[kPROMO_DESCRIPTION]))
                self.promotionDescription = dictionary[kPROMO_DESCRIPTION];
            
            if (!IS_EMPTY(dictionary[kPROMO_FOOTER_TEXT]))
                self.footerText = dictionary[kPROMO_FOOTER_TEXT];
            
            if (!IS_EMPTY(dictionary[kPROMO_IMAGE_URL]))
                self.imageUrl = dictionary[kPROMO_IMAGE_URL];
        }
    }
    return self;
}

#pragma mark - Getters/Setters

- (NSString *)promotionTitle {
    if (!_promotionTitle) {
        _promotionTitle = @"";
    }
    return _promotionTitle;
}

- (NSString *)promotionDescription {
    if (!_promotionDescription) {
        _promotionDescription = @"";
    }
    return _promotionDescription;
}

- (NSString *)promotionButtonTarget {
    if (!_promotionButtonTarget) {
        //Default to A&F home page.
        _promotionButtonTarget = @"https://m.abercrombie.com";
    }
    return _promotionButtonTarget;
}

- (NSString *)promotionButtonTitle {
    if (!_promotionButtonTitle) {
        //Default button title.
        _promotionButtonTitle = @"Click Here!";
    }
    return _promotionButtonTitle;
}

- (NSString *)footerText {
    if (!_footerText) {
        _footerText = @"";
    }
    return _footerText;
}

- (NSString *)imageUrl {
    if (!_imageUrl) {
        //TODO:Replace with a default image asset.
        _imageUrl = @"";//@"http://master-logo.blogspot.com/2015/04/abercrombie-and-fitch-logo-vector.html";
    }
    return _imageUrl;
}

@end
