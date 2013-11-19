module main;

import std.stdio;
import std.conv : to;
import std.algorithm : canFind;
import std.array : front;
import std.range : retro;
import std.string : join, strip, format, splitLines, toLower;
import std.file : dirEntries, SpanMode, isDir, isFile, readText;
import std.getopt : getopt;
import stdx.d.lexer;

struct Import {
public:
	immutable string Module;
	immutable string Id;
	immutable uint Line;
	
	const Protection prot;
	
	uint usage;
}

struct TempImport {
public:
	immutable string Module;
	immutable uint Line;
	string[] parts;
}

class Protection {
public:
	enum Level {
		Private,
		Public,
		Protected,
		Package
	}
	
	enum Attr {
		None,
		Block,
		Line,
		Label
	}
	
	const Level level;
	const uint line;
	const Attr attr;
	
	Protection next;
	
	this(Level lvl, uint line, Attr attr) {
		this.level = lvl;
		this.line = line;
		this.attr = attr;
	}
	
	override string toString() const {
		return format("Protection(%s, %d, %s)", this.level, this.line, this.attr);
	}
}

struct Stack {
public:
	Protection current;
	
	void push(Protection prot) {
		Protection cur = this.current;
		this.current = prot;
		
		if (cur !is null)
			this.current.next = cur;
	}
	
	Protection pop() {
		Protection cur = this.current;
		if (cur.next !is null)
			this.current = cur.next;
		
		return cur;
	}
}

Protection.Level convertProtLevel(TokenType tt) {
	switch (tt) {
		case TokenType.export_:
		case TokenType.public_:
			return Protection.Level.Public;
		case TokenType.private_:
			return Protection.Level.Private;
		case TokenType.protected_:
			return Protection.Level.Protected;
		case TokenType.package_:
			return Protection.Level.Package;
		default:
			assert(0);
	}
}

void main(string[] args) {
	debug {
		enum File1 = "unittest_stdio.txt", File2 = "unittest_test.txt";
		
		//		scanForUnderUsedImports("D:/D/dmd2/src/phobos/std/stdio.d", 2, false);//, File(File1, "w+"));
		scanForUnderUsedImports("test.d", 2, true);//, File(File2, "w+"));
		scanForUnderUsedVariables("test.d", 1);
	} else {
		int minImportUsage = -1;
		int minVarUsage = -1;
		bool quit = false;
		
		getopt(args,
		       "minImportUsage|miu", &minImportUsage,
		       "minVarUsage|mvu", &minVarUsage,
		       "quit|q", &quit);
		
		uint totalOccur = 0;
		uint fileCount = 0;
		
		if (minImportUsage > 0) {
			writeln(" :: Check minimum import usage:\n----");
			
			foreach (string part; args[1 .. $]) {
				uint occur = 0;
				
				if (isDir(part)) {
					foreach (string file; dirEntries(part, "*.d", SpanMode.depth)) {
						occur = scanForUnderUsedImports(file, minImportUsage, quit);
						
						totalOccur += occur;
						fileCount++;
					}
				} else if (isFile(part)) {
					occur = scanForUnderUsedImports(part, minImportUsage, quit);
					
					totalOccur += occur;
					fileCount++;
				}
			}
			
			writefln("-------\n%s occurrences in %d files.", totalOccur, fileCount);
			
			totalOccur = fileCount = 0; /// Reset
		}
		
		if (minVarUsage > 0) {
			writeln(" :: Check minimum variable usage:\n----");
			
			foreach (string part; args[1 .. $]) {
				uint occur = 0;
				
				if (isDir(part)) {
					foreach (string file; dirEntries(part, "*.d", SpanMode.depth)) {
						occur = scanForUnderUsedVariables(file, minVarUsage, quit);
						
						totalOccur += occur;
						fileCount++;
					}
				} else if (isFile(part)) {
					occur = scanForUnderUsedVariables(part, minVarUsage, quit);
					
					totalOccur += occur;
					fileCount++;
				}
			}
			
			writefln("-------\n%s occurrences in %d files.", totalOccur, fileCount);
		}
	}
} unittest {
	enum File1 = "unittest_stdio.txt", File2 = "unittest_test.txt";
	
	uint occur1 = scanForUnderUsedImports("D:/D/dmd2/src/phobos/std/stdio.d", 2, false, File(File1, "w+"));
	assert(occur1 == 2, to!string(occur1));
	
	string[] output = readText(File1).splitLines();
	
	assert(output[0 .. 2].join(";") == "Warning:;Named import FHND_WCHAR of module std.c.stdio imported on line 35 is used only 1 times.",
	"Output is: " ~ output[0 .. 2].join(";"));
	assert(output[3 .. 6].join(";") == "Warning:;Named import memcpy of module core.stdc.string imported on line 3145 is used only 1 times.;But maybe the import is used outside, because it is marked as public.",
	"Output is: " ~ output[3 .. 6].join(";"));
	
	uint occur2 = scanForUnderUsedImports("test.d", 2, false, File(File2, "w+"));
	assert(occur2 == 9, to!string(occur2));
	
	output = readText(File2).splitLines();
	
	assert(output[0 .. 3].join(";") == "Warning:;Named import read of module std.file imported on line 5 is never used.;But maybe the import is used outside, because it is marked as public.",
	"Output is: " ~ output[0 .. 3].join(";"));
	assert(output[4 .. 7].join(";") == "Warning:;Named import format of module std.string imported on line 6 is used only 1 times.;But maybe the import is used outside, because it is marked as public.",
	"Output is: " ~ output[4 .. 7].join(";"));
	assert(output[8 .. 11].join(";") == "Warning:;Named import strip of module std.string imported on line 6 is used only 1 times.;But maybe the import is used outside, because it is marked as public.",
	"Output is: " ~ output[8 .. 11].join(";"));
	assert(output[12 .. 14].join(";") == "Warning:;Named import split of module std.array imported on line 8 is never used.",
	"Output is: " ~ output[12 .. 14].join(";"));
	assert(output[15 .. 17].join(";") == "Warning:;Named import join of module std.array imported on line 8 is never used.",
	"Output is: " ~ output[15 .. 17].join(";"));
	assert(output[18 .. 20].join(";") == "Warning:;Named import empty of module std.array imported on line 8 is used only 1 times.",
	"Output is: " ~ output[18 .. 20].join(";"));
	assert(output[21 .. 23].join(";") == "Warning:;Named import startsWith of module std.algorithm imported on line 9 is never used.",
	"Output is: " ~ output[21 .. 23].join(";"));
	assert(output[24 .. 28].join(";") == "Warning:;Named import endsWith of module std.algorithm imported on line 9 is never used.;;=> Therefore it is useless to import std.algorithm.",
	"Output is: " ~ output[24 .. 28].join(";"));
	assert(output[29 .. 31].join(";") == "Warning:;Named import memcpy of module std.c.string imported on line 10 is used only 1 times.",
	"Output is: " ~ output[29 .. 31].join(";"));
	
	uint occur3 = scanForUnderUsedVariables("test.d", 1, false, File(File2, "w+"));
	assert(occur3 == 8, to!string(occur3));
	
	output = readText(File2).splitLines();
	
	assert(output[0 .. 2].join(";") == "Warning:;Variable arr of type int[] on line 17 is never used.");
	assert(output[3 .. 5].join(";") == "Warning:;Variable arrs of type int[4] on line 18 is never used.");
	assert(output[6 .. 8].join(";") == "Warning:;Variable arrt of type int[int] on line 19 is never used.");
	assert(output[9 .. 11].join(";") == "Warning:;Variable arrt2 of type int[ulong] on line 20 is never used.");
	assert(output[12 .. 14].join(";") == "Warning:;Variable str_ of type string on line 27 is never used.");
	assert(output[15 .. 17].join(";") == "Warning:;Variable id of type int on line 43 is never used.");
	assert(output[18 .. 20].join(";") == "Warning:;Variable c_map of type void* on line 46 is never used.");
	assert(output[21 .. 23].join(";") == "Warning:;Variable bbmap of type byte[byte*] on line 55 is never used.");
}

void warning(Args...)(ref File output, string msg, Args args) {
	if (args.length != 0)
		msg = format(msg, args);
	
	output.writeln("Warning:\n", msg);
	output.writeln();
}

size_t scanForUnderUsedImports(string filename, int minUsage,
                               bool quit = false, File output = stdout)
{
	LexerConfig config;
	config.tokenStyle = TokenStyle.default_;
	config.iterStyle  = IterationStyle.codeOnly;
	config.fileName   = filename;
	
	File f = File(filename, "r");
	
	auto source = cast(ubyte[]) f.byLine(KeepTerminator.yes).join();
	auto tokens = byToken(source, config);
	
	f.close();
	
	bool isImport = false;
	string curImp;
	uint curLine = 0;
	
	Import[] imports;
	
	Stack protection;
	protection.push(new Protection(Protection.Level.Private, 0, Protection.Attr.Label));
	
	Token tok;
	for ( ; !tokens.empty(); tok = tokens.moveFront()) {
		if (tok.type == TokenType.rBrace
		    && protection.current.attr == Protection.Attr.Block)
		{
			protection.pop();
		}
		
		if (isProtection(tok.type)) {
			const Token next = tokens.front;
			
			Protection.Attr pattr = Protection.Attr.None;
			if (next.type == TokenType.colon)
				pattr = Protection.Attr.Label;
			else if (next.type == TokenType.lBrace)
				pattr = Protection.Attr.Block;
			else if (next.type == TokenType.import_)
				pattr = Protection.Attr.Line;
			
			if (pattr != Protection.Attr.None) {
				if (protection.current.attr == Protection.Attr.Label)
					protection.pop();
				
				protection.push(new Protection(convertProtLevel(tok.type), tok.line, pattr));
			}
		}
		
		if (tok.type == TokenType.import_) {
			isImport = true;
			curLine = tok.line;
			
			continue;
		}
		
		if (tok.type == TokenType.semicolon) {
			if (isImport) {
				if (curImp.canFind(':')) {
					string[] results;
					char[] temp;
					bool foundColon = false;
					
					TempImport[] tempImports;
					
					foreach (char c; curImp) {
						if (c == ',') {
							if (temp.length != 0 && tempImports.length != 0)
								tempImports.front.parts ~= temp.idup;
							
							temp = null;
						} else if (c == ':') {
							tempImports ~= TempImport(temp.idup, curLine);
							
							temp = null;
						} else
							temp ~= c;
					}
					
					if (temp.length != 0)
						tempImports[$ - 1].parts ~= temp.idup;
					
					foreach (ref const TempImport tmpi; tempImports) {
						foreach (string part; tmpi.parts) {
							imports ~= Import(tmpi.Module, part, tmpi.Line, protection.current);
						}
					}
				}
				
				curImp = null;
			}
			
			isImport = false;
			
			if (protection.current.attr == Protection.Attr.Line)
				protection.pop();
		}
		
		if (isImport)
			curImp ~= tok.value;
		
		if (tok.type == TokenType.identifier) {
			foreach (ref Import imp; imports) {
				if (imp.Id == tok.value.strip()) {
					imp.usage++;
					
					break;
				}
			}
		}
	}
	
	//writeln(imports);
	
	const(Import)* lastImport;
	uint[string] totalImportUsage;
	uint totalOccur = 0;
	
	foreach (ref const Import imp; imports) {
		if (lastImport is null || lastImport.Module != imp.Module) {
			if (lastImport !is null
			    && totalImportUsage[lastImport.Module] == 0
			&& (lastImport.prot.level == Protection.Level.Private
			    || lastImport.prot.level == Protection.Level.Protected))
			{
				output.writefln("=> Therefore it is useless to import %s.\n", lastImport.Module);
			}
			
			lastImport = &imp;
		}
		
		totalImportUsage[imp.Module] += imp.usage;
		
		if (imp.usage < minUsage) {
			string info;
			if (imp.prot.level == Protection.Level.Public)
				info = "public";
			else if (imp.prot.level == Protection.Level.Package)
				info = "package";
			
			if (info.length != 0)
				info = format("\nBut maybe the import is used outside, because it is marked as %s.", info);
			
			if (info.length == 0 || !quit) {
				if (imp.usage != 0) {
					warning(output, "%s(%d): Named import '%s' of module '%s' is used only %d times.%s",
					        filename, imp.Line, imp.Id, imp.Module, imp.usage, info);
				} else {
					warning(output, "%s(%d): Named import '%s' of module '%s' is never used.%s",
					        filename, imp.Line, imp.Id, imp.Module, info);
				}
				
				totalOccur++;
			}
		}
	}
	
	if (lastImport !is null
	    && totalImportUsage[lastImport.Module] == 0
	&& (lastImport.prot.level == Protection.Level.Private
	    || lastImport.prot.level == Protection.Level.Protected))
	{
		output.writefln("=> Therefore it is useless to import %s.\n", lastImport.Module);
	}
	
	return totalOccur;
}

struct Var {
	enum Type : ubyte {
		None,
		Byte,
		Short,
		Int,
		Long,
		Cent,
		Float,
		Double,
		Real,
		Bool,
		Char,
		WChar,
		DChar,
		String,
		WString,
		DString,
		Void,
		Bit = Bool,
		Equals_t = Bool,
		Size_t = Long,
	}
	
	enum Array : ubyte {
		None,
		Dynamic,
		Static,
		Associative
	}
	
	Protection prot;
	
	bool unsigned;
	bool pointer;
	
	Type type;
	Array array;
	
	AA aa;
	int dim = -1;
	
	string name;
	uint line;
	uint[] usageLines;
	
	this(Protection prot, Type type, string name, uint line) {
		this.prot = prot;
		this.type = type;
		this.name = name;
		this.line = line;
	}
	
	@property
	size_t usage() const pure nothrow {
		return this.usageLines.length;
	}
}

struct AA {
	Var.Type type;
	bool unsigned;
	bool pointer;
}

private Var.Type _isBuiltInType(TokenType tt, string value, bool* unsigned) {
	switch (tt) {
		case TokenType.ubyte_:
			*unsigned = true; goto case;
		case TokenType.byte_:
			return Var.Type.Byte;
		case TokenType.ushort_:
			*unsigned = true; goto case;
		case TokenType.short_:
			return Var.Type.Short;
		case TokenType.uint_:
			*unsigned = true; goto case;
		case TokenType.int_:
			return Var.Type.Int;
		case TokenType.ulong_:
			*unsigned = true; goto case;
		case TokenType.long_:
			return Var.Type.Long;
		case TokenType.ucent_:
			*unsigned = true; goto case;
		case TokenType.cent_:
			return Var.Type.Cent;
		case TokenType.float_:
			return Var.Type.Float;
		case TokenType.double_:
			return Var.Type.Double;
		case TokenType.real_:
			return Var.Type.Real;
		case TokenType.bool_:
			return Var.Type.Bool;
		case TokenType.char_:
			return Var.Type.Char;
		case TokenType.wchar_:
			return Var.Type.WChar;
		case TokenType.dchar_:
			return Var.Type.DChar;
		case TokenType.void_:
			return Var.Type.Void;
		case TokenType.identifier:
			if (value.length == 0)
				goto default;
			
			switch (value) {
				case "size_t":
					*unsigned = true;
					return Var.Type.Size_t;
				case "equals_t":
					return Var.Type.Equals_t;
				case "string":
					return Var.Type.String;
				case "wstring":
					return Var.Type.WString;
				case "dstring":
					return Var.Type.DString;
				default:
					return Var.Type.None;
			}
		default:
			return Var.Type.None;
	}
}

private bool _isAssign(TokenType tt) {
	switch (tt) {
		case TokenType.assign:
		case TokenType.bitAndAssign:
		case TokenType.bitOrAssign:
		case TokenType.catAssign:
		case TokenType.minusAssign:
		case TokenType.modAssign:
		case TokenType.mulAssign:
		case TokenType.plusAssign:
		case TokenType.powAssign:
		case TokenType.shiftLeftAssign:
		case TokenType.shiftRightAssign:
		case TokenType.unsignedShiftRightAssign:
		case TokenType.xorAssign:
			return true;
		default:
			return false;
	}
}

private Var* _isKnown(Var[] vars, ref const Token tok) {
	foreach (ref Var v; vars.retro()) {
		if (v.name == tok.value)
			return &v;
	}
	
	return null;
}

private string _builtType(ref const Var v) {
	string type = toLower(to!string(v.type));
	if (v.unsigned)
		type = 'u' ~ type;
	
	if (v.pointer)
		type ~= '*';
	
	if (v.array != Var.Array.None) {
		final switch (v.array) {
			case Var.Array.Dynamic:
				type ~= "[]";
				break;
			case Var.Array.Static:
				type ~= '[' ~ to!string(v.dim) ~ ']';
				break;
			case Var.Array.Associative:
				string mapType = toLower(to!string(v.aa.type));
				if (v.aa.unsigned)
					mapType = 'u' ~ mapType;
				if (v.aa.pointer)
					mapType ~= '*';
				
				type ~= '[' ~ mapType ~ ']';
				break;
			case Var.Array.None:
				assert(0);
		}
	}
	
	return type;
}

size_t scanForUnderUsedVariables(string filename, int minUsage,
                                 bool quit = false, File output = stdout)
{
	LexerConfig config;
	config.tokenStyle = TokenStyle.default_;
	config.iterStyle  = IterationStyle.codeOnly;
	config.fileName   = filename;
	
	File f = File(filename, "r");
	
	auto source = cast(ubyte[]) f.byLine(KeepTerminator.yes).join();
	auto tokens = byToken(source, config);
	
	f.close();
	
	Stack protection;
	protection.push(new Protection(Protection.Level.Public, 0, Protection.Attr.Label));
	
	Var[] vars;
	
	Token tok;
	for ( ; !tokens.empty(); tok = tokens.moveFront()) {
		if (tok.type == TokenType.rBrace
		    && protection.current.attr == Protection.Attr.Block)
		{
			protection.pop();
		}
		
		if (isProtection(tok.type)) {
			const Token next = tokens.front;
			
			Protection.Attr pattr = Protection.Attr.None;
			if (next.type == TokenType.colon)
				pattr = Protection.Attr.Label;
			else if (next.type == TokenType.lBrace)
				pattr = Protection.Attr.Block;
			else {
				bool _unused = false;
				if (_isBuiltInType(next.type, next.value, &_unused))
					pattr = Protection.Attr.Line;
			}
			
			if (pattr != Protection.Attr.None) {
				if (protection.current.attr == Protection.Attr.Label)
					protection.pop();
				
				protection.push(new Protection(convertProtLevel(tok.type), tok.line, pattr));
			}
		}
		
		Var.Type vt;
		bool unsigned = false;
		
		if ((vt = _isBuiltInType(tok.type, tok.value, &unsigned)) != Var.Type.None) {
			Token[] toks;
			
			do {
				toks ~= tokens.moveFront();
			} while (toks[$ - 1] != TokenType.semicolon 
			&& !_isAssign(toks[$ - 1].type)
			&& toks[$ - 1].type != TokenType.colon
			&& toks[$ - 1].type != TokenType.lParen
			&& toks[$ - 1].type != TokenType.rParen /// for cast(int)<--
			//			&& toks[$ - 1].type != TokenType.lBracket
			&& toks[$ - 1].type != TokenType.lBrace);
			
			if (toks.length > 1
			    && toks[$ - 2].type == TokenType.identifier /// for byte[] _buf = new byte[4];
			&& toks[$ - 1] == TokenType.semicolon
			|| _isAssign(toks[$ - 1].type)
			|| toks[$ - 1].type == TokenType.lBracket)
			{
				scope(failure) writeln('\n', toks);
				
				string name = toks[$ - 2].value;
				uint line = toks[$ - 2].line;
				
				assert(name.length != 0);
				
				Var v = Var(protection.current, vt, name, line);
				v.unsigned = unsigned;
				
				if (toks.length >= 2) {
					Token[] type = toks[0 .. $ - 2];
					
					if (type.length != 0) {
						if (type[0].type == TokenType.star)
							v.pointer = true;
						else if (type[0].type == TokenType.lBracket) {
							//							writeln("Array: ", type);
							
							int dim = -1;
							bool ptr = false;
							Var.Type at;
							
							size_t i = 0;
							for (TokenType tt = toks[i].type; tt != TokenType.rBracket; tt = toks[i].type) {
								if (tt == TokenType.intLiteral)
									dim = to!int(toks[i].value);
								else if ((at = _isBuiltInType(tt, null, &unsigned)) != Var.Type.None) {
									const size_t j = i + 1;
									if (j < toks.length && toks[j].type == TokenType.star) {
										ptr = true;
										i = j;
									}
								}
								
								i++;
							}
							
							if (dim != -1) {
								v.array = Var.Array.Static;
								v.dim = dim;
							}
							
							if (at != Var.Type.None) {
								v.array = Var.Array.Associative;
								v.aa.type = at;
								v.aa.unsigned = unsigned;
								v.aa.pointer = ptr;
							}
							
							if (v.array == Var.Array.None)
								v.array = Var.Array.Dynamic;
						}
					}
				}
				
				//				writeln("Variable: ", v);
				
				vars ~= v;
			}
		} else if (tok.type == TokenType.identifier) {
			if (Var* vptr = vars._isKnown(tok)) {
				vptr.usageLines ~= tok.line;
			}
		}
	}
	
	uint totalOccur = 0;
	
	foreach (ref const Var v; vars) {
		if (v.usage < minUsage) {
			string info;
			if (v.prot.level == Protection.Level.Public)
				info = "public";
			else if (v.prot.level == Protection.Level.Package)
				info = "package";
			
			if (info.length != 0)
				info = format("\nBut maybe it is used outside, because it is marked as %s.", info);
			
			if (info.length == 0 || !quit) {
				totalOccur++;
				
				if (v.usage == 0) {
					warning(output, "%s(%d): Variable '%s' of type %s is never used.%s",
					        filename, v.line, v.name, _builtType(v), info);
				} else {
					warning(output, "%s(%d): Variable '%s' of type %s is used only %d times on the lines: %s",
					        filename, v.line, v.name, _builtType(v), v.usage, v.usageLines);
				}
			}
		}
	}
	
	return totalOccur;
}