//
//  OPTencentPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <TencentOpenAPI/TencentOAuth.h>
#import "OPTencentPlatform.h"
#import "OPOpenPlatform.h"
#import "OPShareMedia.h"
@interface OPTencentPlatform()<TencentSessionDelegate>
@property(nonatomic,copy)void (^shareComplete)(NSInteger);
@property(nonatomic,strong)TencentOAuth * tencent;
@end
@implementation OPTencentPlatform

- (instancetype)initWithAppid:(NSString *)appid
{
    self = [super init];
    if (self) {
        self.tencent = [[TencentOAuth alloc] initWithAppId:appid andDelegate:self];
    }
    return self;
}
-(void)shareWithMedia:(OPShareMedia *)media isChart:(BOOL)isChart completed:(void (^)(NSInteger))completedBlock
{
    if (![QQApiInterface isQQInstalled]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorNotInstall);
        }
        return;
    }
    if (![QQApiInterface isQQSupportApi]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorUnsuport);
        }
        return;
    }
    QQApiURLObject *urlobj=[[QQApiURLObject alloc] initWithURL:[NSURL URLWithString:media.linkURL]
                                                         title:media.title
                                                   description:media.content
                                              previewImageData:UIImageJPEGRepresentation(media.image, 0.1)
                                             targetContentType:QQApiURLTargetTypeNews];
    
    QQApiSendResultCode code=0;
    if (isChart) {
        code= [QQApiInterface sendReq:[SendMessageToQQReq reqWithContent:urlobj]];
    }
    else
    {
        code=[QQApiInterface SendReqToQZone:[SendMessageToQQReq reqWithContent:urlobj]];
    }
    if (code==EQQAPIAPPSHAREASYNC||code==EQQAPISENDSUCESS) {
        self.shareComplete=completedBlock;
    }
    else
    {
        if (completedBlock) {
            completedBlock([self erroTypeWithResult:code]);
        }
        return;
    }
}
- (OPPlatformError)erroTypeWithResult:(QQApiSendResultCode)sendResult
{
    OPPlatformError result=OPPlatformErrorUnknown;
    switch (sendResult)
    {
        case EQQAPIQQNOTINSTALLED:
        {
            result=OPPlatformErrorNotInstall;
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            result=OPPlatformErrorUnsuport;
            break;
        }
        case EQQAPISENDFAILD:
        {
            result=OPPlatformErrorUnknown;
            break;
        }
        case EQQAPIAPPNOTREGISTED:
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            result=OPPlatformErrorException;
            break;
        }
        default:
        {
            break;
        }
    }
    return result;
}

#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req
{
}
- (void)onResp:(QQBaseResp *)resp
{
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        if (self.shareComplete) {
            OPPlatformError type=OPPlatformErrorUnknown;
            if ([resp.result isEqualToString:@"0"]) {
                type=OPPlatformErrorSucceed;
            }
            else if ([resp.result isEqualToString:@"-4"])
            {
                type=OPPlatformErrorCancel;
            }
            self.shareComplete(type);
            self.shareComplete=nil;
        }
    }
}


- (void)isOnlineResponse:(NSDictionary *)response
{
    
}
#pragma mark QQ methods
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin
{
    [self.tencent getUserInfo];
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork
{
}
- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
    
}
- (void)getUserInfoResponse:(APIResponse*) response
{
}

@end
