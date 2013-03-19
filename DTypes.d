module Puzzle.DTypes;

public import std.c.string : memcpy;

import Puzzle.DLexer : Loc, Token, Tok;
import Puzzle.DParser : Keyword;

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
	const_ 		= 1,		// type is const
	shared_		= 2,		// type is shared
	immutable_	= 4,		// type is immutable
	wild			= 8		// type is wild
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
	Token[] toks;
	
	this(ref const Loc loc, Token[] toks) {
		this.loc  = loc;
		this.toks = toks;
	}
	
	this(ref const Loc loc, ref const Token tok) {
		this.loc  = loc;
		this.toks ~= toks;
	}
	
	@property
	ref const(Token) type() const pure nothrow {
		return this.toks[0];
	}
	
	string toString() const pure nothrow {
		string output;
		foreach (ref const Token tok; this.toks)
			output ~= tok.toChars();
		
		return output;
	}
}

struct Decl {
public:
	const Loc loc;
	Mod mod;
	Identifier type;
	Identifier name;
	
	size_t inuse;
	
	this(ref const Loc loc) {
		this.loc = loc;
	}
}

struct AssignExp {
public:
	const Loc loc;
	const Decl decl;
	const Identifier value;
	
	this(ref const Loc loc, ref const Decl decl, ref const Identifier val) {
		this.loc = loc;
		this.decl = decl;
		this.value = val;
	}
}

struct Exp {
public:
	const Loc loc;
	const Decl decl;
	
	const Tok op;
	
	this(ref const Loc loc, ref const Decl decl, Tok op) {
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
	const Loc   loc;
	// const Token id; // auch als Identifier! Wegen Templates.
	const Identifier type;
	const Token var;
	Identifier* value;
	STC storage;
	
	this(ref const Loc loc, ref const Token tok, ref const Token val, STC stc) {
		this.type = Identifier(loc, tok);
		
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

// struct ParamExp {
// public:
	// const Loc loc;
	// Identifier* value;
	// bool isLvalue;
	
	// this(ref const Loc loc) {
		// this.loc = loc;
	// }
// }

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