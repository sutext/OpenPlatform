//
//  OPPlatformProtocol.h
//  OpenPlatform
//
//  Created by supertext on 2017/11/27.
//  Copyright © 2017年 icegent. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@protocol OPPlatformProtocol<NSObject>
@property(nonatomic,readonly)BOOL isInstalled;
@property(nonatomic,strong,nullable,readonly)NSString * installURL;
-(BOOL)handelOpenURL:(NSURL *)openURL;
-(BOOL)open;
@end
@protocol OPWeiboProtocol<OPPlatformProtocol>
-(void)linkToUser:(nullable NSString *)user;
@end

typedef NS_ENUM(NSUInteger, OPPaymentStatus) {
    OPPaymentStatusUnknown,
    OPPaymentStatusFailed,
    OPPaymentStatusCancel,
    OPPaymentStatusRefuse,
    OPPaymentStatusSucceed,
    OPPaymentStatusNetError,
    OPPaymentStatusUnsuport,
    OPPaymentStatusProcessing,
    OPPaymentStatusNotInstall,
};
@interface OPPaymentInfo:NSObject
@property(nonatomic,strong,nullable)NSString * sign;
@property(nonatomic,strong,nullable)NSString * appid;
@property(nonatomic,strong,nullable)NSString * package;
@property(nonatomic,strong,nullable)NSString * prepayid;
@property(nonatomic,strong,nullable)NSString * noncestr;
@property(nonatomic,strong,nullable)NSString * partnerid;
@property(nonatomic,strong,nullable)NSString * timestamp;
@end
@protocol OPPlatformPayment<OPPlatformProtocol>
-(void)paymentWithInfo:(OPPaymentInfo *)info finishBlock:(nullable void (^)(OPPaymentStatus)) finishBlock;
@end
NS_ASSUME_NONNULL_END
