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
	foo1(A());
	foo1(A(42));
	foo2(A(42, 23));
	
	foo12(A(42, 23), A(42));
	foo13(A(42, 23), A(42));
	
	foo11(A(42), A(23, 42));
	foo11(A(42), A(42));
	A a2;
	foo11(A(23), a2);
	
	auto f = new Foo!(int, float)();
	f.foo(Vector2!(int, float)(42));
	f.foo(Vector2!(float)(42));
	f.foo(Vector2!float(42));
	
	foo4(Test.Bar);
}