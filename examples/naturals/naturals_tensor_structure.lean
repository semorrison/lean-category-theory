-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Stephen Morgan, Scott Morrison
import .naturals
import ...monoidal_categories.monoidal_category

namespace tqft.categories.examples.naturals

open tqft.categories
open tqft.categories.functor
open tqft.categories.monoidal_category

@[unfoldable] definition ℕTensorProduct : TensorProduct ℕCategory :=
  { onObjects     := prod.fst,
    onMorphisms   := λ _ _ n, n.fst + n.snd,
    identities    := ♮,
    functoriality := ♯
  }

-- local attribute [simp] id_locked_eq

-- TODO What follows involves a lot of boring natural transformations
-- Can we construct them automatically?
definition ℕMonoidalCategory : MonoidalStructure ℕCategory :=
begin
refine { 
   tensor                    := ℕTensorProduct,
   tensor_unit               := (),
   associator_transformation := {
     morphism := { components := λ _, 0, naturality := ♯ },
     inverse  := { components := λ _, _, naturality := _ },
     witness_1 := _,
     witness_2 := _
   },
   left_unitor               := {
     morphism := { components := λ _, 0, naturality := ♯ },
     inverse  := { components := λ _, 0, naturality := ♯ },
     witness_1 := ♮,
     witness_2 := ♮
   },
   right_unitor              := {
     morphism := { components := λ _, 0, naturality := ♯ },
     inverse  := { components := λ _, 0, naturality := ♯ },
     witness_1 := ♮,
     witness_2 := ♮
   },
   pentagon := _,
   triangle := _
 },
 all_goals { intros },
--  all_goals { dsimp }, -- FIXME For now this segfaults. Waiting on https://github.com/leanprover/lean/issues/1502
 
 end 

end tqft.categories.examples.naturals