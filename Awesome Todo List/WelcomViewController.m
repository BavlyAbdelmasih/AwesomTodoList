//
//  WelcomViewController.m
//  Awesome Todo List
//
//  Created by iambavly on 3/2/21.
//

#import "WelcomViewController.h"
#import "MyTabBarViewController.h"

@interface WelcomViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation WelcomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view

    _startButton.layer.borderWidth = 3;
}
- (IBAction)start:(id)sender {
    MyTabBarViewController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"tab"];
        
    tabBar.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:tabBar animated:YES completion:nil];
}




@end
