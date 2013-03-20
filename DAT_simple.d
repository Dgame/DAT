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
auto __tempRR0 = A();  foo1(__tempRR0);
auto __tempRR1 = A(42);  foo1(__tempRR1);
auto __tempRR2 = A(42,23);  foo2(__tempRR2);
	
auto __tempRR3 = A(42,23);  foo12(__tempRR3, A(42));
auto __tempRR4 = A(42);  foo13(A(42,23), __tempRR4);
	
auto __tempRR5 = A(42); auto __tempRR6 = A(23,42);  foo11(__tempRR5, __tempRR6);
auto __tempRR7 = A(42); auto __tempRR8 = A(42);  foo11(__tempRR7, __tempRR8);
	A a2;
auto __tempRR9 = A(23);  foo11(__tempRR9);
	
	auto f = new Foo!(int, float)();
auto __tempRR10 = Vector2!(int,float)(42);  foo(__tempRR10);
auto __tempRR11 = Vector2!(float)(42);  foo(__tempRR11);
auto __tempRR12 = Vector2!float(42);  foo(__tempRR12);
	
	foo4(Test.Bar);
}