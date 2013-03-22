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

void test(int i) in {

} out {

} body {

}

ref SysTime add(string units)(long value, AllowDayOverflow allowOverflow = AllowDayOverflow.yes) nothrow {

}

IntervalRange!(TP, Direction.fwd) fwdRange(TP delegate(in TP) func, PopFirst popFirst = PopFirst.no) const {
	
}

private alias std.string.indexOf stds_indexOf;
static alias std.string.indexOf stds_indexOf;
alias std.string.indexOf stds_indexOf;

void main(string*[][] args) {
auto __tempRR0 = A();  	foo1(__tempRR0);
auto __tempRR1 = A(42);  	foo1(__tempRR1);
auto __tempRR2 = A(42,23);  	foo2(__tempRR2);
	
auto __tempRR3 = A(42,23);  	foo12(__tempRR3,A(42));
	if (cond)
	{auto __tempRR4 = A(42);  foo13(A(42,23),__tempRR4);}
	
auto __tempRR5 = A(42); auto __tempRR6 = A(23,42);  	foo11(__tempRR5,__tempRR6);
auto __tempRR7 = A(42); auto __tempRR8 = A(42);  	foo11(__tempRR7,__tempRR8);
	A a2;
auto __tempRR9 = A(23);  	foo11(__tempRR9,a2);
	
auto __tempRR10 = Vector2!float(42);  	foo21(__tempRR10);
auto __tempRR11 = Vector2!(float)(42);  	foo21(__tempRR11);
	
	auto f = new Foo!(int, float)();
auto __tempRR12 = Vector2!(int,float)(42);  	f.foo(__tempRR12);
auto __tempRR13 = Vector2!(float)(42);  	f.foo(__tempRR13);
auto __tempRR14 = Vector2!float(42);  	f.foo(__tempRR14);
	
	foo4(Test.Bar);
	
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
	
	Foo!(int, float) ftpl;
	
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