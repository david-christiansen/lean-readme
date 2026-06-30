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

/-- A formatted message line. -/
structure Message where
  /-- The formatted text of the message. -/
  rendered : String
deriving Inhabited

/-- The result of checking one block. -/
structure BlockOutcome where
  /-- Whether checking the block failed. -/
  failed : Bool := false
  /-- The messages produced while checking the block. -/
  messages : Array Message := #[]
deriving Inhabited
