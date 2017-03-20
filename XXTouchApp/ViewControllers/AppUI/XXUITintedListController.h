#import <Preferences/PSListController.h>
#import "XXUIListControllerProtocol.h"
#import "XXUICommonDefine.h"

@interface XXUITintedListController : PSListController <XXUIListControllerProtocol>
- (id)localizedSpecifiersWithSpecifiers:(NSArray *)specifiers;

- (NSString *)localizedString:(NSString *)string;
@end
