//
//  UIImage+MKAdd.h
//  FitPolo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MKAdd)

#pragma mark - 图片处理
/**
 *  返回一张拉伸不变形的图片
 *
 *  @param name 图片名称
 */
+ (UIImage *)resizableImage:(NSString *)name;

/**
 *  在一个View上截图
 *
 *  @param view 目标View
 *  @param rect 需要截取的范围
 */
+ (UIImage *)imageByScreenshotsWithView:(UIView *)view andRect:(CGRect)rect;

/**
 *  保持原来的长宽比，生成一个缩略图
 *  @param asize 需要的长、宽
 *
 */
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

/** 2016年08月01日 add by 
 *  图片上传到服务器之前的处理：
 *  1、保证图片不旋转90度；
 *  2、根据图片的大小比例进行压缩；
 *  3、通过UIImageJPEGRepresentation压缩一半
 *
 *  @param bigImage 要处理的大图片
 *
 *  @return 处理后的小图片
 */
+ (UIImage *) handleImageBeforeUploadWithImage:(UIImage *) bigImage;

/** 2016年12月23日 by ：针对登记证1-2，3-4做特殊处理
 根据传入的大图片，和指定的压缩宽度，压缩图片
 
 @param bigImage 大图片
 @param resizeWidth 指定的压缩宽度
 @return 处理后的小图片
 */
+ (UIImage *) handleImageBeforeUploadWithImage:(UIImage *) bigImage resizeWidth:(CGFloat) resizeWidth;

#pragma mark - 图片压缩

+ (UIImage *)thumbnailWithImage:(UIImage *)image;

#pragma mark - 创建纯色的image

+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 获取启动页图片

 @return 启动页图片
 */
+ (UIImage *)launchImage;

/**
 将图片存入本地指定文件夹,该图片位于library路径下
 
 @param filePath 文件夹名称
 @param imageName 图片保存的名称
 @return YES:保存成功，保存失败
 */
- (BOOL)saveToLocal:(NSString *)filePath
          imageName:(NSString *)imageName;

- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

- (UIImage *)fixOrientationforJZG;

- (UIImage *)rotatedByDegrees:(CGFloat)degrees;

@end
