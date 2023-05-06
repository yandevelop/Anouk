#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

NSString *reason = @"Use your passcode to view and manage hidden album.";

BOOL accessed;
static NSString *localizedHiddenLabel = nil;
static NSString *recentlyDeletedLabel = nil;

static NSString *domain = @"com.yan.anoukpreferences";
static NSString *preferencesNotification = @"com.yan.anoukpreferences/changed";

static BOOL enabled;
static BOOL lockRecentlyDeleted;
static BOOL popToRoot;
static BOOL hiddenItemCountEnabled;
static long long hiddenItemCount;

@interface TCCDService : NSObject
@property (retain, nonatomic) NSString *name;
- (void)setDefaultAllowedIdentifiersList:(NSArray *)list;
@end

@interface PXNavigationListGadget : UIViewController
@end

@interface PUAlbumsGadgetViewController : UIViewController
@end

@interface PUSidebarViewController : UIViewController
@end

@interface NSUserDefaults (Anouk)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
