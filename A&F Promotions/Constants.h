//
//  Constants.h
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#pragma mark - Macros
#define IS_EMPTY(value) (((value) == (id)[NSNull null] || (value) == nil || ([(value) isKindOfClass:[NSString class]] && ([(id)(value) isEqualToString:@""] || [(id)(value) isEqualToString:@"<null>"]))) ? YES : NO)

#pragma mark - API URLs
#define BASE_URL                    @"http://www.abercrombie.com/anf/nativeapp"
#define PROMOTIONS_URL BASE_URL     @"/Feeds/promotions.json"

#pragma mark - API Keys
#define kPROMO_BUTTON_KEY           @"button"
#define kPROMO_BUTTON_TARGET        @"target"
#define kPROMO_BUTTON_TITLE         @"title"
#define kPROMO_TITLE                @"title"
#define kPROMO_DESCRIPTION          @"description"
#define kPROMO_FOOTER_TEXT          @"footer"
#define kPROMO_IMAGE_URL            @"image"

#endif /* Constants_h */
