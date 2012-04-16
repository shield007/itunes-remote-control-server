#!/bin/bash

GEMS=""
GEMS="$GEMS sqlite3"
GEMS="$GEMS escape"
GEMS="$GEMS itunes-controller"

JRUBY_ARGS="--1.9"

# Compile the gem
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
