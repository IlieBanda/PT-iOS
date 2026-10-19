#import "import_controller.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
static NSArray<NSString*>* RequiredFiles() { return @[@"chunk1.psarc", @"texture.qar", @"pathid_list_ps4.bin"]; }
BOOL PTIOSHasGame(NSURL* dir) {
    for (NSString* name in RequiredFiles()) {
        NSNumber* size = nil;
        NSURL* file = [dir URLByAppendingPathComponent:name];
        NSNumber* regular = nil;
        [file getResourceValue:&regular forKey:NSURLIsRegularFileKey error:nil];
        [file getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
        if (!regular.boolValue || size.unsignedLongLongValue == 0) return NO;
    }
    return YES;
}

@implementation PTImportController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.025 alpha:1];
    UILabel* title = [UILabel new]; title.text = @"P.T.";
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:76];
    title.textColor = UIColor.whiteColor; title.textAlignment = NSTextAlignmentCenter;
    UILabel* subtitle = [UILabel new]; subtitle.text = @"PLAYABLE TEASER";
    subtitle.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    subtitle.textColor = [UIColor colorWithWhite:0.55 alpha:1]; subtitle.textAlignment = NSTextAlignmentCenter;
    self.detail = [UILabel new]; self.detail.numberOfLines = 0; self.detail.textAlignment = NSTextAlignmentCenter;
    self.detail.font = [UIFont systemFontOfSize:14]; self.detail.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    self.detail.text = @"Select the folder from your own PS4 dump.\nchunk1.psarc · texture.qar · pathid_list_ps4.bin\n\nNative iOS engine · No CPU JIT";
    self.importButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration* config = [UIButtonConfiguration borderedButtonConfiguration];
    config.title = @"Import game files"; config.baseForegroundColor = UIColor.whiteColor;
    config.contentInsets = NSDirectionalEdgeInsetsMake(12, 26, 12, 26); self.importButton.configuration = config;
    [self.importButton addTarget:self action:@selector(selectFolder) forControlEvents:UIControlEventTouchUpInside];
    self.progress = [UIProgressView new]; self.progress.progressTintColor = UIColor.whiteColor; self.progress.hidden = YES;
    UIStackView* stack = [[UIStackView alloc] initWithArrangedSubviews:@[title,subtitle,self.detail,self.importButton,self.progress]];
    stack.axis = UILayoutConstraintAxisVertical; stack.spacing = 18; stack.alignment = UIStackViewAlignmentFill;
    stack.translatesAutoresizingMaskIntoConstraints = NO; [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
      [stack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
      [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
      [stack.widthAnchor constraintLessThanOrEqualToConstant:510],
      [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:28],
      [stack.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-28]]];
}
- (void)selectFolder {
    UIDocumentPickerViewController* picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeFolder] asCopy:NO];
    picker.delegate = self; picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentsAtURLs:(NSArray<NSURL*>*)urls {
    NSURL* source = urls.firstObject; if (!source) return;
    self.importButton.enabled = NO; self.progress.hidden = NO; self.progress.progress = 0;
    self.detail.text = @"Checking game files…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,0), ^{
        BOOL scoped = [source startAccessingSecurityScopedResource];
        NSURL* root = source;
        if (!PTIOSHasGame(root)) {
            NSURL* nested = [source URLByAppendingPathComponent:@"CUSA01127" isDirectory:YES];
            if (PTIOSHasGame(nested)) root = nested;
        }
        NSError* error = nil;
        BOOL valid = PTIOSHasGame(root);
        NSFileManager* fm = NSFileManager.defaultManager;
        NSURL* stage = [self.destination.URLByDeletingLastPathComponent URLByAppendingPathComponent:@"Game.importing"];
        if (valid) {
            [fm removeItemAtURL:stage error:nil];
            valid = [fm createDirectoryAtURL:stage withIntermediateDirectories:YES attributes:nil error:&error];
            NSUInteger count = 0;
            for (NSString* name in RequiredFiles()) {
                if (!valid) break;
                dispatch_async(dispatch_get_main_queue(), ^{ self.detail.text = [@"Copying " stringByAppendingString:name]; });
                valid = [fm copyItemAtURL:[root URLByAppendingPathComponent:name] toURL:[stage URLByAppendingPathComponent:name] error:&error];
                float progress = ++count / 3.0f;
                dispatch_async(dispatch_get_main_queue(), ^{ [self.progress setProgress:progress animated:YES]; });
            }
            if (valid) {
                if ([fm fileExistsAtPath:self.destination.path])
                    valid = [fm replaceItemAtURL:self.destination withItemAtURL:stage backupItemName:nil options:0 resultingItemURL:nil error:&error];
                else valid = [fm moveItemAtURL:stage toURL:self.destination error:&error];
            }
            if (!valid) [fm removeItemAtURL:stage error:nil];
        }
        if (scoped) [source stopAccessingSecurityScopedResource];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ready = valid;
            if (!valid) {
                self.detail.text = error ? error.localizedDescription : @"The selected folder must contain all three non-empty game files.\nSelect CUSA01127 or the folder containing the archives.";
                self.importButton.enabled = YES; self.progress.hidden = YES;
            }
        });
    });
}
@end
