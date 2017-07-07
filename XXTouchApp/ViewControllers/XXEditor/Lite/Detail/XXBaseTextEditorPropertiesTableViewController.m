//
//  XXBaseTextEditorPropertiesTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/20/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXBaseTextEditorPropertiesTableViewController.h"
#import "XXLocalDataService.h"

@interface XXBaseTextEditorPropertiesTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *filesizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *modificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *encodingLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineEndingsLabel;
@property (weak, nonatomic) IBOutlet UILabel *syntaxDefinitionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordCountLabel;

@end

@implementation XXBaseTextEditorPropertiesTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *err = nil;
    [self loadFilePropertiesWithError:&err];
    if (err) {
        [self.navigationController.view makeToast:[err localizedDescription]];
    }
}

- (BOOL)loadFilePropertiesWithError:(NSError **)err {
    self.filenameLabel.text = [self.filePath lastPathComponent];
    NSNumber *size = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:err] objectForKey:NSFileSize];
    self.filesizeLabel.text = [NSByteCountFormatter stringFromByteCount:[size intValue] countStyle:NSByteCountFormatterCountStyleFile];
    if (*err) return NO;
    NSDate *modifiedAt = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:err] objectForKey:NSFileModificationDate];
    if (*err) return NO;
    self.modificationLabel.text = [[XXTGSSI.dataService defaultDateFormatter] stringFromDate:modifiedAt];
    self.encodingLabel.text = NSLocalizedString(@"Unicode (UTF-8)", nil); // Certain
    NSRange crlfRange = [self.fileContent rangeOfString:@"\r\n"];
    if (crlfRange.location != NSNotFound) {
        self.lineEndingsLabel.text = NSLocalizedString(@"Windows (CRLF)", nil);
    } else {
        NSRange crRange = [self.fileContent rangeOfString:@"\r"];
        if (crRange.location != NSNotFound) {
            self.lineEndingsLabel.text = NSLocalizedString(@"Mac (CR)", nil);
        } else {
            self.lineEndingsLabel.text = NSLocalizedString(@"Unix (LF)", nil);
        }
    }
    NSString *fileExt = [[self.filePath pathExtension] lowercaseString];
    if ([fileExt isEqualToString:@"lua"]) {
        self.syntaxDefinitionLabel.text = NSLocalizedString(@"Lua (*.lua)", nil);
    } else if ([fileExt isEqualToString:@"txt"]) {
        self.syntaxDefinitionLabel.text = NSLocalizedString(@"Plain Text (*.txt)", nil);
    } else {
        self.syntaxDefinitionLabel.text = NSLocalizedString(@"N/A", nil);
    }
    NSUInteger lineCount = [self countChar:self.fileContent cchar:'\n'];
    self.lineCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)lineCount];
    NSUInteger charCount = [self countCharacters:self.fileContent];
    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)charCount];
    NSUInteger wordCount = [self wordCount:self.fileContent];
    self.wordCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)wordCount];
    return YES;
}

- (NSUInteger)countChar:(NSString *)s cchar:(char)c
{
    int count = 0;
    NSUInteger l = [s length];
    for (int i = 0; i < l; i++) {
        char cc = [s characterAtIndex:i];
        if (cc == c) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)wordCount:(NSString *)str {
    NSUInteger words = 0;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while ([scanner scanUpToCharactersFromSet:whiteSpace intoString:nil])
        words++;
    return words;  
}

- (NSUInteger)countCharacters:(NSString *)s {
    int count = 0;
    NSUInteger l = [s length];
    for (int i = 0; i < l; i++) {
        char cc = [s characterAtIndex:i];
        if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:cc]) {
            count++;
        }
    }
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    XXLog(@"");
}

@end
