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
	property 	= 0x4000,
	trusted 	= 0x8000,
	safe 		= 0x10000,
	disable 	= 0x20000,
	system		= 0x40000
}

string toStr(const STC stc) {
	string output;
	
	if (stc & STC.none)
		output ~= "none ";
	
	if (stc & STC.const_)
		output ~= "const ";
	
	if (stc & STC.immutable_)
		output ~= "immutable ";
	
	if (stc & STC.ref_)
		output ~= "ref ";
	
	if (stc & STC.out_)
		output ~= "out ";
	
	if (stc & STC.scope_)
		output ~= "scope ";
	
	if (stc & STC.lazy_)
		output ~= "lazy ";
	
	if (stc & STC.shared_)
		output ~= "shared ";
	
	if (stc & STC.wild)
		output ~= "inout ";
	
	return output;
}

Tok isNext(ref const Token[] toks, size_t i) pure nothrow {
	return i < toks.length ? toks[i].type : Tok.None;
}

struct Identifier {
public:
	const Loc loc;
	const string id; /// preferred
	Token[] toks;
	
	bool isDelegate;
	
	this(ref const Loc loc, Token[] toks) {
		this.loc  = loc;
		this.toks = toks;
	}
	
	this(ref const Loc loc, ref Token tok) {
		this.loc  = loc;
		this.toks ~= tok;
	}
	
	this(ref const Loc loc, string id) {
		this.loc = loc;
		this.id  = id;
	}
	
	this(ref Identifier id) {
		this.loc  = id.loc;
		this.toks = id.toks;
		this.isDelegate = id.isDelegate;
	}
	
	string toString() const pure nothrow {
		if (this.id.length != 0)
			return this.id;
		
		string output = "";
		foreach (size_t i, ref const Token tok; this.toks) {
			output ~= tok.toChars();
			if (this.isDelegate && tok == Tok.Identifier 
				&& isNext(this.toks, i + 1) == Tok.Identifier)
			{
				output ~= ' ';
			}
		}
		
		return output;
	}
}

struct VarDecl {
public:
	const Loc loc;
	const Mod mod;
	const string name;
	Identifier* type;
	
	size_t inuse;
	
	this(ref const Loc loc, string name, Mod mod = Mod.none) {
		this.loc = loc;
		this.name = name;
		this.mod = mod;
	}
	
	string toString(bool noSem = false) const {
		string end = noSem ? "" : ";";
		
		if (this.mod == Mod.none) {
			return this.type.toString() ~ ' ' ~ this.name ~ end;
		}
		
		return to!(string)(this.mod) ~ ' ' ~ this.type.toString() ~ ' ' ~ this.name ~ end;
	}
}

struct AssignExp {
public:
	const Loc loc;
	/*const */VarDecl varDecl;
	const Identifier value;
	
	this(ref const Loc loc, ref VarDecl vdecl, ref const Identifier val) {
		this.loc = loc;
		this.varDecl = vdecl;
		this.value = val;
		
		this.varDecl.inuse += 1;
	}
	
	this(ref const Loc loc, ref VarDecl vdecl, const Identifier val) {
		this(loc, vdecl, val);
	}
	
	string toString() const {
		return this.varDecl.toString(true) ~ " = " ~ this.value.toString() ~ ';';
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
	const Identifier* id;
	// STC storage;
	
	this(const Keyword* kw, const Identifier* id) {
		this.kw = kw;
		this.id = id;
	}
}

struct ParamDecl {
public:
	const Loc loc;
	/// auch als Identifier, wegen Templates.
	const Identifier type;
	const string var;
	Identifier* value;
	STC storage;
	
	this(ref const Loc loc, ref Token tok, string var, STC stc) {
		this.type = Identifier(loc, tok);
		// writeln(" :: ", this.type.toString(), " <-> ", var.toChars());
		this.loc = loc;
		this.var = var;
		this.storage = stc;
	}
	
	this(ref const Loc loc, ref const Identifier id, string var, STC stc) {
		// writeln(" :: ", id.toString(), " <-> ", var.toChars());
		this.loc = loc;
		this.type = id;
		this.var = var;
		this.storage = stc;
	}
	
	string toString() const {
		string output = toStr(this.storage) ~ this.type.toString() ~ ' ' ~ this.var;
		if (this.value)
			output ~= " = " ~ this.value.toString();
		
		return output;
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
		return id !is null ? id.toString() : "Undefinied ID";
	}
}

struct FuncCall {
public:
	const Loc loc;
	const string name;
	ParamExp[] pexp;
	
	this(ref const Loc loc, string name) {
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
	const string name;
	ParamDecl[] params;
	FMod fmod;
	
	this(ref const Loc loc, ref const RetType rt, ref const Token id) {
		this.loc = loc;
		this.rt = rt;
		this.name = cast(string) id.toChars();
	}
	
	string toString() const {
		string output = this.rt.id.toString() ~ ' ' ~ this.name ~ '(';
		foreach (size_t i, ref const ParamDecl pd; this.params) {
			output ~= pd.toString() ~ ((i + 1) < this.params.length ? "," : "");
		}
		
		return output ~ ");";
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