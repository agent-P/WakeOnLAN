/**
 * @file ResolvedService.h
 * 
 * @author Perry Spagnola
 * @date 2/20/11 - created
 * @version 1.0
 * @brief Header file for the <code>interface</code> of the ResolvedService class.
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

#import <Cocoa/Cocoa.h>

@interface ResolvedService : NSManagedObject {
	
	NSString *host;
	NSString *domain;
	NSString *ipAddr;
	NSString *macAddr;
	BOOL status;
	NSString *owner;
	NSString *icon;
	NSString *name;
	NSString *type;
	
}

@property (readwrite, retain) NSString *host;
@property (readwrite, retain) NSString *domain;
@property (readwrite, retain) NSString *ipAddr;
@property (readwrite, retain) NSString *macAddr;
@property (readwrite, retain) NSString *owner;
@property (readwrite, retain) NSString *icon;
@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSString *type;
@property (readwrite) BOOL status;


-(ResolvedService*) initWithNSNetService: (NSNetService*) service;

@end
