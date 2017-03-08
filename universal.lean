-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Stephen Morgan, Scott Morrison

import .category
import .discrete_category
import .functor
import .natural_transformation
import .examples.types

open tqft.categories

namespace tqft.categories.universal

structure InitialObject ( C : Category ) :=
  (object : C^.Obj)
  (morphism : ∀ Y : C^.Obj, C^.Hom object Y)
  (uniqueness : ∀ Y : C^.Obj, ∀ f : C^.Hom object Y, f = morphism Y)

instance InitialObject_coercion_to_object { C : Category } : has_coe (InitialObject C) (C^.Obj) :=
  { coe := InitialObject.object }

structure is_initial { C : Category } ( X : C^.Obj ) :=
  (morphism : ∀ Y : C^.Obj, C^.Hom X Y)
  (uniqueness :  ∀ Y : C^.Obj, ∀ f : C^.Hom X Y, f = morphism Y)

lemma InitialObjects_have_only_the_identity_endomorphism { C : Category } ( X: InitialObject C ) ( f : C^.Hom X X ) : f = C^.identity X :=
  begin
   blast, -- blast is not actually doing anything here; but perhaps later it will.
   rewrite X^.uniqueness X f,
   rewrite X^.uniqueness X (C^.identity X)
  end

lemma InitialObjects_are_unique { C : Category } ( X Y : InitialObject C ) : Isomorphism C X Y :=
  {
      morphism  := X^.morphism Y,
      inverse   := Y^.morphism X,
      witness_1 := begin apply InitialObjects_have_only_the_identity_endomorphism end,
      witness_2 := begin apply InitialObjects_have_only_the_identity_endomorphism end
  }

definition Opposite ( C : Category ) : Category :=
{
  Obj      := C^.Obj,
  Hom      := λ X Y, C^.Hom Y X,
  identity := C^.identity,
  compose  := λ X Y Z f g, C^.compose g f,
  left_identity  := ♮,
  right_identity := ♮,
  associativity  := ♮
}

-- Do we dare:
definition TerminalObject ( C : Category ) := InitialObject (Opposite C)

-- If not:
-- structure TerminalObject ( C : Category ) :=
--   (object : C^.Obj)
--   (morphism : ∀ Y : C^.Obj, C^.Hom Y object)
--   (uniqueness : ∀ Y : C^.Obj, ∀ f : C^.Hom Y object, f = morphism Y)

open tqft.categories.functor
open tqft.categories.natural_transformation

-- The diagonal functor sends X to the constant functor that sends everything to X.
definition DiagonalFunctor ( J C : Category ) : Functor C (FunctorCategory J C) :=
{
  onObjects     := λ X : C^.Obj, {
    onObjects     := λ _, X,
    onMorphisms   := λ _ _ _, C^.identity X,
    identities    := ♮,
    functoriality := ♮
  },
  onMorphisms   := λ X Y f, {
    components := λ _, f,
    naturality := ♮
  },
  identities    := ♮,
  functoriality := ♮  
}

-- The elaborator has some trouble understanding what p.2.2 and q.2.2 mean below.
-- Leo suggested the following work-around, at <https://groups.google.com/d/msg/lean-user/8jW4BIUFl24/MOtgbpfqCAAJ>.
local attribute [elab_simple]  sigma.snd

-- unfortunately one can't coerce along subtype.elt_of
open subtype

local attribute [ematch] subtype.has_property

definition CommaCategory { A B C : Category} ( S : Functor A C ) ( T : Functor B C ) : Category :=
{
  Obj      := Σ a : A^.Obj, Σ b : B^.Obj, C^.Hom (S a) (T b),
  Hom      := λ p q, { gh : (A^.Hom p.1 q.1) × (B^.Hom p.2.1 q.2.1) // C^.compose (S^.onMorphisms gh.1) q.2.2 = C^.compose p.2.2 (T^.onMorphisms gh.2) },
  identity := λ p, tag (A^.identity p.1, B^.identity p.2.1) ♮,
  compose  := λ p q r f g, tag (A^.compose (elt_of f).1 (elt_of g).1, B^.compose (elt_of f).2 (elt_of g).2) ♮,
  left_identity  := ♮,
  right_identity := ♮,
  associativity  := ♮
}

definition ObjectAsFunctor { C : Category } ( X : C^.Obj ) : Functor (DiscreteCategory (fin 1)) C :=
{
  onObjects     := λ _, X,
  onMorphisms   := λ _ _ _, C^.identity X,
  identities    := ♮,
  functoriality := ♮
}

-- TODO probably better to give the simplified definition of slice and coslice categories, and then prove equivalence with this.
definition SliceCategory   { C : Category } ( X : C^.Obj ) := CommaCategory (IdentityFunctor C) (ObjectAsFunctor X) 
definition CosliceCategory { C : Category } ( X : C^.Obj ) := CommaCategory (ObjectAsFunctor X) (IdentityFunctor C)

definition Cones   { J C : Category } ( F : Functor J C ) := CommaCategory (DiagonalFunctor J C)                      (ObjectAsFunctor F)
definition Cocones { J C : Category } ( F : Functor J C ) := CommaCategory (@ObjectAsFunctor (FunctorCategory J C) F) (DiagonalFunctor J C)

definition Limit   { J C : Category } ( F: Functor J C ) := TerminalObject (Cones   F)
definition Colimit { J C : Category } ( F: Functor J C ) := InitialObject  (Cocones F)

structure ExplicitLimit { J C : Category } ( F: Functor J C ) :=
  ( limit : C^.Obj )
  ( maps  : Π X : J^.Obj, C^.Hom limit (F X) )
  ( commutativity : Π X Y : J^.Obj, Π f : J^.Hom X Y, C^.compose (maps X) (F^.onMorphisms f) = maps Y )

open tqft.categories.examples.types

definition Limit_agrees_with_ExplicitLimit { J C : Category } ( F: Functor J C ) : Isomorphism CategoryOfTypes (Limit F) (ExplicitLimit F) := {
  morphism  := λ L, { 
    limit := begin
               unfold Limit at F, -- TODO why doesn't this do anything?
               -- The idea here is that the underlying object of L is an object in the 
               -- comma category. Taking its left projection (i.e. the first piece of the dependent pair) is an object in C, which is the one we want!
               exact sorry
             end,
    maps  := sorry,
    commutativity := sorry
  },
  inverse   := sorry,
  witness_1 := sorry,
  witness_2 := sorry
}

-- TODO How do we even prove 0 < 2 ??! :-)
def zero : fin 2 := ⟨ 0, sorry ⟩
def one  : fin 2 := ⟨ 1, sorry ⟩

-- TODO This breaks, with a mysterious error. Any ideas?
-- definition Product { C : Category } ( A B : C^.Obj ) := @Limit (DiscreteCategory (fin 2)) C {
--   onObjects     := λ X, match X with
--                           | zero := A
--                           | one  := B
--                         end, 
--   onMorphisms   := sorry,
--   identities    := sorry,
--   functoriality := sorry
-- }

-- TODO then products, equalizers, etc.
-- perhaps a good way to find out if these definitions are usable is to verify that products are products.

-- TODO ... how to handle dual notions without too much duplication?

end tqft.categories.universal

