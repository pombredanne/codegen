#codegen
codegen is a tool for automating the creation of new source code files, by ensuring that they have the required license's inserted at the start of the code, correct names, includes and basic components you would want to have
in each source code file.

###Why?
This tool is more intended for use in my own projects, though other people are more than welcome to make use of, add to and contribute to this tool if they find it useful or think that they would.

###Using
Before using codegen, you will need to install it. Instructions are given below for installing. Once it is installed you can produce a new file by doing the following:

    codegen file-name

By default codegen builds C files. This can be configured in one of two ways; providing a default configuration file at `~/.codegen` or specifying in the command line arguments. More detailed information about this is provided here.

To specify the language on the command line, use the following:

    codegen -lang=name file-name

In addition to this, you may want to specify author information and license. These can be provided using the following:

    codegen -lang=name -author="Author Name" -email="author@test.com" -license=MIT file-name

###Installing
To install codegen, you will need to have GNU Make present on your system. To build and install the tool simply use the following command
    
    make

This will copy all the appropriate files in to the correct locations and handle any bindings that need to be setup.

To remove codegen you can use the following

    make clean

This will remove any of the installed files from your system.


##License
The MIT License (MIT)

Copyright (c) 2014 Tom Hancocks

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.