all: clean drwest.js

drwest.js:
	haxe drwest.hxml

clean:
	rm -f drwest.js
