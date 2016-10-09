//
//  Http.h
//  AppFrame
//
//  Created by XiaoHuizhe on 15/6/13.
//  Copyright (c) 2015年 Huizhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define HttpMethodGet 0
#define HttpMethodPost 1
#define HttpMethodDelete 2
#define HttpMethodPut 3

#define CacheTimeLoadCacheIfExists -1
#define CacheTimeNoCache 0
@protocol AFMultipartFormData;
@class NSURLSessionTask;
typedef NSURLSessionTask HttpRequest;
@interface NSDictionary(JSONHelper)
//
// NSDictionary* test = @{@"a": @{@"b": @"ccc"} }
// [test get:@"a.b"]  => @"ccc"
//
-(id)get:(NSString*)name;
@end

@interface HttpAPI : NSObject
@property (nonatomic) int method;
@property (nonatomic, strong) NSString* url;
+(HttpAPI*) get:(NSString*)url;
+(HttpAPI*) post:(NSString*)url;
+(HttpAPI*) delete:(NSString*)url;
+(HttpAPI*) put:(NSString*)url;
@end

#define HttpGet(s) ([HttpAPI get:s])
#define HttpPost(s) ([HttpAPI post:s])
#define HttpDelete(s) ([HttpAPI delete:s])
#define HttpPut(s) ([HttpAPI put:s])

@interface Http : NSObject
+(NSDictionary*)getHeaders:(NSString*)url;
+(NSString*)formatUrl:(NSString*)url;
+(BOOL)needAuthToken:(NSString*)url;
+(void)setOfficalHosts:(NSArray*)hosts;
+(NSArray*)officalHosts;
+(void)registerPrefix:(NSString*)prefix forUrl:(NSString*)url;
+(void)setAuthorizationToken:(NSString*)token;
+(NSString*)authorizationToken;
+(void)cancelDelayedRequest:(NSString*)tag;
+(HttpRequest*)request:(__weak UIViewController*)controller method:(int)method url:(NSString*)url params:(NSDictionary*)params constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block cacheTime:(NSTimeInterval)cacheTime delayTime:(NSTimeInterval)delayTime delayTag:(NSString*)tag success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail done:(void (^)(HttpRequest *operation))done;
+(HttpRequest*)get:(__weak UIViewController*)controller url:(NSString*)url cacheTime:(NSTimeInterval)cacheTime success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail;
+(HttpRequest*)get:(__weak UIViewController*)controller url:(NSString*)url success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail;
+(HttpRequest*)post:(__weak UIViewController*)controller url:(NSString*)url params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail;

+(HttpRequest*)delete:(__weak UIViewController*)controller url:(NSString*)url params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail;

+(HttpRequest*)request:(__weak UIViewController*)controller api:(HttpAPI*)api urlArgs:(NSArray*)urlArgs params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail;

+(HttpRequest*)request:(__weak UIViewController*)controller api:(HttpAPI*)api params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail;

+(HttpRequest*)requestWithJson:(__weak UIViewController*)controller api:(HttpAPI*)api params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail;
+(HttpRequest*)requestWithPhotos:(__weak UIViewController*)controller api:(HttpAPI*)api urlArgs:(NSArray*)urlArgs params:(NSDictionary*)params constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block  success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail;
+(id)getCache:(NSString*)url;
+(NSTimeInterval)getCacheTime:(NSString*)url;

@end

