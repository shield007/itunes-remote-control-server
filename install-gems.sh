#!/bin/sh

echo "Installing GEMS....."

gem install yard rake test-unit rdoc
gem install escape sqlite3 log4r json
gem install sequel

