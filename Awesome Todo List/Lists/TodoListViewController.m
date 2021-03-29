//
//  TodoListViewController.m
//  Awesome Todo List
//
//  Created by iambavly on 2/25/21.
//

#import "TodoListViewController.h"
#import "TodoListManager.h"
#import "TodoItem.h"
#import "MaterialButtons.h"
#import "CustomFloatingButton.h"
#import "DetailsViewController.h"
#import "AddTodoItemViewController.h"
@import Firebase;

@interface TodoListViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *mySerachBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *floatView;
@property (nonatomic, readwrite) FIRFirestore *db;

@end


@implementation TodoListViewController{
    TodoListManager *manager;
    
    NSMutableArray *searchResults;
    NSMutableArray *arrayTableData;
    CustomFloatingButton *fb;
    DetailsViewController *detailsScreen;
    AddTodoItemViewController *addVC;
    UIImageView *resultImage;
    NSDictionary *userData;
    NSString *path;

    bool isSorted ;


}


- (void)viewDidLoad {

    [super viewDidLoad];
    manager = [TodoListManager new];
    userData = [NSDictionary new];
    self.db = [FIRFirestore firestore];
    searchResults = [NSMutableArray new];
    
    arrayTableData = [[NSMutableArray alloc]init];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self drawFloatButton];
    
    isSorted = false;
    
    resultImage = [self drawImage];

    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (IBAction)sortTodoList:(id)sender {
    
    [manager sortListByPriority];
    [self fetchData];
    [self.view reloadInputViews];
    [_tableView reloadData];
    isSorted = true;
}
-(void)getDateBaseWithUid:(NSString *)uid{
    NSMutableArray *arr = [NSMutableArray new ];
    if(uid){
        
        path = [NSString stringWithFormat:@"/users/%@/todo_list", uid];

        [[self.db collectionWithPath:path]getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (error != nil) {
                     NSLog(@"Error getting documents: %@", error);
                   } else {
                     for (FIRDocumentSnapshot *document in snapshot.documents) {
                         TodoItem *item = [TodoItem new];
                         [item initWithDict:document.data];
                         item.itemId = document.documentID;
                         [arr addObject:item];
//                         [item todoItemLogger];
                     }
                       
                       if(arr != self->manager.getTodoList){
                               [self->manager.getTodoList removeAllObjects];
                           [self->manager.getTodoList addObjectsFromArray:arr];
                       }
                   }
            
        }];

    }
    

}

- (void)deleteDocumentWithId : (NSString *) itemId {
  // [START delete_document]
  [[[self.db collectionWithPath:path] documentWithPath:itemId]
      deleteDocumentWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error removing document: %@", error);
        } else {
          NSLog(@"Document successfully removed!");
        }
  }];
  // [END delete_document]
}

- (void)updateDocumentWithId : (NSString *) itemId property : (NSString *)property value :(NSNumber *)value   {
  // [START update_document]
  FIRDocumentReference *ref =
      [[self.db collectionWithPath:path] documentWithPath:itemId];
  // Set the "capital" field of the city
  [ref updateData:@{
    property: value
  } completion:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error updating document: %@", error);
    } else {
      NSLog(@"Document successfully updated");
    }
  }];
  // [END update_document]
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    _user = [User new];
    _user.uid = [[NSUserDefaults standardUserDefaults]
                 stringForKey:@"uid"];
    printf("%s\n\n" , [_user.uid UTF8String]);
    [self fetchData];

    printf("appeared\n");
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    printf("appeared2\n");
}
-(void)drawFloatButton{
    CGRect newFrame = CGRectMake( 300, 660, 70, 70);

    self.floatView.frame = newFrame;
    self.floatView.backgroundColor = [UIColor systemBlueColor];
    self.floatView.layer.cornerRadius = 35;
    self.floatView.layer.shadowRadius  = 1.5f;
    self.floatView.layer.shadowColor   = [UIColor colorWithRed:176.f/255.f green:199.f/255.f blue:226.f/255.f alpha:1.f].CGColor;
    self.floatView.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    self.floatView.layer.shadowOpacity = 0.9f;
    self.floatView.layer.masksToBounds = NO;
    self.floatView.layer.timeOffset = 0.9f;
    
    UITapGestureRecognizer *singleFingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleSingleTap:)];
    [self.floatView addGestureRecognizer:singleFingerTap];
}

-(UIImageView *)drawImage{
    CGRect newFrame = CGRectMake( self.view.center.x-50  ,self.view.center.y -50, 100, 100);
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"no_results.jpg"]];
    imageView.frame = newFrame;
    return imageView;
}
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    printf("addButtonClicked\n");
  //Do stuff here...
    AddTodoItemViewController *ads = [self.storyboard instantiateViewControllerWithIdentifier:@"add"];
    [self.navigationController pushViewController:ads animated:YES];

    
}

-(void)fetchData{
    [self getDateBaseWithUid:_user.uid];
    arrayTableData = manager.getTodoList;
    [_tableView reloadData];

}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    @try
     {
         if([searchText length] > 0){
             searchResults = [manager searchArrayWithString:searchText targetArray:manager.getTodoList];
             arrayTableData = searchResults;


             if([searchResults count] > 0){
                 self.tableView.backgroundView = nil;
                 [_tableView reloadData];
                 
             }else{
                 [arrayTableData removeAllObjects];
                 printf("no item with this title\n");
                 self.tableView.backgroundView = resultImage;
                 [_tableView reloadData];
             }
         }else{

             arrayTableData = manager.getTodoList;
             [_tableView reloadData];
             printf("no search text\n");
             self.tableView.backgroundView = nil;

         }
   }
   @catch (NSException *exception) {
   }
    
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    printf("clicked\n");


}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    printf("end edit\n");
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    TodoItem *item;
    item  = [arrayTableData objectAtIndex:indexPath.row];
    
    UIImageView *checkBox = [cell viewWithTag:1];
    UIImageView *reminder = [cell viewWithTag:2];

    UILabel *dateLabel = [cell viewWithTag:5];
    NSDateFormatter *df = [[NSDateFormatter alloc] init]; //Autorelease
    
    

    [df setDateFormat:@"yyyy-MM-dd     HH:mm:ss"];
    NSString * dueDateString = [df stringFromDate:item.itemDate];
    
    cell.textLabel.text =[item title];
    cell.imageView.image = [UIImage imageNamed: [manager getImageWithItem:item]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", @"State: ", [item getStateName]];
    dateLabel.text = [NSString stringWithFormat:@"%@%@", @"Created At: ", dueDateString];
    [reminder setHidden:!(item.setReminder)];
    
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

            [self deleteDocumentWithId:item.itemId];
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
    
    UIContextualAction *pend =[UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
    title:@"InProgre.." handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        
        
        TodoItem *item = [self->manager.getTodoList objectAtIndex:indexPath.row];
        TodoItem *item2 = [self->arrayTableData objectAtIndex:indexPath.row];

        [item setState:1];
        [item2 setState:1];
        [self updateDocumentWithId:item.itemId property:@"state" value:@(1)];

        printf("in progress\n");
        [tableView reloadData];
        
        
        
    }];
    
    UIContextualAction *done =[UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
    title:@"Done" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
        
        
        TodoItem *item = [self->manager.getTodoList objectAtIndex:indexPath.row];
        TodoItem *item2 = [self->arrayTableData objectAtIndex:indexPath.row];

        [item setState:2];
        [item2 setState:2];

        printf("in progress\n");
        [tableView reloadData];
        
        [self updateDocumentWithId:item.itemId property:@"state" value:@(2)];
        
    }];
     pend.backgroundColor = [UIColor systemYellowColor]; //arbitrary color
    done.backgroundColor = [UIColor systemGreenColor]; //arbitrary color

    
    
    
    UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:@[pend , done]];
    swipeActionConfig.performsFirstActionWithFullSwipe = false;
    

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
