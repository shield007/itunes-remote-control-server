@echo off

echo "Installing GEMS....."

REM Test GEMS
gem install yard rake test-unit rdoc 

REM Runtime GEMS
gem install escape log4r json sequel

REM Install native GEMS
gem install sqlite3

