/**
 * @file NodeImageValueTransformer.m
 * 
 * @author Perry Spagnola
 * @date 2/13/11 - created
 * @version 1.0
 * @brief Class file for the NodeImageValueTransformer class.
 * @details This class enables the display of the Mac machine icon
 * associated with the model code for the node published by bonjour.
 * The default Mac machine icon is provided if the icon for the 
 * published model code cannot be found.
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

#import "NodeImageValueTransformer.h"


@implementation NodeImageValueTransformer
+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value {

	// DEBUG: NSLog(@"NodeImageValueTransformer transformedValueClass: %@", value);
	
	return [self getComputerIconForModelCode:value];	
}

/**
 * Returns the Icon for the ModelCode published by bonjour.
 * if the modelCode can not be associated to an icon the default Mac icon is returned.
 * @param modelCode - the model code to retrieve the icon for
 * 
 * @return the icon associated with the model code or the default Mac icon
 * @retval success - the the icon associated with the model code argument
 * @retval failure - the default mac machine icon
 */
-(NSImage *) getComputerIconForModelCode:(NSString *)modelCode {
	[modelCode retain];
	
	// Standard Model Codes.
	CFStringRef uti = nil;
	if ((nil != modelCode) && (![modelCode isEqualToString:@""])){
		uti = UTTypeCreatePreferredIdentifierForTag((CFStringRef)@"com.apple.device-model-code", (CFStringRef) modelCode, nil);
	}
	else{
		uti = (CFStringRef) @"com.apple.mac";
	}
	[modelCode release];
	
	CFDictionaryRef utiDecl = UTTypeCopyDeclaration(uti);
	if (utiDecl){
		CFStringRef iconFileNameRef = CFDictionaryGetValue(utiDecl, (CFStringRef)@"UTTypeIconFile");
		/**
		 * If there is no icon for this UTI, load the icon for the key conformsTo UTI.
		 * cycle until we find one, there is always one at the top of the tree.
		 */
		if (nil == iconFileNameRef){
			while ((nil==iconFileNameRef) && (nil != utiDecl)){
				uti = CFDictionaryGetValue(utiDecl, (CFStringRef)@"UTTypeConformsTo");
				utiDecl = UTTypeCopyDeclaration(uti);
				iconFileNameRef = CFDictionaryGetValue(utiDecl, (CFStringRef)@"UTTypeIconFile");
			}
		}
		CFURLRef bundleURL = UTTypeCopyDeclaringBundleURL(uti);
		NSString *iconPath = [[[(NSURL *)bundleURL path] stringByAppendingPathComponent:@"Contents/Resources/"]stringByAppendingPathComponent:(NSString*)iconFileNameRef];
		return [[[NSImage alloc] initWithContentsOfFile:iconPath] autorelease];
	}
	else{
		/**
		 * No UTI available, return the default mac icon.
		 */
		return [self getDefaultMacComputerIcon];
	}
}


/**
 * Returns the default Mac machine icon.
 *
 * @return the default Mac icon
 * @retval success - the default mac machine icon
 * @retval failure - nil
 */
-(NSImage *) getDefaultMacComputerIcon {
	
	CFStringRef uti = (CFStringRef) @"com.apple.mac";
	CFDictionaryRef utiDecl = UTTypeCopyDeclaration(uti);
	if (utiDecl){
		CFStringRef iconFileNameRef = CFDictionaryGetValue(utiDecl, (CFStringRef)@"UTTypeIconFile");
		CFURLRef bundleURL = UTTypeCopyDeclaringBundleURL(uti);
		NSString *iconPath = [[[(NSURL *)bundleURL path] stringByAppendingPathComponent:@"Contents/Resources/"]stringByAppendingPathComponent:(NSString*)iconFileNameRef];
		return [[[NSImage alloc] initWithContentsOfFile:iconPath] autorelease];
	}
	return nil;
}

@end
