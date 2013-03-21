DAT
===

D analysis tool

DAT can resolve rvalue references and unused or underused variables.

Usage
===
Example:
DCompiler --file mytest.d --autoref --unused

Options
===
--file        Your filename
--autoref     Resolve rvalue references by creating temporary variables. Creates a new file 'DAT_filename.d'.
--unused      Detects completly unused variables.
--underused   Detects Variables which are used one time or less.
--compile     Compiles the new files, if any. (Not implemented)
