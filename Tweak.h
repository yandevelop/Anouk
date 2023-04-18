#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface TCCDService : NSObject
@property (retain, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL isAccessAllowedByDefault;
@end

@interface PUAlbumsGadgetViewController : UIViewController
@end