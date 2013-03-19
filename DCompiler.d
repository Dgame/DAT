module Dat.DCompiler;

import std.stdio;
import std.string : splitLines, replace, join;
import std.getopt;

import Dat.DParser;
import Dat.DTypes;

enum tempPrefix = "__";

static string genId(string name) {
	static size_t _tempCounter = 0;
	return tempPrefix ~ name ~ to!(string)(_tempCounter++);
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
		
		foreach (ref const FuncCall fc; p.funcCalls) {
			foreach (size_t i, ref const ParamExp pe; fc.pexp) {
				if (pe.isLvalue) {
					const(FuncDecl*) fd = p.isFunc(fc.name);
					if (fd
						&& (fd.params[i].storage & STC.const_)
						&& (fd.params[i].storage & STC.ref_))
					{
						// writeln(" #-> ", fd.params[i].type.toString());
						
						Decl d = Decl(fc.loc);
						d.type = new Identifier(fc.loc, "auto");
						d.name = new Identifier(fc.loc, genId("tempRR"));
						
						AssignExp ae = AssignExp(fc.loc, d, *pe.id);
						//writeln(ae.toString());
						
						/// pe.id = d.name;
						
						const size_t lnr = fc.loc.lineNum - 1;
						
						string fline = flines[lnr].replace(" ", "");
						fline = fline.replace(pe.id.toString(), d.name.toString());
						
						flines[lnr] = ae.toString() ~ fline;
					}
				}
			}
		}
		
		File f = File("DAT_" ~ file, "w+");
		f.write(flines.join("\n"));
		f.close();
		
		if (compile) {
			// TODO:
		}
	}
}