#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <Photos/Photos.h>
#import <rootless.h>

#define NSLog(args...) NSLog(@"[Anouk] "args)

static NSString *preferencesNotification = @"com.yan.anoukpreferences/changed";
NSString *reason = @"Use your passcode to view and manage hidden album.";

BOOL accessed;

BOOL lockRecentlyDeleted;
BOOL popToRoot;
BOOL hiddenItemCountEnabled;
BOOL showLockIcon;
NSInteger hiddenItemCount;

@interface TCCDService : NSObject
@property (retain, nonatomic) NSString *name;
- (void)setDefaultAllowedIdentifiersList:(NSArray *)list;
@end

@interface PXNavigationListCell : UITableViewCell
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

@interface PHAssetCollection (Private)
@property (nonatomic,readonly) BOOL px_isHiddenSmartAlbum;
@property (nonatomic,readonly) BOOL px_isRecentlyDeletedSmartAlbum;
@end

@interface PXNavigationListItem : NSObject
@end

@interface PXNavigationListDisplayAssetCollectionItem : PXNavigationListItem
@property (nonatomic, assign, readonly) PHCollection *collection;
@end

@interface PXGadgetUIViewController : UICollectionViewController
@end

@interface PXHorizontalCollectionGadget : PXGadgetUIViewController
@end

@interface PUHorizontalAlbumListGadget : PXHorizontalCollectionGadget
@end

@interface PXNavigationListAssetCollectionItem : PXNavigationListDisplayAssetCollectionItem
@property (nonatomic, readonly) PHAssetCollection *_collection;
@end

@interface PUAlbumListViewController : UIViewController
@end

@interface _UITableViewCellBadge : UIView
@property (nonatomic, strong, readwrite) UILabel *badgeTextLabel;
@end