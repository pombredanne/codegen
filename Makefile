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

# Directories
ROOT-PATH := /usr/local/codegen
TEMPLATES-PATH := $(ROOT-PATH)/templates
LANGUAGES-PATH := $(TEMPLATES-PATH)/languages
LICENSES-PATH := $(TEMPLATES-PATH)/licenses
USR_BIN := /usr/local/bin

LICENSES := ./templates/licenses
LANGUAGES := ./templates/languages

CODEGEN := "codegen.rb"

.PHONY: all install clean install-languages install-licenses clean-languages clean-licenses

all: clean install

clean: clean-languages clean-licenses
	rm -rfv $(ROOT-PATH)
	rm $(USR_BIN)/codegen

clean-languages:
	rm -rfv $(LANGUAGES-PATH)

clean-licenses:
	rm -rfv $(LICENSES-PATH)

install: $(ROOT-PATH) $(TEMPLATES-PATH) install-licenses install-languages
	cp codegen.rb $(USR_BIN)/codegen
	chmod 0755 $(USR_BIN)/codegen
	cp HELP $(ROOT-PATH)/HELP

install-licenses: $(LICENSES-PATH)
	cp -rv $(LICENSES)/* $(LICENSES-PATH)/

install-languages: $(LANGUAGES-PATH)
	cp -rv $(LANGUAGES)/* $(LANGUAGES-PATH)/

$(ROOT-PATH):
	mkdir -p $(ROOT-PATH)

$(TEMPLATES-PATH):
	mkdir -p $(TEMPLATES-PATH)

$(LICENSES-PATH):
	mkdir -p $(LICENSES-PATH)

$(LANGUAGES-PATH):
	mkdir -p $(LANGUAGES-PATH)