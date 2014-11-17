# iTunes Remote Control Server 

This is a project to create make it possible to control enable iTunes to be operated 
on a headless server without the GUI. It provides a TCP server which can be connected 
to locally or remote by other applications to control iTunes.

The server only currently runs on Mac OSX It's written in such a way that if someone 
knows how to script iTunes from ruby on windows, then windows support could be added.

## Features

* Provides a remote control server TCP server
* Provides scripts to interact with iTunes without using the TCP server.
* Able to add, remove and refresh tracks.
* Able to to list and remove dead tracks.
* Keeps a sqlite3 database in sync with the iTunes library to make operations very quick.
* Can Be used with Windows or Mac OSX versions of iTunes.

## Requirments

* iTunes (latest)
* MacOS X
* Mac Ruby

## Installation

Instructions for install on different platforms can be found on the wiki.

* [Windows Install Instuctions](https://github.com/shield007/itunes-remote-control-server/wiki/Windows-Install-Instructions)
* [Max OSX Install Instructions](https://github.com/shield007/itunes-remote-control-server/wiki/Max-OSX-Install-Instructions)

## Building

If you need to rebuild gem and run all the tests, then from a terminal change to the project directory and type:

rake

## Configuration

[Server Configration] (https://github.com/shield007/itunes-remote-control-server/wiki/Server-Configuration)

## Using

TBD

[![Analytics](https://ga-beacon.appspot.com/UA-5774405-9/itunes-remote-control-server/Readme)](https://github.com/igrigorik/ga-beacon) [ ![Codeship Status for shield007/itunes-remote-control-server](https://codeship.com/projects/3f0d8e30-5066-0132-ad3b-661f60be2436/status)](https://codeship.com/projects/48011)
