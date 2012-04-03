rake
jruby -S gem install -i ./itunes-controller etc sqlite3 escape itunes-controller --no-rdoc --no-ri
jar cf itunes-controller-dummy-server.jar -C itunes-controller .

rm -rf ./itunes-controller

jruby -ritunes-controller-dummy-server.jar -S gem list
