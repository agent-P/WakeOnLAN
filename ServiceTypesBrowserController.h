/**
 * @file ServiceTypesBrowserController.h
 * 
 * @author Perry Spagnola
 * @date 3/5/11 - created
 * @version 1.0
 * @brief Header file for the <code>interface</code> of the ServiceTypesBrowserController class.
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


@interface ServiceTypesBrowserController : NSObject {
	
    NSNetServiceBrowser *browser;
    NSMutableArray *services;
    IBOutlet NSArrayController *serviceTypesController;
}

@property (readwrite, retain) NSNetServiceBrowser *browser;
@property (readwrite, retain) NSMutableArray *services;

@end
