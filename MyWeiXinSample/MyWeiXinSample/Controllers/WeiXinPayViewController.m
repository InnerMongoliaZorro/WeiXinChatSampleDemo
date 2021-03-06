
//
//  WeiXinPayViewController.m
//  MyWeiXinSample
//
//  Created by MoGo on 16/5/20.
//  Copyright © 2016年 李策--MoGo--. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "LCGetWiFiSSID.h"
#import "DataMD5.h"
#import "XMLDictionary.h"

#import "WeiXinPayViewController.h"
#import "AFNetworking.h"
#import "WXApi.h"
@interface WeiXinPayViewController ()
- (IBAction)backAction:(UIButton *)sender;
- (IBAction)serverSign:(UIButton *)sender;
- (IBAction)clientSign:(UIButton *)sender;
@end

@implementation WeiXinPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)serverSign:(UIButton *)sender {
    NSString *url = @"http://121.199.21.212/clubx-web/api/app/wxpay/unifiedOrder";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html",@"text/plain", nil];
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    bodyDict[@"token"] = @"e3f5019713387e2719c4f43f529f9f16";
    NSMutableDictionary *business = [NSMutableDictionary dictionary];
    //设备号 非必填
    business[@"device_info"] = @"";
    //商品描述	必填
    business[@"body"] = @"大暗色";
    //商品详情 非必填
    business[@"detail"] = @"";
    //附加数据	非必填
    business[@"attach"] = @"";
    //商户订单号 必填
    business[@"out_trade_no"] = @"12345";
    //货币类型	 非必填
    business[@"fee_type"] = @"";
    //总金额	必填
    business[@"total_fee"] = @"1";
    //终端IP	必填
    business[@"spbill_create_ip"] = @"121.199.21.212";
    //交易起始时间 非必填
    business[@"time_start"] = @"";
    //交易结束时间	非必填
    business[@"time_expire"] = @"";
    //商品标记	非必填
    business[@"goods_tag"] = @"";
    //通知地址	必填
    business[@"notify_url"] = @"www.baidu.com";
    //交易类型	必填
    business[@"trade_type"] = @"APP";
    //指定支付方式	 非必填
    business[@"limit_pay"] = @"";
    
    bodyDict[@"business"]  = business;
       [manager POST:url parameters:bodyDict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *data = responseObject[@"data"];
        NSDictionary *m_values = data[@"m_values"];
        
        //调起微信支付
        PayReq* req = [[PayReq alloc] init];
        /** 商家向财付通申请的商家id */
        req.partnerId = [m_values objectForKey:@"partnerid"];
        /** 预支付订单 */
        req.prepayId = [m_values objectForKey:@"prepayid"];
        /** 随机串，防重发 */
        req.nonceStr = [m_values objectForKey:@"noncestr"];
        /** 时间戳，防重发 */
        req.timeStamp = [[m_values objectForKey:@"timestamp"] intValue];
        /** 商家根据财付通文档填写的数据和签名 */
        req.package = [m_values objectForKey:@"package"];
        /** 商家根据微信开放平台文档对数据做的签名 */
        req.sign = [m_values objectForKey:@"sign"];
        [WXApi sendReq:req];
        //日志输出
        NSLog(@"\nappid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[m_values objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

}

- (IBAction)clientSign:(UIButton *)sender {
    NSString *appid,*mch_id,*nonce_str,*sign,*body,*out_trade_no,*total_fee,*spbill_create_ip,*notify_url,*trade_type,*partner;
    //应用APPID
    appid =@"wx2cdeb77de80d1f6e";
    //微信支付商户号
    mch_id =@"1326534101";
    ///产生随机字符串，这里最好使用和安卓端一致的生成逻辑
    nonce_str =[self generateTradeNO];
    body =@"16G白色";
    //随机产生订单号用于测试，正式使用请换成你从自己服务器获取的订单号
    out_trade_no = [self getOrderNumber];
    //交易价格1表示0.01元，10表示0.1元
    total_fee = @"1";
    //获取本机IP地址，请再wifi环境下测试，否则获取的ip地址为error，正确格式应该是8.8.8.8
    spbill_create_ip =[LCGetWiFiSSID localIPAddress];
    //交易结果通知网站此处用于测试，随意填写，正式使用时填写正确网站
    notify_url =@"www.baidu.com";
    trade_type =@"APP";
    //商户密钥
    partner = @"Clubx123456789012345678901234567";
    //获取sign签名
    DataMD5 *data = [[DataMD5 alloc] initWithAppid:appid mch_id:mch_id nonce_str:nonce_str partner_id:partner body:body out_trade_no:out_trade_no total_fee:total_fee spbill_create_ip:spbill_create_ip notify_url:notify_url trade_type:trade_type];
    sign = [data getSignForMD5];
    //设置参数并转化成xml格式
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:appid forKey:@"appid"];//公众账号ID
    [dic setValue:mch_id forKey:@"mch_id"];//商户号
    [dic setValue:nonce_str forKey:@"nonce_str"];//随机字符串
    [dic setValue:sign forKey:@"sign"];//签名
    [dic setValue:body forKey:@"body"];//商品描述
    [dic setValue:out_trade_no forKey:@"out_trade_no"];//订单号
    [dic setValue:total_fee forKey:@"total_fee"];//金额
    [dic setValue:spbill_create_ip forKey:@"spbill_create_ip"];//终端IP
    [dic setValue:notify_url forKey:@"notify_url"];//通知地址
    [dic setValue:trade_type forKey:@"trade_type"];//交易类型
    NSString *string = [dic XMLString];
    [self http:string];

}

- (void)http:(NSString *)xml{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //这里传入的xml字符串只是形似xml，但是不是正确是xml格式，需要使用af方法进行转义
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"https://api.mch.weixin.qq.com/pay/unifiedorder" forHTTPHeaderField:@"SOAPAction"];
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return xml;
    }];
    //发起请求
    [manager POST:@"https://api.mch.weixin.qq.com/pay/unifiedorder" parameters:xml progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] ;
        //将微信返回的xml数据解析转义成字典
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:responseString];
        //判断返回的许可
        if ([[dic objectForKey:@"result_code"] isEqualToString:@"SUCCESS"] &&[[dic objectForKey:@"return_code"] isEqualToString:@"SUCCESS"] ) {
            
            
            //发起微信支付，设置参数
            PayReq *request = [[PayReq alloc] init];
            request.partnerId = [dic objectForKey:@"mch_id"];
            request.prepayId= [dic objectForKey:@"prepay_id"];
            request.package = @"Sign=WXPay";
            request.nonceStr= [dic objectForKey:@"nonce_str"];
            //将当前事件转化成时间戳
            NSDate *datenow = [NSDate date];
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
            UInt32 timeStamp =[timeSp intValue];
            request.timeStamp= timeStamp;
            DataMD5 *md5 = [[DataMD5 alloc] init];
            request.sign=[md5 createMD5SingForPay:@"wx2cdeb77de80d1f6e" partnerid:request.partnerId prepayid:request.prepayId package:request.package noncestr:request.nonceStr timestamp:request.timeStamp];
            
            NSLog(@"\n%@\n%@\n%@\n%u\n%@",request.partnerId,request.prepayId,request.package,(unsigned int)request.timeStamp,request.sign);
            //调用微信
            [WXApi sendReq:request];
        }else{
            NSLog(@"参数不正确，请检查参数");
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error is %@",error);
        
    }];
}

#pragma mark 微信支付
///产生随机字符串
- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRST";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

//将订单号使用md5加密
-(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16]= "0123456789abcdef";
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
//产生随机数
- (NSString *)getOrderNumber{
    int random = arc4random()%10000;
    return [self md5:[NSString stringWithFormat:@"%d",random]];
}
@end
