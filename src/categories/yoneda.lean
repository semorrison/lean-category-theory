-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Scott Morrison

import category_theory.natural_transformation
import categories.isomorphism
import categories.opposites
import categories.equivalence
import categories.products.switch
import categories.types
import categories.functor_categories.evaluation
import categories.universe_lifting
import tactic.interactive
import categories.tactics.obviously

open category_theory

namespace category_theory.yoneda

universes u₁ v₁ u₂

section
variables (C : Type u₁) [category.{u₁ v₁} C]

-- FIXME why isn't this already available?
instance : category ((Cᵒᵖ) ↝ Type v₁ × (Cᵒᵖ)) := category_theory.prod.category.{(max u₁ (v₁+1)) (max u₁ v₁) u₁ v₁} (Cᵒᵖ ↝ Type v₁) (Cᵒᵖ)

definition YonedaEvaluation 
  : (((Cᵒᵖ) ↝ (Type v₁)) × (Cᵒᵖ)) ↝ (Type (max u₁ v₁)) 
  := (FunctorCategory.Evaluation (Cᵒᵖ) (Type v₁)) ⋙ type_lift.{v₁ u₁}

-- FIXME hmmm.
open tactic.interactive
meta def unfold_coes' := `[unfold_coes]
local attribute [tidy] unfold_coes'

definition Yoneda : C ↝ ((Cᵒᵖ) ↝ (Type v₁)) := 
{ obj := λ X, 
    { obj := λ Y, @category.Hom C _ Y X,
      map := λ Y Y' f g, f ≫ g },
  map := λ X X' f, 
    { app := λ Y g, g ≫ f } }

-- FIXME typeclass resolution needs some help.
definition YonedaPairing : (((Cᵒᵖ) ↝ (Type v₁)) × (Cᵒᵖ)) ↝ (Type (max u₁ v₁)) := 
let F := (ProductCategory.switch ((Cᵒᵖ) ↝ (Type v₁)) (Cᵒᵖ)) in
let G := (functor.prod ((Yoneda C).opposite) (functor.id ((Cᵒᵖ) ↝ (Type v₁)))) in
let H := (hom_pairing ((Cᵒᵖ) ↝ (Type v₁))) in
begin
  letI : category (Cᵒᵖ × (Cᵒᵖ ↝ Type v₁)) := by apply_instance,
  exact (F ⋙ G ⋙ H)      
end

definition CoYoneda (C : Type u₁) [category.{u₁ v₁} C] : (Cᵒᵖ) ↝ (C ↝ (Type v₁)) := 
{ obj := λ X, 
   { obj := λ Y, @category.Hom C _ X Y,
     map := λ Y Y' f g, g ≫ f },
  map := λ X X' f,
    { app := λ Y g, f ≫ g } }
end

section
variable {C : Type u₁}
variable [𝒞 : category.{u₁ v₁} C]
include 𝒞

class Representable (F : C ↝ (Type v₁)) := 
(c : C)
(Φ : F ⇔ ((CoYoneda C) c))

end

@[simp] private lemma YonedaLemma_aux_1 {C : Type u₁} [category.{u₁ v₁} C] {X Y : C} (f : X ⟶ Y) {F G : (Cᵒᵖ) ↝ (Type v₁)} (τ : F ⟹ G) (Z : F Y) :
     (G.map f) ((τ Y) Z) = (τ X) ((F.map f) Z) := eq.symm (congr_fun (τ.naturality f) Z)

local attribute [tidy] dsimp_all'

set_option pp.universes true

def YonedaLemma (C : Type u₁) [category.{u₁ v₁} C] : (YonedaPairing C) ⇔ (YonedaEvaluation C) := 
{ map := { app := λ F x, ulift.up ((x.app F.2) (𝟙 F.2)), naturality := by obviously' },
  inv := { app := λ F x, { app := λ X a, (F.1.map a) x.down, naturality := by obviously' }, naturality := by obviously' } }.

def YonedaFull (C : Type u₁) [category.{u₁ v₁} C] : Full (Yoneda C) := 
{ preimage := λ X Y f, (f X) (𝟙 X),
  witness := λ X Y f, begin tidy, have p := congr_fun (f.naturality x) (𝟙 X), tidy, end } -- PROJECT a pure rewriting proof?

def YonedaFaithful (C : Type u₁) [category.{u₁ v₁} C]  : Faithful (Yoneda C) := {
    injectivity := λ X Y f g w, begin 
                                  -- PROJECT automation
                                  dsimp_all',
                                  have p := congr_arg nat_trans.app w, 
                                  have p' := congr_fun p X, 
                                  have p'' := congr_fun p' (𝟙 X),
                                  tidy,
                                end
}

end category_theory.yoneda