#import <UIKit/UIKit.h>
BOOL PTIOSHasGame(NSURL* dir);
@interface PTImportController : UIViewController <UIDocumentPickerDelegate>
@property(nonatomic) NSURL* destination;
@property(nonatomic) UILabel* detail;
@property(nonatomic) UIButton* importButton;
@property(nonatomic) UIProgressView* progress;
@property(nonatomic) BOOL ready;
@end
