//
//  UIImageColorPalette.m
//  UIImageColorPalette
//
//  Created by Artem Kasper on 05.10.2023.
//  Copyright © 2023 Artem Kasper. All rights reserved.
//

#import "UIImageColorPalette.h"

@implementation UIImageColorPalette

- (instancetype)initWithPrimary:(UIColor *)primary secondary:(UIColor *)secondary tertiary:(UIColor *)tertiary {
    self = [super init];
    if (self) {
        _primary = primary;
        _secondary = secondary;
        _tertiary = tertiary;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"Primary: %@", self.primary];
    
    if (self.secondary) {
        [description appendFormat:@", Secondary: %@", self.secondary];
    }
    
    if (self.tertiary) {
        [description appendFormat:@", Tertiary: %@", self.tertiary];
    }
    
    return description;
}

@end

@implementation UIImage (ColorPalette)

- (UIImage *)resizeImageWithDesiredSize:(CGSize)desiredSize quality:(UIImageResizeQuality)quality {
    if (CGSizeEqualToSize(desiredSize, self.size)) {
        return self;
    }
    
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat new];
    format.scale = self.scale;
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:desiredSize format:format];
    
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [self drawInRect:CGRectMake(0, 0, desiredSize.width, desiredSize.height)];
    }];
}

- (void)retrieveColorPaletteWithQuality:(UIImageResizeQuality)quality completion:(void (^)(UIImageColorPalette *palette))completion {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        UIImageColorPalette *palette = [self retrieveColorPaletteWithQuality:quality];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(palette);
        });
    });
}

- (UIImageColorPalette *)retrieveColorPaletteWithQuality:(UIImageResizeQuality)quality {
    CGSize desiredSize = self.size;
    if (quality != UIImageResizeQualityStandard) {
        CGFloat resizeQuality = 1.0;
        
        switch (quality) {
            case UIImageResizeQualityLow:
                resizeQuality = 0.3;
                break;
            case UIImageResizeQualityMedium:
                resizeQuality = 0.5;
                break;
            case UIImageResizeQualityHigh:
                resizeQuality = 0.8;
                break;
            default:
                break;
        }
        
        desiredSize = CGSizeMake(self.size.width * resizeQuality, self.size.height * resizeQuality);
    }
    
    UIImage *imageToProcess = [self resizeImageWithDesiredSize:desiredSize quality:quality];
    if (!imageToProcess) {
        return nil;
    }
    
    CGImageRef cgImage = imageToProcess.CGImage;
    if (!cgImage) {
        return nil;
    }
    
    CFDataRef imageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    if (!imageDataRef) {
        return nil;
    }
    
    const UInt8 *imageData = CFDataGetBytePtr(imageDataRef);
    
    NSInteger width = CGImageGetWidth(cgImage);
    NSInteger height = CGImageGetHeight(cgImage);
    
    NSMutableArray<Pixel *> *pixels = [NSMutableArray arrayWithCapacity:width * height];
    
    for (NSInteger x = 0; x < width; x++) {
        for (NSInteger y = 0; y < height; y++) {
            NSInteger pixelIndex = ((width * y) + x) * 4;
            Pixel *pixel = [[Pixel alloc] initWithR:imageData[pixelIndex] g:imageData[pixelIndex + 1] b:imageData[pixelIndex + 2] a:imageData[pixelIndex + 3]];
            [pixels addObject:pixel];
        }
    }
    
    PixelClusterer *analyzer = [[PixelClusterer alloc] initWithClusterNumber:3 tolerance:0.01 dataPoints:pixels];
    NSArray<Pixel *> *prominentPixels = [analyzer calculateProminentClusters];
    
    UIColor *primaryColor = [UIColor colorWithPixel:prominentPixels[0]];
    UIColor *secondaryColor = [UIColor colorWithPixel:prominentPixels[1]];
    UIColor *tertiaryColor = [UIColor colorWithPixel:prominentPixels[2]];
    
    return [[UIImageColorPalette alloc] initWithPrimary:primaryColor secondary:secondaryColor tertiary:tertiaryColor];
}

@end

@implementation Pixel

- (instancetype)initWithR:(double)r g:(double)g b:(double)b a:(double)a {
    self = [super init];
    if (self) {
        _r = r;
        _g = g;
        _b = b;
        _a = a;
    }
    return self;
}

- (double)distanceTo:(Pixel *)other {
    double rDistance = pow(self.r - other.r, 2);
    double gDistance = pow(self.g - other.g, 2);
    double bDistance = pow(self.b - other.b, 2);
    double aDistance = pow(self.a - other.a, 2);
    
    return sqrt(rDistance + gDistance + bDistance + aDistance);
}

- (void)append:(Pixel *)pixel {
    self.r += pixel.r;
    self.g += pixel.g;
    self.b += pixel.b;
    self.a += pixel.a;
}

- (void)averageOutWithCount:(NSInteger)count {
    self.count = count;
    self.r /= count;
    self.g /= count;
    self.b /= count;
    self.a /= count;
}

@end

@implementation UIColor (Pixel)

+ (UIColor *)colorWithPixel:(Pixel *)pixel {
    if (isnan(pixel.r)) {
        return nil;
    }
    
    return [UIColor colorWithRed:pixel.r/255.0 green:pixel.g/255.0 blue:pixel.b/255.0 alpha:pixel.a/255.0];
}

@end

@implementation PixelClusterer

- (instancetype)initWithClusterNumber:(NSInteger)clusterNumber tolerance:(double)tolerance dataPoints:(NSArray<Pixel *> *)dataPoints {
    self = [super init];
    if (self) {
        _clusterNumber = clusterNumber;
        _tolerance = tolerance;
        _dataPoints = dataPoints;
    }
    return self;
}

- (NSArray<Pixel *> *)calculateProminentClusters {
    NSArray<Pixel *> *pixels = [self PixelClustererWithPartitions:self.clusterNumber tolerance:self.tolerance entries:self.dataPoints];
    
    return [pixels sortedArrayUsingComparator:^NSComparisonResult(Pixel *pixel1, Pixel *pixel2) {
        return pixel1.count < pixel2.count ? NSOrderedAscending : (pixel1.count == pixel2.count ? NSOrderedSame : NSOrderedDescending);
    }];
}

- (NSArray<Pixel *> *)PixelClustererWithPartitions:(NSInteger)partitions tolerance:(double)tolerance entries:(NSArray<Pixel *> *)entries {
    NSMutableArray<Pixel *> *centroids = [self generateInitialCentersWithSamples:entries k:partitions];
    
    double centerMoveDist = 0.0;
    do {
        NSMutableArray<Pixel *> *centerCandidates = [NSMutableArray arrayWithCapacity:partitions];
        NSMutableArray<NSNumber *> *totals = [NSMutableArray arrayWithCapacity:partitions];
        
        for (int i = 0; i < partitions; i++) {
            [centerCandidates addObject:[[Pixel alloc] initWithR:0 g:0 b:0 a:0]];
            [totals addObject:@(0)];
        }
        
        for (Pixel *pixel in entries) {
            NSInteger index = [self indexOfNearestCentroid:pixel centroids:centroids];
            [centerCandidates[index] append:pixel];
            totals[index] = @(totals[index].integerValue + 1);
        }
        
        for (int i = 0; i < partitions; i++) {
            [centerCandidates[i] averageOutWithCount:totals[i].integerValue];
        }
        
        centerMoveDist = 0.0;
        for (int i = 0; i < partitions; i++) {
            centerMoveDist += [centroids[i] distanceTo:centerCandidates[i]];
        }
        
        centroids = centerCandidates;
    } while (centerMoveDist > tolerance);
    
    return centroids;
}

- (NSMutableArray<Pixel *> *)generateInitialCentersWithSamples:(NSArray<Pixel *> *)samples k:(NSInteger)k {
    NSMutableArray<Pixel *> *centers = [NSMutableArray arrayWithCapacity:k];
    NSInteger random = arc4random_uniform((uint32_t)samples.count);
    [centers addObject:samples[random]];
    
    for (int i = 1; i < k; i++) {
        Pixel *centerCandidate = [[Pixel alloc] initWithR:0 g:0 b:0 a:0];
        double furthestDistance = DBL_MIN;
        
        for (Pixel *pixel in samples) {
            double distance = DBL_MAX;
            
            for (Pixel *center in centers) {
                distance = MIN([center distanceTo:pixel], distance);
            }
            
            if (distance <= furthestDistance) {
                continue;
            }
            
            furthestDistance = distance;
            centerCandidate = pixel;
        }
        
        [centers addObject:centerCandidate];
    }
    
    return centers;
}

- (NSInteger)indexOfNearestCentroid:(Pixel *)pixel centroids:(NSArray<Pixel *> *)centroids {
    double smallestDistance = DBL_MAX;
    NSInteger index = 0;
    
    for (int i = 0; i < centroids.count; i++) {
        double distance = [pixel distanceTo:centroids[i]];
        if (distance >= smallestDistance) {
            continue;
        }
        
        smallestDistance = distance;
        index = i;
    }
    
    return index;
}

@end