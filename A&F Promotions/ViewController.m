//
//  ViewController.m
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#import "ViewController.h"
#import "AFPromotionsTableViewCell.h"
#import "WebServiceManager.h"
#import "AFPromotion.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <AFPromotion *> *promotions;

@end

@implementation ViewController

#pragma mark - Getter/Setter

- (NSMutableArray<AFPromotion *> *)promotions {
    if (!_promotions) {
        _promotions = [NSMutableArray new];
    }
    return _promotions;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self getPromotions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web Service Calls

- (void)getPromotions {
    [[WebServiceManager sharedManager] getPromotionsWithCompletion:^(NSArray<AFPromotion *> *promotions, BOOL isCachedLocally, NSError *error) {
        if (!error) {
            if (!isCachedLocally) {
                //If this data doesn't exist locally, remove all
                //objects and reload the tableview with new response.
                _promotions = nil;
            }
            
            //Load the response into the tableview datasource array.
            [self.promotions addObjectsFromArray:promotions];
            
            //Reload table view on main thread as the completion
            //call back might happen on a secondary thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else {
            NSLog(@"Error loading promotions:%@", error.description);
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.promotions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AFPromotionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PromotionsTableViewCell"];
    AFPromotion *promotionObject = [self.promotions objectAtIndex:indexPath.row];
    [cell configureWithPromotion:promotionObject];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO:Show a promotion detail view.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0f;//Based on the storyboard.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
