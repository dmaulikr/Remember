//
//  IndexRequestHandler.m
//  Spotlight
//
//  Created by Keeton on 1/5/16.
//  Copyright © 2016 Solar Pepper Studios. All rights reserved.
//

#import "IndexRequestHandler.h"

@implementation IndexRequestHandler

- (void)searchableIndex:(CSSearchableIndex *)searchableIndex reindexAllSearchableItemsWithAcknowledgementHandler:(void (^)(void))acknowledgementHandler {
    // Reindex all data with the provided index
    
    acknowledgementHandler();
}

- (void)searchableIndex:(CSSearchableIndex *)searchableIndex reindexSearchableItemsWithIdentifiers:(NSArray <NSString *> *)identifiers acknowledgementHandler:(void (^)(void))acknowledgementHandler {
    // Reindex any items with the given identifiers and the provided index
    
    acknowledgementHandler();
}

@end
