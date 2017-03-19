//
//  FileClient.h
//  Wil_User
//
//  Created by xianyang on 19/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileClient : NSObject

- (void)uploadFile:(AVFile *)file success:(void (^)(NSString *fileURL))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)getPhotoWithURL:(NSString *)imageURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock;

- (void)getAppUserProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock;

- (void)getClientProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)getValetProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock;

@end
