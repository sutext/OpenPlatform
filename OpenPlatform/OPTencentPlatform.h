//
//  OPTencentPlatform.h
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <CoreTelephony/CoreTelephonyDefines.h>
@class OPShareMedia;
@interface OPTencentPlatform : NSObject<QQApiInterfaceDelegate>
-(instancetype)initWithAppid:(NSString *)appid;
@property(nonatomic,strong)NSString *schema;
-(void)shareWithMedia:(OPShareMedia *)media isChart:(BOOL)isChart completed:(void (^)(NSInteger errorCode)) completedBlock;
@end
