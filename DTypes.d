module Dat.DTypes;

import std.stdio;
import std.conv : to;
public import std.c.string : memcpy;

import Dat.DLexer : Loc, Token, Tok;
import Dat.DParser : Keyword;

/*
enum Protection {
	undefined,
	none,           // no access
	private_,
	package_,
	protected_,
	public_,
	export_,
}
*/

enum STC {
	none 		= 1,
	const_ 	= 2,
	immutable_ = 4,
	ref_ 		= 8,
	out_ 		= 0x10,
	scope_ 	= 0x20,
	lazy_ 		= 0x40,
	shared_ 	= 0x80,
	wild 		= 0x100
}

enum Mod {
	none			= 1,
	const_ 		= 2,		// type is const
	shared_		= 4,		// type is shared
	immutable_	= 8,		// type is immutable
	wild			= 0x10		// type is wild
}

enum FMod {
	none 		= 1,
	pure_ 		= 2,
	nothrow_ 	= 4,
	const_ 	= 8,
	immutable_ = 0x10,
	wild 		= 0x20,
	// ref_ 		= 0x40,
	// deprecated_ = 0x80,
	// static_ 	= 0x100,
	// extern_ 	= 0x200,
	// final_ 		= 0x400,
	// synchronized_ = 0x800,
	// override_ 	= 0x1000,
	// abstract_ 	= 0x2000,
	// property 	= 0x4000,
	// trusted 	= 0x8000,
	// safe 		= 0x10000,
	// disable 	= 0x20000
}

struct Identifier {
public:
	const Loc loc;
	const string id; /// preferred
	const(Token)[] toks;
	
	this(ref const Loc loc, Token[] toks) {
		this.loc  = loc;
		this.toks = toks;
	}
	
	this(ref const Loc loc, ref const Token tok) {
		this.loc  = loc;
		this.toks ~= tok;
	}
	
	this(ref const Loc loc, string id) {
		this.loc = loc;
		this.id  = id;
	}
	
	this(ref const Identifier id) {
		this.loc  = id.loc;
		this.toks = id.toks;
	}
	
	@property
	ref const(Token) type() const pure nothrow {
		return this.toks[0];
	}
	
	string toString() const pure nothrow {
		if (this.id.length != 0)
			return this.id;
		
		string output;
		foreach (ref const Token tok; this.toks)
			output ~= tok.toChars();
		
		return output;
	}
}

struct VarDecl {
public:
	const Loc loc;
	Mod mod;
	Identifier* type;
	Identifier* name;
	
	size_t inuse;
	
	this(ref const Loc loc) {
		this.loc = loc;
	}
	
	string toString(bool noSem) const {
		string end = noSem ? "" : ";";
		
		if (this.mod == Mod.none) {
			return this.type.toString() ~ ' ' ~ this.name.toString() ~ end;
		}
		
		return to!(string)(this.mod) ~ ' ' ~ this.type.toString() ~ ' ' ~ this.name.toString() ~ end;
	}
}

struct AssignExp {
public:
	const Loc loc;
	const VarDecl decl;
	const Identifier value;
	
	this(ref const Loc loc, ref const VarDecl decl, ref const Identifier val) {
		this.loc = loc;
		this.decl = decl;
		this.value = val;
		
		this.decl.inuse += 1;
	}
	
	string toString() const {
		return this.decl.toString(true) ~ " = " ~ this.value.toString() ~ ';';
	}
}

struct Exp {
public:
	const Loc loc;
	const VarDecl decl;
	
	const Tok op;
	
	this(ref const Loc loc, ref const VarDecl decl, Tok op) {
		this.loc = loc;
		
		this.decl = decl;
		this.op = op;
	}
}

struct RetType {
public:
	const Keyword* kw;
	const Token id;
	// STC storage;
}

struct ParamDecl {
public:
	const Loc loc;
	// const Token id; // auch als Identifier! Wegen Templates.
	const Identifier type;
	const Token var;
	Identifier* value;
	STC storage;
	
	this(ref const Loc loc, ref const Token tok, ref const Token var, STC stc) {
		this.type = Identifier(loc, tok);
		//writeln(" :: ", this.type.toString());
		
		this.loc = loc;
		this.var = var;
		this.storage = stc;
	}
	
	this(ref const Loc loc, ref const Identifier id, ref const Token val, STC stc) {
		this.loc = loc;
		this.type = id;
		this.var = var;
		this.storage = stc;
	}
}

struct ParamExp {
public:
	const Loc loc;
	Identifier* id;
	bool isLvalue;
	
	this(ref const Loc loc) {
		this.loc = loc;
	}
	
	string toString() const pure nothrow {
		return id !is null ? id.toString() : "None";
	}
}

struct FuncCall {
public:
	const Loc loc;
	const string name;
	ParamExp[] pexp;
	
	this(ref const Loc loc, const char[] name) {
		this.loc = loc;
		this.name = cast(string) name;
	}
	
	string toString() const pure nothrow {
		string output = this.name ~ '(';
		foreach (size_t i, ref const ParamExp pe; this.pexp) {
			output ~= pe.toString() ~ ((i + 1) < this.pexp.length ? "," : "");
		}
		
		return output ~ ");";
	}
}

struct FuncDecl {
public:
	const Loc loc;
	const RetType rt;
	const Token name;
	ParamDecl[] params;
	FMod fmod;
	
	this(ref const Loc loc, ref const RetType rt, ref const Token id) {
		this.loc = loc;
		this.rt = rt;
		this.name = id;
	}
}

struct Struct {
public:
	const Loc loc;
	const Token tok;
	
	this(ref const Loc loc, ref const Token tok) {
		this.loc = loc;
		this.tok = tok;
	}
}