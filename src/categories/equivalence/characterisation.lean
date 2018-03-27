-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Tim Baumann, Stephen Morgan, Scott Morrison

import ..equivalence

open categories
open categories.isomorphism
open categories.functor
open categories.natural_transformation

namespace categories.equivalence

universes u₁ u₂

variable {C : Type (u₁+1)}
variable [category C]
variable {D : Type (u₂+1)}
variable [category D]


lemma Equivalences_are_EssentiallySurjective (e : Equivalence C D) : EssentiallySurjective (e.functor) :=
  λ Y : D, ⟨ e.inverse Y, e.isomorphism_2.components Y ⟩

lemma Equivalences_are_Faithful (e : Equivalence C D) : Faithful (e.functor) := {
    injectivity := λ X Y f g w, begin  
                                    have p := congr_arg (@Functor.onMorphisms _ _ _ _ e.inverse  _ _) w,
                                    simp at p,  
                                    exact p
                                end
}


lemma Equivalences_are_Full (e : Equivalence C D) : Full (e.functor) := {
    preimage := λ X Y f, (e.isomorphism_1.components X).inverse ≫ (e.inverse.onMorphisms f) ≫ (e.isomorphism_1.components Y).morphism,
    witness := λ X Y f, begin
                            apply (Equivalences_are_Faithful e.reverse).injectivity,
                            erw ← e.isomorphism_1.naturality_2,
                            tidy,
                        end
}


section
private meta def faithfulness := `[apply faithful.injectivity] -- This is a bit dicey.
local attribute [tidy] faithfulness

-- TODO: weirdly, failing to name `faithful` causes an error.
definition Fully_Faithful_EssentiallySurjective_Functor_inverse (F : Functor C D) [Full F] [faithful : Faithful F] [es : EssentiallySurjective F] : Functor D C := {
    onObjects := λ X, (es X).1,
    onMorphisms := λ X Y f, preimage F ((es X).2.morphism ≫ f ≫ (es Y).2.inverse)
}

lemma Fully_Faithful_EssentiallySurjective_Functor_is_Equivalence (F : Functor C D) [Full F] [faithful : Faithful F] [es : EssentiallySurjective F] : is_Equivalence' F := {
    inverse := Fully_Faithful_EssentiallySurjective_Functor_inverse F,
    isomorphism_1 := NaturalIsomorphism.from_components (λ X, preimage_iso F (es (F X)).2) (by obviously), 
    isomorphism_2 := NaturalIsomorphism.from_components (λ Y, (es Y).2)                    (by obviously), 
}
end

end categories.equivalence