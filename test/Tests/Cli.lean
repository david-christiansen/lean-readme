/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: David Thrane Christiansen
-/
module

-- Both imports are required: `import` lets ordinary definitions reference `parseArgs`; `meta import` provides the compiled symbols the interpreter needs for `#eval`.
import LeanReadme.Cli
meta import LeanReadme.Cli

set_option linter.missingDocs true
set_option doc.verso true

open LeanReadme

def showOpts : Except String Options → String
  | .error e => s!"error: {e}"
  | .ok o => s!"prefix={o.prefixPath} files={o.files.toList.map (·.toString)}"

-- Default prefix, no files.
/-- info: prefix=.lean-readme/Prefix.lean files=[] -/
#guard_msgs in
#eval IO.println (showOpts (parseArgs []))

-- Explicit files preserved in order.
/-- info: prefix=.lean-readme/Prefix.lean files=[a.md, b.md] -/
#guard_msgs in
#eval IO.println (showOpts (parseArgs ["a.md", "b.md"]))

-- --prefix overrides the default.
/-- info: prefix=custom/P.lean files=[r.md] -/
#guard_msgs in
#eval IO.println (showOpts (parseArgs ["--prefix", "custom/P.lean", "r.md"]))

-- --prefix without an argument is an error.
/-- info: error: --prefix requires a path argument -/
#guard_msgs in
#eval IO.println (showOpts (parseArgs ["--prefix"]))

-- An unknown option is rejected rather than treated as a filename.
/-- info: error: unknown option: --bogus -/
#guard_msgs in
#eval IO.println (showOpts (parseArgs ["--bogus"]))
