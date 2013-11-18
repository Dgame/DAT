module main;

import std.stdio;
import std.conv : to;
import std.algorithm : canFind;
import std.array : front;
import std.string : join, strip, format, splitLines;
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

		scanForUnderUsedImports("D:/D/dmd2/src/phobos/std/stdio.d", 2, false);//, File(File1, "w+"));
		scanForUnderUsedImports("test.d", 2, true);//, File(File2, "w+"));
	} else {
		int minImportUsage = 1;
		bool quit = false;

		getopt(args,
			   "minImportUsage|miu", &minImportUsage,
			   "quit|q", &quit);

		if (minImportUsage < 1)
			minImportUsage = 1;

		uint totalOccur = 0;
		uint fileCount = 0;

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

				fileCount++;
			}

			if (occur != 0)
				totalOccur += occur;
		}

		writefln("-------\n%s occurrences in %d files.", totalOccur, fileCount);
	}
} unittest {
	enum File1 = "unittest_stdio.txt", File2 = "unittest_test.txt";

	uint occur1 = scanForUnderUsedImports("D:/D/dmd2/src/phobos/std/stdio.d", 2, false, File(File1, "w+"));
	assert(occur1 == 1, to!string(occur1));

	string[] output = readText(File1).splitLines();

	assert(output[0 .. 2].join(";") == "Warning:;Named import FHND_WCHAR of module std.c.stdio imported on line 35 is used only 1 times.",
		   "Output is: " ~ output[0 .. 2].join(";"));

	uint occur2 = scanForUnderUsedImports("test.d", 2, false, File(File2, "w+"));
	assert(occur2 == 9, to!string(occur2));

	output = readText(File2).splitLines();

	assert(output[0 .. 3].join(";") == "Warning:;Named import read of module std.file imported on line 5 is never used.;But maybe the import is used outside, because it is marked with public.",
		   "Output is: " ~ output[0 .. 3].join(";"));
	assert(output[4 .. 7].join(";") == "Warning:;Named import format of module std.string imported on line 6 is used only 1 times.;But maybe the import is used outside, because it is marked with public.",
		   "Output is: " ~ output[4 .. 7].join(";"));
	assert(output[8 .. 11].join(";") == "Warning:;Named import strip of module std.string imported on line 6 is used only 1 times.;But maybe the import is used outside, because it is marked with public.",
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

	writeln(" > File ", filename);

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
				info = format("\nBut maybe the import is used outside, because it is marked with %s.", info);

			if (info.length == 0 || !quit) {
				if (imp.usage != 0) {
					warning(output, "Named import %s of module %s imported on line %d is used only %d times.%s",
							imp.Id, imp.Module, imp.Line, imp.usage, info);
				} else {
					warning(output, "Named import %s of module %s imported on line %d is never used.%s",
							imp.Id, imp.Module, imp.Line, info);
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

void scanForUnderUsedVariables() {
	
}