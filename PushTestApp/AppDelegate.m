//
//  AppDelegate.m
//  PushTestApp
//
//  Created by 王盛魁 on 2017/8/9.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()<UIAlertViewDelegate>

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
    // 在此根据版本不同，设置不同的注册方式 以ios8为分界线
    if([UIDevice currentDevice].systemVersion.integerValue >= 8.0){
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
// 注册成功的回调
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
#pragma mark - LocalPush
// 点击本地推送通知 进入APP后的回调
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [application cancelLocalNotification:notification];
}
@end
