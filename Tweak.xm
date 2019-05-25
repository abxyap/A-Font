#include <UIKit/UIKit.h>

NSString *fontname;

typedef NSString *UIFontTextStyle;

@interface UIFont (Private)
+ (id)fontWithName:(id)arg1 size:(double)arg2 traits:(int)arg3;
@end

%hook UIFont
+ (id)fontWithName:(id)arg1 size:(double)arg2 {
  return %orig(fontname, arg2);
}
+ (id)fontWithName:(id)arg1 size:(double)arg2 traits:(int)arg3 {
  return %orig(fontname, arg2, arg3);
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
  return [self fontWithName:fontname size:arg3 traits:arg2];
}
+ (id)monospacedDigitSystemFontOfSize:(double)arg1 weight:(double)arg2 {
  return [self fontWithName:fontname size:arg1];
}
%end

%hook UIKBRenderFactoryiPhoneChoco
- (id)thinKeycapsFontName {
  return fontname;
}
- (id)lightKeycapsFontName {
  return fontname;
}
%end

%ctor {
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.afontprefs.plist"];
  fontname = plistDict[@"font"];
  NSArray *fonts = [UIFont familyNames];
  if([plistDict[@"isEnabled"] boolValue] && fontname != nil && [fonts containsObject:fontname]) {
    HBLogDebug(@"A-Font is will hooking UIFont.");
    %init;
  }
}
