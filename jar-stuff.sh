#!/bin/bash

source ~/.rvm/environments/jruby-1.7.9@itunes-controller

GEMS=""
#GEMS="$GEMS sqlite3"
GEMS="$GEMS escape"
GEMS="$GEMS log4r"
GEMS="$GEMS json"
GEMS="$GEMS itunes-controller"

export JRUBY_ARGS="--1.9"
export JRUBY_OPTS="--1.9"
#export JRUBY_OPTS="--1.9 -Xcext.enabled=true"

# Compile the gem
rm *.gem
jruby $JRUBY_ARGS -S rake gem
if [ $? -ne 0 ] 
then
    exit 1
fi

# Create the jar
jruby  $JRUBY_ARGS -S gem install -i ./itunes-controller $GEMS --no-rdoc --no-ri
jar cf itunes-controller-dummy-server.jar -C itunes-controller .

rm -rf ./itunes-controller

# Display the results
jruby $JRUBY_ARGS -ritunes-controller-dummy-server.jar -S gem list
