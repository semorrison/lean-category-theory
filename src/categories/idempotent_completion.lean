-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Stephen Morgan, Scott Morrison

import categories.category
import categories.equivalence
import categories.functor

open categories
open categories.functor
open categories.natural_transformation
open categories.functor_categories

namespace categories.idempotent_completion

universes u u₁ u₂

structure Idempotent (C : Type (u+1)) [large_category C] :=
   (object : C)
   (idempotent : object ⟶ object)
   (witness : idempotent ≫ idempotent = idempotent . obviously)

make_lemma Idempotent.witness
attribute [simp,ematch] Idempotent.witness_lemma

local attribute [ematch] subtype.property

variables {C : Type (u+1)} [large_category C]

structure Idempotent_morphism (X Y : Idempotent C) :=
(morphism : X.object ⟶ Y.object)
(left : X.idempotent ≫ morphism = morphism . obviously)
(right : morphism ≫ Y.idempotent = morphism . obviously)

make_lemma Idempotent_morphism.left
make_lemma Idempotent_morphism.right
attribute [simp,ematch] Idempotent_morphism.left_lemma Idempotent_morphism.right_lemma

@[applicable] lemma Idempotent_morphisms_equal
  (X Y : Idempotent C)
  (f g : Idempotent_morphism X Y)
  (w : f.morphism = g.morphism) : f = g :=
  begin
    induction f,
    induction g,
    tidy
  end


instance IdempotentCompletion : large_category (Idempotent C) := {
  Hom            := Idempotent_morphism,
  identity       := λ X, ⟨ X.idempotent ⟩,
  compose        := λ X Y Z f g, ⟨ f.morphism ≫ g.morphism ⟩
}

definition functor_to_IdempotentCompletion (C : Type (u+1)) [large_category C] : C ↝ (Idempotent C) := {
  onObjects     := λ X, ⟨ X, 𝟙 X ⟩,
  onMorphisms   := λ _ _ f, ⟨ f, by obviously ⟩
}

-- -- PROJECT
-- definition IdempotentCompletion_functorial (C : Type u) [category C] (D : Type u) [category D] : Functor (Functor C D) (Functor (Idempotent C) (Idempotent D)) := {

open categories.equivalence

lemma embedding_in_IdempotentCompletition (C : Type (u+1)) [large_category C]  : Embedding (functor_to_IdempotentCompletion C) := by obviously

variable {D : Type (u₂+1)}
variable [large_category D]

definition restrict_Functor_from_IdempotentCompletion (F : Functor (Idempotent C) D) : Functor C D :=
  FunctorComposition (functor_to_IdempotentCompletion C) F

@[simp] private lemma double_idempotent_morphism_left (X Y : Idempotent (Idempotent C)) (f : X ⟶ Y)
  : (X.idempotent).morphism ≫ (f.morphism).morphism = (f.morphism).morphism :=
congr_arg Idempotent_morphism.morphism f.left
@[simp] private lemma double_idempotent_morphism_right (X Y : Idempotent (Idempotent C)) (f : X ⟶ Y)
  : (f.morphism).morphism ≫ (Y.idempotent).morphism = (f.morphism).morphism :=
congr_arg Idempotent_morphism.morphism f.right

private def IdempotentCompletion_idempotent_functor (C : Type (u+1)) [large_category C] : Functor (Idempotent (Idempotent C)) (Idempotent C) :=
{ onObjects     := λ X, ⟨ X.object.object, X.idempotent.morphism, congr_arg Idempotent_morphism.morphism X.witness ⟩, -- PROJECT think about automation here
  onMorphisms   := λ X Y f, ⟨ f.morphism.morphism, by obviously ⟩ }
private def IdempotentCompletion_idempotent_inverse (C : Type (u+1)) [large_category C] : Functor (Idempotent C) (Idempotent (Idempotent C)) :=
{ onObjects     := λ X, ⟨ X, ⟨ X.idempotent, by obviously ⟩, by obviously ⟩,
  onMorphisms   := λ X Y f, ⟨ f, by obviously ⟩ }

-- PROJECT prove these lemmas about idempotent completion

-- lemma IdempotentCompletion_idempotent (C : Type u) [category C] :
--   Equivalence (IdempotentCompletion (IdempotentCompletion C)) (IdempotentCompletion C) :=
-- {
--   functor := IdempotentCompletion_idempotent_functor C,
--   inverse := IdempotentCompletion_idempotent_inverse C,
--   isomorphism_1 := begin tidy, exact C.identity _, tidy, induction f_2, tidy, end, -- PROJECT very slow??
--   isomorphism_2 := sorry
--}

definition extend_Functor_to_IdempotentCompletion (F : C ↝ (Idempotent D)) : (Idempotent C) ↝ (Idempotent D) :=
{ onObjects     := λ X, { object := (F +> X.object).object, 
                          idempotent := (F &> X.idempotent).morphism },
  onMorphisms   := λ X Y f, { morphism := (F &> f.morphism).morphism } }

-- lemma Functor_from_IdempotentCompletion_determined_by_restriction 
--   {C D : Category} (F : Functor (IdempotentCompletion C) (IdempotentCompletion D)) :
--     NaturalIsomorphism (extend_Functor_to_IdempotentCompletion (restrict_Functor_from_IdempotentCompletion F)) F := 
--       sorry

-- PROJECT idempotent completion left adjoint to the forgetful functor from categories to semicategories?

end categories.idempotent_completion
