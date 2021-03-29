//
//  EditTodoItemViewController.h
//  Awesome Todo List
//
//  Created by iambavly on 2/28/21.
//

#import "TodoItem.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditTodoItemViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource>
@property TodoItem *editableItem;

@end

NS_ASSUME_NONNULL_END
