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
void foo(in ref A a) {

}

void foo(in ref A a, bool inUse = false) {

}

void foo(T)(T a) {

}

void foo(Test temp = Test.Foo) {

}

class Foo(T, V) {
public:
	void foo(in ref Vector2!(T, V) vecT) {
	
	}
	
	void foo(in ref Vector2!(T) vecf) {
	
	}
}

void main() {
	foo(A());
	foo(A(42));
	foo(A(42, 23));
	
	auto f = new Foo!(int, float)();
	f.foo(Vector2!(int, float)(42));
	f.foo(Vector2!(float)(42));
	f.foo(Vector2!float(42));
	
	foo(Test.Bar);
}