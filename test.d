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

private void _foo() {
	int[] arr;
	int[4] arrs;
	int[int] arrt;
	int[ulong] arrt2;
}

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

struct C {
	int id;
}

C[void*] c_map;

void main() {
	uint id = 0;
	id++;

	byte[] _buffer;
	_buffer = new byte[4];

	byte[byte*] bbmap;
}