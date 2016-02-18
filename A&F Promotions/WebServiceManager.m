//
//  WebServiceManager.m
//  A&F Promotions
//
//  Created by Ravi Vuba on 2/17/16.
//  Copyright © 2016 Vuba Interactive. All rights reserved.
//

#import "AFNetworking.h"
#import "WebServiceManager.h"
#import "Constants.h"
#import "AFPromotion.h"

@interface WebServiceManager ()

@property (nonatomic, strong) AFHTTPSessionManager *requestOperationManager;

@end

@implementation WebServiceManager

#pragma mark - Initialization

static WebServiceManager *sharedInstance = nil;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebServiceManager alloc] initPrivate];
    });
    return sharedInstance;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Init is not available. Use sharedManager instead."
                                 userInfo:nil];
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _requestOperationManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _requestOperationManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        //Reset acceptable content types here.
        _requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    }
    return self;
}

#pragma mark - Public

- (void)getPromotionsWithCompletion:(void (^)(NSArray<AFPromotion *> *promotions, BOOL isCachedLocally, NSError *error))completion {
    NSError *requestError = nil;
    NSString *resourcesPath = [[self getBasePath] stringByAppendingPathComponent:PROMOTIONS_URL];
    NSString *resourcesJSONFilePath = [resourcesPath stringByAppendingPathExtension:@"json"];
    
    NSMutableURLRequest *request = [self.requestOperationManager.requestSerializer requestWithMethod:@"GET"
                                                                                           URLString:PROMOTIONS_URL
                                                                                          parameters:nil
                                                                                               error:&requestError];
    if (!requestError) {
        [self fetchLocalContentIfAvailableWithRequest:request basePathString:resourcesPath andFilePath:resourcesJSONFilePath withCompletion:^(NSDictionary *response, BOOL isCachedLocally, NSError *error) {
            NSMutableArray *responseArray = [NSMutableArray new];
            
            if (!error) {
                NSArray <NSDictionary *> *promotions = [response objectForKey:@"promotions"];
                [promotions enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull promoDictionary, NSUInteger idx, BOOL * _Nonnull stop) {
                    AFPromotion *promotionObject = [[AFPromotion alloc] initWithDictionary:promoDictionary];
                    [responseArray addObject:promotionObject];
                }];
            }
            
            if (completion) {
                completion(responseArray, isCachedLocally, error);
            }
        }];
    }
    else {
        //Some error creating url request.
        NSLog(@"Error creating get content request:%@ for url:%@", requestError.description, PROMOTIONS_URL);
        if (completion) {
            completion(nil, NO, requestError);
        }
    }
}

#pragma mark - Content Retrival

- (void)fetchContentWithRequest:(NSURLRequest *)request withCompletion:(void (^)(NSDictionary *response, BOOL isCachedResponse, NSError *error))completionHandler {
    BOOL __block isCachedResponse = YES;
    NSURLSessionDataTask *dataTask = [self.requestOperationManager dataTaskWithRequest:request
                                                                     completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                                         if(!error) {
                                                                             if (![responseObject isKindOfClass:[NSNull class]]) {
                                                                                 completionHandler(responseObject, isCachedResponse, error);
                                                                             }
                                                                             else {
                                                                                 NSDictionary *userInfo = @{
                                                                                                            NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                                                                                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The NSHTTPURLResponse is Null.", nil),
                                                                                                            };
                                                                                 NSError *err = [NSError errorWithDomain:BASE_URL
                                                                                                                    code:0
                                                                                                                userInfo:userInfo];
                                                                                 if (completionHandler) {
                                                                                     completionHandler(nil, NO, err);
                                                                                 }
                                                                             }
                                                                         }
                                                                         else {
                                                                             completionHandler(responseObject, isCachedResponse, error);
                                                                         }
                                                                     }];
    
    [self.requestOperationManager setDataTaskWillCacheResponseBlock:^NSCachedURLResponse *(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse) {
        isCachedResponse = NO;
        return proposedResponse;
    }];
    
    [dataTask resume];
}

#pragma mark - Local File Storage

- (void)fetchLocalContentIfAvailableWithRequest:(NSMutableURLRequest *)request
                                 basePathString:(NSString *)basePath
                                    andFilePath:(NSString *)filepath
                                 withCompletion:(void (^)(NSDictionary *response, BOOL isCachedLocally, NSError *error))completion {
    
    //Call back once if the file exists locally for faster load.
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
    if (exists) {
        [self getCachedFileAtPath:filepath maxFileAge:NSTimeIntervalSince1970 withCompletion:^(NSDictionary *response, NSError *error) {
            if (error == nil && response != nil) {
                if (completion)
                    completion(response, exists, nil);
            }
            else {
                //Some error occurred fetching from local storage
                NSLog(@"retrieving the cached file at %@ failed with error %@", filepath, error.localizedDescription);
            }
            
            //Then make an API call to the server to get the updated content from server.
            [self fetchAndSaveData:request basePathString:basePath andFilePath:filepath withCompletion:completion];
        }];
    }
    else {
        [self fetchAndSaveData:request basePathString:basePath andFilePath:filepath withCompletion:completion];
    }
}

- (void)fetchAndSaveData:(NSMutableURLRequest *)request
          basePathString:(NSString *)basePath
             andFilePath:(NSString *)filepath
          withCompletion:(void (^)(NSDictionary *response, BOOL isCachedLocally, NSError *error))completion {
    [self fetchContentWithRequest:request withCompletion:^(NSDictionary *response, BOOL isCachedResponse, NSError *error) {
        if (!error) {
            NSData *jsonData;
            NSError *jsonError;
            jsonData = [NSJSONSerialization dataWithJSONObject:response options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"%s Error converting json to NSData: %@", __PRETTY_FUNCTION__, jsonError);
            }
            else {
                if (![[NSFileManager defaultManager] fileExistsAtPath:basePath isDirectory:nil]) {
                    NSError *createDirectoryError;
                    [[NSFileManager defaultManager] createDirectoryAtPath:basePath
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:&createDirectoryError];
                    if (createDirectoryError) {
                        NSLog(@"%s Error creating directory at %@: %@", __PRETTY_FUNCTION__, basePath, createDirectoryError);
                    }
                }
                
                NSError *fileSaveError;
                [jsonData writeToFile:filepath options:0 error:&fileSaveError];
                
                if (fileSaveError) {
                    NSLog(@"%@ failed to save", filepath);
                    if (completion) {
                        completion(nil, isCachedResponse, fileSaveError);
                    }
                }
                else if (completion)
                    completion(response, isCachedResponse, error);
            }
        }
        else {
            completion(nil, NO, error);
            NSLog(@"File doesn't exist in cache and the web service failed with error:%@", error.description);
        }
    }];
}

- (void)getCachedFileAtPath:(NSString *)filePath maxFileAge:(NSTimeInterval)maxFileAgeInSeconds withCompletion:(void (^)(NSDictionary *response, NSError *error))completion {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *jsonDict = nil;
        NSError *responseError = nil;
        NSError *attributesRetrievalError = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&attributesRetrievalError];
        //If file manager fails with error, call completion with attributes error.
        if (attributesRetrievalError) {
            NSLog(@"%s Error retrieving file attributes for file at %@: %@", __PRETTY_FUNCTION__, filePath, attributesRetrievalError);
            responseError = attributesRetrievalError;
        }
        else {
            NSDate *fileCreationDate = attributes.fileCreationDate;
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitSecond fromDate:fileCreationDate toDate:[NSDate date] options:0];
            NSInteger fileAgeInSeconds = components.second;
            
            if (fileAgeInSeconds <= maxFileAgeInSeconds) {
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                NSError *jsonError;
                jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                //If the JSON serilization fails with error, remove item at local file path
                if (jsonError) {
                    NSLog(@"%s Error parsing file at %@: %@", __PRETTY_FUNCTION__, filePath, jsonError);
                    NSError *deleteError;
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&deleteError];
                    
                    //If cannot delete existing item at file path, call completion with deletion error.
                    if (deleteError) {
                        NSLog(@"%s Error deleting file at %@: %@", __PRETTY_FUNCTION__, filePath, deleteError);
                        responseError = deleteError;
                    }
                    else {
                        //Call completion with JSON error after removing the item at local file path
                        responseError = jsonError;
                    }
                }
                
                //Successfully retrieved file from local file path. Call completion with JSON response.
                if (completion)
                    completion(jsonDict, responseError);
            }
            else {
                //If the file at local path exists for more than the max file age, purge it and call completion block
                NSError *deleteError;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&deleteError];
                if (deleteError)
                    NSLog(@"%s Error deleting old resources.json file: %@", __PRETTY_FUNCTION__, deleteError);
                
                if (completion)
                    completion (nil, deleteError);
                
            }
        }
    }
}

#pragma mark - Helper

//Get Path of directory
- (NSString *)getBasePath {
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    NSString *basePath = [libraryPath stringByAppendingPathComponent:@"Application Content"];
    return basePath;
}

@end
