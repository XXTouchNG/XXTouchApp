#import <objc/runtime.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#import "XXTUISpecifierParser.h"
#import "XXTUICommonDefine.h"
#import "XXTUIListController.h"
#import "XXLocalDataService.h"

@implementation XXTUISpecifierParser
+ (PSCellType)PSCellTypeFromString:(NSString *)str {
    if ([str isEqual:@"XXTUIGroupCell"])
        return PSGroupCell;
    if ([str isEqual:@"XXTUILinkCell"])
        return PSLinkCell;
    if ([str isEqual:@"XXTUILinkListCell"])
        return PSLinkListCell;
    if ([str isEqual:@"XXTUIListItemCell"])
        return PSListItemCell;
    if ([str isEqual:@"XXTUITitleValueCell"])
        return PSTitleValueCell;
    if ([str isEqual:@"XXTUISliderCell"])
        return PSSliderCell;
    if ([str isEqual:@"XXTUISwitchCell"])
        return PSSwitchCell;
    if ([str isEqual:@"XXTUIStaticTextCell"])
        return PSStaticTextCell;
    if ([str isEqual:@"XXTUIEditTextCell"])
        return PSEditTextCell;
    if ([str isEqual:@"XXTUISegmentCell"])
        return PSSegmentCell;
    if ([str isEqual:@"XXTUIGiantIconCell"])
        return PSGiantIconCell;
    if ([str isEqual:@"XXTUIGiantCell"])
        return PSGiantCell;
    if ([str isEqual:@"XXTUISecureEditTextCell"])
        return PSSecureEditTextCell;
    if ([str isEqual:@"XXTUIButtonCell"])
        return PSButtonCell;

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

+ (NSArray *)specifiersFromArray:(NSArray *)array forTarget:(XXTUIListController *)target {
    NSString *configPath = [[XXLocalDataService sharedInstance] uicfgPath];
    NSMutableArray *specifiers = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        PSCellType cellType = [XXTUISpecifierParser PSCellTypeFromString:dict[PSTableCellClassKey]];
        PSSpecifier *spec = nil;
        if (cellType == PSGroupCell) {
            if (dict[PSTitleKey] != nil) {
                spec = [PSSpecifier groupSpecifierWithName:dict[PSTitleKey]];
                [spec setProperty:dict[PSTitleKey] forKey:PSTitleKey];
            } else
                spec = [PSSpecifier emptyGroupSpecifier];

            if (dict[PSFooterTextGroupKey] != nil)
                [spec setProperty:dict[PSFooterTextGroupKey] forKey:PSFooterTextGroupKey];

            [spec setProperty:@"PSGroupCell" forKey:PSTableCellClassKey];
        } else {
            NSString *label = dict[PSTitleKey] == nil ? @"" : dict[PSTitleKey];
            Class detail = dict[PSDetailControllerClassKey] == nil ? nil : NSClassFromString(dict[PSDetailControllerClassKey]);
            Class edit = dict[PSEditPaneClassKey] == nil ? nil : NSClassFromString(dict[PSEditPaneClassKey]);
            SEL set = dict[PSSetterKey] == nil ? @selector(setPreferenceValue:specifier:) : NSSelectorFromString(dict[PSSetterKey]);
            SEL get = dict[PSGetterKey] == nil ? @selector(readPreferenceValue:) : NSSelectorFromString(dict[PSGetterKey]);
            SEL action = dict[PSActionKey] == nil ? nil : NSSelectorFromString(dict[PSActionKey]);
            spec = [PSSpecifier preferenceSpecifierNamed:label target:target set:set get:get detail:detail cell:cellType edit:edit];
            spec->action = action;

            NSArray *validTitles = dict[PSValidTitlesKey];
            NSArray *validValues = dict[PSValidValuesKey];
            if (validTitles && validValues)
                [spec setValues:validValues titles:validTitles];

            for (NSString *key in dict) {
                if ([key isEqual:PSCellClassKey]) {
                    NSString *s = dict[key];
                    [spec setProperty:NSClassFromString(s) forKey:key];
                } else if ([key isEqual:PSValidValuesKey] || [key isEqual:PSValidTitlesKey])
                    continue;
                else
                    [spec setProperty:dict[key] forKey:key];
            }
        }

        if (dict[PSBundleIconPathKey]) {
            UIImage *image = [UIImage imageWithContentsOfFile:[self convertPathFromPath:dict[PSBundleIconPathKey] relativeTo:target.filePath]];
            [spec setProperty:image forKey:PSIconImageKey];
        }
        if (dict[PSDetailControllerClassKey]) {
            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                [spec setProperty:@"load:" forKey:PSActionKey];
                spec->action = NSSelectorFromString(@"load:");
            }
        }
        if (dict[@"path"]) {
            [spec setProperty:[self convertPathFromPath:dict[@"path"] relativeTo:target.filePath] forKey:@"path"];
        }
        if (dict[PSDefaultsKey]) {
            [spec setProperty:[self convertPathFromPath:dict[PSDefaultsKey] relativeTo:configPath] forKey:PSDefaultsKey];
        }
        if (dict[PSSliderLeftImageKey]) {
            UIImage *image = [UIImage imageWithContentsOfFile:[self convertPathFromPath:dict[PSSliderLeftImageKey] relativeTo:target.filePath]];
            [spec setProperty:image forKey:PSSliderLeftImageKey];
        }
        if (dict[PSSliderRightImageKey]) {
            UIImage *image = [UIImage imageWithContentsOfFile:[self convertPathFromPath:dict[PSSliderRightImageKey] relativeTo:target.filePath]];
            [spec setProperty:image forKey:PSSliderRightImageKey];
        }

        if (dict[PSIDKey])
            [spec setProperty:dict[PSIDKey] forKey:PSIDKey];
        else
            [spec setProperty:dict[PSTitleKey] forKey:PSIDKey];
        spec.target = target;

        [specifiers addObject:spec];
    }
    return specifiers;
}
@end
