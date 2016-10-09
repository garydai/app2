 //
//  Http.m
//  AppFrame
//
//  Created by XiaoHuizhe on 15/6/13.
//  Copyright (c) 2015年 Huizhe. All rights reserved.
//

#import "Http.h"
#import "AFNetworking.h"
#import "NSString+NSHash.h"
#define DD_LEGACY_MACROS 1

@implementation NSDictionary(JSONHelper)
-(id)get:(NSString*)name{
    NSArray* parts = [name componentsSeparatedByString:@"."];
    id result = self;
    for (NSString* p in parts) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            result = [result objectForKey:p];
            continue;
        }else if([result isKindOfClass:[NSArray class]]){
            result = [result objectAtIndex:[p integerValue]];
            continue;
        }
        return nil;
    }
    if([result isKindOfClass:[NSNull class]]) return nil;
    return result;
}
@end
@implementation HttpAPI

+(HttpAPI*) get:(NSString*)url{
    HttpAPI* result = [[HttpAPI alloc] init];
    result.method = HttpMethodGet;
    result.url = url;
    return result;
}
+(HttpAPI*) post:(NSString*)url{
    
    HttpAPI* result = [[HttpAPI alloc] init];
    result.method = HttpMethodPost;
    result.url = url;
    return result;
}

+(HttpAPI*) delete:(NSString*)url{
    
    HttpAPI* result = [[HttpAPI alloc] init];
    result.method = HttpMethodDelete;
    result.url = url;
    return result;
}
+(HttpAPI*) put:(NSString*)url{
    
    HttpAPI* result = [[HttpAPI alloc] init];
    result.method = HttpMethodPut;
    result.url = url;
    return result;
}

@end
@implementation Http
#define URL_PREFIX_CHAR @":"
#define URL_DEFAULT_PREFIX @"::"
typedef void (^AF_SUCCESS_CB)(NSURLSessionTask *operation, id responseObject);
typedef void (^AF_FAIL_CB)(NSURLSessionTask *operation, NSError* err);

/*
+(NSDictionary*)getHeaders:(NSString*)url{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    if ([self needAuthToken:url] && authorizationToken) {
        [dic setObject:[NSString stringWithFormat:@"AppFrame %@", authorizationToken] forKey:@"Authorization"];
    }
    return dic;
}
 */
static NSString* authorizationToken = nil;
+(void)setAuthorizationToken:(NSString*)token{
    authorizationToken = token;
}
+(NSString*)authorizationToken{
    return authorizationToken;
}
+(NSString*)formatUrl:(NSString*)url{
    if(!url) url = @"";
    if(url.length == 0 || [url hasPrefix:@"/"]){
        return [NSString stringWithFormat:@"%@%@", [urlPrefixes objectForKey:URL_DEFAULT_PREFIX], url];
    }
    if([url hasPrefix:URL_PREFIX_CHAR]){
        NSUInteger endIndex = [url rangeOfString:URL_PREFIX_CHAR options:0 range:NSMakeRange(1, url.length-1)].location;
        NSString* prefix = [url substringToIndex:endIndex];
        return [NSString stringWithFormat:@"%@%@", [urlPrefixes objectForKey:prefix], [url substringFromIndex:prefix.length]];
    }
    return url;
}
/*
+(BOOL)needAuthToken:(NSString*)url{
    if(!url) return false;
    url = [url lowercaseString];
    if(![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]){
        // 是类似 /user/add 这种shortcut url
        return true;
    }
    NSURL* u = [NSURL URLWithString:url];
    
    NSString* host = u.host;
    if(!host.length) return false;
    host = [host stringByReplacingOccurrencesOfRegex:@"\\:\\d+" withString:@""];
    
    for(NSString* allowedHost in officalHosts){
        if([allowedHost isEqualToString:host] || [host hasSuffix:[NSString stringWithFormat:@".%@", allowedHost]]){
            return true;
        }
    }
    
    return false;
}
 */
static NSArray* officalHosts = nil;
+(NSArray*)officalHosts{
    return officalHosts;
}
+(void)setOfficalHosts:(NSArray*)hosts{
    officalHosts = hosts;
}
static NSMutableDictionary* urlPrefixes = nil;
+(void)registerPrefix:(NSString*)prefix forUrl:(NSString*)url{
    if(!urlPrefixes) urlPrefixes = [[NSMutableDictionary alloc] init];
    [urlPrefixes setObject:url forKey:prefix];
}
static NSString* cacheFolder = nil;
+(NSString*)cacheFolder{
    if (!cacheFolder) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        BOOL isDir = NO;
        cachePath = [cachePath stringByAppendingPathComponent:@"httpcache"];
        NSError *error;
        if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir]) {
            if(![[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error]){
                [NSException raise:@"cannot create cache folder" format:@"%@", error.description];
                return nil;
            }
        }
        cacheFolder = cachePath;
    }
    return cacheFolder;
}
+(id)getCache:(NSString*)url{
    
    NSString* file = [[self cacheFolder] stringByAppendingPathComponent:[url MD5]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) return nil;
    NSData* data = [NSData dataWithContentsOfFile:file];
    if (!data)
        return nil;
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
}
+(NSTimeInterval)getCacheTime:(NSString*)url{
    
    NSString* file = [[self cacheFolder] stringByAppendingPathComponent:[url MD5]];
    
    NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
    
    if (attrs != nil) {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        return [date timeIntervalSince1970];
    } else {
        return -1;
    }
}
+(void)writeCache:(NSString*)url data:(id)data{
    if (!url)
        return;
    NSString* file = [[self cacheFolder] stringByAppendingPathComponent:[url MD5]];
    if (!data)
        [[NSFileManager defaultManager] removeItemAtPath:file error:NULL];
    else
        [[NSJSONSerialization dataWithJSONObject:data options:0 error:NULL] writeToFile:file atomically:YES];
}
+(HttpRequest*)doRequest:(__weak UIViewController*)controller method:(int)method url:(NSString*)url params:(NSDictionary*)params constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block cacheTime:(NSInteger)cacheTime success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, NSURLSessionTask *operation))fail done:(void (^)(HttpRequest *operation))done requestJson:(bool)json{
    
    if (method == HttpMethodGet && (cacheTime == CacheTimeLoadCacheIfExists || cacheTime > 0.01f)) {
        NSTimeInterval ct = [self getCacheTime:url];
        id responseObject = [self getCache:url];
        
        if (responseObject && ct > 0 && (cacheTime == CacheTimeLoadCacheIfExists || [[NSDate date] timeIntervalSince1970] - ct > cacheTime)) {
            // cache 有效
            if (success) success(responseObject, nil);
            if (done) done(nil);
            return nil;
        }
    }
    NSString* methodStr = method == HttpMethodGet ? @"Get" : @"Post";
  //  DDLogDebug(@"Http %@ %@", methodStr, url);
    
    NSString* formattedURL = [self formatUrl:url];
   // NSDictionary* headers = [self getHeaders:formattedURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
   // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(json)
    {
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
   // [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   // [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  //  manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = requestSerializer;
    }
   // manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
   // for (NSString* k in headers.allKeys) {
     //   [manager.requestSerializer setValue:[headers objectForKey:k] forHTTPHeaderField:k];
   // }
  // manager.responseSerializer.acceptableStatusCodes [NSIndexSet indexSetWithIndex:400];
    AF_SUCCESS_CB successCB = ^(NSURLSessionTask *operation, id responseObject) {
        
        NSString* errorCode = nil;
        NSString *message = nil, *messageType = nil, *stackTrace = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
           
            NSNumber *responseStatus = [responseObject get:@"statusCode"];
            if ([responseStatus integerValue] == 200) {      //      DDLogDebug(@"Http %@ Success %@ %@", methodStr, url, operation.responseString);
                NSDictionary* responseData = [responseObject get:@"data"];
                if (method == HttpMethodGet && responseData) {
                    [self writeCache:url data:responseData];
                }
                if(controller && message)
                {
        //        [Utils hudShowWithText:message];
                }
                if(success) success(responseData, operation);
            }
          //  else if(message)
           // {
             //   [Utils hudShowWithText:message];
            //}
        }
        
        if(done) done(operation);
        
    };
    AF_FAIL_CB failCB = ^(NSURLSessionTask *operation, NSError *error) {
    //    DDLogDebug(@"Http %@ Fail %@ %@", methodStr, url, error.description);
        NSString* errorCode, *message;
        NSInteger statusCode = ((NSHTTPURLResponse*)operation.response).statusCode;
        if(statusCode){
            
            errorCode = @"ServerError";
            message = @"服务器错误";
            if(statusCode == 400)
            {
                /*
               id responseObject = operation.responseObject;
                NSString* errorCode = nil;
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSString *messageType = nil, *stackTrace = nil;
                    NSDictionary* responseStatus = [responseObject get:@"ResponseStatus"];
                    if (responseStatus) {
                        errorCode = [responseStatus get:@"ErrorCode"];
                        message = [responseStatus get:@"Message"];
                        NSRange range = [message rangeOfString:@"||"];
                        if (range.location != NSNotFound) {
                            messageType = [message substringToIndex:range.location];
                            message = [message substringFromIndex:range.location + range.length];
                        }
                        stackTrace = [responseStatus get:@"StackTrace"];
                    }
                    if (errorCode.length && !message.length) {
                        message = @"未知错误";
                    }
                    if (errorCode.length && !messageType.length) {
                        messageType = @"error";
                    }

                }
                 */
            }
        }else{
            errorCode = @"NetworkError";
            message = @"网络错误";
        }
        
        if (controller) {
         //   [SVProgressHUD showErrorWithStatus:message];
           // [TSMessage showNotificationWithTitle:message type:TSMessageNotificationTypeError];
        }
        
        if(message && controller){
            
        }
          //  [Utils hudShowWithText:message];
        if(fail)
        {
            
        }
            //fail(errorCode, operation);
        
        if(done)
        {
            
        }
        //    done(operation);
        
    };
    if(block){
        return [manager POST:formattedURL parameters:params constructingBodyWithBlock:block progress:nil success:successCB failure:failCB];
        
      //  return [manager POST:formattedURL parameters:params constructingBodyWithBlock:block success:successCB failure:failCB];
        
    }
    
    if(method == HttpMethodGet){
        
        return [manager GET:formattedURL parameters:params success:successCB failure:failCB];
    }else if(method == HttpMethodPost){
        return [manager POST:formattedURL parameters:params success:successCB failure:failCB];
    }
    else if(method == HttpMethodDelete)
    {
        return [manager DELETE:formattedURL parameters:params success:successCB failure:failCB];
    }
    else if(method == HttpMethodPut)
    {
        return [manager PUT:formattedURL parameters:params success:successCB failure:failCB];
    }
    // 不支持的 method
    assert(false);
}
static NSMutableDictionary* delayExecutingRequests = nil;
+(HttpRequest*)request:(__weak UIViewController*)controller method:(int)method url:(NSString*)url params:(NSDictionary*)params constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block cacheTime:(NSTimeInterval)cacheTime delayTime:(NSTimeInterval)delayTime delayTag:(NSString*)tag success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail done:(void (^)(HttpRequest *operation))done requestJson:(bool)json{
    if (delayTime > 0.0001f) {
        if (!delayExecutingRequests) {
            delayExecutingRequests = [[NSMutableDictionary alloc] init];
        }
        if(tag)
            [delayExecutingRequests setObject:@"1" forKey:tag];
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * delayTime);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
            if (tag) {
                // 已经被cancel了
                if(![delayExecutingRequests objectForKey:tag]) return;
            }
            [self doRequest:controller method:method url:url params:params constructingBodyWithBlock:block cacheTime:cacheTime success:success fail:fail done:done requestJson:json];
        });
        return nil;
    }
    
    return [self doRequest:controller method:method url:url params:params constructingBodyWithBlock:block cacheTime:cacheTime success:success fail:fail done:done requestJson:json];
}
+(void)cancelDelayedRequest:(NSString*)tag{
    [delayExecutingRequests removeObjectForKey:tag];
}
+(HttpRequest*)get:(__weak UIViewController*)controller url:(NSString*)url cacheTime:(NSTimeInterval)cacheTime success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail{
    return [self request:controller method:HttpMethodGet url:url params:nil constructingBodyWithBlock:nil cacheTime:cacheTime delayTime:0 delayTag:nil success:success fail:fail done:nil requestJson:false];
}
+(HttpRequest*)get:(__weak UIViewController*)controller url:(NSString*)url success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail{
    return [self get:controller url:url cacheTime:0 success:success fail:fail];
}
+(HttpRequest*)post:(__weak UIViewController*)controller url:(NSString*)url params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail{
    return [self request:controller method:HttpMethodPost url:url params:params constructingBodyWithBlock:nil cacheTime:0 delayTime:0 delayTag:nil success:success fail:fail done:nil requestJson:false];
}

+(HttpRequest*)delete:(__weak UIViewController*)controller url:(NSString*)url params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail{
    return [self request:controller method:HttpMethodDelete url:url params:params constructingBodyWithBlock:nil cacheTime:0 delayTime:0 delayTag:nil success:success fail:fail done:nil requestJson:false];
}

+ (id)stringWithFormat:(NSString *)format array:(NSArray *)arguments
{
    if ( arguments.count > 10 ) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Maximum of 10 arguments allowed" userInfo:@{@"collection": arguments}];
    }
    NSArray* a = [arguments arrayByAddingObjectsFromArray:@[@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X"]];
    return [NSString stringWithFormat:format, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10] ];
}
+(HttpRequest*)request:(__weak UIViewController*)controller api:(HttpAPI*)api urlArgs:(NSArray*)urlArgs params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail{
    return [self request:controller method:api.method url:[self stringWithFormat:api.url array:urlArgs] params:params constructingBodyWithBlock:nil cacheTime:0 delayTime:0 delayTag:nil success:success fail:fail done:nil requestJson:false];
}

+(HttpRequest*)requestWithJson:(__weak UIViewController*)controller api:(HttpAPI*)api  params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail{
    return [self request:controller method:api.method url:api.url params:params constructingBodyWithBlock:nil cacheTime:0 delayTime:0 delayTag:nil success:success fail:fail done:nil requestJson:true];
}

+(HttpRequest*)request:(__weak UIViewController*)controller api:(HttpAPI*)api params:(NSDictionary*)params success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail{
    return [self request:controller method:api.method url:api.url params:params constructingBodyWithBlock:nil cacheTime:0 delayTime:0 delayTag:nil success:success fail:fail done:nil requestJson:false];
}

+(HttpRequest*)requestWithPhotos:(__weak UIViewController*)controller api:(HttpAPI*)api urlArgs:(NSArray*)urlArgs params:(NSDictionary*)params constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block  success:(void (^)(id responseObject, HttpRequest *operation))success fail:(void (^)(NSString* errorCode, HttpRequest *operation))fail{
    return [self request:controller method:api.method url:[self stringWithFormat:api.url array:urlArgs] params:params constructingBodyWithBlock:block cacheTime:0 delayTime:0 delayTag:nil success:success fail:fail done:nil requestJson:false ];
}

@end



