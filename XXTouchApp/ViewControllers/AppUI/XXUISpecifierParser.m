#import <Preferences/Preferences.h>
#import "XXUISpecifierParser.h"
#import <objc/runtime.h>
#import "XXUICommonDefine.h"
#import "XXUIListController.h"
#import "XXLocalDataService.h"

@interface PSListController (Maybe)
- (UIColor *)iconColor;

- (UIColor *)tintColor;
@end

@implementation XXUISpecifierParser
+ (PSCellType)PSCellTypeFromString:(NSString *)str {
    if ([str isEqual:@"XXUIGroupCell"])
        return PSGroupCell;
    if ([str isEqual:@"XXUILinkCell"])
        return PSLinkCell;
    if ([str isEqual:@"XXUILinkListCell"])
        return PSLinkListCell;
//    if ([str isEqual:@"XXUIListItemCell"])
//        return PSListItemCell;
    if ([str isEqual:@"XXUITitleValueCell"])
        return PSTitleValueCell;
    if ([str isEqual:@"XXUISliderCell"])
        return PSSliderCell;
    if ([str isEqual:@"XXUISwitchCell"])
        return PSSwitchCell;
    if ([str isEqual:@"XXUIStaticTextCell"])
        return PSStaticTextCell;
    if ([str isEqual:@"XXUIEditTextCell"])
        return PSEditTextCell;
    if ([str isEqual:@"XXUISegmentCell"])
        return PSSegmentCell;
//    if ([str isEqual:@"XXUIGiantIconCell"])
//        return PSGiantIconCell;
//    if ([str isEqual:@"XXUIGiantCell"])
//        return PSGiantCell;
    if ([str isEqual:@"XXUISecureEditTextCell"])
        return PSSecureEditTextCell;
    if ([str isEqual:@"XXUIButtonCell"])
        return PSButtonCell;
//    if ([str isEqual:@"XXUIEditTextViewCell"])
//        return PSEditTextViewCell;

    return PSGroupCell;
}

+ (NSString *)convertPathFromPath:(NSString *)path relativeTo:(NSString *)root {
    if (root == nil) {
        return path;
    }
    NSString *imagePath = nil;
    if ([path isAbsolutePath]) {
        imagePath = [[NSURL fileURLWithPath:path] path];
    } else {
        imagePath = [[[NSURL alloc] initWithString:path relativeToURL:[NSURL URLWithString:root]] path];
    }
    return imagePath;
}

+ (NSArray *)specifiersFromArray:(NSArray *)array forTarget:(XXUIListController *)target {
    NSString *configPath = [[XXLocalDataService sharedInstance] uicfgPath];
    NSMutableArray *specifiers = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        PSCellType cellType = [XXUISpecifierParser PSCellTypeFromString:dict[@"cell"]];
        PSSpecifier *spec = nil;
        if (cellType == PSGroupCell) {
            if (dict[@"label"] != nil) {
                spec = [PSSpecifier groupSpecifierWithName:dict[@"label"]];
                [spec setProperty:dict[@"label"] forKey:@"label"];
            } else
                spec = [PSSpecifier emptyGroupSpecifier];

            if (dict[@"footerText"] != nil)
                [spec setProperty:dict[@"footerText"] forKey:@"footerText"];

            [spec setProperty:@"PSGroupCell" forKey:@"cell"];
        } else {
            NSString *label = dict[@"label"] == nil ? @"" : dict[@"label"];
            Class detail = dict[@"detail"] == nil ? nil : NSClassFromString(dict[@"detail"]);
            Class edit = dict[@"pane"] == nil ? nil : NSClassFromString(dict[@"pane"]);
            SEL set = dict[@"set"] == nil ? @selector(setPreferenceValue:specifier:) : NSSelectorFromString(dict[@"set"]);
            SEL get = dict[@"get"] == nil ? @selector(readPreferenceValue:) : NSSelectorFromString(dict[@"get"]);
            SEL action = dict[@"action"] == nil ? nil : NSSelectorFromString(dict[@"action"]);
            spec = [PSSpecifier preferenceSpecifierNamed:label target:target set:set get:get detail:detail cell:cellType edit:edit];
            spec->action = action;

            NSArray *validTitles = dict[@"validTitles"];
            NSArray *validValues = dict[@"validValues"];
            if (validTitles && validValues)
                [spec setValues:validValues titles:validTitles];

            for (NSString *key in dict) {
                if ([key isEqual:@"cellClass"]) {
                    NSString *s = dict[key];
                    [spec setProperty:NSClassFromString(s) forKey:key];
                } else if ([key isEqual:@"validValues"] || [key isEqual:@"validTitles"])
                    continue;
                else
                    [spec setProperty:dict[key] forKey:key];
            }
        }

        if (dict[@"icon"]) {
            UIImage *image = [dict[@"icon"] isKindOfClass:[UIImage class]] ? dict[@"icon"] : nil;
            if (image == nil)
                image = [UIImage imageNamed:dict[@"icon"] inBundle:[NSBundle bundleForClass:target.class]];
            if (image == nil)
                image = [UIImage imageNamed:dict[@"icon"] inBundle:[NSBundle bundleForClass:self.class]];
            if (image == nil)
                image = [UIImage imageWithContentsOfFile:[self convertPathFromPath:dict[@"icon"] relativeTo:target.filePath]];

            if ([target respondsToSelector:@selector(iconColor)])
                image = [image changeImageColor:target.iconColor];
            else if ([target respondsToSelector:@selector(tintColor)])
                image = [image changeImageColor:target.tintColor];

            [spec setProperty:image forKey:@"iconImage"];
        }
        
        if (dict[@"path"]) {
            [spec setProperty:[self convertPathFromPath:dict[@"path"] relativeTo:target.filePath] forKey:@"path"];
        }
        if (dict[@"defaults"]) {
            [spec setProperty:[self convertPathFromPath:dict[@"defaults"] relativeTo:configPath] forKey:@"defaults"];
        }
        if (dict[@"leftImage"]) {
            UIImage *image = [UIImage imageNamed:dict[@"leftImage"] inBundle:[NSBundle bundleForClass:target.class]];
            if (image == nil)
                image = [UIImage imageNamed:dict[@"leftImage"] inBundle:[NSBundle bundleForClass:self.class]];
            if (image == nil)
                image = [UIImage imageWithContentsOfFile:[self convertPathFromPath:dict[@"leftImage"] relativeTo:target.filePath]];
            
            [spec setProperty:image forKey:@"leftImage"];
        }
        if (dict[@"rightImage"]) {
            UIImage *image = [UIImage imageNamed:dict[@"rightImage"] inBundle:[NSBundle bundleForClass:target.class]];
            if (image == nil)
                image = [UIImage imageNamed:dict[@"rightImage"] inBundle:[NSBundle bundleForClass:self.class]];
            if (image == nil)
                image = [UIImage imageWithContentsOfFile:[self convertPathFromPath:dict[@"rightImage"] relativeTo:target.filePath]];

            [spec setProperty:image forKey:@"rightImage"];
        }

        if (dict[@"id"])
            [spec setProperty:dict[@"id"] forKey:@"id"];
        else
            [spec setProperty:dict[@"label"] forKey:@"id"];
        spec.target = target;

        [specifiers addObject:spec];
    }
    return specifiers;
}
@end
