/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: David Thrane Christiansen
-/
module

import LeanReadme.Check
import LeanReadme.Cli

set_option linter.missingDocs true
set_option doc.verso true

open LeanReadme

/-- Parses arguments, checks the requested README files, and returns a process exit code. -/
public def main (args : List String) : IO UInt32 := do
  unsafe Lean.enableInitializersExecution
  Lean.initSearchPath (← Lean.findSysroot)
  match parseArgs args with
  | .error e => IO.eprintln s!"lean-readme: {e}"; return 2
  | .ok opts =>
    if opts.files.isEmpty then
      match ← findReadme "." with
      | none => IO.eprintln "lean-readme: no README found"; return 2
      | some p =>
        let res ← checkFile opts.prefixPath p
        IO.print res.output
        return if res.failed then 1 else 0
    else
      let mut anyFail := false
      for file in opts.files do
        let res ← checkFile opts.prefixPath file
        IO.print res.output
        if res.failed then anyFail := true
      return if anyFail then 1 else 0
