//
//  AppDelegate.m
//  PushTestApp
//
//  Created by 王盛魁 on 2017/8/9.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h> // ios10推送 需要导入以及遵守协议
@interface AppDelegate ()<UIAlertViewDelegate,UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerAPN];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSInteger times = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GoBackground"] integerValue];
    times++;
    [[NSUserDefaults standardUserDefaults]setInteger:times forKey:@"GoBackground"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSInteger times = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GoBackground"] integerValue];
    if (times >= 3) {
        // ios9之后 将会被UIAlertController替代
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"打开推送权限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"允许", nil];
        [alert show];
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 0) {
        // 用户点击允许 ios8之后，可以直接调转手机设置界面
        if([UIDevice currentDevice].systemVersion.integerValue >= 8.0){
            [self goToSetting];
        }
    }
}
- (void)goToSetting{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)registerAPN {
    // 在此根据版本不同，设置不同的注册方式 以ios8/10为分界线
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        // 需要导入 <UserNotifications/UserNotifications.h>
        UNUserNotificationCenter *notifiCenter = [UNUserNotificationCenter currentNotificationCenter];
        notifiCenter.delegate = self;
        [notifiCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 注册成功
                [notifiCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@",settings);
                }];
            }else{
                // 注册失败
            }
        }];
    }else if([UIDevice currentDevice].systemVersion.floatValue >= 8.0){
        // ios8 - ios10
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }else{
        // ios7以下
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert ];
    }
    
}
// 用户允许通知，会进入此回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    // 注册通知
    [application registerForRemoteNotifications];
}
// 注册成功的回调 获取token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    // 在此回调中获得deviceToken
    NSString *tokenString = [NSString stringWithFormat:@"%@",deviceToken];
    // 对数据进行处理，删除<、>、空格
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    // 将处理好的tokenString上传给服务器
}
// 注册失败的回调
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
}
#pragma mark - RemotePush
// 远程推送 回调 在iOS10之后将会变更
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
}
#pragma mark - LocalPush
// 点击本地推送通知 进入APP后的回调 在iOS10之后将会变更
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [application cancelLocalNotification:notification];
}
#pragma mark - UNUserNotificationCenterDelegate 
// iOS10 推送回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSDictionary *userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; //收到推送消息的全部内容
    NSNumber *badge = content.badge; // 推送消息的角标
    NSString *body = content.body; // 收到推送消息具体内容
    UNNotificationSound *sound = content.sound; //声音
    NSString *subTitle = content.subtitle; // 推送收到的副标题
    NSString *title = content.title; // 推送收到的标题
    
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知");
    }else{
        NSLog(@"ios10 收到本地通知%@%@%@%@%@",title,subTitle,body,badge,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge |
                      UNNotificationPresentationOptionSound |
                      UNNotificationPresentationOptionAlert );
    // 需要执行此方法，选择是否提醒用户，有以上三种那个类型可选
    
}
// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request;
    UNNotificationContent *content = request.content; //收到推送消息的全部内容
    NSNumber *badge = content.badge; // 推送消息的角标
    NSString *body = content.body; // 收到推送消息具体内容
    UNNotificationSound *sound = content.sound; //声音
    NSString *subTitle = content.subtitle; // 推送收到的副标题
    NSString *title = content.title; // 推送收到的标题
    NSLog(@">>>通知的点击事件");
    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知");
    }else{
        NSLog(@"ios10 收到本地通知%@%@%@%@%@",title,subTitle,body,badge,userInfo);
    }
    completionHandler(); //系统要求执行此方法
    
}
@end
