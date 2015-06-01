#!/bin/sh

echo "Installing GEMS....."

# Test GEMS
#gem install yard rake test-unit rdoc simplecov 

# Runtime GEMS
#gem install escape log4r json sequel
bundle install

# Install native GEMS

ruby --version | grep -q jruby 
if [ $? -ne 0 ]
then
    gem install sqlite3
fi

