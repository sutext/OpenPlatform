//
//  OPWeixinPlatform.h
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenPlatform/OPPlatformProtocol.h>

@class OPShareObject;
@class OPAuthObject;
NS_ASSUME_NONNULL_BEGIN
@interface OPWeixinPlatform : NSObject<OPPlatformProtocol>
-(instancetype)initWithAppid:(NSString *)appid appkey:(NSString *)appkey;
@property(nonatomic,strong)NSString *appid;
@property(nonatomic,strong)NSString *appkey;
-(void)shareWithMedia:(OPShareObject *)media isChart:(BOOL)isChart completed:(void (^)(NSInteger errorCode)) completedBlock;
-(void)authCompleted:(void (^)(NSInteger errorCode,NSString *token)) completedBlock;
@end
NS_ASSUME_NONNULL_END
