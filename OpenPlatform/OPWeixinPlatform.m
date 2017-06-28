//
//  OPWeixinPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//

#import "OPWeixinPlatform.h"
#import "OPOpenPlatform.h"
#import "OPShareMedia.h"
#import "OPAuthObject.h"
@interface OPWeixinPlatform()
@property(nonatomic,copy)void (^shareComplete)(NSInteger);
@property(nonatomic,copy)void (^authComplete)(NSInteger,OPAuthObject *);
@end
@implementation OPWeixinPlatform
-(void)authCompleted:(void (^)(NSInteger, OPAuthObject *))completedBlock
{
    if (![WXApi isWXAppInstalled]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorNotInstall,nil);
        }
        return;
    }
    if (![WXApi isWXAppSupportApi]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorUnsuport,nil);
        }
        return;
    }
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
                OPAuthObject *auth = [[OPAuthObject alloc] init];
                auth.token = authresp.code;
                self.authComplete(OPPlatformErrorSucceed,auth);
                self.authComplete=nil;
            }
            else
            {
                self.authComplete(errorCode,nil);
                self.authComplete=nil;
            }
        }
    }
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
