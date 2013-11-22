//
//  SMAddressParser.m
//  I Bike CPH
//
//  Created by Ivan Pavlovic on 12/11/2013.
//  Copyright (c) 2013 City of Copenhagen. All rights reserved.
//

#import "SMAddressParser.h"

@implementation SMAddressParser

+ (BOOL)testNumber:(NSString*)string {
    NSRegularExpression * regex3 = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSRegularExpression * regex4 = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+[a-zA-Z]" options:NSRegularExpressionCaseInsensitive error:NULL];
    if (([string length] <= 3 && [regex3 numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0) || ([string length] == 4 && [regex4 numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0)) {
        return YES;
    }
    return NO;
}

+ (BOOL)testZip:(NSString*)string {
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+" options:NSRegularExpressionCaseInsensitive error:NULL];
    if ([string length] == 4 && [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0) {
        return YES;
    }
    return NO;
}

+ (NSDictionary*)parseStreetAndNumber:(NSString*)streetAndNumber {
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[streetAndNumber componentsSeparatedByString:@" "]];
    if ([arr count] == 0) {
        return @{};
    }
    if ([arr count]> 1) {
        NSString * number = [arr lastObject];
        if ([self testNumber:number]) {
            [arr removeObject:number];
            return @{@"street" : [arr componentsJoinedByString:@" "],
                     @"number" : number
                     };
        }
    }
    return @{@"street" : streetAndNumber};
}

+ (NSDictionary*)parseZipAndCity:(NSString*)zipAndCity {
    if ([[zipAndCity stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return @{};
    }
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[zipAndCity componentsSeparatedByString:@" "]];
    if ([arr count] == 0) {
        return @{};
    }
    NSString * zip = nil;
    for (NSString * s in arr) {
        if ([self testZip:s]) {
            zip = s;
            break;
        }
    }
    
    if (zip) {
        if ([zip isEqualToString:[arr objectAtIndex:0]] || [zip isEqualToString:[arr lastObject]]) {
            [arr removeObject:zip];
            NSString * city = [arr componentsJoinedByString:@" "];
            if ([[city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                return @{@"zip" : zip};
            } else {
                return @{@"zip" : zip, @"city" : city};
            }
        }
    }
    return @{@"city" : zipAndCity};
}


+ (NSDictionary*)parseAddressProcedure:(NSString*)addressString {
    /**
     * clear trailing spaces and commas
     */
    NSMutableCharacterSet * set = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [set addCharactersInString:@","];
    addressString = [addressString stringByTrimmingCharactersInSet:set];
    
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[addressString componentsSeparatedByString:@","]];
    /**
     * clean the strings by trimming them
     */
    if ([arr count] > 0) {
        for (int i = 0; i < [arr count]; i++) {
            [arr replaceObjectAtIndex:i withObject:[[arr objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    /**
     * we first check if there is a "," that divides street address from the zip and city part
     */
    if ([arr count] > 1) {
        NSString * streetAndNumber = [[arr objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDictionary* streetAddress = [self parseStreetAndNumber:streetAndNumber];
        NSMutableDictionary * d = [NSMutableDictionary dictionaryWithDictionary:streetAddress];
        [arr removeObjectAtIndex:0];
        
        if ([d objectForKey:@"number"] == nil && [self testNumber:[arr objectAtIndex:0]]) {
            [d setValue:[arr objectAtIndex:0] forKey:@"number"];
            [arr removeObjectAtIndex:0];
        } else {
            NSString * number = nil;
            NSMutableArray * a = [NSMutableArray arrayWithArray:[[arr objectAtIndex:0] componentsSeparatedByString:@" "]];
            if ([arr count] > 0) {
                for (int i = 0; i < [a count]; i++) {
                    [a replaceObjectAtIndex:i withObject:[[a objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                }
                
                for (NSString * s in a) {
                    if ([self testNumber:s]) {
                        number = s;
                        break;
                    }
                }
                
                if (number) {
                    [d setValue:number forKey:@"number"];
                    [a removeObject:number];
                    [arr replaceObjectAtIndex:0 withObject:[a componentsJoinedByString:@" "]];
                }
            }
            
        }
        
        if ([arr count] > 1) {
            NSString * zip = nil;
            for (NSString * s in arr) {
                if ([self testZip:s]) {
                    zip = s;
                    break;
                }
            }
            if (zip) {
                [d setValue:zip forKey:@"zip"];
                if ([arr indexOfObject:zip] == 0) {
                    if ([arr count] > 1) {
                        NSDictionary * zipCity = [self parseZipAndCity:[arr objectAtIndex:1]];
                        [d addEntriesFromDictionary:zipCity];
                    }
                    return d;
                } else {
                    NSUInteger ind = [arr indexOfObject:zip];
                    [arr removeObjectsInRange:NSMakeRange(ind, [arr count] - ind)];
                    NSString * zipAndCity = [arr componentsJoinedByString:@" "];
                    NSDictionary * zipCity = [self parseZipAndCity:zipAndCity];
                    [d addEntriesFromDictionary:zipCity];
                    return d;
                }
            } else {
                NSString * zipAndCity = [arr objectAtIndex:0];
                NSDictionary * zipCity = [self parseZipAndCity:zipAndCity];
                [d addEntriesFromDictionary:zipCity];
                return d;
            }
        }
        
        NSString * zipAndCity = [arr componentsJoinedByString:@" "];
        NSDictionary * zipCity = [self parseZipAndCity:zipAndCity];
        [d addEntriesFromDictionary:zipCity];
        return d;
    } else {
        NSMutableDictionary * addr = [NSMutableDictionary dictionary];
        /**
         * there are no commas; we must check the string manually
         * we start by separating them by " "
         */
        arr = [NSMutableArray arrayWithArray:[addressString componentsSeparatedByString:@" "]];
        /**
         * clean the strings by trimming them
         */
        if ([arr count] > 0) {
            for (int i = 0; i < [arr count]; i++) {
                [arr replaceObjectAtIndex:i withObject:[[arr objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
        }
        NSString * number = nil;
        /**
         * first we try to find the house number because we know the street name is before it and zip and city are after it
         * giving us a nice way to divide the string
         */
        for (NSString * s in arr) {
            if ([self testNumber:s]) {
                number = s;
                break;
            }
        }
        if (number) {
            [addr setObject:number forKey:@"number"];
            NSUInteger ind = [arr indexOfObject:number];
            if (ind > 0) {
                NSMutableArray * a = [NSMutableArray array];
                for (int i = 0; i < ind; i++) {
                    [a addObject:[arr objectAtIndex:i]];
                }
                NSString * street = [a componentsJoinedByString:@" "];
                if ([[street stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
                    [addr setObject:street forKey:@"street"];
                }
            }
            [arr removeObjectsInRange:NSMakeRange(0, ind + 1)];
            if ([arr count] > 0) {
                NSDictionary * d = [self parseZipAndCity:[arr componentsJoinedByString:@" "]];
                [addr addEntriesFromDictionary:d];
            }
        } else {
            /**
             * we couldn't find a house number; let's try with zip code
             * we must assume that the city name will follow the zip code;
             */
            NSString * zip = nil;
            for (NSString * s in arr) {
                if ([self testZip:s]) {
                    zip = s;
                    break;
                }
            }
            
            if (zip) {
               [addr setObject:zip forKey:@"zip"];
                NSUInteger ind = [arr indexOfObject:zip];
                if (ind > 0) {
                    NSMutableArray * a = [NSMutableArray array];
                    for (int i = 0; i < ind; i++) {
                        [a addObject:[arr objectAtIndex:i]];
                    }
                    NSString * street = [a componentsJoinedByString:@" "];
                    if ([[street stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
                        [addr setObject:street forKey:@"street"];
                    }
                }
                [arr removeObjectsInRange:NSMakeRange(0, ind + 1)];
                NSString * city = [arr componentsJoinedByString:@" "];
                if ([[city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
                    [addr setObject:city forKey:@"city"];
                }
            } else {
                /**
                 * there is no zip code or house number
                 * we assume that the user has just given us the street name
                 */
                return @{@"street" : addressString};
            }
        }
        return addr;
    }
    
    
    return @{};
}

+ (NSDictionary*)parseAddressRegex:(NSString*)addressString {
    /**
     * clear trailing spaces and commas
     */
    NSMutableCharacterSet * set = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [set addCharactersInString:@","];
    addressString = [addressString stringByTrimmingCharactersInSet:set];
    NSMutableDictionary * addr = [NSMutableDictionary dictionary];
    
    NSRegularExpression * exp;
    NSRange range;
    
    
    exp = [NSRegularExpression regularExpressionWithPattern:@"[\\s,](\\d{1,3}[a-zA-Z]?)[\\s,]" options:0 error:NULL];
    NSRange rangeN = [exp rangeOfFirstMatchInString:addressString options:0 range:NSMakeRange(0, [addressString length])];
    if (rangeN.location != NSNotFound) {
        NSString * s = [addressString substringWithRange:rangeN];
        if (s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
            [addr setValue:[s stringByTrimmingCharactersInSet:set] forKey:@"number"];
        }
    } else {
        exp = [NSRegularExpression regularExpressionWithPattern:@"[\\s,](\\d{1,3}[a-zA-Z]?)$" options:0 error:NULL];
        rangeN = [exp rangeOfFirstMatchInString:addressString options:0 range:NSMakeRange(0, [addressString length])];
        if (rangeN.location != NSNotFound) {
            NSString * s = [addressString substringWithRange:rangeN];
            if (s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
                [addr setValue:[s stringByTrimmingCharactersInSet:set] forKey:@"number"];
            }
        } else {
            exp = [NSRegularExpression regularExpressionWithPattern:@"^(\\d{1,3}[a-zA-Z]?)[\\s,]+" options:0 error:NULL];
            rangeN = [exp rangeOfFirstMatchInString:addressString options:0 range:NSMakeRange(0, [addressString length])];
            if (rangeN.location != NSNotFound) {
                NSString * s = [addressString substringWithRange:rangeN];
                if (s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
                    [addr setValue:[s stringByTrimmingCharactersInSet:set] forKey:@"number"];
                }
            }
        }
    }
    
    exp = [NSRegularExpression regularExpressionWithPattern:@"\\d{4}" options:0 error:NULL];
    NSRange rangeZ = [exp rangeOfFirstMatchInString:addressString options:0 range:NSMakeRange(0, [addressString length])];
    if (rangeZ.location != NSNotFound) {
        NSString * s = [addressString substringWithRange:rangeZ];
        if (s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
            [addr setValue:[s stringByTrimmingCharactersInSet:set] forKey:@"zip"];
        }
    }

    NSInteger len = MIN(MIN(rangeN.location, rangeZ.location), [addressString length]);
    
    if (len > 0) {
        exp = [NSRegularExpression regularExpressionWithPattern:@"^[\\s,]*([^\\d,]+)" options:0 error:NULL];
        NSRange rangeS = [exp rangeOfFirstMatchInString:addressString options:0 range:NSMakeRange(0, len)];
        if (rangeS.location != NSNotFound) {
            NSString * s = [addressString substringWithRange:rangeS];
            if (s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
                [addr setValue:[s stringByTrimmingCharactersInSet:set] forKey:@"street"];
            }
        } else {
            exp = [NSRegularExpression regularExpressionWithPattern:@"^[\\s,]*\\d{1,3}[a-zA-Z]?[\\s,]([^\\d,]+)" options:0 error:NULL];
            rangeS = [exp rangeOfFirstMatchInString:addressString options:0 range:NSMakeRange(0, [addressString length])];
            if (rangeS.location != NSNotFound) {
                NSString * s = [addressString substringWithRange:rangeS];
                if (s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
                    [addr setValue:[s stringByTrimmingCharactersInSet:set] forKey:@"street"];
                }
            }
        }
    }
    exp = [NSRegularExpression regularExpressionWithPattern:@"\\d\\w?\\s+(([\\p{L}\\.]\\s*)+)" options:0 error:NULL];
    NSRegularExpression * e2 = [NSRegularExpression regularExpressionWithPattern:@"\\b(kbh|cph)\\.\\s*" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSRegularExpression * e3 = [NSRegularExpression regularExpressionWithPattern:@"\\b(kbh|cph)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSRange rangeC = [exp rangeOfFirstMatchInString:addressString options:0 range:NSMakeRange(0, [addressString length])];
    if (rangeC.location != NSNotFound) {
        NSString * s = [addressString substringWithRange:rangeC];
        exp = [NSRegularExpression regularExpressionWithPattern:@"^(\\d\\w)+" options:0 error:NULL];
        range = [exp rangeOfFirstMatchInString:s options:0 range:NSMakeRange(0, [s length])];
        if (range.location != NSNotFound) {
            s = [s stringByTrimmingCharactersInSet:set];
            s = [s stringByReplacingCharactersInRange:range withString:@""];
        }
        if (s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
            NSMutableString * s1 = [NSMutableString stringWithString:[s stringByTrimmingCharactersInSet:set]];
            NSUInteger count = [e2 replaceMatchesInString:s1 options:0 range:NSMakeRange(0, [s1 length]) withTemplate:@"København "];
            count = [e3 replaceMatchesInString:s1 options:0 range:NSMakeRange(0, [s1 length]) withTemplate:@"København"];
            [addr setValue:s1 forKey:@"city"];
        }
    } else {
        // [,\\s]+([\\w\\-\\'\\.]+\\s*)+
        // ,\\s*(([\\p{L}\\.]\\s*)+)
        exp = [NSRegularExpression regularExpressionWithPattern:@",\\s*(([\\p{L}\\.\\-\\']\\s*)+)" options:0 error:NULL];
        rangeC = [exp rangeOfFirstMatchInString:addressString options:0 range:NSMakeRange(0, [addressString length])];
//        NSArray * ranges = [exp matchesInString:addressString options:0 range:NSMakeRange(0, [addressString length])];
        if (rangeC.location != NSNotFound) {
            NSString * s = [addressString substringWithRange:rangeC];
            if (s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] == NO) {
                NSMutableString * s1 = [NSMutableString stringWithString:[s stringByTrimmingCharactersInSet:set]];
                NSUInteger count = [e2 replaceMatchesInString:s1 options:0 range:NSMakeRange(0, [s1 length]) withTemplate:@"København "];
                count = [e3 replaceMatchesInString:s1 options:0 range:NSMakeRange(0, [s1 length]) withTemplate:@"København"];
                [addr setValue:s1 forKey:@"city"];
            }
        }
    }
    
    return addr;
}

+ (NSDictionary*)parseAddress:(NSString*)addressString {
    return [self parseAddressRegex:addressString];
}

@end
