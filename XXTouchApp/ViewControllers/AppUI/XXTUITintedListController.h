#import <Preferences/PSListController.h>
#import "XXTUIListControllerProtocol.h"
#import "XXTUICommonDefine.h"

@interface XXTUITintedListController : PSListController <XXTUIListControllerProtocol>
- (id)localizedSpecifiersWithSpecifiers:(NSArray *)specifiers;

- (NSString *)localizedString:(NSString *)string;
@end
