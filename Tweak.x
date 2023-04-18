#import "Tweak.h"

NSString *reason = @"Use your passcode to view and manage hidden album.";

BOOL accessed;
NSString *localizedHiddenLabel = nil;

%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *info = [%orig mutableCopy];
    NSMutableDictionary *mPlist = [info mutableCopy] ?: [NSMutableDictionary dictionary];
    [mPlist setValue:reason forKey:@"NSFaceIDUsageDescription"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSBundleDidLoadNotification object:self];
    return mPlist.copy;
}
%end

// Credits to https://github.com/jacobcxdev/iDunnoU/blob/648e27a564b42df45c0ed77dc5d1609baedc98ef/Tweak.x
%hook TCCDService
- (void)setDefaultAllowedIdentifiersList:(NSArray *)list {
    if ([self.name isEqual:@"kTCCServiceFaceID"]) {
        NSMutableArray *tcclist = [list mutableCopy];
        [tcclist addObject:@"com.apple.mobileslideshow"];
        return %orig([tcclist copy]);
    }
    return %orig;
}
%end


%hook PXNavigationListGadget
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get an instance of the current cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = cell.contentView.subviews[1];
    NSString *cellLabel = label.text;

    // Check if the tapped cell is the "Hidden" cell.
    // There are definetely more reliable or elegant ways to check that (for example with PHFetchResult or similar)
    if ([cellLabel isEqualToString:localizedHiddenLabel]) {
        LAContext *context = [[LAContext alloc] init];
        NSError *authError = nil;

        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        accessed = YES;
                        %orig;
                    } else {
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }
                });
            }];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];;
        }
    } else {
        %orig;
    }
}
%end

%hook PUAlbumsGadgetViewController
// When photos app is being left in background and the hidden album
// is accessed, it will go back to it's root view controller
- (void)_applicationDidEnterBackground:(id)arg1 {
	if (accessed) {
        UINavigationController *nav = self.navigationController;
        if (nav) {
            accessed = NO;
            [nav popToRootViewControllerAnimated:NO];   
        }
	}
    %orig;
}
%end

%ctor {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.PhotoLibraryServices"];
    localizedHiddenLabel = [bundle localizedStringForKey:@"ALL_HIDDEN" value:@"" table:@"PhotoLibraryServices"];
}