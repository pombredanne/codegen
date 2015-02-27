#Language Definition
This document details the creation and setup of a language definition file and variant code files.

##Basic Syntax
The basic syntax and layout of a `definitions` file is as follows

    # Commented line
    [section-name]
    property-name = "property value"

*Section Names* act as comments for all intents and purposes, but are intended to act as groupings for types of property.

This file is be located at `templates/languages/name/definitions`, where name is the name of the language (i.e. C, Ruby, Swift, etc).

###Properties
The language definitions can contain a number of properties that instruct codegen on what its behaviour should be when generating code files of that language.

####shebang
Certain languages such as shell scripting languages (Ruby, Python, Perl, etc) are able to be executed as native programs directly from the command line without the need to specify the runtime environment. In order to do this you need to specify a *shebang* at the top of the file. A shebang looks like

    #!/path/to/environment

You can specify the shebang to be inserted into a file at the top of the definitions file. This value should just be the environment path, and not the `#!` token.

    shebang = "/path/to/environment"
    shebang = "/usr/bin/ruby"
    shebang = "/usr/bin/python"

####block-comment-start
Tells codegen what to place at the beginning of a block comment.

    block-comment-start = "/*"

####block-comment-end
Tells codegen what to place at the end of a block comment.

    block-comment-end = "*/"

####comment
Tells codegen what to use for singleline comments.

    comment = "//"

####has-block-comment
Tells codegen if the language offers block comments. If this is set to yes then it will attempt to use block comments. This property is assumed to be no. It should be noted that the user can also specify a preference on the use of block comments.

    has-block-comment = "yes"

####has-header
Tells codegen if the language makes use of header files. If this is set to no then it will not produce any header files for this language. The property is assumed to be no.

    has-header = "no"

####header-extension
Tells codegen what file extension to use when generating header files for this language. This is also used in conjunction with the specified variant to locate the template source code to use when generating a file.

    header-extension = "h"

####source-extension
Tells codegen what file extension to use when generating source files for this language. This is also used in conjunction with the specified variant to locate the template source code to use when generating a file.

    source-extension = "c"

###Template Variants
Variants are the way that codegen is able to produce multiple types of output for a given language and that users are able to add custom templates with their own frequently used boiler plate code.

On a fresh install of codegen, each language comes with at least a *default* variant, that will be used if no variant is specified in the configuration or arguments. 

The name of a variant code file should be as follows:

    variant_name.header_extension
    variant_name.source_extension

codegen will look for these files when generating files. It then uses the contents of these files as a basis for the output of the newly generated files.

An example of what one of these looks like, is the C++ header file.

    %%LICENSE%%
    
    #ifndef __%%INCLUDE_GUARD%%__
    #define __%%INCLUDE_GUARD%%__
    
    #include <iostream>
    
    class %%OBJECT_NAME%%
    {
        %%OBJECT_NAME%%();
        ~%%OBJECT_NAME%%();
    };
    
    #endif

Inside this template code are a number of tokens in the form of `%%TOKEN%%`. These are what codegen will look for and replace with appropriate values. codegen provides a number of tokens that are generated using the current file name, as well as providing access to any value specified in the configuration files or arguments.

The name of a token when specified in template code should always be uppercase.

The predefined values are listed below.

####LICENSE
Although this is actually the name of a property in the configuration file, it will altered by codegen to be the contents of the license with that name.

####INCLUDE_GUARD
This is one specifically intented for C based languages, though it may be useful in other places.

It generates an uppercase symbol of the current file name. For example `Example Class` would become `EXAMPLE_CLASS`.

####OBJECT_NAME
This is similar to *INCLUDE_GUARD* as it too produces a symbol name from the current file name. However it differs in so much that it produces a CamelCase version of the file name with any whitespace stripped. 

For example `Example Class` would become `ExampleClass`.

####HEADER
This is the name of the header file for the file being currently generated. If the current file is called `Example Class` then this would become `Example Class.hpp` (assuming the language was set to C++).
