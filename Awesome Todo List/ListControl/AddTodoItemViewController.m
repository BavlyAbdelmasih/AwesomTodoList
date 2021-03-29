//
//  AddTodoItemViewController.m
//  Awesome Todo List
//
//  Created by iambavly on 2/26/21.
//

#import "AddTodoItemViewController.h"
#import "TodoItem.h"
#import "TodoListManager.h"
#import "TodoListViewController.h"
@import Firebase;

@interface AddTodoItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *detailsField;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *deadLinePicker;
@property (nonatomic, readwrite) FIRFirestore *db;

@end

@implementation AddTodoItemViewController{
    NSMutableArray *piriorities;
    TodoListViewController *listVC;
    int priority;
    NSDate * now;
    NSString *path;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.db = [FIRFirestore firestore];
    User *user = [User new];
    user.uid = [[NSUserDefaults standardUserDefaults]
                 stringForKey:@"uid"];
    printf("%s\n\n" , [user.uid UTF8String]);
    path = [NSString stringWithFormat:@"/users/%@/todo_list", user.uid];

    piriorities = [NSMutableArray new];
    priority = 1;
    [piriorities addObject:@"High"];
    [piriorities addObject:@"Medium"];
    [piriorities addObject:@"Low"];
    now = [NSDate date];
    }
- (IBAction)addItem:(id)sender {
    listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"listView"];
    TodoListManager *manager = [TodoListManager new];
    TodoItem *item = [TodoItem new];
    [item initWithTitle:self->_titleField.text description:_detailsField.text priority:priority itemDate:now deadLine:_deadLinePicker.date itemId:@"50"];
    [manager addTodoItem:item];
    [self addDocument:item];

    [self.navigationController popToRootViewControllerAnimated:NO];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"An Item Is Added to Your Todo-List Successfully" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:yesAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return piriorities.count;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return piriorities[row];

}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    priority = row +1;
    printf("priority %i", priority);
//Here, like the table view you can get the each section of each row if you've multiple sections

}
- (void)addDocument : (TodoItem *)item  {
  // [START add_document]
  // Add a new document with a generated id.
  __block FIRDocumentReference *ref =
      [[self.db collectionWithPath:path] addDocumentWithData:@{
          @"title" : item.title,
          @"details" : item.details,
          @"priority" : [NSNumber numberWithInt:item.priority],
          @"state" : [NSNumber numberWithInt:item.state],
          @"itemDate" : item.itemDate,
          @"deadLine" : item.deadLine,
      } completion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error adding document: %@", error);
        } else {
          NSLog(@"Document added with ID: %@", ref.documentID);
            item.itemId = ref.documentID;
        }
      }];
  // [END add_document]
}
@end
