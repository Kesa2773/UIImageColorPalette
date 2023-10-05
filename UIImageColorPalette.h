//
//  UIImageColorPalette.h
//  UIImageColorPalette
//
//  Created by Artem Kasper on 05.10.2023.
//  Copyright © 2023 Artem Kasper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIImageResizeQuality) {
    UIImageResizeQualityLow = 1,
    UIImageResizeQualityMedium = 2,
    UIImageResizeQualityHigh = 3,
    UIImageResizeQualityStandard = 4
};

@interface UIImageColorPalette : NSObject
@property (nonatomic, strong) UIColor *primary;
@property (nonatomic, strong) UIColor *secondary;
@property (nonatomic, strong) UIColor *tertiary;

- (instancetype)initWithPrimary:(UIColor *)primary secondary:(UIColor *)secondary tertiary:(UIColor *)tertiary;
- (NSString *)description;
@end

@interface UIImage (ColorPalette)
- (UIImage *)resizeImageWithDesiredSize:(CGSize)desiredSize quality:(UIImageResizeQuality)quality;
- (void)retrieveColorPaletteWithQuality:(UIImageResizeQuality)quality completion:(void (^)(UIImageColorPalette *palette))completion;
- (UIImageColorPalette *)retrieveColorPaletteWithQuality:(UIImageResizeQuality)quality;
@end

@interface Pixel : NSObject
@property (nonatomic, assign) double r;
@property (nonatomic, assign) double g;
@property (nonatomic, assign) double b;
@property (nonatomic, assign) double a;
@property (nonatomic, assign) NSInteger count;

- (instancetype)initWithR:(double)r g:(double)g b:(double)b a:(double)a;
- (double)distanceTo:(Pixel *)other;
- (void)append:(Pixel *)pixel;
- (void)averageOutWithCount:(NSInteger)count;
@end

@interface UIColor (Pixel)
+ (UIColor *)colorWithPixel:(Pixel *)pixel;
@end

@interface PixelClusterer : NSObject
@property (nonatomic, assign) NSInteger clusterNumber;
@property (nonatomic, assign) double tolerance;
@property (nonatomic, strong) NSArray<Pixel *> *dataPoints;

- (instancetype)initWithClusterNumber:(NSInteger)clusterNumber tolerance:(double)tolerance dataPoints:(NSArray<Pixel *> *)dataPoints;
- (NSArray<Pixel *> *)calculateProminentClusters;
@end

