//
//  User.h
//  Awesome Todo List
//
//  Created by iambavly on 3/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject
@property NSString *email , *uid;
-(void)initWithEmail:(NSString *)email uid:(NSString *)uid;


@end

NS_ASSUME_NONNULL_END
