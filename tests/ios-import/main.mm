// UI smoke harness: the actual production importer, without a game or renderer.
#import "import_controller.h"
@interface PTImportTestDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic) UIWindow* window;
@end
@implementation PTImportTestDelegate
- (BOOL)application:(UIApplication*)app didFinishLaunchingWithOptions:(NSDictionary*)options {
    self.window=[[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    PTImportController* importer=[PTImportController new];
    NSURL* documents=[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    importer.destination=[documents URLByAppendingPathComponent:@"Game"];
    self.window.rootViewController=importer; [self.window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc,char**argv) { @autoreleasepool { return UIApplicationMain(argc,argv,nil,NSStringFromClass(PTImportTestDelegate.class)); } }
