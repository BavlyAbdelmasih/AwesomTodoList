//
//  AppDelegate.m
//  Awesome Todo List
//
//  Created by iambavly on 2/24/21.
//

#import "AppDelegate.h"
#import "TodoItem.h"
#import "TodoListManager.h"
#import <UserNotifications/UNUserNotificationCenter.h>
@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate{
    TodoListManager *manager ;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [FIRApp configure];
    FIRFirestore *defaultFirestore = [FIRFirestore firestore];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)applicationWillTerminate:(UIApplication *)application{
    
 

}
@end
