//
//  UFOSighting+Import.h
//  MDMHPCoreData
//
//  Created by Matthew Morey (http://matthewmorey.com) on 10/16/13.
//  Copyright (c) 2013 Matthew Morey. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
//  to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "UFOSighting.h"


// JSON/Dictionary keys
extern NSString *const UFO_KEY_COREDATA_GUID;
extern NSString *const UFO_KEY_COREDATA_TEXT;
extern NSString *const UFO_KEY_COREDATA_NAME;
extern NSString *const UFO_KEY_COREDATA_AVATAR;

extern NSString *const UFO_KEY_JSON_GUID;
extern NSString *const UFO_KEY_JSON_TEXT;
extern NSString *const UFO_KEY_JSON_NAME;
extern NSString *const UFO_KEY_JSON_AVATAR;

@interface UFOSighting (Additions)

+ (instancetype)importSighting:(NSDictionary *)data intoContext:(NSManagedObjectContext *)context;
+ (NSString *)entityName;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (UIImage *)imageForShape:(NSString *)shape;

@end
