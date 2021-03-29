//
//  PendingTodoListViewController.m
//  Awesome Todo List
//
//  Created by iambavly on 2/27/21.
//

#import "PendingTodoListViewController.h"
#import "TodoListManager.h"
#import "DetailsViewController.h"

#import "TodoItem.h"

@interface PendingTodoListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PendingTodoListViewController{
    TodoListManager *manager;
    NSMutableArray *searchResults;
    NSMutableArray *arrayTableData;
    DetailsViewController *detailsScreen;
    UIImageView *resultImage;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    searchResults = [NSMutableArray new];
    arrayTableData = [[NSMutableArray alloc]init];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    manager = [TodoListManager new];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    resultImage = [self drawImage];


    [self fetchData];
    [_tableView reloadData];
    printf("appeed");
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [self fetchData];
    [_tableView reloadData];
    printf("will appeed");

}
-(UIImageView *)drawImage{
    CGRect newFrame = CGRectMake( self.view.center.x-50  ,self.view.center.y -50, 100, 100);
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"no_results.jpg"]];
    imageView.frame = newFrame;
    return imageView;
}
-(void)fetchData{
    [manager getTodoList];
    arrayTableData = manager.getPendingListItems;
    [_tableView reloadData];

}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
 

    @try
     {
         if([searchText length] > 0){
             searchResults = [manager searchArrayWithString:searchText targetArray:manager.getTodoList];


             if([searchResults count] > 0){
                 self.tableView.backgroundView = nil;
                 arrayTableData = searchResults;
                 [_tableView reloadData];
                 
             }else{
                 [arrayTableData removeAllObjects];
                 printf("no item with this title\n");
                 self.tableView.backgroundView = resultImage;
                 [_tableView reloadData];
             }
         }else{

             arrayTableData = manager.getPendingListItems;
             [_tableView reloadData];
             printf("no search text\n");
             self.tableView.backgroundView = nil;

         }
   }
   @catch (NSException *exception) {
   }
    
    
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    printf("clicked");
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    printf("end edit\n");
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    TodoItem *item;
    item  = [arrayTableData objectAtIndex:indexPath.row];
    
    UIImageView *checkBox = [cell viewWithTag:1];
    UILabel *dateLabel = [cell viewWithTag:5];
    NSDateFormatter *df = [[NSDateFormatter alloc] init]; //Autorelease

    [df setDateFormat:@"yyyy-MM-dd     HH:mm:ss"];
    NSString * dueDateString = [df stringFromDate:item.itemDate];
    
    cell.textLabel.text =[item title];
    cell.imageView.image = [UIImage imageNamed: [manager getImageWithItem:item]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", @"State: ", [item getStateName]];
    dateLabel.text = [NSString stringWithFormat:@"%@%@", @"Created At: ", dueDateString];
    
    if([item state] == 2){
        [checkBox setImage:[UIImage imageNamed:@"checked.png"]];
    }else if([item state] == 0){
        [checkBox setImage:[UIImage imageNamed:@"forbidden.png"]];

    }else if([item state] == 1){
        [checkBox setImage:[UIImage imageNamed:@"22.png"]];

    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    return arrayTableData.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}




- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction *delete =[UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
    title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        TodoItem *item = [self->arrayTableData objectAtIndex:indexPath.row];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:item.title message:@"Are You Sure You Want To Delete This Item ?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self->manager.getTodoList removeObject:item];
            [self->arrayTableData removeObject:item];

            printf("Delete item with id = %i\n" , item.itemId);
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:yesAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    
    delete.backgroundColor = [UIColor systemRedColor];
    delete.image = [UIImage imageNamed:@"ic_delete.png"];

    UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:@[delete]];
    swipeActionConfig.performsFirstActionWithFullSwipe = false;
    return  swipeActionConfig;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *done =[UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
    title:@"Done" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        TodoItem *item = [self->manager.getPendingListItems objectAtIndex:indexPath.row];
        TodoItem *item2 = [self->arrayTableData objectAtIndex:indexPath.row];

        [item setState:2];
        [item2 setState:2];
        [self->arrayTableData removeObject:item2];

        printf("Done\n");
        [tableView reloadData];

                                                                       }];
     done.backgroundColor = [UIColor systemGreenColor]; //arbitrary color

    UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:@[done]];
    swipeActionConfig.performsFirstActionWithFullSwipe = NO;
    
    
    

    return swipeActionConfig;
}
 

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //1. Define the initial state (Before the animation)
    cell.transform = CGAffineTransformMakeTranslation(0.f, 60);
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;

    //2. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8];
    cell.transform = CGAffineTransformMakeTranslation(0.f, 0);
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsViewController *detailsScreen;
    detailsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"details"];
    TodoItem *item = [arrayTableData objectAtIndex:indexPath.row];
    detailsScreen.todoItem = item;
    [self.navigationController pushViewController:detailsScreen animated:true];
}

@end
