-- -- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- -- Released under Apache 2.0 license as described in the file LICENSE.
-- -- Authors: Scott Morrison

-- import category_theory.limits.equalizers
-- import category_theory.abelian.monic

-- open category_theory
-- open category_theory.limits

-- namespace category_theory.universal.monic

-- universes u v
-- variables {C : Type u} [category.{u v} C] {X Y Z : C}

-- structure regular_mono (f : X ⟶ Y) :=
-- (Z : C)
-- (a b : Y ⟶ Z)
-- (w : f ≫ a = f ≫ b)
-- (e : is_equalizer ⟨ ⟨ X ⟩, f, w ⟩)

-- -- EXERCISE
-- -- def SplitMonic_implies_RegularMonic
-- --   {f : Hom X Y} 
-- --   (s : SplitMonic f) : RegularMonic f := sorry

-- -- EXERCISE
-- -- def RegularMonic_implies_Monic
-- --   {f : Hom X Y} 
-- --   (s : RegularMonic f) : Monic f := sorry

-- structure regular_epi (f : Y ⟶ Z) :=
-- (X : C)
-- (a b : X ⟶ Y)
-- (w : a ≫ f = b ≫ f)
-- (c : is_coequalizer ⟨ ⟨ Z ⟩, f, w ⟩)

-- end category_theory.universal.monic