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
#import "WXApi.h"
@interface OPWeixinPlatform()<WXApiDelegate>
@property(nonatomic,copy)void (^shareComplete)(NSInteger);
@property(nonatomic,copy)void (^authComplete)(NSInteger,NSString *);
@end
@implementation OPWeixinPlatform
- (instancetype)initWithAppid:(NSString *)appid appkey:(NSString *)appkey
{
    self = [super init];
    if (self) {
        self.appkey      = appkey;
        self.appid       = appid;
        
        [WXApi registerApp:appid enableMTA:NO];

    }
    return self;
}
-(void)authCompleted:(void (^)(NSInteger, NSString *))completedBlock
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
-(void)shareWithMedia:(OPShareObject *)media isChart:(BOOL)isChart completed:(void (^)(NSInteger))completedBlock
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
    message.thumbData=media.thumbData;
    if ([media isKindOfClass:[OPShareWebpage class]]){
        WXWebpageObject *webpage = [WXWebpageObject object];
        webpage.webpageUrl = ((OPShareWebpage *)media).weburl;
        message.mediaObject = webpage;
    }else if([media isKindOfClass:[OPShareMusic class]]) {
        WXMusicObject *music = [WXMusicObject object];
        OPShareMusic *share = (OPShareMusic *)media;
        music.musicUrl = share.weburl;
        music.musicDataUrl = share.dataURL;
        music.musicLowBandUrl = share.lowbandURL;
        music.musicLowBandDataUrl = share.lowbandDataURL;
        message.mediaObject = music;
    }else if ([media isKindOfClass:[OPShareImage class]]){
        WXImageObject * image = [WXImageObject object];
        OPShareImage *share = (OPShareImage *)media;
        image.imageData = share.imageData;
        message.mediaObject = image;
    }
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
-(NSString *)installURL{
    return WXApi.getWXAppInstallUrl;
}
-(BOOL)isInstalled{
    return [WXApi isWXAppInstalled];
}
-(BOOL)handelOpenURL:(NSURL *)openURL{
    return  [WXApi handleOpenURL:openURL delegate:self];
}
-(BOOL)open{
    return [WXApi openWXApp];
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
                self.authComplete(OPPlatformErrorSucceed,authresp.code);
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
