//
//  TodoListViewController.h
//  Awesome Todo List
//
//  Created by iambavly on 2/25/21.
//

#import "TodoListProtocol.h"
#import "User.h"
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface TodoListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate , TodoListProtocol>
@property User *user;


-(void)myRsefreshTable;
@end

NS_ASSUME_NONNULL_END
