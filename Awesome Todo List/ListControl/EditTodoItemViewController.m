//
//  EditTodoItemViewController.m
//  Awesome Todo List
//
//  Created by iambavly on 2/28/21.
//

#import "EditTodoItemViewController.h"
#import "TodoListManager.h"
#import "User.h"
@import Firebase;

@interface EditTodoItemViewController ()
@property (weak, nonatomic) IBOutlet UITextView *titleView;
@property (weak, nonatomic) IBOutlet UITextView *detailsView;
@property (weak, nonatomic) IBOutlet UIPickerView *priorityView;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueDateView;
@property (weak, nonatomic) IBOutlet UIDatePicker *deadLineView;
@property (nonatomic, readwrite) FIRFirestore *db;


@end

@implementation EditTodoItemViewController{
    NSMutableArray *piriorities;
    TodoListManager *manager;
    int priority;
    NSString *path;

}
- (IBAction)doneEditing:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_editableItem.title message:@"Are You Sure You Want To Edit This Item ?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self->_editableItem.title = self->_titleView.text;
        self->_editableItem.details = self->_detailsView.text;
        self->_editableItem.priority =self->priority;
        self->_editableItem.deadLine = self->_deadLineView.date;
        [self updateDocumentWithId];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
   

}

- (void)viewDidLoad {
    [super viewDidLoad];
    piriorities = [NSMutableArray new];
    manager = [TodoListManager new];
    self.db = [FIRFirestore firestore];
    User *user = [User new];
    user.uid = [[NSUserDefaults standardUserDefaults]
                 stringForKey:@"uid"];
    printf("%s\n\n" , [user.uid UTF8String]);
    path = [NSString stringWithFormat:@"/users/%@/todo_list", user.uid];

    [piriorities addObject:@"High"];

    [piriorities addObject:@"Medium"];
    [piriorities addObject:@"Low"];
    [_priorityView selectRow:(_editableItem.priority - 1 )inComponent:0 animated:YES];
    priority = _editableItem.priority;
    
    [_editableItem todoItemLogger];
    
    _titleView.text = _editableItem.title ;
   _detailsView.text =  _editableItem.details ;

    _deadLineView.date = _editableItem.deadLine ;
    

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
  
//Here, like the table view you can get the each section of each row if you've multiple sections
    
    priority = row + 1 ;

}


- (void)updateDocumentWithId  {
  // [START update_document]
    if(path){
        FIRDocumentReference *ref =
            [[self.db collectionWithPath:path] documentWithPath:_editableItem.itemId];
        // Set the "capital" field of the city
        [ref updateData:@{
            @"title" : self->_titleView.text,
            @"details" : self->_detailsView.text,
            @"priority" : [NSNumber numberWithInt:self->priority]  ,
            @"deadLine" : self->_deadLineView.date,
        } completion:^(NSError * _Nullable error) {
          if (error != nil) {
            NSLog(@"Error updating document: %@", error);
          } else {
            NSLog(@"Document successfully updated");
          }
        }];
    }
  
  // [END update_document]
}
@end
