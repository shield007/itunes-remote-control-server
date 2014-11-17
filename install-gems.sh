#!/bin/sh

echo "Installing GEMS....."

rvm info

# Test GEMS
gem install yard rake test-unit rdoc 

# Runtime GEMS
gem install escape sqlite3 log4r json sequel

