#import "UITextField+RACKeyboardSupport.h"

@interface UITextField (RACKeyboardSupport)
- (RACSignal *)rac_keyboardReturnSignal;
@end
