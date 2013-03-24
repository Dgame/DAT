module Dat.DParser;

import std.stdio;
import std.algorithm : popFront, popBack, back, splitter, canFind;
import std.conv : to;

import Dat.DLexer;
import Dat.DTypes;

enum KeyTok {
	This,
	Super,
	Assert,
	Null,
	True,
	False,
	Cast,
	New,
	Delete,
	Throw,
	Module,
	Pragma,
	Typeof,
	Typeid,

	Template,

	Void,
	Int8,
	Uint8,
	Int16,
	Uint16,
	Int32,
	Uint32,
	Int64,
	Uint64,
	Int128,
	Uint128,
	Float32,
	Float64,
	Float80,

	Bool,
	Char,
	Wchar,
	Dchar,

	Imaginary32,
	Imaginary64,
	Imaginary80,

	Complex32,
	Complex64,
	Complex80,

	Delegate,
	Function,
	
	String,

	Is,
	If,
	Else,
	While,
	For,
	Do,
	Switch,
	Case,
	Default,
	Break,
	Continue,
	Synchronized,
	Return,
	Goto,
	Try,
	Catch,
	Finally,
	With,
	Asm,
	Foreach,
	Foreach_reverse,
	Scope,

	Struct,
	Class,
	Interface,
	Union,
	Enum,
	Import,
	Mixin,
	Static,
	Final,
	Const,
	Typedef,
	Alias,
	Override,
	Abstract,
	Volatile,
	Vebug,
	Deprecated,
	In,
	Out,
	Inout,
	Lazy,
	Auto,

	Align,
	Extern,
	Private,
	Package,
	Protected,
	Public,
	Export,

	Body,
	Invariant,
	Unittest,
	Version,
	//manifest,

	// Added after 1.0
	argTypes,
	parameters,
	Ref,
	Macro,
	Pure,
	Nothrow,
	Gshared,
	Traits,
	Vector,
	Overloadset,
	File,
	Line,
	modulestring,
	funcstring,
	prettyfunc,
	Shared,
	Immutable
}

struct Keyword {
public:
	const string name;
	const KeyTok tok;
	const bool isBasicType;
}

private static const Keyword[][256] keywords = [
	[
		{	"__argTypes",		KeyTok.argTypes		},
		{	"__parameters",	KeyTok.parameters	},
		{	"__gshared",		KeyTok.Gshared		},
		{	"__traits",		KeyTok.Traits			},
		{	"__vector",		KeyTok.Vector			},
		{	"__overloadset",	KeyTok.Overloadset	},
		{	"__FILE__",		KeyTok.File			},
		{	"__LINE__",		KeyTok.Line			},
		{	"__MODULE__",		KeyTok.modulestring	},
		{	"__FUNCTION__",	KeyTok.funcstring	},
		{	"__PRETTY_FUNCTION__",	KeyTok.prettyfunc	}
	],
	[
		{	"abstract",	KeyTok.Abstract	},
		{	"assert",		KeyTok.Assert		},
		{	"asm",			KeyTok.Asm		},
		{	"alias",		KeyTok.Alias		},
		{	"auto",		KeyTok.Auto		},
		{	"align",		KeyTok.Align		}
	],
	[
		{	"byte",		KeyTok.Int8,	true	},
		{	"bool",		KeyTok.Bool,	true	},
		{	"break",		KeyTok.Break			},
		{	"body",		KeyTok.Body			},
	],
	[
		{	"cast",		KeyTok.Cast		},
		{	"cent",	 	KeyTok.Int128,		true	},
		{	"char",		KeyTok.Char,			true	},
		{	"cfloat",		KeyTok.Complex32,	true	},
		{	"cdouble",	KeyTok.Complex64,	true	},
		{	"creal",		KeyTok.Complex80,	true	},
		{	"case",		KeyTok.Case		},
		{	"catch",		KeyTok.Catch		},
		{	"continue",	KeyTok.Continue	},
		{	"class",		KeyTok.Class		},
		{	"const",		KeyTok.Const		}
	],
	[
		{	"delete",		KeyTok.Delete			},
		{	"double",		KeyTok.Float64,	true	},
		{	"dchar",		KeyTok.Dchar,		true	},
		{	"delegate",	KeyTok.Delegate		},
		{	"do",			KeyTok.Do				},
		{	"default",	KeyTok.Default		},
		{	"debug",		KeyTok.Vebug			},
		{	"deprecated",	KeyTok.Deprecated	}
	],
	[
		{	"else",		KeyTok.Else		},
		{	"enum",		KeyTok.Enum		},
		{	"extern",		KeyTok.Extern		},
		{	"export",		KeyTok.Export		}
	],
	[
		{	"false",		KeyTok.False		},
		{	"float",		KeyTok.Float32,	true	},
		{	"function",	KeyTok.Function	},
		{	"for",			KeyTok.For		},
		{	"finally",	KeyTok.Finally	},
		{	"foreach",	KeyTok.Foreach	},
		{	"foreach_reverse",	KeyTok.Foreach_reverse	},
		{	"final",		KeyTok.Final		}
	],
	[
		{	"goto",		KeyTok.Goto		},
	],
		null,
	[
		{	"int",	 		KeyTok.Int32,			true	},
		{	"ifloat",		KeyTok.Imaginary32,	true	},
		{	"idouble",	KeyTok.Imaginary64,	true	},
		{	"ireal",		KeyTok.Imaginary80,	true	},
		{	"is",			KeyTok.Is			},
		{	"if",			KeyTok.If			},
		{	"interface",	KeyTok.Interface	},
		{	"import",		KeyTok.Import		},
		{	"in",			KeyTok.In			},
		{	"inout",		KeyTok.Inout		},
		{	"immutable",	KeyTok.Immutable	},
		{	"invariant",	KeyTok.Invariant	},
	],
		null,
		null,
	[
		{	"long",	 	KeyTok.Int64,		true	},
		{	"lazy",		KeyTok.Lazy				},
	],
	[
		{	"module",		KeyTok.Module		},
		{	"mixin",		KeyTok.Mixin		},
		{	"macro",		KeyTok.Macro		}
		// { "manifest",	 KeyTok.manifest	},
	],
	[
		{	"null",		KeyTok.Null 		},
		{	"new",			KeyTok.New		},
		{	"nothrow",	KeyTok.Nothrow	}
	],
	[
		{	"override",	KeyTok.Override	},
		{	"out",			KeyTok.Out		},
	],
	[
		{	"pragma",		KeyTok.Pragma		},
		{	"private",	KeyTok.Private	},
		{	"package",	KeyTok.Package	},
		{	"protected",	KeyTok.Protected	},
		{	"public",		KeyTok.Public		},
		{	"pure",		KeyTok.Pure		}
	],
		null,
	[
		{	"real",		KeyTok.Float80,	true	},
		{	"return",		KeyTok.Return				},
		{	"ref",			KeyTok.Ref				}
	],
	[
		{	"super",		KeyTok.Super				},
		{	"short",		KeyTok.Int16,		true	},
		{	"string",		KeyTok.String,	true	},
		{	"switch",		KeyTok.Switch				},
		{	"synchronized",	KeyTok.Synchronized	},
		{	"scope",		KeyTok.Scope				},
		{	"struct",		KeyTok.Struct				},
		{	"static",		KeyTok.Static				},
		{	"shared",		KeyTok.Shared				}
	],
	[	
		{	"this",		KeyTok.This		},
		{	"true",		KeyTok.True		},
		{	"throw",		KeyTok.Throw		},
		{	"typeof",		KeyTok.Typeof		},
		{	"typeid",		KeyTok.Typeid		},
		{	"template",	 KeyTok.Template	},
		{	"try",			KeyTok.Try		},
		{	"typedef",	KeyTok.Typedef	}
	],
	[
		{	"ubyte",		KeyTok.Uint8,		true	},
		{	"ushort",		KeyTok.Uint16,	true	},
		{	"uint",	 	KeyTok.Uint32,	true	},
		{	"ulong",		KeyTok.Uint64,	true	},
		{	"ucent",		KeyTok.Uint128,	true	},
		{	"union",		KeyTok.Union				},
		{	"unittest",	KeyTok.Unittest			}
	],
	[
		{	"void",		KeyTok.Void,		true	},
		{	"volatile",	KeyTok.Volatile			},
		{	"version",	KeyTok.Version			}
	],
	[
		{	"wchar",		KeyTok.Wchar,		true	},
		{	"while",		KeyTok.While				},
		{	"with",		KeyTok.With				}
	]
];

const(Keyword)* isKeyword(ref const Token t) {
	const char[] value = t.toChars();
	const int fl = value[0] != '_' ? value[0] - 96 : 0;
	
	scope(failure) writeln(" -> ", value[0], fl);
	
	if (fl < 0 || keywords[fl].length == 0)
		return null;
	
	for (size_t i = 0; i < keywords[fl].length; ++i) {
		if (keywords[fl][i].name == value) {
			return &keywords[fl][i];
		}
	}
	
	return null;
}

bool hasTplList(const Identifier* id) {
	if (isTpl(id)) {
		foreach (size_t i, ref const Token t; id.toks) {
			if (t.type == Tok.Not && id.toks[i + 1].type == Tok.LParen)
				return true;
		}
	}
	
	return false;
}

bool isTpl(const Identifier* id) {
	if (isValidVarType(id)) {
		foreach (ref const Token t; id.toks) {
			if (t.type == Tok.Not)
				return true;
		}
	}
	
	return false;
}

size_t count(const Identifier* id) {
	return id ? id.toks.length : 0;
}

bool isValidVarType(const Identifier* id) {
	if (count(id) != 0) {
		foreach (ref const Token t; id.toks) {
			if (t.type == Tok.Dot)
				return false;
		}
		
		return true;
	}
	
	return false;
}

Tok isExpression(ref const Token t) {
	switch (t.type) {
		case Tok.BitAndAssign:
		case Tok.BitOrAssign:
		case Tok.CatAssign:
		case Tok.DivAssign:
		case Tok.MinusAssign:
		case Tok.ModAssign:
		case Tok.MulAssign:
		case Tok.PlusAssign:
		case Tok.PowAssign:
		case Tok.UnsignedShiftRightAssign:
		case Tok.XorAssign:
		case Tok.Assign:
		case Tok.Increment:
		case Tok.Decrement:
			return t.type;
		default:
			return Tok.None;
	}
}

bool isEmbraceMod(ref const Token t) {
	switch (t.toChars()) {
		case "const":
		case "immutable":
		case "inout":
			return true;
		default:
			return false;
	}
}

bool isEmbraceMod(STC stc) {
	if (stc & STC.const_)
		return true;
	if (stc & STC.immutable_)
		return true;
	if (stc & STC.wild)
		return true;
	
	return false;
}

struct Parser {
public:
	Struct[]   structs;
	VarDecl[]  varDecls;
	AssignExp[] varAssignExps;
	FuncDecl[] funcDecls;
	FuncDecl[] ignoredFuncDecls;
	FuncCall[] funcCalls;
	
	Lexer* lex;
	
	alias lex this;
	
	@disable
	this();
	
	@disable
	this(this);
	
	this(string filename) {
		this.lex = new Lexer(filename);
	}
	
	const(Struct)* isStruct(const char[] id) const pure nothrow {
		foreach (ref const Struct s; this.structs) {
			if (s.tok.toChars() == id)
				return &s;
		}
		
		return null;
	}

	const(FuncDecl)* isFunc(const char[] id) const pure nothrow {
		foreach (ref const FuncDecl fd; this.funcDecls) {
			if (fd.name == id)
				return &fd;
		}
		
		return null;
	}
	
	const(FuncDecl)* isIgnoredFunc(const char[] id) const pure nothrow {
		foreach (ref const FuncDecl fd; this.ignoredFuncDecls) {
			if (fd.name == id)
				return &fd;
		}
		
		return null;
	}
	
	const(FuncDecl)* isMethod(string name) {
		return isFunc(name.splitter('.').back);
	}
	
	VarDecl* isVar(const char[] id) {
		auto id2 = id.canFind('.') ? id.splitter('.').back : id;
		
		if (auto vd = isVarDecl(id2)) {
			return vd;
		}
		
		foreach_reverse (ref AssignExp ae; this.varAssignExps) {
			if (ae.varDecl.name.toString() == id2)
				return &(ae.varDecl);
		}
		
		return null;
	}
	
	VarDecl* isVarDecl(const char[] id) {
		auto id2 = id.canFind('.') ? id.splitter('.').back : id;
		
		foreach_reverse (ref VarDecl vd; this.varDecls) {
			if (vd.name.toString() == id2)
				return &vd;
		}
		
		return null;
	}
	
	void ignoreTo(Tok upto) {
		while (this.lex.token != upto)
			this.nextToken();
	}
	
	void match(Tok type, string file = __FILE__, size_t line = __LINE__) {
		if (this.lex.token.type != type) {
			writeln(file, '@', line);
			error("found 'Tok.%s' when expecting 'Tok.%s'", this.lex.loc,
				this.lex.token.type, type);
		}
		this.lex.nextToken();
	}
	
	void match(char c, string file = __FILE__, size_t line = __LINE__) {
		if (this.lex.token.toChars()[0] != c) {
			writeln(file, '@', line);
			error("found '%s' when expecting '%s'", this.lex.loc,
				this.lex.token.toChars(), c);
		}
		this.lex.nextToken();
	}

	void match(const char[] str, string file = __FILE__, size_t line = __LINE__) {
		if (this.lex.token.toChars() != str) {
			writeln(file, '@', line);
			error("found '%s' when expecting '%s'", this.lex.loc,
				this.lex.token.toChars(), str);
		}
		this.lex.nextToken();
	}
	
	Identifier* summarize() {
		// writeln(this.lex.token.toChars());
		if (this.lex.token.type != Tok.Identifier)
			return null;
		
		Token[] ttoks;
		ttoks ~= this.lex.token;
		this.lex.nextToken();
		
		while (true) {
			bool loop = false;
			
			/// Template
			if (this.lex.token == Tok.Not) {
				ttoks ~= this.lex.token;
				this.match('!');
				
				/// Template List => !(....)
				if (this.lex.token == Tok.LParen) {
					ttoks ~= this.lex.token;
					this.match('(');
					
					while (true) {
						ttoks ~= this.lex.token;
						this.nextToken();
						
						if (this.lex.token == Tok.RParen)
							break;
					}
					
					ttoks ~= this.lex.token;
					this.match(')');
				} else {
					ttoks ~= this.lex.token;
					
					if (this.lex.token == Tok.Identifier)
						this.match(Tok.Identifier);
					else
						this.nextToken();
				}
				
				loop = true;
			}
			
			/// Enum or Function call
			if (this.lex.token == Tok.Dot) {
				ttoks ~= this.lex.token;
				this.match('.');
				ttoks ~= this.lex.token;
				this.match(Tok.Identifier);
				
				loop = true;
			}
			
			if (!loop)
				break;
		}
		
		return new Identifier(this.loc, ttoks);
	}
	
	void parse() {
		Token* t = this.nextToken();
		
		do {
			// writefln("Token: %s", t.toChars());
			Identifier* mid = this.summarize();
			// if (mid)
				// writeln('@', mid.loc.lineNum, " -- ", mid.toString(), " : ", this.lex.token.toChars());
				
			// goto Lend;
				
			const Tok expType = isExpression(this.lex.token);
			
			if (count(mid) && expType != Tok.None) {
				// writefln("EXPRESSION @ %d : %s -> %s", this.loc.lineNum, mid.toString(), expType);
				this.parseVarExp(mid, expType);
				
				continue;
			}
			
			if (count(mid) && this.lex.token == Tok.Identifier) {
				// writeln(mid.toString(), " -- ", this.lex.token.toChars());
				const Keyword* kw = count(mid) == 1 ? isKeyword(mid.toks[0]) : null;
				
				/// ignore normal Keywords, except structs
				if (kw && !kw.isBasicType && kw.tok != KeyTok.Struct) {
					/// is it an alias or typedef decl?
					if (kw && 
						(kw.tok == KeyTok.Alias || kw.tok == KeyTok.Typedef))
					{
						this.parseAliasDecl();
					}
					
					continue;
				}
				
				if (*this.peekNext() == Tok.LParen) {
					if (!kw || kw.isBasicType) {
						debug writefln("\t @ %d Function Decl: %s %s", this.loc.lineNum, mid.toString(), this.lex.token.toChars());
						
						this.parseFuncDecl(mid, kw);
						
						continue; /// To ensure that no identifier is forgotten.
					} else if (kw.tok == KeyTok.Struct)
						goto Lstruct; /// Template struct
				} else if (kw && kw.tok == KeyTok.Struct) {
					Lstruct:
					
					debug writefln("\t - Struct @ %d: %s", this.loc.lineNum, this.lex.token.toChars());
					this.parseStructDecl();
					
					continue;
				} else if (isValidVarType(mid)
					&& (kw is null || kw.isBasicType || kw.tok == KeyTok.Auto)
					&& (*this.lex.peekNext() == Tok.Semicolon
					|| *this.lex.peekNext() == Tok.Assign))
				{
					debug writefln("\tVD @ %d: %s, %s %s", mid.loc.lineNum, mid.toString(), this.lex.token.toChars(), this.lex.peekNext().toChars());
					
					this.parseVarDecl(mid);
					
					continue;
				}
			} else if (count(mid) && this.lex.token == Tok.LParen) {
				// writeln(mid.toString(), " == ", this.lex.token.toChars());
				const Keyword* kw = count(mid) == 1 ? isKeyword(mid.toks[0]) : null;
				
				const string fn = mid.toString();
				/// Is function call?
				if (!kw && 
					(isFunc(fn) || isMethod(fn) || isIgnoredFunc(fn)))
				{
					debug writefln("\t @ %d Function Call: %s", this.loc.lineNum, mid.toString());
					
					this.parseFuncCall(mid);
					
					continue;
				} else if (kw && kw.tok == KeyTok.This) {
					/// Parse CTor declaration
					this.parseCTorDecl();
						
					continue;
				}
			}
			
			Lend:
			
			t = this.nextToken();
		} while (t.type != Tok.Eof);
	}
	
	void parseCTorDecl() {
		debug writeln(this.loc.lineNum, ':', "CTOR");
		// this.match(Tok.Identifier);
		this.match('(');
		this.ignoreTo(Tok.LCurly);
		this.match('{');
	}
	
	void parseAliasDecl() {
		this.ignoreTo(Tok.Semicolon);
		this.match(';');
	}
	
	void parseStructDecl() {
		structs ~= Struct(this.loc, this.lex.token);
		// writeln(" = ", this.lex.token.toChars());
		this.match(Tok.Identifier); /// match struct name
	}
	
	void parseVarExp(const Identifier* id, Tok expType) {
		// writefln("VarExp: %s", id.toString());
		this.match(expType);
		
		/// increase var use counter
		if (VarDecl* vd = isVar(id.toString())) {
			// writeln(vd.name.toString(), ':',vd.inuse);
			vd.inuse += 1;
		}
		
		/// ignore exp. assignment
		this.ignoreTo(Tok.Semicolon);
		this.match(';');
	}
	
	void parseVarDecl(Identifier* id) {
		Token tv = this.lex.token;
		debug writeln(" VD => ", tv.toChars());
		this.match(Tok.Identifier);
		
		VarDecl vd = VarDecl(this.loc);
		vd.type = id;
		vd.name = new Identifier(this.loc, tv);
		
		/// Assign?
		if (this.lex.token == Tok.Assign) {
			this.match('=');
			
			Token[] ttoks;
			while (true) {
				ttoks ~= this.lex.token;
				
				if (this.lex.token == Tok.Semicolon || this.lex.token == Tok.Eof)
					break;
				
				this.nextToken();
			}
			this.match(';');
			
			AssignExp ae = AssignExp(this.loc, vd, Identifier(this.loc, ttoks));
			this.varAssignExps ~= ae;
			
			return;
		}
		
		this.match(';');
		this.varDecls ~= vd;
	}
	
	void parseFuncCall(const Identifier* mid) {
		FuncCall fc = FuncCall(this.loc, mid.toString());
		
		this.match('(');
		
		if (this.lex.token == Tok.RParen)
			goto LemptyCall;
		
		while (this.lex.token != Tok.RParen) {
			Token tp = this.lex.token;
			
			Identifier* id;
			
			/// is Identifier or rvalue?
			if (tp == Tok.Identifier) {
				id = this.summarize(); /// collects also tp
			} else {
				Token[] ttoks;
				ttoks ~= tp;
				
				this.nextToken();
				
				while (true) {
					if (this.lex.token == Tok.Comma)
						break;
					if (this.lex.token == Tok.RParen
						&& (*this.peekNext() == Tok.Comma
						|| *this.peekNext() == Tok.Semicolon))
					{
						break;
					}
					
					ttoks ~= this.lex.token;
					this.nextToken();
				}
				
				id = new Identifier(this.loc, ttoks);
				
				goto Ldone;
			}
			
			/// Call. Bsp.: Before: A, After: A(42)
			if (this.lex.token == Tok.LParen) {
				Token[] ttoks;
				
				ttoks ~= this.lex.token;
				this.match('(');
				while (this.lex.token != Tok.RParen) {
					ttoks ~= this.lex.token;
					// writeln(ttoks[$ - 1].toChars());
					this.lex.nextToken();
				}
				ttoks ~= this.lex.token;
				this.match(')');
				
				id.toks ~= ttoks;
				// ...
			}
			
			/// Jump to, if param is no Identifier
			Ldone:
			
			/// All other stuff. Mostly important for rvalues.
			if (this.lex.token != Tok.Comma 
				&& this.lex.token != Tok.RParen)
			{
				while (true) {
					if (this.lex.token == Tok.Comma
						|| this.lex.token == Tok.RParen)
					{
						break;
					}
					
					id.toks ~= this.lex.token;
					this.nextToken();
				}
			}
			
			fc.pexp ~= ParamExp(this.loc);
			fc.pexp[$ - 1].id = id;
			
			if (isStruct(tp.toChars())) {
				fc.pexp[$ - 1].isLvalue = true;
				// writefln("\t\t\t Lvalue for struct %s => %s", tp.toChars(), id.toString());
			}
			
			if (this.lex.token == Tok.RParen)
				break;
			
			/// next parameter
			this.match(',');
		}
		
		LemptyCall:
		
		this.match(')');
		
		/// If func call is inside of other call, we ignore him.
		if (this.lex.token == Tok.Semicolon)
		{
			this.match(';');
			/// Save only if it is an unignored function.
			if (!isIgnoredFunc(mid.toString())) {
				// writeln(fc.toString());
				this.funcCalls ~= fc;
			}
		}
		
		/// Look for 'assigned' variables
		foreach (ref const ParamExp pe; fc.pexp) {
			if (!pe.id)
				error("Invalid Parameter.", pe.loc);
			
			string vname = pe.id.toString();
			/// is/was pointer?
			if (pe.id.toks[0] == Tok.BitAnd || pe.id.toks[0] == Tok.Star)
				vname.popFront();
			// writefln("@ %d -> Check Var: %s", pe.id.loc.lineNum, vname);
			/// is known variable?
			if (auto vd = isVar(vname)) {
				// writeln(pe.loc.lineNum, " :: ", vd.loc.lineNum, " -- ", vd.name.toString());
				vd.inuse++;
			}
		}
	}
	
	void parseFuncDecl(const Identifier* id, const Keyword* kw) {
		RetType rt  = RetType(kw, id);
		FuncDecl fd = FuncDecl(this.loc, rt, this.lex.token);
		
		this.match(Tok.Identifier);
		this.match('(');
		
		/// has parameters?
		if (this.lex.token == Tok.RParen)
			goto Ldone;
		
		while (true) {
			/// Parameter storage class
			STC stc = parseSTC();
			
			Identifier* tyid = this.summarize();
			if (!tyid) {
				if (this.lex.token == Tok.LParen 
					&& *this.peekNext() == Tok.Identifier
					&& isEmbraceMod(stc))
				{
					Token[] ttoks;
					// ttoks ~= this.lex.token;
					this.match('(');
					ttoks ~= this.lex.token;
					this.match(Tok.Identifier);
					// ttoks ~= this.lex.token;
					this.match(')');
					
					tyid = new Identifier(this.loc, ttoks);
				}
				
				if (!tyid)
					error("Undefined parameter type.", this.loc);
			}
			
			// writeln("Type Id: ", tyid.toString());
			
			if (this.lex.token == "delegate" 
				|| this.lex.token == "function")
			{
				tyid.isDelegate = true;
				
				tyid.toks ~= this.lex.token;
				this.match(Tok.Identifier);
				tyid.toks ~= this.lex.token;
				this.match('(');
				
				while (this.lex.token != Tok.RParen) {
					tyid.toks ~= this.lex.token;
					this.nextToken();
				}
				
				tyid.toks ~= this.lex.token;
				this.match(')');
			}
			
			Token tv = this.lex.token;
			// writeln(" #1 => ", tv.toChars());
			
			/// Is Template?
			/// 'tv' is same as 'this.lex.token'
			if (tv != Tok.Identifier || *this.peekNext2() == Tok.LParen) {
				// writeln("\tPossible TPL: ", fd.name, " => ", tv.toChars());
				
				bool isArray = false;
				if (tv == Tok.LBracket) {
					Larray:
					
					isArray = true;
					
					tyid.toks ~= tv;
					this.match('[');
					
					while (true) {
						tyid.toks ~= this.lex.token;
						
						if (this.lex.token == Tok.RBracket 
							&& *this.peekNext() != Tok.LBracket)
						{
							break;
						}
						
						this.nextToken();
					}
					
					this.match(']');
					
					tv = this.lex.token;
					this.nextToken();
				}
				
				bool isPtr = false;
				if (tv == Tok.Star) {
					isPtr = true;
					
					if (!isArray) {
						tyid.toks ~= tv;
						
						this.nextToken();
					}
					
					while (this.lex.token == Tok.Star) {
						tyid.toks ~= this.lex.token;
						this.nextToken();
					}
					
					tv = this.lex.token; /// new parameter var
					
					if (!isArray && tv == Tok.LBracket)
						goto Larray;
					
					if (tv == Tok.Identifier)
						this.match(Tok.Identifier);
					else
						goto Lignore;
				}
				
				// writeln(fd.name, " => ", tv.toChars());
				
				if ((!isArray && !isPtr) || tv != Tok.Identifier) {
					/// ignore tpl list
					this.ignoreTo(Tok.RParen);
					this.match(')');
					
					goto Lignore;
				}
			} else
				this.match(Tok.Identifier);			// this.nextToken();
			
			fd.params ~= ParamDecl(this.loc, *tyid, tv, stc);
			
			/// Next Parameter?
			if (this.lex.token == Tok.Comma) {
				this.match(',');
				
				continue;
			}
			
			// writeln(" #2 => ", this.lex.token.toChars());
			
			/// Has default value?
			if (this.lex.token == Tok.Assign) {
				debug writeln("Has default value");
				
				this.match(Tok.Assign);
				
				Identifier* defId = this.summarize();
				/// Is no Identifier?
				if (!defId) {
					Token[] ttoks;
					
					while (this.lex.token != Tok.Comma 
						&& this.lex.token != Tok.RParen)
					{
						ttoks ~= this.lex.token;
						this.nextToken();
					}
					
					if (ttoks.length == 0)
						error("Invalid default value.", this.loc);
					
					defId = new Identifier(this.loc, ttoks);
				}
					
				// writeln("DefId: ", defId.toString());
				
				/// Is call?
				if (this.lex.token == Tok.LParen) {
					defId.toks ~= this.lex.token;
					this.match('(');
					
					while (this.lex.token != Tok.RParen) {
						defId.toks ~= this.lex.token;
						this.nextToken();
					}
					
					defId.toks ~= this.lex.token;
					this.match(')');
				}
				
				/// Default value
				fd.params[$ - 1].value = defId;
				
				/// Next Parameter?
				if (this.lex.token == Tok.Comma) {
					this.match(',');
					
					continue;
				}
			}
			
			/// Function decl. end?
			if (this.lex.token == Tok.RParen || this.lex.token == Tok.Eof)
				break;
		}
		
		/// Jump to, if parameter list is empty.
		Ldone:
		
		this.match(')');
		fd.fmod = parseFMod(); /// Func Modifier
		parseContract();
		
		if (this.lex.token == Tok.LCurly) {
			this.match('{');
			this.funcDecls ~= fd;
			
			return;
		}
		
		Lignore:
		
		// writeln("Ignored: ", fd.toString());
		
		this.ignoredFuncDecls ~= fd;
	}
	
	void parseContract() {
		if (this.lex.token == "in" || this.lex.token == "out") {
			debug writeln("CONTRACT");
			this.nextToken(); /// jump over 'in' or 'out'
			while (!(this.lex.token == "body" && *this.peekNext() == Tok.LCurly)) {
				this.nextToken();
				// TODO
			}
			
			this.match("body");
		}
	}
	
	STC parseSTC() {
		STC stc = STC.none;
		
		bool loop = true;
		while (loop) {
			switch (this.lex.token.toChars()) {
				case "const":
					stc |= STC.const_;
				break;
				case "immutable":
					stc |= STC.immutable_;
				break;
				case "ref":
					stc |= STC.ref_;
				break;
				case "out":
					stc |= STC.out_;
				break;
				case "scope":
					stc |= STC.scope_;
				break;
				case "in":
					stc |= STC.scope_|STC.const_;
				break;
				case "lazy":
					stc |= STC.lazy_;
				break;
				case "shared":
					stc |= STC.shared_;
				break;
				case "inout":
					stc |= STC.wild;
				break;
				default: loop = false;
			}
			
			if (loop)
				this.nextToken();
		}
		
		stc &= ~STC.none;
		
		return stc;
	}
	
	FMod parseFMod() {
		FMod fmod = FMod.none;
		
		bool loop = true;
		while (loop) {
			switch (this.lex.token.toChars()) {
				case "pure":
					fmod |= FMod.pure_;
				break;
				case "nothrow":
					fmod |= FMod.nothrow_;
				break;
				case "const":
					fmod |= FMod.const_;
				break;
				case "immutable":
					fmod |= FMod.immutable_;
				break;
				case "inout":
					fmod |= FMod.wild;
				break;
				
				/// Begin backwars compatibility
				case "@property":
					fmod |= FMod.property;
				break;
				case "@safe":
					fmod |= FMod.safe;
				break;
				case "@trusted":
					fmod |= FMod.trusted;
				break;
				case "@system":
					fmod |= FMod.system;
				break;
				case "@disable":
					fmod |= FMod.disable;
				break;
				/// End backwars compatibility
				
				default: loop = false;
			}
			
			if (loop)
				this.nextToken();
		}
		
		fmod &= ~FMod.none;
		
		return fmod;
	}
}

// void main() {
	// version(Test) {
		// Parser p = Parser("simple.d");
		// p.parse();
	// } else {
		// Parser p = Parser("rvalue_ref_model.d");
		// p.parse();
	// }
// }