#!/bin/sh

echo "Installing GEMS....."

# Test GEMS
gem install yard rake test-unit rdoc 

# Runtime GEMS
gem install escape log4r json sequel

# Install native GEMS
if [ "`ruby --version | grep -q jruby`" -ne "0" ] 
then
    gem install sqlite3
fi

