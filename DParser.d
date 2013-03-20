module Dat.DParser;

import std.stdio;
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
			// t.type = keywords[i].tok;
			return &keywords[fl][i];
		}
	}
	
	return null;
}

struct Parser {
public:
	Struct[]   structs;
	FuncDecl[] funcDecls;
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
	
	const(Struct*) isStruct(const char[] id) {
		foreach (ref const Struct s; this.structs) {
			if (s.tok.toChars() == id)
				return &s;
		}
		
		return null;
	}

	const(FuncDecl*) isFunc(const char[] id) {
		foreach (ref const FuncDecl fd; this.funcDecls) {
			if (fd.name.toChars() == id)
				return &fd;
		}
		
		return null;
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
	
	void parse() {
		Token* t = this.nextToken();
		
		do {
			if (*t == Tok.Identifier && *this.peekNext() == Tok.Identifier) {
				const Keyword* kw = isKeyword(*t);
				
				if (*this.peekNext2() == Tok.LParen) {
					if (kw is null || kw.isBasicType) {
						// writeln(this.loc.lineNum, ':', t.toChars(), " => ", this.peekNext().toChars());
						this.parseFuncDecl(t, kw);
						
						continue; // To ensure that no identifier is forgotten.
					} else if (kw.tok == KeyTok.Struct) {
						/// Template struct
						goto Lstruct;
					}
				} else if (kw && kw.tok == KeyTok.Struct) {
					Lstruct:
					
					this.match(Tok.Identifier); /// match 'struct'
					debug writeln("\t struct -> ", this.loc.lineNum, ':', this.lex.token.toChars());
					structs ~= Struct(this.loc, this.lex.token);
					this.match(Tok.Identifier); /// match struct name
				}
			} else if (*t == Tok.Identifier && *this.peekNext() == Tok.LParen) {
				/// Is function call?
				if (!isKeyword(*t) && isFunc(t.toChars())) {
					debug writeln("\t\t", this.loc.lineNum, ':', t.toChars());
					this.parseFuncCall(t);
					
					continue;
				} else {
					/// Garbage
					this.match(Tok.Identifier);
					this.match('(');
				}
			}
			
			t = this.nextToken();
		} while (t.type != Tok.Eof);
	}
	
	void parseFuncCall(Token* t) {
		FuncCall fc = FuncCall(this.loc, t.toChars());
		
		this.match(Tok.Identifier);
		this.match('(');
		
		if (this.lex.token != Tok.RParen) {
			while (this.lex.token != Tok.RParen) {
				Token tp = this.lex.token;
				this.match(Tok.Identifier);
				
				Identifier* id;
				if (this.lex.token == Tok.Dot) {
					Token[] ttoks;
					ttoks ~= tp;
					
					while (true) {
						ttoks ~= this.lex.token;
						this.match('.');
						ttoks ~= this.lex.token;
						this.match(Tok.Identifier);
						
						if (this.lex.token != Tok.Dot)
							break;
					}
					
					id = new Identifier(this.loc, ttoks);
				} else if (this.lex.token == Tok.Not) {
					Token[] ttoks;
					ttoks ~= tp;
					//while (true) {
					ttoks ~= this.lex.token;
					this.match('!');
					
					/// Template List => !(....)
					if (this.lex.token == Tok.LParen) {
						ttoks ~= this.lex.token;
						this.match('(');
						
						while (true) {
							ttoks ~= this.lex.token;
							this.match(Tok.Identifier);
							
							if (this.lex.token == Tok.Comma) {
								ttoks ~= this.lex.token;
								this.match(',');
								
								continue;
							}
							
							if (this.lex.token == Tok.RParen)
								break;
						}
						
						ttoks ~= this.lex.token;
						this.match(')');
					} else {
						ttoks ~= this.lex.token;
						this.match(Tok.Identifier);
					}
					debug writeln("TPL .........");
					id = new Identifier(this.loc, ttoks);
				}
				
				// writeln("\t --##--> ", id ? id.toString() : tp.toChars());
				// writeln(" = ", this.lex.token.toChars());
				
				/// Call
				if (this.lex.token == Tok.LParen) {
					Token[] ttoks;
					
					if (!id)
						ttoks ~= tp;
					
					ttoks ~= this.lex.token;
					this.match('(');
					while (this.lex.token != Tok.RParen) {
						ttoks ~= this.lex.token;
						// writeln(ttoks[$ - 1].toChars());
						this.lex.nextToken();
					}
					ttoks ~= this.lex.token;
					this.match(')');
					
					if (id)
						id.toks ~= ttoks;
					else
						id = new Identifier(this.loc, ttoks);
					
					fc.pexp ~= ParamExp(this.loc);
					fc.pexp[$ - 1].id = id;
					
					if (isStruct(tp.toChars())) {
						fc.pexp[$ - 1].isLvalue = true;
						// TODO: Funktion holen, Parameter durchgehen und schauen, ob dieser 'in ref' ist. Dazu vllt erstmal alle ParameterExpression parsen und danach durchgehen.
						debug writeln("\t\t\t ----> Lvalue => ", id.toString());
					}
				}
				
				if (this.token == Tok.RParen)
					break;
				
				/// next parameter?
				this.match(',');
			}
		}
		
		// writeln(fc.toString());
		this.funcCalls ~= fc;
		
		this.match(')');
		this.match(';');
	}
	
	void parseFuncDecl(Token* t, const Keyword* kw) {
		RetType rt  = RetType(kw, *t);
		FuncDecl fd = FuncDecl(this.loc, rt, *this.peekNext());
		
		this.match(Tok.Identifier);
		this.match(Tok.Identifier);
		this.match('(');
		
		/// has parameters?
		if (this.lex.token == Tok.RParen)
			goto Ldone;
		
		while (true) {
			/// Parameter storage class
			STC stc = parseSTC();
			
			Token ty = this.lex.token;
			debug writeln(" -> ", ty.toChars());
			this.match(Tok.Identifier);			// this.nextToken();
			
			Identifier* tyid;
			/// Is Template Type?
			if (this.lex.token == Tok.Not) {
				Token[] ttoks;
				ttoks ~= ty;
				while (true) {
					ttoks ~= this.lex.token;
					this.match(Tok.Not);
					
					/// Template List => !(....)
					if (this.lex.token == Tok.LParen) {
						ttoks ~= this.lex.token;
						this.match('(');
						
						while (true) {
							ttoks ~= this.lex.token;
							this.match(Tok.Identifier);
							
							if (this.lex.token == Tok.Comma) {
								ttoks ~= this.lex.token;
								this.match(',');
								
								continue;
							}
							
							if (this.lex.token == Tok.RParen)
								break;
						}
						
						ttoks ~= this.lex.token;
						this.match(')');
					} else {
						ttoks ~= this.lex.token;
						this.match(Tok.Identifier);
					}
					
					if (this.lex.token != Tok.Not)
						break;
				}
				/// Type Identifier (if type is a template)
				tyid = new Identifier(this.loc, ttoks);
				debug writeln(" ====> ", tyid.toString());
			}
			
			Token tv = this.lex.token;
			debug writeln(" => ", tv.toChars());
			
			/// Is Template?
			if (tv != Tok.Identifier) { // tv <-> this.lex.token
				debug writeln("\tTPL");
				
				while (true) {
					this.nextToken();
					if (this.lex.token == Tok.LCurly || this.lex.token == Tok.Eof)
						break;
				}
				
				this.match('{');
				
				return;
			} else
				this.match(Tok.Identifier);			// this.nextToken();
			
			/// Is type Identifier or Token?
			if (tyid)
				fd.params ~= ParamDecl(this.loc, *tyid, tv, stc);
			else
				fd.params ~= ParamDecl(this.loc, ty, tv, stc);
			
			/// Next Parameter?
			if (this.lex.token == Tok.Comma) {
				this.match(',');
				
				continue;
			}
			
			/// Has default value?
			if (this.lex.token == Tok.Assign) {
				this.match(Tok.Assign);
				
				Token[] ttoks;
				ttoks ~= this.lex.token;
				this.match(Tok.Identifier);
				
				while (true) {
					/// Enum or Func.Call
					if (this.lex.token == Tok.Dot) {
						while (true) {
							ttoks ~= this.lex.token;
							this.match(Tok.Dot);
							ttoks ~= this.lex.token;
							this.match(Tok.Identifier);
							
							if (this.lex.token != Tok.Dot)
								break;
						}
						/// Template
					} else if (this.lex.token == Tok.Not) {
						while (true) {
							ttoks ~= this.lex.token;
							this.match(Tok.Not);
							ttoks ~= this.lex.token;
							this.match(Tok.Identifier);
							
							if (this.lex.token != Tok.Not)
								break;
						}
					} else
						break;
				}
				/// Default value
				fd.params[$ - 1].value = new Identifier(this.loc, ttoks);
			}
			
			/// Function decl. end?
			if (this.lex.token == Tok.RParen || this.lex.token == Tok.Eof)
				break;
		}
		
		Ldone:
		
		this.match(')');
		fd.fmod = parseFMod(); /// Func Modifier
		this.match('{');
		
		this.funcDecls ~= fd;
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
				default: loop = false;
			}
			
			if (loop)
				this.nextToken();
		}
		
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