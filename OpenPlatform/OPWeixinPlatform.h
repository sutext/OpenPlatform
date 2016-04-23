//
//  OPWeixinPlatform.h
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
@class OPShareMedia;
@class OPAuthObject;
@interface OPWeixinPlatform : NSObject<WXApiDelegate>
@property(nonatomic,strong)NSString *appid;
@property(nonatomic,strong)NSString *appkey;
-(void)shareWithMedia:(OPShareMedia *)media isChart:(BOOL)isChart completed:(void (^)(NSInteger errorCode)) completedBlock;
-(void)authCompleted:(void (^)(NSInteger errorCode,OPAuthObject *auth)) completedBlock;
@end
