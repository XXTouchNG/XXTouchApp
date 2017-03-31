#import <Preferences/PSListController.h>

@interface XXTUISpecifierParser : NSObject
+ (PSCellType)PSCellTypeFromString:(NSString *)str;

+ (NSArray *)specifiersFromArray:(NSArray *)array forTarget:(PSListController *)target;

+ (NSString *)convertPathFromPath:(NSString *)path relativeTo:(NSString *)root;
@end
