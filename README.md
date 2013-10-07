DAT
===

<b>D</b> <b>a</b>nalysis <b>t</b>ool
<p>This project uses the Lexer and Parser of https://github.com/Hackerpilot/Dscanner</p>

Check your (named) imports on unused or under used.<br />

<hr />
Usage:
<pre>
--minImportUsage - The minimum of usage for the imports. If this is exceeded, there is a warning.
-miu - the same
--quit - No warning for public or package imports
-q - the same
</pre>
<hr />
test.d:
<pre>
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
</pre>

Checked with:
<code>dat test.d -miu=2</code>

<pre>
 > File test.d
Warning:
Named import read of module std.file imported on line 5 is never used.
But maybe the import is used outside, because it is marked with public.

Warning:
Named import format of module std.string imported on line 6 is used only 1 times
.
But maybe the import is used outside, because it is marked with public.

Warning:
Named import strip of module std.string imported on line 6 is used only 1 times.

But maybe the import is used outside, because it is marked with public.

Warning:
Named import split of module std.array imported on line 8 is never used.

Warning:
Named import join of module std.array imported on line 8 is never used.

Warning:
Named import empty of module std.array imported on line 8 is used only 1 times.

Warning:
Named import startsWith of module std.algorithm imported on line 9 is never used.

Warning:
Named import endsWith of module std.algorithm imported on line 9 is never used.

=> Therefore it is useless to import std.algorithm.

Warning:
Named import memcpy of module std.c.string imported on line 10 is used only 1 times.
</pre>

And with <code>dat test.d -miu=2 -q</code>

<pre>
 > File test.d
Warning:
Named import split of module std.array imported on line 8 is never used.

Warning:
Named import join of module std.array imported on line 8 is never used.

Warning:
Named import empty of module std.array imported on line 8 is used only 1 times.

Warning:
Named import startsWith of module std.algorithm imported on line 9 is never used.

Warning:
Named import endsWith of module std.algorithm imported on line 9 is never used.

=> Therefore it is useless to import std.algorithm.

Warning:
Named import memcpy of module std.c.string imported on line 10 is used only 1 times.
</pre>

And for std/stdio.d checked with:
<code>dat D:/D/dmd2/src/phobos/std/stdio.d -miu=2</code>

<pre>
 > File D:/D/dmd2/src/phobos/std/stdio.d
Warning:
Named import FHND_WCHAR of module std.c.stdio imported on line 35 is used only 1 times.

</pre>
