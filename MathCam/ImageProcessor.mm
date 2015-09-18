//
//  ImageProcessor.m
//  MathCam
//
//  Created by Achintya Gopal on 4/11/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "ImageProcessor.h"
#import "RecognizeCharacters.h"
#include "opencv2/opencv.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/core/types.hpp"

@implementation ImageProcessor

-(instancetype)initWithImage: (UIImage *)croppedImage{
    self = [super init];
    if(self){
        self.cropped = croppedImage;
    }
    return self;
}

-(NSString *)makeImageBlackAndWhite{
    UIImage *croppedImage = self.cropped;
    UIImage *scaledImage =
    [UIImage imageWithCGImage:[croppedImage CGImage]
                        scale:(croppedImage.scale * 0.3)
                  orientation:(croppedImage.imageOrientation)];
    
    cv::Mat frame = [self cvMatFromUIImage:scaledImage];
    cv::Mat image;
    cv::GaussianBlur(frame, image, cv::Size(0, 0), 3);
    cv::addWeighted(frame, 1.5, image, -0.5, 0, image);
    croppedImage = [self UIImageFromCVMat:image];
    
    cv::Mat A = [self cvMatGrayFromUIImage:croppedImage];
    
    int channels = A.channels();
    int nRows = A.rows;
    int nCols = A.cols * channels;
    
    if(A.isContinuous()){
        nCols *= nRows;
        nRows = 1;
    }
    
    //find average and standard deviation of image
    
    long count = 0;
    long total = 0;
    uchar *p = A.ptr<uchar>(0);
    for(int j = 0; j <nCols- 1; j++){
        count += abs(p[j] - p[j+1]);
        total++;
        if(j + A.rows <nCols){
            count += abs(p[j] - p[j + A.cols]);
            total++;
        }
    }
    long average = count/total;
    
    long stdev = 0;
    for(int j = 0; j <nCols- 1; j++){
        stdev += (p[j] - average)^2;
    }
    stdev = stdev/total;
    stdev = sqrt(stdev);
    long threshold = average + stdev;
    //NSLog(@"%lu %lu", average,stdev);
    
    for(int j = 0; j<A.cols; j++){
        p[j] = 0;
    }
    cv::Mat B = [self cvMatGrayFromUIImage:croppedImage];
    uchar *r = B.ptr<uchar>(0);
    
    int black = 0;
    int blackCount = 0;
    NSMutableDictionary *blackValues = [[NSMutableDictionary alloc]init];
    
    for(int k = A.cols ; k<nCols - A.cols;k++){
        int diffL = p[k-1] - p[k];
        int diffU = p[k-A.cols] - p[k];
        int diffR = p[k+1] - p[k];
        int diffD = p[k+A.cols] - p[k];
        int diffUR = p[k - A.cols + 1] - p[k];
        int diffUL = p[k - A.cols - 1] - p[k];
        int diffDL = p[k + A.cols - 1] - p[k];
        int diffDR = p[k + A.cols + 1] - p[k];
        if(((diffL)>= threshold) || ((diffU) >= threshold) || ((diffR) >= threshold)|| ((diffD) >= threshold || (diffUR)>= threshold || (diffUL) >= threshold || (diffDR) >= threshold || (diffDL)>=threshold)){
             r[k] = 0;
             black += p[k];
             blackCount++;
             NSString *key = [NSString stringWithFormat:@"%d",k];
             [blackValues setObject:[NSNumber numberWithInteger:k] forKey:key];
         }
         else{
            r[k] = 255;
         }
    }
    
    A = B.clone();
    
    fastNlMeansDenoising(A, A,3,7,21);
    UIImage *editImage = [self UIImageFromCVMat:A];
    
    RecognizeCharacters *recognizor = [[RecognizeCharacters alloc]initWithImage:editImage withOriginalImage:croppedImage withArray:blackValues withSize:A.cols];
    NSString *interpreted = [recognizor interpretBlackAndWhiteImage];
    return interpreted;
}

//convert image to Mat
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

//convert image to gray scale Mat
-(cv::Mat)cvMatGrayFromUIImage:(UIImage *)convertImage{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(convertImage.CGImage);
    CGFloat cols = convertImage.size.width;
    CGFloat rows = convertImage.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), convertImage.CGImage);
    CGContextRelease(contextRef);
    cv::Mat im_gray;
    cvtColor(cvMat,im_gray,3);
    cvtColor(cvMat,im_gray,6);
    
    return im_gray;
}

//convert Mat back to image
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
