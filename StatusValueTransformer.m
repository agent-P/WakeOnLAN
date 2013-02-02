/**
 * @file StatusValueTransformer.m
 * 
 * @author Perry Spagnola 
 * @date 2/12/11 - created
 * @version 1.0
 * @brief Class file for the StatusValueTransformer class.
 * @details This class is a very simple value transformer. It transforms
 * an is awake node status to a green or red icon depending on the status,
 * green for awake, and red for not awake.
 *
 * @copyright Copyright 2011 Perry M. Spagnola. All rights reserved.
 *
 * @section LICENSE
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details at
 * http://www.gnu.org/copyleft/gpl.html
 */

#import "StatusValueTransformer.h"


@implementation StatusValueTransformer
+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value {
	
	BOOL _isAwake = [value boolValue];
	
	if(_isAwake){
		return [NSImage imageNamed:@"green.png"];
	}else{
		return [NSImage imageNamed:@"red.png"];
	}
	
	return nil;
}
	
@end
