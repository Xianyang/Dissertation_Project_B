//
//  FileClient.m
//  Wil_User
//
//  Created by xianyang on 19/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "FileClient.h"

@implementation FileClient

- (void)uploadFile:(AVFile *)file success:(void (^)(NSString *fileURL))successBlock fail:(void (^)(NSError *error))failBlock {
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            successBlock(file.url);
        } else {
            failBlock(error);
        }
    }];
}

- (void)getPhotoWithURL:(NSString *)imageURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock {
    AVFile *file = [AVFile fileWithURL:imageURL];
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (data && !error) {
            UIImage *image = [UIImage imageWithData:data];
            successBlock(image);
        } else {
            failBlock(error);
        }
    }];
}

- (void)getAppUserProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock {
    AVFile *file = [AVFile fileWithURL:fileURL];
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (data && !error) {
            UIImage *image = [UIImage imageWithData:data];
            successBlock(image);
        } else {
            failBlock(error);
        }
    }];
}

- (void)getClientProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock {
    AVFile *file = [AVFile fileWithURL:fileURL];
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (data && !error) {
            UIImage *image = [UIImage imageWithData:data];
            successBlock(image);
        } else {
            failBlock(error);
        }
    }];
}

- (void)getValetProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock {
    // ???
}

@end
