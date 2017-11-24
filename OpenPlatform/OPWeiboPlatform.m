//
//  OPWeiboPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//
#ifdef ALLOW_WEIBO
#import "OPWeiboPlatform.h"
#import "OPOpenPlatform.h"
#import "OPShareMedia.h"
#import "OPAuthObject.h"
@interface OPWeiboPlatform()
@property(nonatomic,copy)void (^shareComplete)(NSInteger);
@property(nonatomic,copy)void (^authComplete)(NSInteger,OPAuthObject *);
@end

@implementation OPWeiboPlatform
#pragma mark WBHttpRequestDelegate methods
-(void)shareWithMedia:(id<OPShareObject>)media redirectURI:(NSString *)redirectURI completed:(void (^)(NSInteger))completedBlock
{
    if (![WeiboSDK isWeiboAppInstalled]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorNotInstall);
        }
        return;
    }
    if (![WeiboSDK isCanShareInWeiboAPP]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorUnsuport);
        }
        return;
    }
//    WBMessageObject *message=[WBMessageObject message];
//    if ([media isKindOfClass:[OPShareWebpage class]]){
//        WBWebpageObject *webpage = [WBWebpageObject object];
//        OPShareWebpage *share = (OPShareWebpage *)media;
//        webpage.objectID = @"objectID";
//        webpage.title = media.title;
//        webpage.description = media.content;
//        webpage.thumbnailData = UIImageJPEGRepresentation(media.image, 0.9);
//        webpage.webpageUrl = share.weburl;
//        message.mediaObject = webpage;
//    }else if([media isKindOfClass:[OPShareMusic class]]) {
//        WBMusicObject *music = [WBMusicObject object];
//        OPShareMusic *share = (OPShareMusic *)media;
//        music.objectID = @"OPShareWebpage";
//        music.title = share.title;
//        music.description = share.title;
//        music.thumbnailData = UIImageJPEGRepresentation(media.image, 0.9);
//        music.musicUrl = share.webURL;
//        music.musicStreamUrl = share.dataURL;
//        music.musicLowBandUrl = share.lowbandURL;
//        music.musicLowBandStreamUrl = share.lowbandDataURL;
//        music.scheme = @"karaok";
//        message.mediaObject = music;
//    }
    WBMessageObject *message = [WBMessageObject message];
    message.text = media.content;
    if ([media isKindOfClass:[OPShareWebpage class]]) {
        WBWebpageObject *webpage = [WBWebpageObject object];
        OPShareWebpage * share = (OPShareWebpage *)media;
        webpage.objectID = @"identifier1";
        webpage.title = share.title;
        webpage.description = share.content;
        webpage.thumbnailData = UIImageJPEGRepresentation(share.image, 0.9);
        webpage.webpageUrl = share.weburl;
        message.mediaObject = webpage;
    }
    
    WBAuthorizeRequest *auth=[WBAuthorizeRequest request];
    auth.redirectURI=redirectURI;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    if ([WeiboSDK sendRequest:request]) {
        self.shareComplete=completedBlock;
    }
    else
    {
        if (completedBlock) {
            completedBlock(OPPlatformErrorException);
        }
    }
}
-(void)authCompleted:(void (^)(NSInteger, OPAuthObject *))completedBlock
{
    if (![WeiboSDK isWeiboAppInstalled]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorNotInstall,nil);
        }
        return;
    }
    if (![WeiboSDK isCanShareInWeiboAPP]) {
        if (completedBlock) {
            completedBlock(OPPlatformErrorUnsuport,nil);
        }
        return;
    }
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.redirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
    self.authComplete=completedBlock;
}
-(NSString *)installURL{
    return WeiboSDK.getWeiboAppInstallUrl;
}
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data
{
}
#pragma mark WeiboSDKDelegate methods
-(void)getSinaUserInfo:(WBAuthorizeResponse *)response
{
}
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBAuthorizeResponse class]])
    {
        WBAuthorizeResponse *authRespons=(WBAuthorizeResponse *)response;
        if (authRespons.statusCode==WeiboSDKResponseStatusCodeSuccess&&authRespons.accessToken.length) {
            if (self.authComplete) {
                OPAuthObject *auth = [[OPAuthObject alloc] init];
                auth.token = authRespons.accessToken;
                self.authComplete(OPPlatformErrorSucceed,auth);
                self.authComplete=nil;
            }
        }
        else
        {
            if (self.authComplete) {
                OPPlatformError errorType=OPPlatformErrorUnknown;
                switch (authRespons.statusCode) {
                    case WeiboSDKResponseStatusCodeUserCancel:
                        errorType=OPPlatformErrorCancel;
                        break;
                    case WeiboSDKResponseStatusCodeSentFail:
                        errorType=OPPlatformErrorNetwork;
                        break;
                    case WeiboSDKResponseStatusCodeAuthDeny:
                        errorType=OPPlatformErrorRefuse;
                        break;
                    default:
                        break;
                }
                self.authComplete(errorType, nil);
            }
        }
    }
    if([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
    {
        if (self.shareComplete) {
            OPPlatformError type=OPPlatformErrorUnknown;
            WBSendMessageToWeiboResponse *msgresp=(WBSendMessageToWeiboResponse *)response;
            switch (msgresp.statusCode)
            {
                case    WeiboSDKResponseStatusCodeSuccess           :
                {
                    type=OPPlatformErrorSucceed;
                    break;
                }
                case    WeiboSDKResponseStatusCodeSentFail     :
                {
                    type=OPPlatformErrorUnknown;
                    break;
                }
                case    WeiboSDKResponseStatusCodeUserCancel :
                case    WeiboSDKResponseStatusCodeUserCancelInstall   :
                {
                    type=OPPlatformErrorCancel;
                    break;
                }
                case    WeiboSDKResponseStatusCodeAuthDeny   :
                {
                    type=OPPlatformErrorRefuse;
                    break;
                }
                case    WeiboSDKResponseStatusCodeShareInSDKFailed  :
                case    WeiboSDKResponseStatusCodeUnsupport  :
                {
                    type=OPPlatformErrorUnsuport;
                    break;
                }
                    break;
                default:
                    break;
            }
            self.shareComplete(type);
            self.shareComplete=nil;
        }
    }
}


@end
#endif
