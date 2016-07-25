//
//  NSDictionary+ResponseObject.m
//  Yaga
//
//  Created by Iegor on 12/17/14.
//  Copyright (c) 2014 Raj Vir. All rights reserved.
//

#import "NSDictionary+ResponseObject.h"

@implementation NSDictionary (ResponseObject)
+ (NSDictionary *)dictionaryFromResponseObject:(id)responseObject withError:(NSError *)error;
{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *res = (NSDictionary *)responseObject;
        return res;
    } else if ([responseObject isKindOfClass:[NSString class]]) {
        @try {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:[responseObject dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
        return JSON;
        }
        @catch (NSException *e) {
            return nil;
        }
    }else {
        @try {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error: &error];
            return JSON;
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
}

- (NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        DLog(@"jsonStringFromDictionary: error: %@", error.localizedDescription);
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
}

@end
