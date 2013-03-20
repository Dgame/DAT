﻿module Dat.DCompiler;

import std.stdio;
import std.string : splitLines, replace, join;
import std.getopt;
import std.algorithm : countUntil;

import Dat.DParser;
import Dat.DTypes;

enum tempPrefix = "__";

static string genId(string name) {
	static size_t _tempCounter = 0;
	return tempPrefix ~ name ~ to!(string)(_tempCounter++);
}

struct Temp {
public:
	string line;
	const string funcCall;
	AssignExp[] aes;
	
	this(string line, string funcCall) {
		this.line = line;
		this.funcCall = funcCall;
	}
}

void main(string[] args) {
	bool compile, resolveRRef;
	string file;
	
	getopt(
		args,
		"compile", &compile,
		"autoRef", &resolveRRef,
		"file", &file
	);
	
	if (resolveRRef) {
		string[] flines = (cast(string) std.file.read(file)).splitLines();
		
		Parser p = Parser(file);
		p.parse();
		
		Temp[size_t] temps;
		
		foreach (ref FuncCall fc; p.funcCalls) {
			foreach (size_t i, ref ParamExp pe; fc.pexp) {
				if (pe.isLvalue) {
					const(FuncDecl*) fd = p.isFunc(fc.name);
					if (fd
						&& (fd.params[i].storage & STC.const_)
						&& (fd.params[i].storage & STC.ref_))
					{
						// writeln(" #-> ", fd.params[i].type.toString());
						
						VarDecl de = VarDecl(fc.loc);
						de.type = new Identifier(fc.loc, "auto");
						de.name = new Identifier(fc.loc, genId("tempRR"));
						
						AssignExp ae = AssignExp(fc.loc, de, *pe.id);
						//writeln(ae.toString());
						
						const size_t lnr = fc.loc.lineNum - 1;
						if (lnr !in temps)
							temps[lnr] = Temp(flines[lnr].replace(" ", ""), fc.toString());
						temps[lnr].aes ~= ae;
						
						pe.id = de.name;
						// writeln(fc.toString());
					}
				}
			}
		}
		
		foreach (ref const FuncCall fc; p.funcCalls) {
			const size_t lnr = fc.loc.lineNum - 1;
			
			if (lnr !in temps)
				continue;
			
			string assigns;
			foreach (ref const AssignExp ae; temps[lnr].aes)
				assigns ~= ae.toString() ~ ' ';
			assigns ~= ' ';
			//writefln("Replace %s with %s", temps[lnr].funcCall, fc.toString());
			flines[lnr] = temps[lnr].line.replace(temps[lnr].funcCall, fc.toString());
			
			auto pos = flines[lnr].countUntil('{');
			// writeln(pos);
			if (pos > 0 && pos < flines[lnr].length)
				flines[lnr] = flines[lnr][0 .. pos + 1] ~ assigns ~ flines[lnr][pos + 1 .. $];
			else
				flines[lnr] = assigns ~ flines[lnr];
		}
		
		File f = File("DAT_" ~ file, "w+");
		f.write(flines.join("\n"));
		f.close();
		
		if (compile) {
			// TODO:
		}
	}
}