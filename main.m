/**
 * @file  main.m
 *
 * @author Perry Spagnola 
 * @date 2/7/11 - created
 * @version 1.0
 * @brief Main file of the application. It starts the application running.
 * @details  This implementation simply tail-calls NSApplicationMain, which sets up the
 * shared NSApplication object and starts it running. That function never returns; when 
 * the user quits a Cocoa app, the process simply exits.
 *
 * @copyright  Copyright 2011 Perry M. Spagnola. All rights reserved.
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

int main(int argc, char *argv[])
{
    return NSApplicationMain(argc,  (const char **) argv);
}
