#!/bin/sh

echo "Installing GEMS....."

rvm info

gem install yard rake test-unit rdoc
gem install escape sqlite3 log4r json
gem install sequel

