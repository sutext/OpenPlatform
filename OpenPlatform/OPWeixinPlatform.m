//
//  OPWeixinPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import <EasyTools/EasyTools.h>
#import "OPWeixinPlatform.h"
#import "OPOpenPlatform.h"
#import "OPShareMedia.h"
#import "OPAuthObject.h"
@interface OPWeixinPlatform()
@property(nonatomic,copy)void (^shareComplete)(NSInteger);
@property(nonatomic,copy)void (^authComplete)(NSInteger,OPAuthObject *);
@property(nonatomic,strong)ETNetworkManager *network;
@end
@implementation OPWeixinPlatform
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.network = [[ETNetworkManager alloc] initWithBaseURL:@"" monitorName:@"" timeoutInterval:20];
#if DEBUG
        [self.network setDebugEnable:YES];
#endif
    }
    return self;
}
-(void)authCompleted:(void (^)(NSInteger, OPAuthObject *))completedBlock
{
    self.authComplete=completedBlock;
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"123";
    [WXApi sendReq:req];
}
-(void)shareWithMedia:(OPShareMedia *)media isChart:(BOOL)isChart completed:(void (^)(NSInteger))completedBlock
{
    if (![WXApi isWXAppInstalled]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorNotInstall);
        }
        return;
    }
    if (![WXApi isWXAppSupportApi]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorUnsuport);
        }
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = media.title;
    message.description = media.content;
    message.thumbData=UIImageJPEGRepresentation(media.image, 0.1);
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = media.linkURL;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = isChart?WXSceneSession:WXSceneTimeline;
    
    if ([WXApi sendReq:req]) {
        self.shareComplete=completedBlock;
    }
    else
    {
        if (completedBlock) {
            completedBlock(OPPlatformErrorException);
        }
    }

}
#pragma mark - WXApiDelegate
- (void)onReq:(BaseReq *)req
{
    
}
- (void)onResp:(BaseReq *)resp
{
    if ([resp isKindOfClass:[SendMessageToWXResp class]] )
    {
        if (self.shareComplete) {
            SendMessageToWXResp *wxresp=(SendMessageToWXResp *)resp;
            self.shareComplete([self errorWithCode:wxresp.errCode]);
            self.shareComplete=nil;
        }
    }
    else if ([resp isKindOfClass:[SendAuthResp class]])
    {
        if (self.authComplete) {
            SendAuthResp *authresp = (SendAuthResp *)resp;
            OPPlatformError errorCode = [self errorWithCode:authresp.errCode];
            if (errorCode==OPPlatformErrorSucceed) {
                ETSimpleRequest *request = [ETSimpleRequest requestWithURL:@"https://api.weixin.qq.com/sns/oauth2/access_token" method:ETNetworkRequestMethodGET params:@{@"appid":self.appid,@"secret":self.appkey,@"code":authresp.code,@"grant_type":@"authorization_code"}];
                [self.network datataskWithRequest:request completedBlock:^(id<ETNetworkRequest> request, ETNetworkResponse *response, NSError *error) {
                    if (!error&&[response.entiyObject isKindOfClass:[NSDictionary class]]) {
                        [self handleResult:response.entiyObject];
                    }
                    else
                    {
                        self.authComplete(OPPlatformErrorException,nil);
                        self.authComplete=nil;
                    }
                }];
            }
            else
            {
                self.authComplete(errorCode,nil);
                self.authComplete=nil;
            }
        }
    }
}
-(void)handleResult:(NSDictionary *)dictionary
{
    OPAuthObject *auth = [[OPAuthObject alloc] init];
    auth.openid = dictionary[@"openid"];
    auth.tokenid = dictionary[@"access_token"];
    auth.unionid = dictionary[@"unionid"];
    ETSimpleRequest *request = [ETSimpleRequest requestWithURL:@"https://api.weixin.qq.com/sns/userinfo" method:ETNetworkRequestMethodGET params:@{@"openid":auth.openid,@"access_token":auth.tokenid}];
    [self.network datataskWithRequest:request completedBlock:^(id<ETNetworkRequest> request, ETNetworkResponse *response, NSError *error) {
        if (!error&&[response.entiyObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = response.entiyObject;
            auth.nickname = dic[@"nickname"];
            auth.gender = [dic[@"sex"] stringValue];
            auth.avatar = dic[@"headimgurl"];
            self.authComplete(OPPlatformErrorSucceed,auth);
            self.authComplete = nil;
        }
        else
        {
            self.authComplete(OPPlatformErrorException,nil);
            self.authComplete=nil;
        }
    }];
}
-(OPPlatformError)errorWithCode:(int)code
{
    OPPlatformError type=OPPlatformErrorUnknown;
    switch (code) {
        case    WXSuccess           :
        {
            type=OPPlatformErrorSucceed;
            break;
        }
        case    WXErrCodeCommon     :
        {
            type=OPPlatformErrorUnknown;
            break;
        }
        case    WXErrCodeUserCancel :
        {
            type=OPPlatformErrorCancel;
            break;
        }
        case    WXErrCodeSentFail   :
        {
            type=OPPlatformErrorException;
            break;
        }
        case    WXErrCodeAuthDeny   :
        {
            type=OPPlatformErrorRefuse;
            break;
        }
        case    WXErrCodeUnsupport  :
        {
            type=OPPlatformErrorUnsuport;
            break;
        }
            break;
        default:
            break;
    }
    return type;
}
@end
