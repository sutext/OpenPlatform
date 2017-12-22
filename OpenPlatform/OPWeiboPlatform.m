//
//  OPWeiboPlatform.m
//  OpenPlatform
//
//  Created by supertext on 15/10/11.
//  Copyright © 2015年 icegent. All rights reserved.
//
#import "OPWeiboPlatform.h"
#import "OPOpenPlatform.h"
#import "OPShareMedia.h"
#import "WeiboSDK.h"
@interface OPWeiboPlatform()<WBHttpRequestDelegate,WeiboSDKDelegate>
@property(nonatomic,copy)void (^shareComplete)(NSInteger);
@property(nonatomic,copy)void (^authComplete)(NSInteger,NSString *);
@end

@implementation OPWeiboPlatform
- (instancetype)initWithAppid:(NSString*)appid schema:(NSString *)schema redirectURI:(NSString *)redirectURI
{
    self = [super init];
    if (self) {
        self.appid = appid;
        self.schema = schema;
        self.redirectURI = redirectURI;
        [WeiboSDK registerApp:appid];
    }
    return self;
}
#pragma mark WBHttpRequestDelegate methods
-(void)shareWithMedia:(OPShareObject *)media redirectURI:(NSString *)redirectURI completed:(void (^)(NSInteger))completedBlock
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
    WBMessageObject *message=[WBMessageObject message];
    message.text = media.content;
    if ([media isKindOfClass:[OPShareWebpage class]]){
        WBWebpageObject *webpage = [WBWebpageObject object];
        OPShareWebpage *share = (OPShareWebpage *)media;
        webpage.objectID = @"objectID";
        webpage.title = media.title;
        webpage.description = media.content;
        webpage.thumbnailData = share.thumbData;
        webpage.webpageUrl = share.weburl;
        message.mediaObject = webpage;
    }else if([media isKindOfClass:[OPShareMusic class]]) {
        WBWebpageObject *webpage = [WBWebpageObject object];
        OPShareMusic *share = (OPShareMusic *)media;
        webpage.objectID = @"objectID";
        webpage.title = media.title;
        webpage.description = media.content;
        webpage.thumbnailData = UIImageJPEGRepresentation(media.thumb, 0.9);
        webpage.webpageUrl = share.weburl;
        message.mediaObject = webpage;
    }else if([media isKindOfClass:[OPShareImage class]]){
        WBImageObject * image = [WBImageObject object];
        OPShareImage * share = (OPShareImage *)media;
        image.imageData = share.imageData;
        message.imageObject = image;
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
-(void)authCompleted:(void (^)(NSInteger, NSString *))completedBlock
{
//    if (![WeiboSDK isWeiboAppInstalled]) {
//        if (completedBlock) {
//            completedBlock(OPPlatformErrorNotInstall,nil);
//        }
//        return;
//    }
//    if (![WeiboSDK isCanShareInWeiboAPP]) {
//        if (completedBlock) {
//            completedBlock(OPPlatformErrorUnsuport,nil);
//        }
//        return;
//    }
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.redirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
    self.authComplete=completedBlock;
}
-(void)setDebugEnable:(BOOL)enable{
    [WeiboSDK enableDebugMode:enable];
}
-(NSString *)installURL{
    return WeiboSDK.getWeiboAppInstallUrl;
}

-(void)linkToUser:(NSString *)user{
    if (user == nil) {
        [WeiboSDK linkToProfile];
    }else{
        [WeiboSDK linkToUser:user];
    }
    
}
-(BOOL)isInstalled{
    return  [WeiboSDK isWeiboAppInstalled];
}
-(BOOL)handelOpenURL:(NSURL *)openURL{
    return [WeiboSDK handleOpenURL:openURL delegate:self];
}
-(BOOL)open{
    return  [WeiboSDK openWeiboApp];
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
                self.authComplete(OPPlatformErrorSucceed,authRespons.accessToken);
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

