#import "Tweak.h"

@implementation UIViewController (Anouk)
- (void)authenticateWithCompletion:(void (^)(BOOL success))completion {
    LAContext *context = [[LAContext alloc] init];
    NSError *authError = nil;

    if (policy == LAPolicyDeviceOwnerAuthenticationWithBiometrics) {
        context.localizedFallbackTitle = @""; // Hide the "Enter password" button when using Face ID
    }

    if ([context canEvaluatePolicy:policy error:&authError]) {
        [context evaluatePolicy:policy localizedReason:reason reply:^(BOOL success, NSError *error) {
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

%group AllowFaceId
%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSDictionary *plist = %orig;
	NSMutableDictionary *mutablePlist = [plist mutableCopy] ?: [NSMutableDictionary dictionary];
    [mutablePlist setObject:reason forKey:@"NSFaceIDUsageDescription"];
	return mutablePlist;
}
%end
%end

%group iPhone
%hook PXNavigationListGadget
- (id)_navigateTolistItem:(PXNavigationListAssetCollectionItem *)item animated:(BOOL)animated {
	PHAssetCollection *collection = (PHAssetCollection *)item.collection;

    id __block orig = nil;

    if (([collection px_isHiddenSmartAlbum] && lockHiddenAlbum) || ([collection px_isRecentlyDeletedSmartAlbum] && lockRecentlyDeleted)) {
        [self authenticateWithCompletion:^(BOOL success) {
            if (success) {
                accessed = YES;
                orig = %orig;
            }
        }];
    } else {
       orig = %orig;
    }
    
    return orig;
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
%end

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

%group iPad
%hook PUSidebarViewController
- (void)_navigateToDestinationForItem:(PXNavigationListAssetCollectionItem *)item sameItem:(BOOL)arg2 completionHandler:(id)arg3 {
    PHAssetCollection *collection = (PHAssetCollection *)item.collection;
    if (([collection px_isHiddenSmartAlbum] && lockHiddenAlbum) || ([collection px_isRecentlyDeletedSmartAlbum] && lockRecentlyDeleted)) {
        [self authenticateWithCompletion:^(BOOL success) {
            if (success) {
                accessed = YES;
                %orig;
            }
        }];
    } else {
        %orig;
    }
}
%end
%end

%group NewItemCount
%hook PXNavigationListGadget
- (void)_configureCell:(PXNavigationListCell *)cell forListItem:(PXNavigationListAssetCollectionItem *)item textColor:(id)color {
	%orig;

	PHAssetCollection *collection = (PHAssetCollection *)item.collection;

    if ([collection px_isHiddenSmartAlbum] && (hiddenItemCountEnabled || showLockIcon)) {
        NSAttributedString *attachmentString;
        if (showLockIcon) {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage systemImageNamed:@"lock.fill"];
            attachment.image = [attachment.image imageWithTintColor:UIColor.systemGrayColor];
            attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        } else if (hiddenItemCountEnabled) {
            NSString *itemCount = [NSString stringWithFormat:@"%ld", (long)hiddenItemCount];
            attachmentString = [[NSAttributedString alloc] initWithString:itemCount];
        }

        _UITableViewCellBadge *badge = [cell valueForKey:@"badge"];
        UILabel *badgeLabel = badge.badgeTextLabel;
        badgeLabel.attributedText = attachmentString;
    } else if ([collection px_isRecentlyDeletedSmartAlbum] && lockRecentlyDeleted && showLockIcon) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage systemImageNamed:@"lock.fill"];
        attachment.image = [attachment.image imageWithTintColor:UIColor.systemGrayColor];
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];

        _UITableViewCellBadge *badge = [cell valueForKey:@"badge"];
        UILabel *badgeLabel = badge.badgeTextLabel;
        badgeLabel.attributedText = attachmentString;
    } 
}
%end
%end

%group LegacyItemCount
%hook PXNavigationListAssetCollectionItem
- (PXNavigationListAssetCollectionItem *)initWithAssetCollection:(PHAssetCollection *)collection itemCount:(NSInteger)arg2 {
    if ([collection px_isHiddenSmartAlbum] && hiddenItemCountEnabled) {
        arg2 = hiddenItemCount;
        return %orig(collection, arg2);
    }

    return %orig;
}
%end
%end

static void loadPreferences(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.yan.anoukpreferences.plist")]) {
        NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.yan.anoukpreferences.plist")];
        
        lockRecentlyDeleted = [preferences[@"lockRecentlyDeleted"] boolValue];
        lockHiddenAlbum = preferences[@"lockHiddenAlbum"] ? [preferences[@"lockHiddenAlbum"] boolValue] : YES;
        popToRoot = [preferences[@"popToRoot"] boolValue];
        hiddenItemCountEnabled = [preferences[@"hiddenItemCountEnabled"] boolValue];
        showLockIcon = [preferences[@"showLockIcon"] boolValue];
        hiddenItemCount = [preferences[@"hiddenItemCount"] longLongValue];
        policy = [preferences[@"policy"] boolValue] ? LAPolicyDeviceOwnerAuthenticationWithBiometrics : LAPolicyDeviceOwnerAuthentication;
    }
}

static bool isEnabled() {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.yan.anoukpreferences.plist")]) {
        NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.yan.anoukpreferences.plist")];
        return [preferences[@"enabled"] boolValue];
    }

    return NO;
}

static bool shouldInject() {
    NSString *currentProcessName = [[NSProcessInfo processInfo] processName];
    NSArray *excludedProcesses = @[@"fitcored", @"finhealthxpcservices", @"coreidvd", @"remindd", @"translationd", @"fmfd"];

    if ([excludedProcesses containsObject:[currentProcessName lowercaseString]]) {
        return NO;
    }
    return YES;
}

%ctor {
    if (!shouldInject()) return;
    if (!isEnabled()) return;

    loadPreferences(NULL, NULL, NULL, NULL, NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, loadPreferences, (CFStringRef)preferencesNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);

    if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.mobileslideshow"]) %init(AllowFaceId);

    %init(_ungrouped);
    
    if ([[[UIDevice currentDevice] model] containsString:@"iPad"]) {
        %init(iPad);
    } else {
        %init(iPhone);
        if ([UIDevice currentDevice].systemVersion.floatValue >= 15.0) {
            %init(NewItemCount);
        } else {
            %init(LegacyItemCount);
        }
    }
}