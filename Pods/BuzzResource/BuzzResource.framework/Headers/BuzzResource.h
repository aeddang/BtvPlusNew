#import <UIKit/UIKit.h>
#import <BuzzResource/NSAttributedString+BuzzResource.h>
#import <BuzzResource/UIColor+BuzzResource.h>
#import <BuzzResource/UIView+BuzzResource.h>

@interface BuzzResource : NSObject

+ (NSString *)localizedString:(NSString *)key;

+ (UIImage *)imageWithName:(NSString *)name;

@end

@interface BuzzResource (Dimension)

+ (CGFloat)buzzvil_bottom_sheet_corner_radius;

@end
