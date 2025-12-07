#import "ColorUtils.h"

@implementation ColorUtils

+ (id)colorFromHex:(id)hexString useAlpha:(BOOL)useAlpha {
    if (!hexString || ![hexString isKindOfClass:[NSString class]]) {
        return [UIColor clearColor];
    }
    
    NSString *hex = [(NSString *)hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 移除 # 前缀
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringFromIndex:1];
    }
    
    // 支持 RGB 和 RGBA
    unsigned int hexValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    if (![scanner scanHexInt:&hexValue]) {
        return [UIColor clearColor];
    }
    
    CGFloat red, green, blue, alpha;
    
    if (hex.length == 6) {
        // RGB
        red = ((hexValue & 0xFF0000) >> 16) / 255.0;
        green = ((hexValue & 0x00FF00) >> 8) / 255.0;
        blue = (hexValue & 0x0000FF) / 255.0;
        alpha = useAlpha ? 1.0 : 1.0;
    } else if (hex.length == 8) {
        // RGBA
        red = ((hexValue & 0xFF000000) >> 24) / 255.0;
        green = ((hexValue & 0x00FF0000) >> 16) / 255.0;
        blue = ((hexValue & 0x0000FF00) >> 8) / 255.0;
        alpha = (hexValue & 0x000000FF) / 255.0;
    } else {
        return [UIColor clearColor];
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

