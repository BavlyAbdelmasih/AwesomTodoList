//
//  DetailsViewController.m
//  Awesome Todo List
//
//  Created by iambavly on 2/26/21.
//

#import "DetailsViewController.h"
#import "TodoItem.h"
#import "TodoListManager.h"
#import "EditTodoItemViewController.h"
#import <UserNotifications/UNNotificationContent.h>
#import <UserNotifications/UNNotificationSound.h>
#import <UserNotifications/UNNotificationRequest.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#import <UserNotifications/UNNotificationTrigger.h>



@interface DetailsViewController (){
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsLabel;
@property (weak, nonatomic) IBOutlet UITextView *StateLabel;
@property (weak, nonatomic) IBOutlet UITextView *priorityLabel;
@property (weak, nonatomic) IBOutlet UITextView *dueDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *deadLineLabel;

@end

@implementation DetailsViewController{
    EditTodoItemViewController *editVC;
    bool isGrantuedNotificationAceess;
    
}
@synthesize todoItem = _todoItem;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init]; //Autorelease

    [df setDateFormat:@"yyyy-MM-dd     HH:mm:ss"];
    NSString * dueDateString = [df stringFromDate:_todoItem.itemDate];
    
    NSString * deadLineString = [df stringFromDate:_todoItem.deadLine];

    
    _titleLabel.text = _todoItem.title;
    _detailsLabel.text = _todoItem.details;
    _StateLabel.text = _todoItem.getStateName;
    _dueDateLabel.text = dueDateString;
    _deadLineLabel.text= deadLineString;
    _priorityLabel.text = _todoItem.getPriorityName;
    
    isGrantuedNotificationAceess = false;
    
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert+UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        self->isGrantuedNotificationAceess = granted;

        
    }];
    
    
    
}
- (IBAction)editItem:(id)sender {
    editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"edit"];
    [self.navigationController pushViewController:editVC animated:YES];
    editVC.editableItem = _todoItem;
}

- (IBAction)sendNotification:(id)sender {

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

   [calendar setTimeZone:[NSTimeZone localTimeZone]];

    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitTimeZone fromDate:_todoItem.deadLine];


   UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
    objNotificationContent.title = _todoItem.title;
    objNotificationContent.body  = _todoItem.details;
    objNotificationContent.sound = [UNNotificationSound defaultSound];
    objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);


   UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];


   UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ten"
                                                                         content:objNotificationContent trigger:trigger];

    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Are You Sure You Want To Set Alarm for This Item ?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"Local Notification succeeded");
//                [self.navigationController popViewControllerAnimated:NO];
                    self->_todoItem.setReminder = true;

            }
            else {
                NSLog(@"Local Notification failed");
            }
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    

}


@end
