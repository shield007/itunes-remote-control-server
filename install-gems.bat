@echo off

echo "Installing GEMS....."

echo "Test GEMS"
gem install yard rake test-unit rdoc 

echo "Runtime GEMS"
gem install escape log4r json sequel

echo "Install native GEMS"
gem install sqlite3

