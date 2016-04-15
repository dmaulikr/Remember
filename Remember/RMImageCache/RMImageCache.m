//
//  RMImageCache.m
//  Remember
//
//  Created by Keeton on 3/3/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "RMImageCache.h"

@implementation RMImageCache
{
    NSCache *cache;
}

- (id)init; {
    self = [super init];
    if (self) {
        // Custom initilization
        cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)newCacheForImage:(UIImage *)image withKey:(NSString *)key andSize:(CGSize)size; {
    /**
     Resizes an image (downsize) and stores the image in cache.
     */
    [cache setObject:[self imageWithImage:image scaledToSize:size] forKey:key];
}

- (void)removeCacheForImageWithKey:(NSString *)key; {
    /**
     Removes an object from the cache using a key.
     */
    [cache removeObjectForKey:key];
}

- (void)purgeRemovedObjects:(bool)statement; {
    /**
     Removes all deleted items from the cache.
     */
    [cache setEvictsObjectsWithDiscardedContent:statement];
}

- (void)cleanCache; {
    /**
     Clears all cached items from cache. (i.e This deletes *everything*)
     */
    [cache removeAllObjects];
}

- (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize; {
    /**
     Downsizes a UIImage and returns the downsized image
     */
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)loadImageFromCacheWithKey:(NSString *)key; {
    /**
     Returns a UIImage after loading it from cache using a key.
     */
    UIImage *image = [cache objectForKey:key];
    if (!image) {
        NSLog(@"Error: No cached image for key %@",key);
        return nil;
    } else {
        return image;
    }
}

@end
