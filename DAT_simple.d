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

void foo2(in ref A a, bool inUse = false) {

}

void foo3(T)(T a) {

}

void foo4(Test temp = Test.Foo) {

}

class Foo(T, V) {
public:
	void foo(in ref Vector2!(T, V) vecT) {
	
	}
	
	void foo(in ref Vector2!(T) vecf) {
	
	}
}

void main() {
auto __tempRR0 = A();	foo1(__tempRR0);
auto __tempRR1 = A(42);	foo1(__tempRR1);
auto __tempRR2 = A(42,23);	foo2(__tempRR2);
	
	auto f = new Foo!(int, float)();
auto __tempRR3 = Vector2!(int,float)(42);	f.foo(__tempRR3);
auto __tempRR4 = Vector2!(float)(42);	f.foo(__tempRR4);
auto __tempRR5 = Vector2!float(42);	f.foo(__tempRR5);
	
	foo4(Test.Bar);
}