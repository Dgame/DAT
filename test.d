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

struct Bar {
	void useless() const {
		int test2;
	}
}

class FR;

int FR_global;

void FR_test() {
	int abc;
}

struct Heap {
	private import core.stdc.stdlib : malloc, realloc, free;
	private import core.stdc.string : memset;
	
	T[] allocate(T = void)(size_t bytes) {
		const size_t cap = bytes * T.sizeof;
		
		void* p = malloc(cap);
		debug writefln(" -> Allocate (ptr = %x) %d bytes on heap.", p, cap);
		
		if (p !is null) {
			memset(p, 0, cap);
			
			static if (is(T == void))
				return p[0 .. bytes];
			else
				return (cast(T*) p)[0 .. bytes];
		}
		
		return null;
	}
	
	void reallocate(T = void)(ref T[] arr, size_t bytes) {
		const size_t cap = arr.length + (bytes * T.sizeof);
		
		debug writefln(" -> Reallocate (ptr = %x) %d bytes on heap.", arr.ptr, cap);
		
		if (cap == 0 || cap >= int.max) {
			this.deallocate(arr);
			arr = null;
			
			return;
		}
		
		void* p = realloc(arr.ptr, cap);
		if (p !is null) {
			static if (is(T == void))
				arr = p[0 .. bytes];
			else
				arr = (cast(T*) p)[0 .. bytes];
		}
	}
	
	void deallocate(T = void)(ref T[] arr) {
		debug writefln(" -> Free (ptr = %x) %d bytes from heap.", arr.ptr, arr.length);
		free(arr.ptr);
		arr = null;
	}
}

struct Stack {
	void[4096] _buffer = void;
	size_t _length = 0;
	
	void[] take(size_t bytes) {
		if (this._length + bytes > this._buffer.length)
			return null;
		
		const size_t index = this._length;
		this._length += bytes;
		
		return this._buffer[index .. this._length];
	}
	
	size_t remain() const pure nothrow {
		return this._buffer.length - this._length;
	}
}

struct TempAlloc {
	private import core.stdc.stdlib : free;
	
	Heap _heap;
	Stack _stack;
	
	// TODO: improve
	void*[32] _ptrs = void;
	size_t _length = 0;
	
	@disable
	this(this);
	
	~this() {
		this.freeAll();
	}
	
	//private void _store(void* ptr) {
	//	if (this._length == this._ptrs.length) {
	//		free(ptr);
	//		this.freeAll();
			
	//		assert(0, "Out of memory.");
	//	}
		
	//	this._ptrs[this._length++] = ptr;
	//}
	
	//void freeAll() {
	//	debug writefln(" --> Free All (%d)", this._length);
		
	//	for (int i = cast(int)(this._length - 1); i >= 0; i--) {
	//		debug writefln(" -> Free (ptr = %x).", this._ptrs[i]);
	//		free(this._ptrs[i]);
	//	}
	//}
	
	//T[] allocate(T = void)(size_t bytes) {
	//	static if (is(T == void))
	//		void[] result = this._stack.take(bytes);
	//	else
	//		T[] result = cast(T[]) this._stack.take(bytes * T.sizeof);
		
	//	if (result.length != 0) {
	//		debug writefln(" --> Allocate %d bytes on the stack", bytes * T.sizeof);
			
	//		return result;
	//	}
		
	//	result = this._heap.allocate!T(bytes);
	//	if (result.length != 0)
	//		this._store(result.ptr);
		
	//	return result;
	//}
	
	//void reallocate(T = void)(ref T[] arr, size_t bytes) {
	//	void* pc = arr.ptr;
	//	this._heap.reallocate(arr, bytes);
		
	//	if (pc !is arr.ptr)
	//		this._store(arr.ptr);
	//}
	
	//void deallocate(T = void)(ref T[] arr) {
	//	this._heap.deallocate(arr);
	//}
}
