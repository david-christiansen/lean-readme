/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: David Thrane Christiansen
-/
module

set_option linter.missingDocs true
set_option doc.verso true

public section

namespace LeanReadme

/-- Parsed command-line options. -/
structure Options where
  /-- The Markdown files to check. -/
  files : Array System.FilePath := #[]
  /-- The path to the Lean prelude file prepended to each block's environment. -/
  prefixPath : System.FilePath := ".lean-readme" / "Prefix.lean"
deriving Inhabited

/-- Parses argv into {name}`Options`. -/
def parseArgs (args : List String) : Except String Options :=
  let rec go (acc : Options) : List String → Except String Options
    | [] => .ok acc
    | "--prefix" :: path :: tl => go { acc with prefixPath := path } tl
    | "--prefix" :: [] => .error "--prefix requires a path argument"
    | arg :: tl =>
      if arg.startsWith "-" then .error s!"unknown option: {arg}"
      else go { acc with files := acc.files.push arg } tl
  go {} args

/-- Finds a README-like file in the given directory, case-insensitively. -/
def findReadme (dir : System.FilePath) : IO (Option System.FilePath) := do
  let entries ← (do pure (← dir.readDir).toList) <|> pure []
  let byName (target : String) : Option System.FilePath :=
    entries.findSome? fun e =>
      if e.fileName.toLower == target then some e.path else none
  for target in ["readme.md", "readme.markdown", "readme"] do
    if let some p := byName target then
      return some p
  return none
