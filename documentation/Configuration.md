#Global Configuration
This document details the creation and setup of the `~/.codegen` file for your current user account in order to apply a number of default settings to codegen.

##Basic Syntax
The basic syntax and layout of a Configuration and Definitions files is as follows

    # Commented line
    [section-name]
    property-name = "property value"

*Section Names* act as comments for all intents and purposes, but are intended to act as groupings for types of property.

Properties are the same as what would be passed in on the command line. The inverse of that would be anything you pass on the command line (except for file names) can also be specified here.

## Properties
The properties that are defined by default are

####author
The author should be the name of primary contributor the source file being generated. This will typically be your name.

An example of this property inside the configuration file might be

    author = "Homer Simpson"

and the same property when being used on the command line

    -auhtor="Homer Simpson"

####email
The email should be the email address of primary contributor the source file being generated. This will typically be your email address.

An example of this property inside the configuration file might be

    email = "homer.simpson@example.com"

and the same property when being used on the command line

    -email="homer.simpson@example.com"

####header-path
The location that any header files should be generated to. If this is not set then the directory from which codegen is run will be used.

    header-path = "/dev/null"

and the same property when being used on the command line

    -header-path="/dev/null"

####ignore-header
This is a boolean property that tells codegen to ignore any required header files. If this is set to yes, then no defined header files will be produced.

    ignore-header = "yes"

and the same property when being used on the command line

    -ignore-header="yes"

####ignore-source
This is a boolean property that tells codegen to ignore any required source files. If this is set to yes, then no defined source files will be produced.

    ignore-source = "yes"

and the same property when being used on the command line

    -ignore-source="yes"

####lang
The source language that you wish to generate. You may only specifiy one language at a time.

    lang = "c"

and the same property when being used on the command line

    -lang="c"

####license
The name of the license that you wish to attach to the file. If you do not wish to attach a license, then specify this as `none`.

    license = "MIT"

and the same property when being used on the command line

    -license="MIT"

####path
The location that any source files should be generated to. If this is not set then the directory from which codegen is run will be used.

    path = "/dev/null"

and the same property when being used on the command line

    -path="/dev/null"

####variants
The type of source file you wish to generate. Most templates contain only a default variant, and thus render this property meaningless. This will default to a value of `default`

    variants = "default"

and the same property when being used on the command line

    -variants="default"

####year
The year in which the source files are being generated. This is usually used in licenses, and will default to the current year.

    year = 2014

and the same property when being used on the command line

    -year=2014


###Custom Properties
You can also specify your own custom properties on either the command line or in the configuration files.
