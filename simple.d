struct A { }

enum Test {
	Foo,
	Bar
}

struct Vector2(T) {

}

/**
 A is light, so it will be converted to:
*/
void foo1(in ref A a) {

}

void foo11(in ref A a, in ref A a) {

}

void foo12(in ref A a, A a) {

}

void foo13(A a, in ref A a) {

}

void foo2(in ref A a, bool inUse = false) {

}

void foo21(ref const Vector!(float) vf) {

}

void foo3(T)(T a) {

}

void foo4(Test temp = Test.Foo) {

}

struct Foo(T, V) {
public:
	void foo(in ref Vector2!(T, V) vecT) {
	
	}
	
	void foo(in ref Vector2!(T) vecf) {
	
	}
}

Foo!(int, float) getFoo() {

}

@safe
static TickDuration currSystemTick()
{
	return TickDuration.currSystemTick;
}

static SysTime currTime(immutable TimeZone tz = LocalTime())
{
	return SysTime(currStdTime, tz);
}

void test(int i) in {

} out {

} body {

}

struct IntWrapper
{
	int value;

	this(int value)
	{
		this.value = value;
	}

	IntWrapper opOpAssign(string op)(IntWrapper rhs)
	{
		mixin("this.value " ~ op ~ "= rhs.value;");

		return this;
	}

	string toString() const
	{
		return to!string(value);
	}
}

class Foo {
public:
	bool init;
	
	void init() {
		this.init = true;
	}
}

ref SysTime add(string units)(long value, AllowDayOverflow allowOverflow = AllowDayOverflow.yes) nothrow {

}

IntervalRange!(TP, Direction.fwd) fwdRange(TP delegate(in TP) func, PopFirst popFirst = PopFirst.no) const {
	
}

private alias std.string.indexOf stds_indexOf;
static alias std.string.indexOf stds_indexOf;
alias std.string.indexOf stds_indexOf;

void main(string*[][] args) {
	foo1(A());
	foo1(A(42));
	foo2(A(42, 23));
	
	foo12(A(42, 23), A(42));
	if (cond)
	{ foo13(A(42, 23), A(42)); }
	
	foo11(A(42), A(23, 42));
	foo11(A(42), A(42));
	A a2;
	foo11(A(23), &a2);
	
	foo21(Vector2!float(42));
	foo21(Vector2!(float)(42));
	
	auto f = new Foo!(int, float)();
	f.foo(Vector2!(int, float)(42));
	f.foo(Vector2!(float)(42));
	f.foo(Vector2!float(42));
	
	foo4(Test.Bar);
	
	int i;
	while (i = fgets()) {
	
	}
	
	for (int c; (c = FGETWC(fp)) != -1; ) { }
	
	L1:
	auto app = appender(buf);
	app.clear();
	if(app.capacity == 0)
		app.reserve(128); // get at least 128 bytes available

	int c;
	while((c = FGETC(fp)) != -1) {
		app.put(cast(char) c);
		if(c == terminator) {
			buf = app.data;
			return buf.length;
		}
	}
	
	string foo;
	
	int f = 42;
	test(f);
	test(42);
	test(42 + 1);
	test(year * -1);
	test((year * -1) + 1);
	
	Vector!(int) vi1;
	Vector!int vi2;
	Vector!(float) vf;
	
	foo = "abc";
	f += 2;
	f = 3;
	
	Foo!(int, float) ftpl;
	
	static bool _initialized;

	//TODO Make this use double-checked locking once shared has been fixed
	//to use memory fences properly.
	if(!_initialized) {
	{
		if(!_utc)
			_utc = cast(shared UTC)new immutable(UTC)();

		_initialized = true;
	}

	return convert!("seconds", "hnsecs")(ts.tv_sec) +
                       ts.tv_nsec / 100 +
                       hnsecsToUnixEpoch;
	
	PosInfInterval!TP  _interval;
	
	auto dstr = to!dstring(strip(isoExtString));

	auto tIndex = dstr.stds_indexOf("T");
	enforce(tIndex != -1, new DateTimeException(format("Invalid ISO Extended String: %s", isoExtString)));

	auto found = dstr[tIndex + 1 .. $].find(".", "Z", "+", "-");
	auto dateTimeStr = dstr[0 .. $ - found[0].length];

	dstring fracSecStr;
	dstring zoneStr;

	if(found[1] != 0)
	{
		if(found[1] == 1)
		{
			auto foundTZ = found[0].find("Z", "+", "-");

			if(foundTZ[1] != 0)
			{
				fracSecStr = found[0][0 .. $ - foundTZ[0].length];
				zoneStr = foundTZ[0];
				
				_interval = 42;
			}
			else
				fracSecStr = found[0];
		}
		else
			zoneStr = found[0];
	}
}