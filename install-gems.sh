#!/bin/sh

echo "Installing GEMS....."

# Test GEMS
gem install yard rake test-unit rdoc 

# Runtime GEMS
gem install escape log4r json sequel

# Install native GEMS

ruby --version | grep -q jruby 
if [ $? -ne 0 ]
then
    gem install sqlite3
fi

