#include "AFPRootListController.h"
#include "AFPBlackListController.h"
#import <spawn.h>
#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.afontprefs.plist"
NSMutableDictionary *prefs;

@interface UIApplication (Private)
- (void)openURL:(NSURL *)url options:(NSDictionary *)options completionHandler:(void (^)(BOOL success))completion;
@end

NSString *findBoldFont(NSArray *list, NSString *name) {
	NSString *orig_font = [name stringByReplacingOccurrencesOfString:@" R" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@"Regular" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@"-Regular" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@" Regular" withString:@""];
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"R$" options:0 error:nil];
	orig_font = [regex stringByReplacingMatchesInString:orig_font options:0 range:NSMakeRange(0, [orig_font length]) withTemplate:@""];
	orig_font = [orig_font stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	if([list containsObject:[NSString stringWithFormat:@"%@-Bold", orig_font]]) return [NSString stringWithFormat:@"%@-Bold", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@-B", orig_font]]) return [NSString stringWithFormat:@"%@-B", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@Bold", orig_font]]) return [NSString stringWithFormat:@"%@Bold", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@B", orig_font]]) return [NSString stringWithFormat:@"%@B", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@ Bold", orig_font]]) return [NSString stringWithFormat:@"%@ Bold", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@ B", orig_font]]) return [NSString stringWithFormat:@"%@ B", orig_font];
	return name;
}

NSArray *getFullFontList() {
	NSArray *fonts = [UIFont familyNames];
	NSMutableArray *fullList = [NSMutableArray new];
	for(NSString *key in fonts) {
		NSArray *fontList = [UIFont fontNamesForFamilyName:key];
		for(NSString *name in fontList) {
			[fullList addObject:name];
		}
	}
	return fullList;
}

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
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"A-Font Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:@"A-Font automatically load fonts in /Library/A-Font/. You can also load the font using the profile." forKey:@"footerText"];
			specifier;
		})];
		[specifiers addObject:({
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
		PSSpecifier *_boldFontSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Bold Font" target:self set:@selector(setFont:forSpecifier:) get:@selector(getFont:) detail:[PSListItemsController class] cell:PSLinkListCell edit:nil];
		[_boldFontSpecifier.properties setValue:@"valuesSource:" forKey:@"valuesDataSource"];
		[_boldFontSpecifier.properties setValue:@"valuesSource:" forKey:@"titlesDataSource"];
		[specifiers addObject:_boldFontSpecifier];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Blacklist" target:nil set:nil get:nil detail:[AFPBlackListController class] cell:PSLinkListCell edit:nil]];

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Recommended" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Restart SpringBoard" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    specifier->action = @selector(Respring);
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
	if([fontName hasPrefix:@"Automatic ("]) fontName = @"Automatic";
	if([specifier.name isEqualToString:@"Bold Font"]) prefs[@"boldfont"] = fontName;
	else prefs[@"font"] = fontName;
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
}
- (NSString *)getFont:(PSSpecifier *)specifier {
	NSArray *fullList = getFullFontList();
	NSString *boldfont = findBoldFont(fullList, prefs[@"font"]);
	if([specifier.name isEqualToString:@"Bold Font"]) return (![prefs[@"boldfont"] isEqualToString:@"Automatic"] ? prefs[@"boldfont"] : [NSString stringWithFormat:@"Automatic (%@)", boldfont]);
	else return prefs[@"font"];
}
- (NSArray *)valuesSource:(PSSpecifier *)target {
	NSMutableArray *dic = [[[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
	if(![target.name isEqualToString:@"Font"]) {
		NSArray *fullList = getFullFontList();
		dic = [[fullList sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
		NSString *boldfont = findBoldFont(fullList, prefs[@"font"]);
		[dic insertObject:[NSString stringWithFormat:@"Automatic (%@)", boldfont] atIndex:0];
	}
	return dic;
}

-(void)openCredits:(PSSpecifier *)specifier {
	NSString *value = specifier.identifier;
	if([value isEqualToString:@"BawAppie"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/BawAppie"] options:@{} completionHandler:nil];
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
