## UIImageColorPalette

`UIImageColorPalette` is a versatile utility for extracting the prominent colors from images in iOS. It efficiently identifies and provides the three most prevalent colors in a `UIImage`.

### Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Examples](#examples)
  - [Example 1: Using a local image file](#example-1-using-a-local-image-file)
  - [Example 2: Using a remote image URL](#example-2-using-a-remote-image-url)
  - [Example 3: Asynchronous retrieval](#example-3-asynchronous-retrieval)
  - [Example 4: Customizing the resize quality](#example-4-customizing-the-resize-quality)
- [License](#license)

### Installation

To install `UIImageColorPalette`, follow these steps:

1. **Download**: Download the `UIImageColorPalette.h` and `UIImageColorPalette.m` files.

2. **Add to project**: Integrate the downloaded files into your project.

3. **Import the Class**: Import the class wherever you want to use it:

```objective-c
#import "UIImageColorPalette.h"
```

### Quick Start

Here are quick examples of how to use `UIImageColorPalette` to extract the color palette from an image:

### Example 1: Using a local image file

```objective-c
// Load an image
NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"imageName" ofType:@"jpg"];
UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

// Retrieve the color palette
UIImageColorPalette *palette = [image retrieveColorPaletteWithQuality:UIImageResizeQualityStandard];
if (palette) {
    NSLog(@"Color Palette: %@", palette);
} else {
    NSLog(@"Failed to retrieve color palette.");
}

// Set the background color of view
UIColor *backgroundColor = palette.primary;
self.view.backgroundColor = backgroundColor;

// Set the text color for a label
UIColor *textColor = palette.secondary;
myLabel.textColor = textColor;
```

#### Example 2: Using a remote image URL

```objective-c
// Load an image from a remote URL
NSURL *imageURL = [NSURL URLWithString:@"https://example.com/image.jpg"];
NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
UIImage *image = [UIImage imageWithData:imageData];

// Retrieve the color palette
UIImageColorPalette *palette = [image retrieveColorPaletteWithQuality:UIImageResizeQualityStandard];
if (palette) {
    NSLog(@"Color Palette: %@", palette);
} else {
    NSLog(@"Failed to retrieve color palette.");
}
```

#### Example 3: Asynchronous retrieval

```objective-c
// Load an image from a remote URL asynchronously
NSURL *imageURL = [NSURL URLWithString:@"https://example.com/image.jpg"];
dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    [image retrieveColorPaletteWithQuality:UIImageResizeQualityStandard completion:^(UIImageColorPalette *palette) {
        if (palette) {
            NSLog(@"Color Palette: %@", palette);
        } else {
            NSLog(@"Failed to retrieve color palette.");
        }
    }];
});
```

#### Example 4: Customizing the resize quality

You can use other presets besides `UIImageResizeQualityStandard` by using the following options:

- `UIImageResizeQualityLow`: Use low-quality resizing algorithm.
- `UIImageResizeQualityMedium`: Use medium-quality resizing algorithm.
- `UIImageResizeQualityHigh`: Use high-quality resizing algorithm.

```objective-c
// Load an image
NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"imageName" ofType:@"jpg"];
UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

// Retrieve the color palette with custom resize quality
UIImageColorPalette *palette = [image retrieveColorPaletteWithQuality:UIImageResizeQualityHigh];
if (palette) {
    NSLog(@"Color Palette: %@", palette);
} else {
    NSLog(@"Failed to retrieve color palette.");
}
```

### License 

This project is licensed under the MIT License.
