#include "AFPRootListController.h"
#import <spawn.h>
#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.afontprefs.plist"
NSMutableDictionary *prefs;

@interface UIApplication (Private)
- (void)openURL:(NSURL *)url options:(NSDictionary *)options completionHandler:(void (^)(BOOL success))completion;
@end

@implementation AFPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Credits" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:@"and JBI, Asamo, r/jailbreakdevelopers, r/Jailbreak, and.. You!" forKey:@"footerText"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"@BawAppie (Developer)" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"BawAppie"];
	    specifier->action = @selector(openCredits:);
			specifier;
		})];

		[specifiers addObject:({
				[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"A-Font Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Enable" target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
				[specifier.properties setValue:@"isEnabled" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Enable in WebKit" target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"enableSafari" forKey:@"displayIdentifier"];
			specifier;
		})];
		PSSpecifier *_fontSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Font" target:self set:@selector(setFont:forSpecifier:) get:@selector(getFont:) detail:[PSListItemsController class] cell:PSLinkListCell edit:nil];
		[_fontSpecifier.properties setValue:@"valuesSource:" forKey:@"valuesDataSource"];
		[_fontSpecifier.properties setValue:@"valuesSource:" forKey:@"titlesDataSource"];
		[specifiers addObject:_fontSpecifier];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Recommended" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:@"Copy your font to Font Manager and install it." forKey:@"footerText"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Restart SpringBoard" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    specifier->action = @selector(Respring);
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Install Font Manager (App Store)" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"fontmanager"];
	    specifier->action = @selector(openCredits:);
			specifier;
		})];

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	prefs[[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs[[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}

- (void)setFont:(NSString *)fontName forSpecifier:(PSSpecifier*)specifier {
	prefs[@"font"] = fontName;
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
}
- (NSString *)getFont:(PSSpecifier *)specifier {
	return prefs[@"font"];
}
- (NSArray *)valuesSource:(id)target {
	return [UIFont familyNames];
}

-(void)openCredits:(PSSpecifier *)specifier {
	NSString *value = specifier.identifier;
	if([value isEqualToString:@"BawAppie"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/BawAppie"] options:@{} completionHandler:nil];
	else if([value isEqualToString:@"fontmanager"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/font-manager/id789211165"] options:@{} completionHandler:nil];
}
-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}
- (void)Respring {
	pid_t pid;
  const char* args[] = {"killall", "backboardd", NULL};
  posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}
@end
