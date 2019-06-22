#include <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

static NSString *fontname;
static NSString *boldfontname;
static BOOL enableSafari;

typedef NSString *UIFontTextStyle;

@interface UIFont (Private)
+ (id)fontWithName:(id)arg1 size:(double)arg2 traits:(int)arg3;
@end

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
  ) {return true;}
  else return false;
}

%hook UIFont
+ (id)fontWithName:(NSString *)arg1 size:(double)arg2 {
  if(checkFont(arg1)) return %orig;
  else return %orig(fontname, arg2);
}
+ (id)fontWithName:(NSString *)arg1 size:(double)arg2 traits:(int)arg3 {
  if(checkFont(arg1)) return %orig;
  else return %orig(fontname, arg2, arg3);
}
+ (id)fontWithFamilyName:(id)arg1 traits:(int)arg2 size:(double)arg3 {
	if(checkFont(arg1)) return %orig;
  else return [self fontWithName:fontname size:arg3 traits:arg2];
}
+ (id)boldSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)userFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)systemFontOfSize:(double)arg1 weight:(double)arg2 design:(id)arg3 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)systemFontOfSize:(double)arg1 weight:(double)arg2 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)systemFontOfSize:(double)arg1 traits:(int)arg2 {
  return [self fontWithName:fontname size:arg1 traits:arg2];
}
+ (id)systemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)italicSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)_systemFontsOfSize:(double)arg1 traits:(int)arg2 {
  return [self fontWithName:fontname size:arg1 traits:arg2];
}
+ (id)_thinSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)_ultraLightSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)_lightSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)_opticalBoldSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)_opticalSystemFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)preferredFontForTextStyle:(UIFontTextStyle)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:font size:font.pointSize];
  return ret;
}
+ (id)preferredFontForTextStyle:(UIFontTextStyle)arg1 compatibleWithTraitCollection:(id)arg2 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:font size:font.pointSize];
  return ret;
}
+ (id)ib_preferredFontForTextStyle:(UIFontTextStyle)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:font size:font.pointSize];
  return ret;
}
+ (id)defaultFontForTextStyle:(UIFontTextStyle)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:font size:font.pointSize];
  return ret;
}
+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)arg1 size:(double)arg2 {
	// HBLogDebug(@"%@", arg1.NSCTFontUIUsageAttribute);
  if(checkFont(arg1.fontAttributes[@"NSFontNameAttribute"])) return %orig;
  // return [self fontWithName:fontname size:arg2 != 0 ? arg2 : arg1.pointSize];
	UIFontDescriptor *d = [UIFontDescriptor fontDescriptorWithName:fontname size:arg2 != 0 ? arg2 : arg1.pointSize];
	if(arg1.symbolicTraits & UIFontDescriptorTraitBold) {
		 d = [UIFontDescriptor fontDescriptorWithName:boldfontname size:arg2 != 0 ? arg2 : arg1.pointSize];
	}
	return %orig(d, 0);
}
+ (id)monospacedDigitSystemFontOfSize:(double)arg1 weight:(double)arg2 {
  return [self fontWithName:fontname size:arg1];
}
- (UIFont *)fontWithSize:(CGFloat)fontSize {
  return [UIFont fontWithName:fontname size:fontSize];
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
  return %orig(fontname, arg2);
}
%end

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, assign) long long fontStyle;
@end

%hook _UIStatusBarStringView
-(void)setText:(NSString *)arg1 {
	%orig;
	if([arg1 isEqualToString:@"LTE"]) self.fontStyle = 1;
}
%end

@interface WKWebView
-(void)evaluateJavaScript:(id)arg1 completionHandler:(id)arg2 ;
@end

%hook WKWebView
-(void)_didFinishLoadForMainFrame {
  %orig;
  if(enableSafari) [self evaluateJavaScript:[NSString stringWithFormat:@"var node = document.createElement('style'); node.innerHTML = '* { font-family: \\'%@\\' }'; document.head.appendChild(node);", fontname] completionHandler:nil];
}
%end

NSString *findBoldFont(NSArray *list, NSString *name) {
	NSString *orig_font = [name stringByReplacingOccurrencesOfString:@" R" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@"Regular" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@"-Regular" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@" Regular" withString:@""];
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"R$" options:0 error:nil];
	orig_font = [regex stringByReplacingMatchesInString:orig_font options:0 range:NSMakeRange(0, [orig_font length]) withTemplate:@""];
	orig_font = [orig_font stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	HBLogDebug(@"orig_font %@", orig_font);

	if([list containsObject:[NSString stringWithFormat:@"%@-Bold", orig_font]]) return [NSString stringWithFormat:@"%@-Bold", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@-B", orig_font]]) return [NSString stringWithFormat:@"%@-B", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@Bold", orig_font]]) return [NSString stringWithFormat:@"%@Bold", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@B", orig_font]]) return [NSString stringWithFormat:@"%@B", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@ Bold", orig_font]]) return [NSString stringWithFormat:@"%@ Bold", orig_font];
	if([list containsObject:[NSString stringWithFormat:@"%@ B", orig_font]]) return [NSString stringWithFormat:@"%@ B", orig_font];
	return name;
}

%ctor {
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.afontprefs.plist"];

	NSFileManager *localFileManager=[[NSFileManager alloc] init];
	NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:@"/Library/A-Font/"];

	NSString *file;
	while ((file = [dirEnum nextObject])) {
		[UIFont familyNames];
    CFErrorRef error;
    NSString *fullPath = [NSString stringWithFormat:@"/Library/A-Font/%@", file];
    CTFontManagerUnregisterFontsForURL((CFURLRef)[NSURL fileURLWithPath:fullPath], kCTFontManagerScopeNone, nil);
    if(!CTFontManagerRegisterFontsForURL((CFURLRef)[NSURL fileURLWithPath:fullPath], kCTFontManagerScopeNone, &error)) {
      CFStringRef errorDescription = CFErrorCopyDescription(error);
      HBLogError(@"Failed to load font: %@", errorDescription);
      CFRelease(errorDescription);
    }
	}

	NSArray *fontlist = [UIFont familyNames];
  fontname = plistDict[@"font"];
	if(!plistDict[@"boldfont"] || [plistDict[@"boldfont"] isEqualToString:@"Automatic"]) boldfontname = findBoldFont(fontlist, fontname);
	else boldfontname = plistDict[@"boldfont"];
	if(![fontlist containsObject:fontname]) enableSafari = false;
  else enableSafari = [plistDict[@"enableSafari"] boolValue];
  NSArray *fonts = [UIFont fontNamesForFamilyName:fontname];
	NSString *identifier = [NSBundle mainBundle].bundleIdentifier;
  if([plistDict[@"isEnabled"] boolValue] && fontname != nil && [fonts count] != 0 && ([plistDict[@"blacklist"][identifier] isEqual:@1] ? false : true) && ![identifier isEqualToString:@"com.apple.SafariViewService"]) {
    %init;
  }
}
