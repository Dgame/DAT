DAT
===

<b>D</b> <b>a</b>nalysis <b>t</b>ool

<b>DAT</b> can resolve rvalue references and unused or underused variables.

Usage
===
Example:
<code>DCompiler --file mytest.d --autoref --unused</code>

Options
===
<ul>
<li><code>--file</code>        Your filename</li>
<li><code>--autoref</code>     Resolve rvalue references by creating temporary variables. Creates a new file 'DAT_filename.d'.</li>
<li><code>--unused</code>      Detects completly unused variables.</li>
<li><code>--underused</code>   Detects Variables which are used one time or less.</li>
<li><code>--compile</code>     Compiles the new files, if any. (Not implemented)</li>
</ul>

TODO:
===
<ul>
<li>Improve detection of unused variables.</li>
<li>Implement detection of unused functions.</li>
<li>Implement detection of unused structs.</li>
<li>Implement listing of all variables/functions and their use counter.</li>
<li>Implement drop option for unused variables/functions.</li>
</ul>

<b>Note that this is only a beta.</b>
