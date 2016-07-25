//
//  Constants.h
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#if DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#    define DLog(...)
#endif

#define kHost @"https://home.sensibo.com"
#define kSensiboCookie @"SensiboCookie"
#define kUsername @"username"

#define kLoginMethodPath @"/api/v1/sessions"
#define kInitialInfoMethodPath @"/api/v1/sessions/this/initialInfo"
#define kUpdateACStateMethodPathTemplate @"/api/v2/pods/%@/acStates/%@?fields=id,acState"

#define kAFNetworkingResponseErrorKey @"com.alamofire.serialization.response.error.data"
#define kSensiboNetworkOperationErrorKey @"kSensiboNetworkOperationErrorKey"

#endif /* Constants_h */
