DAT
===

<b>D</b> <b>A</b>nalysis <b>T</b>ool
<p>This project uses the Lexer and Parser of https://github.com/Hackerpilot/Dscanner</p>

Check your (named) imports on unused or under used.<br />

<hr />
Usage:
<pre>
--minImportUsage - The minimum of usage for imports. If this is deceeded, there is a warning.
-miu - the same
--minVarUsage - The minimum of usage for variables. If this is deceeded, there is a warning.
-mvu - the same
--quit - No warning for public or package imports/variables and for variables within a unittest.
-q - the same
</pre>
<hr />
test.d:
<pre>
module test;

import std.stdio;
public {
	import std.file : read, mkdir;
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
private:
	int id;
}

C[void*] c_map;

void main() {
	uint id = 0;
	id++;

	byte[] _buffer;
	_buffer = new byte[4];

	byte[byte*] bbmap;

	const uint msize = 42;
	void[] memory = new void[msize];
	assert(memory !is null);
}

debug {
	string outdir = "Debug";
} else {
	string outdir = "Release";
}

void unused() {
	if (!outdir)
		mkdir(outdir);
	else
		mkdir(outdir ~ "_New");
}

struct Foo {
	int foo1;

	enum : ubyte {
		Unused,
	} /// <--

	int foo2;
}
</pre>

Checked with:
<code>dat test.d -miu=2</code>

<pre>
 :: Check minimum import usage:
----
Warning:
test.d(5): Named import 'read' of module 'std.file' is never used.
But maybe the import is used outside, because it is marked as public.

Warning:
test.d(6): Named import 'format' of module 'std.string' is used only 1 times.
But maybe the import is used outside, because it is marked as public.

Warning:
test.d(6): Named import 'strip' of module 'std.string' is used only 1 times.
But maybe the import is used outside, because it is marked as public.

Warning:
test.d(8): Named import 'split' of module 'std.array' is never used.

Warning:
test.d(8): Named import 'join' of module 'std.array' is never used.

Warning:
test.d(8): Named import 'empty' of module 'std.array' is used only 1 times.

Warning:
test.d(9): Named import 'startsWith' of module 'std.algorithm' is never used.

Warning:
test.d(9): Named import 'endsWith' of module 'std.algorithm' is never used.

=> Therefore it is useless to import std.algorithm.

Warning:
test.d(10): Named import 'memcpy' of module 'std.c.string' is used only 1 times.


-------
9 occurrences in 1 files.
</pre>

And with <code>dat test.d -miu=2 -q</code>

<pre>
 :: Check minimum import usage:
----
Warning:
test.d(8): Named import 'split' of module 'std.array' is never used.

Warning:
test.d(8): Named import 'join' of module 'std.array' is never used.

Warning:
test.d(8): Named import 'empty' of module 'std.array' is used only 1 times.

Warning:
test.d(9): Named import 'startsWith' of module 'std.algorithm' is never used.

Warning:
test.d(9): Named import 'endsWith' of module 'std.algorithm' is never used.

=> Therefore it is useless to import std.algorithm.

Warning:
test.d(10): Named import 'memcpy' of module 'std.c.string' is used only 1 times.


-------
6 occurrences in 1 files.
</pre>

And for std/stdio.d checked with:
<code>dat D:/D/dmd2/src/phobos/std/stdio.d -miu=2</code>

<pre>
Warning:
D:/D/dmd2/src/phobos/std/stdio.d(35): Named import 'FHND_WCHAR' of module 'std.c.stdio' is used only 1 times.

Warning:
D:/D/dmd2/src/phobos/std/stdio.d(3145): Named import 'memcpy' of module 'core.stdc.string' is used only 1 times.
But maybe the import is used outside, because it is marked as public.
</pre>

And finally a test for unused/underused variables with <code>dat test.d -mvu=1</code>
<pre>
 :: Check minimum variable usage:
----
Warning:
test.d(17): Variable 'arr' of type int[] is never used.

Warning:
test.d(18): Variable 'arrs' of type int[4] is never used.

Warning:
test.d(19): Variable 'arrt' of type int[int] is never used.

Warning:
test.d(20): Variable 'arrt2' of type int[ulong] is never used.

Warning:
test.d(27): Variable 'str_' of type string is never used.

Warning:
test.d(44): Variable 'id' of type int is never used.

Warning:
test.d(47): Variable 'c_map' of type void* is never used.

Warning:
test.d(56): Variable 'bbmap' of type byte[byte*] is never used.

Warning:
test.d(77): Variable 'foo1' of type int is never used.
But maybe it is used outside, because it is marked as public.

Warning:
test.d(83): Variable 'foo2' of type int is never used.
But maybe it is used outside, because it is marked as public.

-------
10 occurrences in 1 files.
</pre>

And with <code>dat test.d -mvu=1 -q</code>

<pre>
 :: Check minimum variable usage:
----
Warning:
test.d(17): Variable 'arr' of type int[] is never used.

Warning:
test.d(18): Variable 'arrs' of type int[4] is never used.

Warning:
test.d(19): Variable 'arrt' of type int[int] is never used.

Warning:
test.d(20): Variable 'arrt2' of type int[ulong] is never used.

Warning:
test.d(27): Variable 'str_' of type string is never used.

Warning:
test.d(44): Variable 'id' of type int is never used.

Warning:
test.d(47): Variable 'c_map' of type void* is never used.

Warning:
test.d(56): Variable 'bbmap' of type byte[byte*] is never used.

-------
8 occurrences in 1 files.
</pre>
