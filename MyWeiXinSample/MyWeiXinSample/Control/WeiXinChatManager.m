//
//  WeiXinChatManager.m
//  MyWeiXinSample
//
//  Created by MoGo on 16/5/20.
//  Copyright © 2016年 李策--MoGo--. All rights reserved.
//

#import "WeiXinChatManager.h"

@implementation WeiXinChatManager
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WeiXinChatManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WeiXinChatManager alloc] init];
    });
    return instance;
}
- (void)onResp:(BaseResp *)resp {
    NSLog(@"%@",resp);
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
       
    }

}
@end
