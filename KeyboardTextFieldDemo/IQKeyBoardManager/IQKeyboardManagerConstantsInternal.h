//
//  IQKeyboardManagerConstantsInternal.h
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#ifndef IQKeyboardManagerConstantsInternal_h
#define IQKeyboardManagerConstantsInternal_h

#define IQ_IS_IOS7_OR_GREATER (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)

/*!
    @discussion To load categories in the current file loadable without using "-load-all" flag. When we try to create framework or library the compilers skips linking files that contain only categories. So user this macro to add a dummy class, which causes the linker to add the file. You will also need to add "-ObjC" to the "Other Linker Flags" build setting in any project that uses the framework.
 
    @param UNIQUE_NAME A globally unique name.
 */
#define IQ_LoadCategory(UNIQUE_NAME) @interface FORCELOAD_##UNIQUE_NAME :NSObject @end @implementation FORCELOAD_##UNIQUE_NAME @end

#endif
