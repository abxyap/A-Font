#include <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

static NSString *fontname;
static NSString *boldfontname;
static BOOL enableSafari;
static BOOL WebKitImportant;
static BOOL isSpringBoard;
static NSNumber *size;
static NSMutableDictionary *fontMatchDict;

typedef NSString *UIFontTextStyle;

@interface UIFont (Private)
+ (id)fontWithName:(id)arg1 size:(double)arg2 traits:(int)arg3;
- (id)initWithName:(id)arg1 size:(double)arg2;
+(UIFont*)fontWithMarkupDescription:(NSString*)markupDescription;
- (id)markupDescription;
@end

double getSize(double orig_size) {
	return ceil(orig_size*[size doubleValue]);
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
  ) return true;
  else return false;
}

@interface UIFont (AFontPrivate)
+ (id)fontWithNameWithoutAFont:(NSString *)arg1 size:(double)arg2;
@end

%group Font
%hook UIFont
+ (id)fontWithName:(NSString *)arg1 size:(double)arg2 {
	if([arg1 containsString:@"disableAFont"]) return %orig([arg1 stringByReplacingOccurrencesOfString:@"disableAFont" withString:@""], arg2);
  if(checkFont(arg1)) return %orig;
	if([arg1 isEqualToString:boldfontname]) return %orig(boldfontname, getSize(arg2));
  else return %orig(fontname, getSize(arg2));
}
%new
+ (id)fontWithNameWithoutAFont:(NSString *)arg1 size:(double)arg2 {
	if([arg1 containsString:@"disableAFont"]) return [self fontWithName:arg1 size:arg2];
	else return [self fontWithName:[NSString stringWithFormat:@"%@disableAFont", arg1] size:arg2];
}
+ (id)fontWithName:(NSString *)arg1 size:(double)arg2 traits:(int)arg3 {
  if(checkFont(arg1)) return %orig;
	if([arg1 isEqualToString:boldfontname]) return %orig(boldfontname, getSize(arg2), arg3);
  else return %orig(fontname, getSize(arg2), arg3);
}
+ (id)fontWithFamilyName:(NSString *)arg1 traits:(int)arg2 size:(double)arg3 {
  return [self fontWithName:fontname size:arg3 traits:arg2];
}
+ (id)userFontOfSize:(double)arg1 {
  return [self fontWithName:fontname size:arg1];
}
+ (id)systemFontOfSize:(double)arg1 weight:(double)arg2 design:(id)arg3 {
	if(isSpringBoard && ![size isEqual:@1]) return %orig;
	return [self fontWithNameWithoutAFont:(arg2 >= 0.2 && boldfontname != nil ? boldfontname : fontname) size:arg1];
}
+ (id)systemFontOfSize:(double)arg1 weight:(double)arg2 {
	if(isSpringBoard && ![size isEqual:@1]) return %orig;
	return [self fontWithNameWithoutAFont:(arg2 >= 0.2 && boldfontname != nil ? boldfontname : fontname) size:arg1];
}
+ (UIFont *)systemFontOfSize:(double)arg1 traits:(int)arg2 {
	if(isSpringBoard && ![size isEqual:@1]) return %orig;
	return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (UIFont *)systemFontOfSize:(double)arg1 {
	if(isSpringBoard && ![size isEqual:@1]) return %orig;
	return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (id)boldSystemFontOfSize:(double)arg1 {
  return [self fontWithNameWithoutAFont:boldfontname != nil ? boldfontname : fontname size:arg1];
}
+ (id)monospacedDigitSystemFontOfSize:(double)arg1 weight:(double)arg2 {
  return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (id)italicSystemFontOfSize:(double)arg1 {
  return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (id)_systemFontsOfSize:(double)arg1 traits:(int)arg2 {
  return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (id)_thinSystemFontOfSize:(double)arg1 {
  return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (id)_ultraLightSystemFontOfSize:(double)arg1 {
  return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (id)_lightSystemFontOfSize:(double)arg1 {
  return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (id)_opticalBoldSystemFontOfSize:(double)arg1 {
  return [self fontWithNameWithoutAFont:fontname size:arg1];
}
+ (id)_opticalSystemFontOfSize:(double)arg1 {
  return [self fontWithNameWithoutAFont:fontname size:arg1];
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
  if(checkFont(arg1.fontAttributes[@"NSFontNameAttribute"])) return %orig;
	UIFontDescriptor *d = [UIFontDescriptor fontDescriptorWithName:fontname size:arg2 != 0 ? arg2 : arg1.pointSize];
	if(arg1.symbolicTraits & UIFontDescriptorTraitBold && boldfontname) d = [UIFontDescriptor fontDescriptorWithName:boldfontname size:getSize(arg2 != 0 ? arg2 : arg1.pointSize)];
	return %orig(d, 0);
}
+(id)fontWithMarkupDescription:(NSString*)markupDescription {
	UIFont *ret = %orig;
	return [self fontWithName:fontname size:ret.pointSize];
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
%end

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, assign) long long fontStyle;
@property (nonatomic, assign) NSString *originalText;
@end

%group iOS12
%hook _UIStatusBarStringView
-(void)font {
	if([self.originalText isEqualToString:@"LTE"]) {
		self.font = [UIFont fontWithNameWithoutAFont:@".SFUIText-Medium" size:12];
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

%group WebKit
@interface WKWebView
-(void)evaluateJavaScript:(id)arg1 completionHandler:(id)arg2 ;
@end

%hook WKWebView
-(void)_didFinishLoadForMainFrame {
  %orig;
  if(enableSafari) {
		NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
		if(([identifier isEqualToString:@"com.apple.mobilesafari"] || [identifier isEqualToString:@"com.apple.SafariViewService"]) && fontMatchDict[fontname]) {
	    NSData *fontFile = [NSData dataWithContentsOfFile:fontMatchDict[fontname]];
			[self evaluateJavaScript:[NSString stringWithFormat:@"var fontFace = document.createElement('style'); fontFace.innerHTML = '@font-face { font-family: \"A-Font Internal Font Loader\"; src:url(data:font/opentype;base64,%@); } * { font-family: \"A-Font Internal Font Loader\"%@ }'; document.head.appendChild(fontFace);", [fontFile base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed], (WebKitImportant ? @" !important" : @"")] completionHandler:nil];
		}
		else [self evaluateJavaScript:[NSString stringWithFormat:@"var node = document.createElement('style'); node.innerHTML = '* { font-family: \\'%@\\'%@ }'; document.head.appendChild(node);", fontname, (WebKitImportant ? @" !important" : @"")] completionHandler:nil];
	}
}
%end
%end

NSString *findBoldFont(NSArray *list, NSString *name) {
	NSString *orig_font = [name stringByReplacingOccurrencesOfString:@" R" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@"" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@" Regular" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@"Regular" withString:@""];
	orig_font = [name stringByReplacingOccurrencesOfString:@"-Regular" withString:@""];
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
	NSString *identifier = [NSBundle mainBundle].bundleIdentifier;
	NSMutableDictionary *fontMatchTempDict = [NSMutableDictionary new];

	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *subpaths = [manager contentsOfDirectoryAtPath:@"/Library/A-Font/" error:NULL];
	[UIFont familyNames];
	for(NSString *key in subpaths) {
		NSString *fullPath = [NSString stringWithFormat:@"/Library/A-Font/%@", key];
		CFErrorRef error;
		CTFontManagerUnregisterFontsForURL((CFURLRef)[NSURL fileURLWithPath:fullPath], kCTFontManagerScopeNone, nil);
		if(!CTFontManagerRegisterFontsForURL((CFURLRef)[NSURL fileURLWithPath:fullPath], kCTFontManagerScopeNone, &error)) {
			CFStringRef errorDescription = CFErrorCopyDescription(error);
			NSLog(@"[AFont] Failed to load font: %@", errorDescription);
			CFRelease(errorDescription);
		}

		if([identifier isEqualToString:@"com.apple.mobilesafari"] || [identifier isEqualToString:@"com.apple.SafariViewService"]) {
			NSData *data = [NSData dataWithContentsOfFile:fullPath];
			CGDataProviderRef fontDataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
			CGFontRef cg_font = CGFontCreateWithDataProvider(fontDataProvider);
    	CTFontRef ct_font = CTFontCreateWithGraphicsFont(cg_font, 36., NULL, NULL);
			NSString *familyName = (NSString *)CTFontCopyFamilyName(ct_font);
			fontMatchTempDict[familyName] = fullPath;
		}
	}
	fontMatchDict = [fontMatchTempDict copy];

	NSArray *fullFontList = getFullFontList();
  fontname = plistDict[@"font"];
	if(fontname != nil) {
		if(!plistDict[@"boldfont"] || [plistDict[@"boldfont"] isEqualToString:@"Automatic"]) boldfontname = findBoldFont(fullFontList, fontname);
		else boldfontname = plistDict[@"boldfont"];
	} else boldfontname = nil;
	size = plistDict[@"size"] ? plistDict[@"size"] : @1;

	fontname = [fontname copy];
	boldfontname = [boldfontname copy];
	size = [size copy];

  enableSafari = [plistDict[@"enableSafari"] boolValue];
  WebKitImportant = [plistDict[@"WebKitImportant"] boolValue];
  NSArray *fonts = [UIFont fontNamesForFamilyName:fontname];
  if([plistDict[@"isEnabled"] boolValue] && fontname != nil && [fonts count] != 0 && ([plistDict[@"blacklist"][identifier] isEqual:@1] ? false : true)) {
		isSpringBoard = [identifier isEqualToString:@"com.apple.springboard"];
		if([identifier isEqualToString:@"com.apple.photos.VideoConversionService"] || [identifier isEqualToString:@"com.apple.photos.VideoConversionService"] || [identifier isEqualToString:@"com.apple.springboard.SBRendererService"]) return;
    %init(Font);
    %init(WebKit);
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		if(isSpringBoard && version >= 12 && version < 13) %init(iOS12);
  }
}
