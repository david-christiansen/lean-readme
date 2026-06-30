/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: David Thrane Christiansen
-/
module

set_option linter.missingDocs true
set_option doc.verso true

open System

/--
Runs one case directory: invokes lean-readme via lake exe with cwd = the test case dir.
-/
def runCase (dir : FilePath) (root : FilePath) : IO (String × String × UInt32) := do
  let out ← IO.Process.output {
    cmd := "lake", args := #["-d", root.toString, "exe", "lean-readme", "input.md"],
    cwd := some dir }
  return (out.stdout, out.stderr, out.exitCode)

def caseDirs : IO (Array FilePath) := do
  let root : FilePath := "test" / "cases"
  let entries ← root.readDir
  let mut dirs := #[]
  for e in entries do
    if ← e.path.isDir then dirs := dirs.push e.path
  return dirs.qsort (·.toString < ·.toString)

/-- Checks or updates one golden test case, returning whether it failed. -/
def checkCase (dir root : FilePath) (updateExpected : Bool) : IO Bool := do
  let (out, err, exit) ← runCase dir root
  let outFile := dir / "expected.out"
  let exitFile := dir / "expected.exit"
  if updateExpected then
    IO.FS.writeFile outFile out
    IO.FS.writeFile exitFile s!"{exit}\n"
    IO.println s!"updated {dir}"
    return false
  else
    let expOut ← IO.FS.readFile outFile
    let expExit := (← IO.FS.readFile exitFile).trimAscii.toString
    if out == expOut && s!"{exit}" == expExit then
      IO.println s!"ok   {dir}"
      return false
    else
      IO.println s!"FAIL {dir}"
      IO.println s!"  expected exit {expExit}, got {exit}"
      IO.println s!"  --- expected ---\n{expOut}\n  --- actual ---\n{out}"
      unless err.isEmpty do
        IO.println s!"  --- stderr ---\n{err}"
      return true

/-- Runs the golden case directories, comparing or updating expected output, and returns an exit code. -/
public def main (args : List String) : IO UInt32 := do
  let updateExpected := args.contains "--update-expected"
  let root ← IO.currentDir
  let mut failed := false
  for dir in (← caseDirs) do
    if ← checkCase dir root updateExpected then
      failed := true
  return (if failed then 1 else 0)
