#include <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

static NSString *fontname;
static NSString *boldfontname;
static BOOL enableSafari;
static BOOL WebKitImportant;
static NSNumber *size;

typedef NSString *UIFontTextStyle;

@interface UIFont (Private)
+ (id)fontWithName:(id)arg1 size:(double)arg2 traits:(int)arg3;
@end

double getSize(double orig_size) {
	return orig_size*[size doubleValue];
}

BOOL Search(NSString* path, NSString* search){
	if([path rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound) {
    return YES;
  }
	else return NO;
}

BOOL checkFont(NSString* font) {
	if(font == nil) return false;
  if(
    Search(font, @"icon")
    || Search(font, @"glyph")
    || Search(font, @"wundercon")
    || Search(font, @"GoogleSans-Regular")
  ) {return true;}
  else return false;
}

id (*orig_systemFontOfSize)(Class, SEL, NSString *, double, int) = nil;

%hook UIFont
+ (id)fontWithName:(NSString *)arg1 size:(double)arg2 {
  if(checkFont(arg1)) return %orig;
	if([arg1 isEqualToString:boldfontname]) return %orig;
  else return %orig(fontname, getSize(arg2));
}
+ (id)fontWithName:(NSString *)arg1 size:(double)arg2 traits:(int)arg3 {
	orig_systemFontOfSize = &%orig;
  if(checkFont(arg1)) return %orig;
	if([arg1 isEqualToString:boldfontname]) return %orig;
  else return %orig(fontname, getSize(arg2), arg3);
}
+ (id)fontWithFamilyName:(NSString *)arg1 traits:(int)arg2 size:(double)arg3 {
	if(checkFont(arg1)) return %orig;
	if([arg1 isEqualToString:boldfontname]) return %orig;
  else return [self fontWithName:fontname size:getSize(arg3) traits:arg2];
}
+ (id)boldSystemFontOfSize:(double)arg1 {
  return [self fontWithName:boldfontname != nil ? boldfontname : fontname size:getSize(arg1)];
}
+ (id)userFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
+ (id)systemFontOfSize:(double)arg1 weight:(double)arg2 design:(id)arg3 {
	return [self fontWithName:(arg2 >= 0.2 && boldfontname != nil ? boldfontname : fontname) size:getSize(arg1)];
}
+ (id)systemFontOfSize:(double)arg1 weight:(double)arg2 {
	return [self fontWithName:(arg2 >= 0.2 && boldfontname != nil ? boldfontname : fontname) size:getSize(arg1)];
}
+ (id)systemFontOfSize:(double)arg1 traits:(int)arg2 {
  return [self fontWithName:fontname size:getSize(arg1) traits:arg2];
}
+ (id)systemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
+ (id)italicSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
+ (id)_systemFontsOfSize:(double)arg1 traits:(int)arg2 {
  return [self fontWithName:fontname size:getSize(arg1) traits:arg2];
}
+ (id)_thinSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
+ (id)_ultraLightSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
+ (id)_lightSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
+ (id)_opticalBoldSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
+ (id)_opticalSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
+ (id)preferredFontForTextStyle:(UIFontTextStyle)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:font size:getSize(font.pointSize)];
  return ret;
}
+ (id)preferredFontForTextStyle:(UIFontTextStyle)arg1 compatibleWithTraitCollection:(id)arg2 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:font size:getSize(font.pointSize)];
  return ret;
}
+ (id)ib_preferredFontForTextStyle:(UIFontTextStyle)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:font size:getSize(font.pointSize)];
  return ret;
}
+ (id)defaultFontForTextStyle:(UIFontTextStyle)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:font size:getSize(font.pointSize)];
  return ret;
}
+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)arg1 size:(double)arg2 {
  if(checkFont(arg1.fontAttributes[@"NSFontNameAttribute"])) return %orig;
	UIFontDescriptor *d = [UIFontDescriptor fontDescriptorWithName:fontname size:arg2 != 0 ? getSize(arg2) : getSize(arg1.pointSize)];
	if(arg1.symbolicTraits & UIFontDescriptorTraitBold && boldfontname) d = [UIFontDescriptor fontDescriptorWithName:boldfontname size:arg2 != 0 ? getSize(arg2) : getSize(arg1.pointSize)];
	return %orig(d, 0);
}
+ (id)monospacedDigitSystemFontOfSize:(double)arg1 weight:(double)arg2 {
  return [self fontWithName:fontname size:getSize(arg1)];
}
%end
%hook UIKBRenderFactory
- (id)thinKeycapsFontName {
  return fontname;
}
- (id)lightKeycapsFontName {
  return fontname;
}
%end
%hook UIKBTextStyle
+ (id)styleWithFontName:(id)arg1 withFontSize:(double)arg2 {
  return %orig(fontname, getSize(arg2));
}
%end

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, assign) long long fontStyle;
@property (nonatomic, assign) NSString *originalText;
@end

%group iOS12
%hook _UIStatusBarStringView
-(void)font {
	if([self.originalText isEqualToString:@"LTE"]) {
		self.font = orig_systemFontOfSize([UIFont class], _cmd, @".SFUIText-Medium", 12, 0);
	}
	%orig;
}
-(void)setText:(NSString *)text {
	if([text isEqualToString:@"LTE"]) {
		self.fontStyle = 1;
	}
	%orig;
}
%end
%end

@interface WKWebView
-(void)evaluateJavaScript:(id)arg1 completionHandler:(id)arg2 ;
@end

%hook WKWebView
-(void)_didFinishLoadForMainFrame {
  %orig;
  if(enableSafari && [[UIFont familyNames] containsObject:fontname]) [self evaluateJavaScript:[NSString stringWithFormat:@"var node = document.createElement('style'); node.innerHTML = '* { font-family: \\'%@\\'%@ }'; document.head.appendChild(node);", fontname, (WebKitImportant ? @" !important" : @"")] completionHandler:nil];
}
%end

NSString *findBoldFont(NSArray *list, NSString *name) {
	NSString *orig_font = [name stringByReplacingOccurrencesOfString:@" R" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@"" withString:@""];
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

%ctor {
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.afontprefs.plist"];

	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *subpaths = [manager contentsOfDirectoryAtPath:@"/Library/A-Font/" error:NULL];
	[UIFont familyNames];
	for(NSString *key in subpaths) {
		NSString *fullPath = [NSString stringWithFormat:@"/Library/A-Font/%@", key];
		CFErrorRef error;
		CTFontManagerUnregisterFontsForURL((CFURLRef)[NSURL fileURLWithPath:fullPath], kCTFontManagerScopeNone, nil);
		if(!CTFontManagerRegisterFontsForURL((CFURLRef)[NSURL fileURLWithPath:fullPath], kCTFontManagerScopeNone, &error)) {
			CFStringRef errorDescription = CFErrorCopyDescription(error);
			HBLogError(@"Failed to load font: %@", errorDescription);
			CFRelease(errorDescription);
		}
	}

	NSArray *fullFontList = getFullFontList();
  fontname = plistDict[@"font"];
	if(fontname != nil) {
		if(!plistDict[@"boldfont"] || [plistDict[@"boldfont"] isEqualToString:@"Automatic"]) boldfontname = findBoldFont(fullFontList, fontname);
		else boldfontname = plistDict[@"boldfont"];
	} else boldfontname = nil;
	size = plistDict[@"size"] ? plistDict[@"size"] : @1;
  enableSafari = [plistDict[@"enableSafari"] boolValue];
  WebKitImportant = [plistDict[@"WebKitImportant"] boolValue];
  NSArray *fonts = [UIFont fontNamesForFamilyName:fontname];
	NSString *identifier = [NSBundle mainBundle].bundleIdentifier;
  if([plistDict[@"isEnabled"] boolValue] && fontname != nil && [fonts count] != 0 && ([plistDict[@"blacklist"][identifier] isEqual:@1] ? false : true) && ![identifier isEqualToString:@"com.apple.SafariViewService"]) {
    %init;
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		if(version >= 12) %init(iOS12);
  }
}
