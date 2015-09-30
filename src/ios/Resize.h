
//  Created by Gabriele Zereik on 28/09/15.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface Resize: CDVPlugin

- (void) resize:(CDVInvokedUrlCommand *)command;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (CGSize)getNewSize:(CGSize)oldSize;
- (void)jsPrintSize:(NSString *) size;
- (void)jsReturnPath:(NSString *) path;
-(UIImage *)scaleImage:(UIImage *) image toScaleFactor:(CGFloat)factor;
- (NSString *)saveImage:(UIImage *)image withName:(NSString *)name;
-(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize) size;
@end
