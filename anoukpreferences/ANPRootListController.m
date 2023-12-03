#import <Foundation/Foundation.h>
#import "ANPRootListController.h"
#import "spawn.h"
#import <rootless.h>

#define kAnoukPreferencesPath ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.yan.anoukpreferences.plist")
#define kAnoukIconPath ROOT_PATH_NS(@"/Library/PreferenceBundles/AnoukPreferences.bundle/anouk.png")
#define kPosixPath ROOT_PATH_NS(@"/usr/bin/killall")

static NSString *domain = @"com.yan.anoukpreferences";

@implementation ANPRootListController

- (instancetype)init {
	self = [super init];

	if (self) {
		self.navigationItem.titleView = [UIView new];

		self.enableSwitch = [UISwitch new];
		[self.enableSwitch addTarget:self action:@selector(enableSwitchChanged) forControlEvents:UIControlEventValueChanged];
		self.enableSwitch.tintColor = [UIColor colorWithRed:255/255.0 green:105/255.0 blue:180/255.0 alpha:1.0];
		self.enableSwitch.onTintColor = [UIColor colorWithRed:255/255.0 green:105/255.0 blue:180/255.0 alpha:1.0];

		self.item = [[UIBarButtonItem alloc] initWithCustomView:self.enableSwitch];
		self.navigationItem.rightBarButtonItem = self.item;
		[self.navigationItem setRightBarButtonItem:self.item];

		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
		self.titleLabel.textColor = [UIColor labelColor];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.titleLabel.text = @"Anouk";
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		[self.navigationItem.titleView addSubview:self.titleLabel];

		self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
		self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
		self.headerImageView.image = [UIImage imageWithContentsOfFile:kAnoukIconPath];
		self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;		
		self.headerImageView.contentMode = UIViewContentModeScaleAspectFit;

		self.headerImageView.layer.shadowColor = [UIColor labelColor].CGColor;
		self.headerImageView.layer.shadowOffset = CGSizeZero;
		self.headerImageView.layer.shadowOpacity = 0.3;
		self.headerImageView.layer.shadowRadius = 10;

		[self.headerView addSubview:self.headerImageView];

		[NSLayoutConstraint activateConstraints:@[
			[self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
        	[self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
        	[self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
        	[self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
			[self.headerImageView.widthAnchor constraintEqualToConstant:125],
			[self.headerImageView.heightAnchor constraintEqualToConstant:125],
			[self.headerImageView.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
			[self.headerImageView.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
		]];
	}

	return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.tableHeaderView = self.headerView;
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)enableSwitchChanged {
	if (self.enableSwitch.isOn) {
		[[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"enabled" inDomain:domain];
		[self.enableSwitch setOn:YES animated:YES];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"enabled" inDomain:domain];
		[self.enableSwitch setOn:NO animated:YES];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self killPhotos];
}

- (void)killPhotos {
	dispatch_async(dispatch_get_main_queue(), ^{
		const char *path = [kPosixPath UTF8String];
		pid_t pid;
		const char* args[] = {"killall", "-9", "MobileSlideShow", NULL, NULL};
		posix_spawn(&pid, path, NULL, NULL, (char* const*)args, NULL);
	});
}


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setEnabledState];
}

- (void)setEnabledState {
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:domain] boolValue]) {
		[[self enableSwitch] setOn:NO animated:NO];
	} else {
		[[self enableSwitch] setOn:YES animated:NO];
	}
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.yan.anoukpreferences/changed", nil, nil, true);
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.yan.anoukpreferences/changed", nil, nil, true);
}
@end