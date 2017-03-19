#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import "XXUITintedListController.h"
#import "XXUICommonDefine.h"
#import "XXUISpecifierParser.h"

@interface PSListController (did_rotate_from_orientation_settingskit)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
@end

@implementation XXUITintedListController
- (id)specifiers {
    if (_specifiers == nil) {
        if ([self respondsToSelector:@selector(customSpecifiers)]) {
            _specifiers = [XXUISpecifierParser specifiersFromArray:self.customSpecifiers forTarget:self];
            if ([self respondsToSelector:@selector(customTitle)])
                self.title = SK_LCL(self.customTitle);
        } else if ([self respondsToSelector:@selector(plistName)])
            _specifiers = [self loadSpecifiersFromPlistName:self.plistName target:self];
        else
            @throw [[NSException alloc] init];

        [self localizedSpecifiersWithSpecifiers:_specifiers];
    }
    return _specifiers;
}

- (id)navigationTitle {
    return [[self bundle] localizedStringForKey:[super title] value:[super title] table:nil];
}

- (id)localizedSpecifiersWithSpecifiers:(NSArray *)specifiers {
    for (PSSpecifier *curSpec in specifiers) {
        NSString *name = [curSpec name];
        if (name) {
            [curSpec setName:[[self bundle] localizedStringForKey:name value:name table:nil]];
        }
        NSString *footerText = [curSpec propertyForKey:@"footerText"];
        if (footerText)
            [curSpec setProperty:[[self bundle] localizedStringForKey:footerText value:footerText table:nil] forKey:@"footerText"];
        id titleDict = [curSpec titleDictionary];
        if (titleDict) {
            NSMutableDictionary *newTitles = [[NSMutableDictionary alloc] init];
            for (NSString *key in titleDict) {
                NSString *value = [titleDict objectForKey:key];
                newTitles[key] = [[self bundle] localizedStringForKey:value value:value table:nil];
            }
            [curSpec setTitleDictionary:newTitles];
        }
    }
    return specifiers;
}

- (NSString *)localizedString:(NSString *)string {
    return [[self bundle] localizedStringForKey:string value:string table:nil] ?: string;
}

- (void)loadView {
    [super loadView];

    BOOL tintSwitches_ = YES;

    if ([self respondsToSelector:@selector(tintSwitches)])
        tintSwitches_ = [self tintSwitches];

    if (tintSwitches_) {
        if ([self respondsToSelector:@selector(switchOnTintColor)]) {
            if (SK_SYSTEM_VERSION_LESS_THAN(@"9.0"))
                [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = self.switchOnTintColor;
            else
                [UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = self.switchOnTintColor;
        } else {
            if ([self respondsToSelector:@selector(tintColor)]) {
                if (SK_SYSTEM_VERSION_LESS_THAN(@"9.0"))
                    [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = self.tintColor;
                else
                    [UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = self.tintColor;
            }
        }

        if ([self respondsToSelector:@selector(switchTintColor)]) {
            if (SK_SYSTEM_VERSION_LESS_THAN(@"9.0"))
                [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = self.switchTintColor;
            else
                [UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = self.switchTintColor;
        } else if ([self respondsToSelector:@selector(tintColor)]) {
            if (SK_SYSTEM_VERSION_LESS_THAN(@"9.0"))
                [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = self.tintColor;
            else
                [UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = self.tintColor;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupHeader];

    if ([self respondsToSelector:@selector(tintColor)]) {
        self.view.tintColor = self.tintColor;
    }
    if ([self respondsToSelector:@selector(navigationTintColor)]) {
        self.navigationController.navigationBar.tintColor = self.navigationTintColor;
    } else if ([self respondsToSelector:@selector(tintColor)]) {
        self.navigationController.navigationBar.tintColor = self.tintColor;
    }
    
    if ([self respondsToSelector:@selector(switchTintColor)]) {
        if (SK_SYSTEM_VERSION_LESS_THAN(@"9.0"))
            [UITableViewCell appearanceWhenContainedIn:self.class, nil].tintColor = self.switchTintColor;
        else
            [UITableViewCell appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = self.switchTintColor;
    }

    BOOL tintNavText = YES;
    if ([self respondsToSelector:@selector(tintNavigationTitleText)])
        tintNavText = self.tintNavigationTitleText;

    if (tintNavText) {
        if ([self respondsToSelector:@selector(navigationTitleTintColor)])
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationTitleTintColor};
        else if ([self respondsToSelector:@selector(tintColor)])
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.tintColor};
    }
}

- (void)setupHeader {
    UIView *header = nil;

    if ([self respondsToSelector:@selector(headerImage)]) {
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 100)];

        UIImage *headerImage = [UIImage imageNamed:self.headerImage inBundle:[NSBundle bundleForClass:self.class]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:headerImage];
        header.frame = (CGRect) {header.frame.origin, headerImage.size};
        imageView.frame = CGRectMake(imageView.frame.origin.x, 10, imageView.frame.size.width, headerImage.size.height);

        [header addSubview:imageView];
    }

    if ([self respondsToSelector:@selector(headerText)] && self.headerText.length != 0) {
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 60)];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, header.frame.size.width, header.frame.size.height + 20)];
        label.text = SK_LCL(self.headerText);
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:45];
        label.backgroundColor = [UIColor clearColor];

        if ([self respondsToSelector:@selector(tintColor)])
            label.textColor = self.tintColor;
        if ([self respondsToSelector:@selector(headerColor)])
            label.textColor = self.headerColor;

        label.textAlignment = NSTextAlignmentCenter;

        if ([self respondsToSelector:@selector(headerSubText)] && self.headerSubText.length != 0) {
            header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y, header.frame.size.width, header.frame.size.height + 60);

            label.frame = CGRectMake(label.frame.origin.x, 10, label.frame.size.width, label.frame.size.height);
            [header addSubview:label];

            UILabel *subText = [[UILabel alloc] initWithFrame:CGRectMake(header.frame.origin.x, label.frame.origin.y + label.frame.size.height, header.frame.size.width, 20)];
            subText.text = SK_LCL(self.headerSubText);
            subText.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16];
            subText.backgroundColor = [UIColor clearColor];
            if ([self respondsToSelector:@selector(tintColor)])
                subText.textColor = self.tintColor;
            if ([self respondsToSelector:@selector(headerColor)])
                subText.textColor = self.headerColor;

            subText.textAlignment = NSTextAlignmentCenter;

            [header addSubview:subText];
        } else {
            label.frame = CGRectMake(label.frame.origin.x, 5, label.frame.size.width, label.frame.size.height);
            [header addSubview:label];
        }
    }

    if ([self respondsToSelector:@selector(headerView)]) {
        header = self.headerView;
    }

    if (header) {
        header.backgroundColor = [UIColor clearColor];

        header.autoresizesSubviews = YES;
        header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self.table setTableHeaderView:header];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [UIView animateWithDuration:.3f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self setupHeader];
                     } completion:^(BOOL finished) {}];
}

@end
