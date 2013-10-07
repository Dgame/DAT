module test;

import std.stdio;
public {
	import std.file : read;
	import std.string : format, strip;
}
import std.array : split, join, empty;
import std.algorithm : startsWith, endsWith;
import std.c.string : memcpy;

bool isEmpty(string test) {
	return test.strip().empty();
}

private void _foo() { }

string fmt() {
	string str = "one\nnew line";

	{
		string str_;
		str = "abc";
	}

	void* p;
	std.c.string.memcpy(p, &str, str.sizeof);

	return format("%d.%d.%d", 0, 9, 9);
}

@property
const(string) bar() pure {
	return "";
}

void main() {

}