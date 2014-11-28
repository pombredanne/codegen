#!/usr/bin/ruby
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Tom Hancocks
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require "date"


class CodeGen
  # The user config is taken from the configuration file in the users home directory
  # and from command line arguments passed to the tool. It is used to keep track
  # of how the tool should behave
  attr_accessor :user_config

  # The definitions about the language and exactly what should be generated
  attr_accessor :definitions

  # The names of the files that need to be generated
  attr_accessor :files


  #
  def initialize
    # Make sure we have any support data available.
    unless File.directory? "/usr/local/codegen"
      puts "\033[31mExpected the directory /usr/local/codegen to exist.\033[0m"
      puts "\033[31mPlease ensure it does and that it has the correct data inside.\033[0m"
      throw "/usr/local/codegen not found!"
    end

    # We want to display the help information if there are no arguments
    if ARGV.count == 0
      puts FileLoader.new("HELP").data
      return
    end

    # Apply the layers of configuration to the tool. These need to be loaded
    # in this order to ensure the correct information is applied.
    self.load_base_configuration
    self.load_home_configuration
    self.load_arguments_configuration

    # load the requested language definitions.
    self.load_language_definition self.user_config["lang"]

    # Determine any files that have been requested.
    self.load_argument_files

    # Finally construct each of the source files requested
    self.construct_source_files self.files
  end


  #
  def load_base_configuration
    self.user_config = Hash.new
    self.user_config["lang"] = "c"
    self.user_config["license"] = "MIT"
    self.user_config["name"] = "Unknown"
    self.user_config["email"] = ""
    self.user_config["path"] = "."
    self.user_config["ignore-header"] = "no"
    self.user_config["ignore-source"] = "no"
    self.user_config["year"] = Date.today.strftime("%Y")
    self.user_config["variants"] = "default"
  end

  #
  def load_home_configuration
    home_config = ConfigurationFile.new("~/.codegen")
    self.user_config = self.user_config.merge(home_config.result)
  end

  #
  def load_arguments_configuration
    ARGV.each do |arg|
      if arg.start_with? "-"
        self.parse_argument arg
      end
    end
  end

  # Parse and interpret a single argument
  def parse_argument(arg)
    components = arg.split(/\=/)
    key = components[0][1..-1]
    value = components[1]
    self.user_config[key] = value
  end


  #
  def load_language_definition(language)
    self.definitions = ConfigurationFile.new("/usr/local/codegen/templates/languages/#{language}/definitions").result
  end


  # Determine what files need to be generated
  def load_argument_files
    self.files = Array.new

    ARGV.each do |arg|
      unless arg.start_with? "-"
        self.files.push arg
      end
    end
  end


  # Retrieve an array of the variant names to construct
  def get_variants
    return self.user_config["variants"].split(/[ \t]*,[ \t]*/)
  end


  # Build the license for the top of code files
  def build_license
    license_name = self.user_config['license'].upcase
    license = FileLoader.new("templates/licenses/#{license_name}")
    license.apply_hash(self.user_config)
    license.comment_out(self.definitions['comment'])
    return license.data
  end


  # Construct the variants of the specified file
  def construct_source_files(files)
    language = self.user_config["lang"]
    source_path = self.user_config["path"]
    header_path = self.user_config["path"]

    if self.user_config.has_key? "header-path"
      header_path = self.user_config["header-path"]
    end

    license = self.build_license

    # Step through each of the variants that need to be produced
    variants = self.get_variants
    variants.each do |variant|
      files.each do |file|

        # Generate any file dependant variables
        file_specific = Hash.new
        file_specific["include_guard"] = self.symbolicate(file.upcase)
        file_specific["header"] = "#{file}.h"
        file_specific["object_name"] = self.symbolicate(file.capitalize, "")
        file_specific["license"] = license

        # Determine which variants we need
        if self.user_config["ignore-header"] == "no" && self.definitions["has-header"] == "yes"
          # Generate a header for this variant
          header_extension = self.definitions["header-extension"]
          header_name = "#{file}.#{header_extension}"
          header_file = FileLoader.new("templates/languages/#{language}/#{variant}.#{header_extension}")
          header_file.apply_hash file_specific
          header_file.apply_hash self.user_config
          header_file.export("#{header_path}/#{file}.#{header_extension}")
        end

        if self.user_config["ignore-source"] == "no"
          # Generate a source file for this variant
          source_extension = self.definitions["source-extension"]
          source_file = FileLoader.new("templates/languages/#{language}/#{variant}.#{source_extension}")

          # Does the file require a shebang?
          if self.definitions.has_key? "shebang"
            shebang = self.definitions["shebang"]
            source_file.prepend_line("#!#{shebang}")
          end

          source_file.apply_hash file_specific
          source_file.apply_hash self.user_config
          source_file.export("#{source_path}/#{file}.#{source_extension}")
        end

      end

    end
  end

  # Given a string, returns a Symbolicated version of that string
  def symbolicate(name, substitution = '_')
    return name.gsub(/\W+/, substitution)
  end
end


class ConfigurationFile
  attr_accessor :config_file_path
  attr_accessor :result

  def initialize(path)
    self.config_file_path = File.expand_path(path)
    self.result = Hash.new
    self.parse
  end

  # Opens a file and begins parsing it. Parsing needs to happen on a line by line basis
  def parse
    file = File.new(self.config_file_path, "r")
    while (line = file.gets)
      self.parse_line line.gsub(/\n/, "")
    end
  end

  # To parse a line of a configuration file, we first need to know what the first character is
  # and how long it is. If there character is a ";" or "#" then the line is a comment and can
  # be ignored. If the line has no length, or the first character is whitespace then it is
  # and empty line, and ignored.
  # If the the line begins with a "[" then it is a section marker, and currently, ignored.
  # Everything else is parsed as a property.
  def parse_line(line)
    first_char = line[0,1]

    if line.length == 0 || (first_char == " " || first_char == "\t" || first_char == "\n") || (first_char == ";" || first_char == "#")
      return

      elsif first_char == "["
      self.parse_section_marker line

      else
      self.parse_property line

    end
  end

  #
  def parse_section_marker(line)
    start = 1
    length = line.length - 2
    marker_name = line[start, length]

    # TODO: Handle section markers
  end

  #
  def parse_property(line)
    components = line.split(/[ \t]*=[ \t]*/)
    self.result[components[0]] = self.parse_value(components[1])
  end

  # Extract a value. If the supplied value is a string (wrapped in double quotes) then the
  # inner value will be returned
  def parse_value(value)
    first_char = value[0,1]

    if first_char == "\""
      length = value.length - 2
      return value[1, length]
      else
      return value
    end
  end
end


# Class for loading data from a support file, and applying variables to it.
class FileLoader
  # The root directory in which the path is looked for
  attr_accessor :root

  # The path of the file to be loaded, relative to the root
  attr_accessor :path

  # The data that has been loaded from the requested file
  attr_accessor :data

  #
  def initialize(path)
    self.root = "/usr/local/codegen"
    self.path = path
    self.load_data
  end

  # Load the data for the specified file
  def load_data
    self.data = ""
    path = "#{self.root}/#{self.path}"
    file = File.new(path, "r")
    while (line = file.gets)
      self.data += line
    end
  end

  # Run a single substitution on the file data
  def sub(orig, rep)
    self.data = self.data.gsub(orig, rep)
  end

  # Run a single key value substitution on the file data
  def apply(key, value)
    token = "%%#{key.upcase}%%"
    self.sub(Regexp.escape(token), value)
  end

  # Apply an entire hash of values to the file as substitutions
  def apply_hash(hash)
    hash.each do |key, value|
      self.apply(key, value)
    end
  end

  # Comment out the entire data
  def comment_out(comment)
    self.sub(/\n/, "\n#{comment} ")
    self.data = "#{comment} " + self.data
  end

  # Export the file out to the specified location
  def export(path)
    puts "\033[32mCreating #{path}\033[0m"
    File.write(path, self.data)
  end

  # Prepend some text to the beginning of the file data.
  def prepend_line(text)
    self.data = "#{text}\n" + self.data
  end
end


# Kick off the entire thing
CodeGen.new
