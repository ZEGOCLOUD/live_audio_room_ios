//
//  ZegoToken.h
//  ZIMChatRoomDemo
//
//  Created by Kael Ding on 2021/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoToken : NSObject

+ (NSString *)getTokenWithUserID:(NSString *)userID
                              appID:(uint32_t)appID
                       appSecret:(NSString *)appSecret;

@end

NS_ASSUME_NONNULL_END
