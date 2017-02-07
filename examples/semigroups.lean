-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Stephen Morgan, Scott Morrison

import ..category
import ..monoidal_category

namespace tqft.categories.examples.semigroups

universe variables u

open tqft.categories

set_option pp.universes true

structure semigroup_morphism { α β : Type u } ( s : semigroup α ) ( t: semigroup β ) :=
  (map: α → β)
  (multiplicative : ∀ x y : α, map(x * y) = map(x) * map(y))

attribute [simp] semigroup_morphism.multiplicative

instance monoid_semigroup_to_map { α β : Type u } { s : semigroup α } { t: semigroup β } : has_coe_to_fun (semigroup_morphism s t) :=
{ F   := λ f, Π x : α, β,
  coe := semigroup_morphism.map }

@[reducible] definition semigroup_identity { α : Type u } ( s: semigroup α ) : semigroup_morphism s s := ⟨ id, ♮ ⟩

@[reducible] definition semigroup_morphism_composition
  { α β γ : Type u } { s: semigroup α } { t: semigroup β } { u: semigroup γ}
  ( f: semigroup_morphism s t ) ( g: semigroup_morphism t u ) : semigroup_morphism s u :=
{
  map := λ x, g (f x),
  multiplicative := begin blast, simp end
}

lemma semigroup_morphism_pointwise_equality
  { α β : Type u } { s : semigroup α } { t: semigroup β }
  ( f g : semigroup_morphism s t )
  ( w : ∀ x : α, f x = g x) : f = g :=
/-
-- This proof is identical to that of the lemma NaturalTransformations_componentwise_equal.
-- TODO: automate!
-/
begin
    induction f with fc,
    induction g with gc,
    have hc : fc = gc, from funext w,
    by subst hc
end

@[reducible] definition CategoryOfSemigroups : Category := 
{
    Obj := Σ α : Type u, semigroup α,
    Hom := λ s t, semigroup_morphism s.2 t.2,

    identity := λ s, semigroup_identity s.2,
    compose  := λ _ _ _ f g, semigroup_morphism_composition f g,

    /-
    -- These proofs are a bit tedious, how do we automate?
    -/
    left_identity  := begin intros, apply semigroup_morphism_pointwise_equality, blast end,
    right_identity := begin intros, apply semigroup_morphism_pointwise_equality, blast end,
    associativity  := ♮
}

open tqft.categories.monoidal_category

@[reducible] definition semigroup_product { α β : Type u } ( s : semigroup α ) ( t: semigroup β ) : semigroup (α × β) := {
  mul := λ p q, (p^.fst * q^.fst, p^.snd * q^.snd),
  -- From https://groups.google.com/d/msg/lean-user/bVs5FdjClp4/cbDZOqq_BAAJ
  mul_assoc := begin
                intros,
                simp [@mul.equations._eqn_1 (α × β)],
                dsimp,
                simp
              end
}

definition semigroup_morphism_product
  { α β γ δ : Type u }
  { s_f : semigroup α } { s_g: semigroup β } { t_f : semigroup γ } { t_g: semigroup δ }
  ( f : semigroup_morphism s_f t_f ) ( g : semigroup_morphism s_g t_g )
  : semigroup_morphism (semigroup_product s_f s_g) (semigroup_product t_f t_g) := {
  map := λ p, (f p.1, g p.2),
  multiplicative :=
    begin
      -- cf https://groups.google.com/d/msg/lean-user/bVs5FdjClp4/tfHiVjLIBAAJ
      intros,
      unfold mul has_mul.mul,
      dsimp,
      simp
    end
}

definition trivial_semigroup: semigroup punit := {
  mul := λ _ _, punit.star,
  mul_assoc := ♮
}

open tqft.categories.products

definition MonoidalCategoryOfSemigroups : MonoidalCategory := {
  CategoryOfSemigroups.{u} with
  tensor               := {
    onObjects     := λ p, sigma.mk (p.1.1 × p.2.1) (semigroup_product p.1.2 p.2.2),
    onMorphisms   := λ s t f, semigroup_morphism_product f.1 f.2,
    identities    := begin
                      abstract tensor_identities { intros, apply semigroup_morphism_pointwise_equality, intros, induction x, blast }
                     end,
    functoriality := ♮
  },
  tensor_unit          := sigma.mk punit trivial_semigroup, -- punit is just a universe-parameterized version of unit
  associator           := begin
                            abstract associator {
                              intros,
                              exact {
                                map := λ t, (t.1.1, (t.1.2, t.2)),
                                multiplicative := ♮
                              }
                            }
                          end,
  backwards_associator := begin
                            abstract backwards_associator {
                              intros,
                              exact {
                                map := λ t, ((t.1, t.2.1), t.2.2),
                                multiplicative := ♮
                              }
                            }
                          end,
  associators_inverses_1 := begin
                              abstract {
                                intros, 
                                apply semigroup_morphism_pointwise_equality, 
                                intros, 
                                blast,
                                delta MonoidalCategoryOfSemigroups.backwards_associator, dsimp,
                                delta MonoidalCategoryOfSemigroups.associator, dsimp, 
                                induction x with a b,
                                induction a,
                                blast
                              }
                            end,
  associators_inverses_2 := begin
                              abstract {
                                intros, 
                                apply semigroup_morphism_pointwise_equality, 
                                intros, 
                                blast,
                                delta MonoidalCategoryOfSemigroups.backwards_associator, dsimp,
                                delta MonoidalCategoryOfSemigroups.associator, dsimp, 
                                induction x with a b,
                                induction b,
                                blast
                              }
                            end,
  interchange          := begin
                            intros, blast
                          end
}

open tqft.categories.natural_transformation

-- definition SymmetricMonoidalCategoryOfSemigroups : SymmetricMonoidalCategory := {
--   MonoidalCategoryOfSemigroups.{u} with
--   braiding             := {
--     morphism  := {
--       components := begin
--                       abstract braiding {
--                         intros,
--                         exact {
--                           map := λ p, (p.2, p.1),
--                           multiplicative := ♮
--                         }
--                       }
--                     end,
--       naturality := ♮
--     },
--     inverse   := {
--       components := begin
--                       abstract inverse_braiding {
--                         intros,
--                         exact {
--                           map := λ p, (p.2, p.1),
--                           multiplicative := ♮
--                         }
--                       }
--                     end,
--       naturality := ♮
--     },
--     witness_1 := begin
--                    apply NaturalTransformations_componentwise_equal,
--                    blast,
--                    -- now what? something like?
--                   --  delta SymmetricMonoidalCategoryOfSemigroups.braiding, dsimp,
--                   --  delta SymmetricMonoidalCategoryOfSemigroups.inverse_braiding, dsimp,
--                   --  blast
--                   exact sorry
--                  end,
--     witness_2 := sorry
--   },
--   symmetry := sorry
-- }

end tqft.categories.examples.semigroups
