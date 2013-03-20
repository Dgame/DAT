struct A { }

/**
 A is light, so it will be converted to:
*/
void foo1(A a) {

}
/** ---- */

void bar1(A a) {

}

void quatz1(ref const A a) {

}

struct B {
public:
	int[1024] _arr;
}


/**
 B is _not_ light, so it will be converted to:
*/
void foo2(ref B b) {

}
/** ---- */

void bar2(B b) {

}

void quatz2(ref const B b) {

}

ref ubyte diesist_ein_Test(T)(T val) pure const {
	return 42;
}

B getB() {
	return B();
}

void main() {
	foo1(A()); // normal D behaviour: move
	A a;
	foo1(a); 
	/// would be converted to:
	foo1(std.algorithm.move(a));
	// ----
	
	bar1(A()); // normal D behaviour: move
	A a;
	bar1(a); // normal D behaviour: copy
	
	quatz1(A()); // normal D behaviour: Error, A() is not an lvalue
	A a;
	quatz1(a); // normal D behaviour: by ref
	
	foo2(B());
	/// would be converted to:
	auto __temp1234 = B();
	foo2(__temp1234);
	// ----
	
	A a;
	foo2(a); // normal D behaviour: by ref
	
	bar2(A()); // normal D behaviour: move
	A a;
	bar2(a); // normal D behaviour: copy
	
	quatz2(A()); // normal D behaviour: Error, A() is not an lvalue
	A a;
	quatz2(a); // normal D behaviour: by ref
	
	if (a && b) {
	
	}
	
	auto foo1 = "foobar"w;
	auto foo2 = d"foobar";
	const string test = "dies.ist-ein.test";
	
	&|
	
	const int value;
	
	this(int value)
	{
		this.value = value;
	}
	
	void* ptr;
	auto cd = 'a';
	auto cw = 'b';
	alias void* FPHANDLE;
	
	if (day == 0)
	{
		short _year = cast(short)(years - 1);
		Month _month = Month.dec;
		byte _day = 31;
	}
	
	void roll(string units, U, V)(long value, AllowDayOverflow allowOverflow = AllowDayOverflow.yes) nothrow
        if(units == "years")
    {
        add!"years"(value, allowOverflow);
    }
	
	/**
	Was
	ist
	das
	denn?
	**/
	bool contains(in PosInfInterval!TP interval) const pure
    {
        _enforceNotEmpty();

        return false;
    }
	
	// Test #1
	string toString() const
	{
		return to!string(value);
	}
	
	if (!false) {
	
	}
}