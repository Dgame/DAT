module Dat.DCompiler;

import std.stdio;
import std.string : splitLines, replace, replaceFirst, join;
import std.getopt;
import std.algorithm;

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
	AssignExp aes[];
	
	this(string line) {
		this.line = line;
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
						
						Decl de = Decl(fc.loc);
						de.type = new Identifier(fc.loc, "auto");
						de.name = new Identifier(fc.loc, genId("tempRR"));
						
						AssignExp ae = AssignExp(fc.loc, de, *pe.id);
						//writeln(ae.toString());
						
						pe.id = de.name;
						
						const size_t lnr = fc.loc.lineNum - 1;
						if (lnr !in temps)
							temps[lnr] = Temp(flines[lnr].replace(" ", ""));
							
						temps[lnr].aes ~= ae;
						
						// writeln(fc.toString());
					}
				}
			}
		}
		
		foreach (ref FuncCall fc; p.funcCalls) {
			const size_t lnr = fc.loc.lineNum - 1;
			
			if (lnr !in temps)
				continue;
			
			string assigns;
			foreach (ref const AssignExp ae; temps[lnr].aes)
				assigns ~= ae.toString() ~ ' ';
			
			flines[lnr] = assigns ~ ' ' ~ fc.toString();
		}
		
		// foreach (size_t lnr, ref Temp t; temps) {
			// string assigns;
			// foreach (ref const AssignExp ae; t.aes) {
				// assigns ~= ae.toString() ~ ' ';
			// }
			// flines[lnr] = assigns ~ ' ' ~ flines[lnr];
		// }
		
		File f = File("DAT_" ~ file, "w+");
		f.write(flines.join("\n"));
		f.close();
		
		if (compile) {
			// TODO:
		}
	}
}