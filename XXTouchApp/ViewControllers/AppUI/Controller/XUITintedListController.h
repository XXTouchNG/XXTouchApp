#import <Preferences/PSListController.h>
#import "XUIListControllerProtocol.h"
#import "XUICommonDefine.h"

@interface XUITintedListController : PSListController <XUIListControllerProtocol>
- (id)localizedSpecifiersWithSpecifiers:(NSArray *)specifiers;

- (NSString *)localizedString:(NSString *)string;
@end
