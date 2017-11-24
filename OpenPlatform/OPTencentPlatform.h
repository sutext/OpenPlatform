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
@protocol OPShareObject;
@class OPAuthObject;
NS_ASSUME_NONNULL_BEGIN
@interface OPTencentPlatform : NSObject<QQApiInterfaceDelegate>
-(instancetype)initWithAppid:(NSString *)appid;
@property(nonatomic,strong)NSString *schema;
@property(strong,nullable,readonly)NSString * installURL;
-(BOOL)handleOpenURL:(NSURL *)url;
-(void)authCompleted:(void (^)(NSInteger errorCode,OPAuthObject *auth)) completedBlock;
-(void)shareWithMedia:(id<OPShareObject>)media isChart:(BOOL)isChart completed:(void (^)(NSInteger errorCode)) completedBlock;
@end
NS_ASSUME_NONNULL_END
