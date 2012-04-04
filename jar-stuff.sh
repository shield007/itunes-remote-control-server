#!/bin/bash

GEMS="etc"
GEMS="$GEMS sqlite3"
GEMS="$GEMS escape"
GEMS="$GEMS itunes-controller"

# Compile the gem
rake
if [ $? -ne 0 ] 
then
    exit 1
fi

# Create the jar
jruby -S gem install -i ./itunes-controller $GEMS --no-rdoc --no-ri
jar cf itunes-controller-dummy-server.jar -C itunes-controller .

rm -rf ./itunes-controller

# Display the results
jruby -ritunes-controller-dummy-server.jar -S gem list
