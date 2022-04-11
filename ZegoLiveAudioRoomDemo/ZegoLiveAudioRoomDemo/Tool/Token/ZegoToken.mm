//
//  ZegoToken.m
//  ZIMChatRoomDemo
//
//  Created by Kael Ding on 2021/11/24.
//

#import "ZegoToken.h"
#import "ZegoRTCServerAssistant.h"
#import "ZegoServerAssistant.h"

@implementation ZegoToken

+ (NSString *)getTokenWithUserID:(NSString *)userID
                              appID:(uint32_t)appID
                          appSecret:(NSString *)appSecret
          effectiveTimeInSeconds:(int64_t)effectiveTimeInSeconds {
    auto tokenResult = ZEGO::SERVER_ASSISTANT::ZegoServerAssistant::GenerateToken(appID,
                                                                                  userID.UTF8String,
                                                                                  appSecret.UTF8String,
                                                                                  effectiveTimeInSeconds);
    NSString *token = [NSString stringWithCString:tokenResult.token.c_str() encoding:NSUTF8StringEncoding];
    return token;
}


@end
