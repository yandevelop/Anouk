#import "Tweak.h"

@implementation UIViewController (Anouk)
- (void)authenticateWithCompletion:(void (^)(BOOL success))completion {
    LAContext *context = [[LAContext alloc] init];
    NSError *authError = nil;

    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    completion(YES);
                } else {
                    completion(NO);
                }
            });
        }];
    } else {
        completion(NO);
    }
}
@end

%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSDictionary *plist = %orig;
	NSMutableDictionary *mutablePlist = [plist mutableCopy] ?: [NSMutableDictionary dictionary];
    [mutablePlist setObject:reason forKey:@"NSFaceIDUsageDescription"];
	return mutablePlist;
}
%end

// Credits to https://github.com/jacobcxdev/iDunnoU/blob/648e27a564b42df45c0ed77dc5d1609baedc98ef/Tweak.x
%hook TCCDService
- (void)setDefaultAllowedIdentifiersList:(NSArray *)list {
    if ([self.name isEqual:@"kTCCServiceFaceID"]) {
        NSMutableArray *tcclist = [list mutableCopy];
        [tcclist addObject:@"com.apple.mobileslideshow"];
        [tcclist addObject:@"com.apple.PhotosUICore"];
        return %orig([tcclist copy]);
    }
    return %orig;
}
%end

%group iPhone
%hook PXNavigationListGadget
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellLabel = [[[(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath] contentView].subviews[1] valueForKey:@"text"] lowercaseString];

    if ([cellLabel isEqualToString:localizedHiddenLabel] || ([cellLabel isEqualToString:recentlyDeletedLabel] && lockRecentlyDeleted)) {
        [self authenticateWithCompletion:^(BOOL success) {
            if (success) {
                accessed = YES;
                %orig;
            } else {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
    } else {
        %orig;
    }
}
%end


%hook PUAlbumsGadgetViewController
// When photos app is being left in background and the hidden album
// is accessed, it will go back to it's root view controller
- (void)_applicationDidEnterBackground:(id)arg1 {
	if (accessed && popToRoot) {
        UINavigationController *nav = self.navigationController;
        if (nav) {
            accessed = NO;
            [nav popToRootViewControllerAnimated:NO];   
        }
	}
    %orig;
}
%end

%hook PXNavigationListItem
- (id)initWithIdentifier:(id)arg1 title:(id)arg2 itemCount:(long long)arg3{
    if ([[arg2 lowercaseString] containsString:localizedHiddenLabel] && hiddenItemCountEnabled){
        return %orig(arg1,arg2,hiddenItemCount);
    } else {
        return %orig;
    }
}
%end
%end

%group iPad
%hook PUSidebarViewController
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellLabel = [[[(UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] contentView].subviews[1] valueForKey:@"text"] lowercaseString];

    if ([cellLabel isEqualToString:localizedHiddenLabel] || ([cellLabel isEqualToString:recentlyDeletedLabel] && lockRecentlyDeleted)) {
        [self authenticateWithCompletion:^(BOOL success) {
            if (success) {
                %orig;
            } else {
                [collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        }];
    } else {
        %orig;
    }
}
%end
%end

static void loadPreferences(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSNumber *enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:domain];
    enabled = (enabledValue) ? [enabledValue boolValue] : NO;
    NSNumber *lockRecentlyDeletedValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"lockRecentlyDeleted" inDomain:domain];
    lockRecentlyDeleted = (lockRecentlyDeletedValue) ? [lockRecentlyDeletedValue boolValue] : NO;
    NSNumber *popToRootValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"popToRoot" inDomain:domain];
    popToRoot = (popToRootValue) ? [popToRootValue boolValue] : NO;
    hiddenItemCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hiddenItemCount" inDomain:domain] longLongValue];
    NSNumber *hiddenItemCountEnabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"hiddenItemCountEnabled" inDomain:domain];
    hiddenItemCountEnabled = (hiddenItemCountEnabledValue) ? [hiddenItemCountEnabledValue boolValue] : NO;
}

%ctor {
    loadPreferences(NULL, NULL, NULL, NULL, NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, loadPreferences, (CFStringRef)preferencesNotification, NULL, CFNotificationSuspensionBehaviorCoalesce); // Preferences changed
    
    if (!enabled) return;

    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.PhotoLibraryServices"];
    localizedHiddenLabel = ([[bundle localizedStringForKey:@"ALL_HIDDEN" value:@"" table:@"PhotoLibraryServices"] lowercaseString]);
    recentlyDeletedLabel = ([[bundle localizedStringForKey:@"ALL_TRASH_BIN" value:@"" table:@"PhotoLibraryServices"] lowercaseString]);

    if ([[[UIDevice currentDevice] model] containsString:@"iPad"]) {
        %init(iPad);
    } else {
        %init(iPhone);
    }
    %init();
}