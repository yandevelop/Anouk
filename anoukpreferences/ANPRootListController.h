#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "spawn.h"
#import <rootless.h>

@interface ANPRootListController : PSListController
@property(nonatomic, retain) UIView *headerView;
@property(nonatomic, retain) UIBarButtonItem *item;
@property(nonatomic, retain) UISwitch *enableSwitch;
@property(nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, retain) UIImageView *headerImageView;
@property(nonatomic, retain) UIImageView *iconView;
@end

@interface NSUserDefaults (Anouk)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end