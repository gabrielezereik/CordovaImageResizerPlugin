//  Created by Gabriele Zereik on 10/09/15.
//
//



#import "Resize.h"
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}


@interface Resize ()
@property (nonatomic) int maxDim;
@end

@implementation Resize

- (void) resize:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        
        //get UIImage
        NSMutableDictionary * options = [command argumentAtIndex:0];
        _maxDim = [[options objectForKey:@"maxDim"] integerValue];
        NSArray *pathArray = [[options objectForKey:@"uri"] componentsSeparatedByString: @"/"];

        NSString *imgName = [pathArray objectAtIndex: [pathArray count] - 1];
        NSString *imgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:imgName];
        UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
        //get new Size
        CGSize newSize = [self getNewSize:img.size];
        //if the Size did not change, return the path of the original image...
        if(CGSizeEqualToSize(img.size, newSize)){
            [self jsReturnPath:imgPath];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;

        }
        //... else resize image...
        UIImage *scaledImage = [self resizeImage:img toSize: newSize];

        //...save it...
        NSString * newPath = [self saveImage:scaledImage withName:[NSString stringWithFormat:@"resized_%@", imgName]];
        //and return the new image path.
        [self jsReturnPath:newPath];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];

}

-(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize) size {
    
    CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    CGContextRef bitmap;
    
    if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, size.width, size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, size.height, size.width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
        
    }
    
    if (image.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -size.height);
        
    }
    else if (image.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -size.width, 0);
    }
    else if (image.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, size.width,size.height);
        CGContextRotateCTM (bitmap, radians(-180.));
        
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, size.width, size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;	
}


- (CGSize)getNewSize:(CGSize)oldSize {
    CGFloat oldWidth = oldSize.width;
    CGFloat oldHeight = oldSize.height;
    CGFloat newWidth, newHeight;
    if(oldWidth>=oldHeight){
        if(oldWidth<= _maxDim) return oldSize;
        newWidth = _maxDim;
        newHeight = (newWidth * oldHeight)/oldWidth;
    }
    else{
        if(oldHeight<= _maxDim) return oldSize;
        newHeight = _maxDim;
        newWidth = (newHeight * oldWidth)/oldHeight;
    }
    return CGSizeMake(newWidth, newHeight);
}
- (NSString *)saveImage:(UIImage *)image withName:(NSString *)name {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    return fullPath;
}



- (void)jsReturnPath:(NSString *) path {
    NSString *jsCallback = [NSString stringWithFormat:@"window.plugins.Resize.getNewImagePath(\"%@\");", path];
    [self.commandDelegate evalJs:jsCallback];
}

@end
