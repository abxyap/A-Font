#include <UIKit/UIKit.h>

NSString *fontname;
BOOL enableSafari;

typedef NSString *UIFontTextStyle;

@interface UIFont (Private)
+ (id)fontWithName:(id)arg1 size:(double)arg2 traits:(int)arg3;
@end

UIFont *changeFont(NSString *orignalfont, double size, int traits) {
  return [UIFont fontWithName:fontname size:size traits: arg3];
}

%hook UIFont
+ (id)fontWithName:(id)arg1 size:(double)arg2 {
  return %orig(fontname, arg2);
}
+ (id)fontWithName:(id)arg1 size:(double)arg2 traits:(int)arg3 {
  return %orig(fontname, arg2, arg3);
}
+ (id)boldSystemFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
+ (id)userFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
+ (id)systemFontOfSize:(double)arg1 weight:(double)arg2 design:(id)arg3 {
  return changeFont(nil, arg1, nil);
}
+ (id)systemFontOfSize:(double)arg1 weight:(double)arg2 {
  return changeFont(nil, arg1, nil);
}
+ (id)systemFontOfSize:(double)arg1 traits:(int)arg2 {
  return changeFont(nil, arg1, arg2);
}
+ (id)systemFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
+ (id)italicSystemFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
+ (id)_systemFontsOfSize:(double)arg1 traits:(int)arg2 {
  return changeFont(nil, arg1, arg2);
}
+ (id)_thinSystemFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
+ (id)_ultraLightSystemFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
+ (id)_lightSystemFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
+ (id)_opticalBoldSystemFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
+ (id)_opticalSystemFontOfSize:(double)arg1 {
  return changeFont(nil, arg1, nil);
}
- (id)fontName {
  return fontname;
}
+ (id)preferredFontForTextStyle:(UIFontTextStyle)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:[font fontDescriptorWithFamily:fontname] size:font.pointSize];
  return ret;
}
+ (id)preferredFontForTextStyle:(UIFontTextStyle)arg1 compatibleWithTraitCollection:(id)arg2 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:[font fontDescriptorWithFamily:fontname] size:font.pointSize];
  return ret;
}
+ (id)ib_preferredFontForTextStyle:(id)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:[font fontDescriptorWithFamily:fontname] size:font.pointSize];
  return ret;
}
+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)arg1 size:(double)arg2 {
  return [self fontWithName:fontname size:arg2 != 0 ? arg2 : arg1.pointSize];
}
+ (id)defaultFontForTextStyle:(UIFontTextStyle)arg1 {
  UIFontDescriptor *font = [UIFontDescriptor preferredFontDescriptorWithTextStyle:arg1];
  UIFont *ret = [self fontWithDescriptor:[font fontDescriptorWithFamily:fontname] size:font.pointSize];
  return ret;
}
+ (id)fontWithFamilyName:(id)arg1 traits:(int)arg2 size:(double)arg3 {
  return changeFont(nil, arg1, arg2);
}
+ (id)monospacedDigitSystemFontOfSize:(double)arg1 weight:(double)arg2 {
  return changeFont(nil, arg1, nil);
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

@interface WKWebView
-(void)evaluateJavaScript:(id)arg1 completionHandler:(id)arg2 ;
@end

%hook WKWebView
-(void)_didFinishLoadForMainFrame {
  %orig;
  if(enableSafari) [self evaluateJavaScript:[NSString stringWithFormat:@"var node = document.createElement('style'); node.innerHTML = '* { font-family: \\'%@\\' !important }'; document.head.appendChild(node);", fontname] completionHandler:nil];
}
%end

%ctor {
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.afontprefs.plist"];
  fontname = plistDict[@"font"];
  enableSafari = [plistDict[@"enableSafari"] boolValue];
  NSArray *fonts = [UIFont familyNames];
  if([plistDict[@"isEnabled"] boolValue] && fontname != nil && [fonts containsObject:fontname]) {
    HBLogDebug(@"A-Font is will hooking UIFont.");
    %init;
  }
}
