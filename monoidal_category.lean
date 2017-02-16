-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Stephen Morgan, Scott Morrison
import .category
import .functor
import .natural_transformation
import .products

--set_option pp.universes true

open tqft.categories
open tqft.categories.functor
open tqft.categories.products
open tqft.categories.natural_transformation

namespace tqft.categories.monoidal_category

universe variables u v

@[reducible] definition TensorProduct ( C: Category ) := Functor ( C × C ) C

structure PreMonoidalCategory
  -- this is only for internal use: it has a tensor product, but no associator at all
  -- it's not interesting mathematically, but may allow us to introduce usable notation for the tensor product
  extends carrier : Category :=
  (tensor : TensorProduct carrier)
  (tensor_unit : Obj)

instance PreMonoidalCategory_coercion : has_coe PreMonoidalCategory Category := 
  ⟨PreMonoidalCategory.to_Category⟩

definition left_associated_triple_tensor ( C : PreMonoidalCategory ) : Functor ((C × C) × C) C :=
  FunctorComposition (C^.tensor × IdentityFunctor C) C^.tensor
definition right_associated_triple_tensor ( C : PreMonoidalCategory ) : Functor (C × (C × C)) C :=
  FunctorComposition (IdentityFunctor C × C^.tensor) C^.tensor

definition Associator ( C : PreMonoidalCategory ) := 
  NaturalTransformation 
    (left_associated_triple_tensor C) 
    (FunctorComposition (ProductCategoryAssociator C C C) (right_associated_triple_tensor C))

definition associator_components ( C : PreMonoidalCategory ) :=
  Π X Y Z : C^.Obj, C^.Hom (C^.tensor (C^.tensor (X, Y), Z)) (C^.tensor (X, C^.tensor (Y, Z)))

/-
definition associator_to_components { C : PreMonoidalCategory } ( α : Associator C ) : associator_components C := 
begin
 induction α,
 -- TODO how do we even begin here?
 -- I just want to change the goal from producing an instance of `associator_components C` to producing the function that actually represents
 exact sorry
end
-/

/- 
-- In general one can't construct an associator from components, because we need proofs of naturality.
-- One should thus build a tactic, something like `blast_naturality components`
-- which look at the components and then attempts to use automation to construct the proof of naturality. 
-/

structure LaxMonoidalCategory
  extends carrier : PreMonoidalCategory :=
  -- (associator : Associator carrier)
  (associator : Π (X Y Z : Obj),
     Hom (tensor (tensor (X, Y), Z)) (tensor (X, tensor (Y, Z)))) 

-- TODO actually, express the associator as a natural transformation!
/- I tried writing the pentagon, but it doesn't type check. :-(
  (pentagon : Π (A B C D : Obj),
     -- we need to compare:
     -- ((AB)C)D ---> (A(BC))D ---> A((BC)D) ---> A(B(CD))
     -- ((AB)C)D ---> (AB)(CD) ---> A(B(CD))
     compose
       (compose
         (tensor <$> (associator A B C, identity D))
         (associator A (tensor (B, C)) D)
       ) (tensor <$> (identity A, associator B C D)) =
     compose
       (associator (tensor (A, B)) C D)
       (associator A B (tensor (C, D)))

  )
-/
/-
-- TODO (far future)
-- One should prove the first substantial result of this theory: that any two ways to reparenthesize are equal.
-- It requires introducing a representation of a reparenthesization, but the proof should then be an easy induction.
-- It's a good example of something that is so easy for humans, that it better eventually be easy for the computer too!
-/

-- Notice that LaxMonoidalCategory.tensor has a horrible signature...
-- It sure would be nice if it read ... Functor (carrier × carrier) carrier
-- print LaxMonoidalCategory

instance LaxMonoidalCategory_coercion : has_coe LaxMonoidalCategory PreMonoidalCategory :=
  ⟨LaxMonoidalCategory.to_PreMonoidalCategory⟩

structure OplaxMonoidalCategory
  extends carrier : PreMonoidalCategory :=
  -- TODO better name? unfortunately it doesn't yet make sense to say 'inverse_associator'.
  (backwards_associator : Π (X Y Z : Obj),
     Hom (tensor (X, tensor (Y, Z)))  (tensor (tensor (X, Y), Z)))

instance OplaxMonoidalCategory_coercion : has_coe OplaxMonoidalCategory PreMonoidalCategory :=
  ⟨OplaxMonoidalCategory.to_PreMonoidalCategory⟩

structure MonoidalCategory
  extends LaxMonoidalCategory, OplaxMonoidalCategory :=
  (associators_inverses_1: Π (X Y Z : Obj), compose (associator X Y Z) (backwards_associator X Y Z) = identity (tensor (tensor (X, Y), Z)))
  (associators_inverses_2: Π (X Y Z : Obj), compose (backwards_associator X Y Z) (associator X Y Z) = identity (tensor (X, tensor (Y, Z))))

-- Convenience methods which take two arguments, rather than a pair. (This seems to often help the elaborator avoid getting stuck on `prod.mk`.)
@[reducible] definition MonoidalCategory.tensorObjects ( C : MonoidalCategory ) ( X Y : C^.Obj ) : C^.Obj := C^.tensor (X, Y)
@[reducible] definition MonoidalCategory.tensorMorphisms ( C : MonoidalCategory ) { W X Y Z : C^.Obj } ( f : C^.Hom W X ) ( g : C^.Hom Y Z ) : C^.Hom (C^.tensor (W, Y)) (C^.tensor (X, Z)) := C^.tensor^.onMorphisms (f, g)

instance MonoidalCategory_coercion_to_LaxMonoidalCategory : has_coe MonoidalCategory LaxMonoidalCategory := ⟨MonoidalCategory.to_LaxMonoidalCategory⟩
-- instance MonoidalCategory_coercion_to_OplaxMonoidalCategory : has_coe MonoidalCategory OplaxMonoidalCategory := ⟨MonoidalCategory.to_OplaxMonoidalCategory⟩

-- TODO This works, but do we really need to be so explicit??
@[reducible] definition MonoidalCategory.interchange
  ( C : MonoidalCategory )
  { U V W X Y Z: C^.Obj }
  ( f : C^.Hom U V )( g : C^.Hom V W )( h : C^.Hom X Y )( k : C^.Hom Y Z ) : 
  @Functor.onMorphisms _ _ C^.tensor (U, X) (W, Z) ((C^.compose f g), (C^.compose h k)) = C^.compose (@Functor.onMorphisms _ _ C^.tensor (U, X) (V, Y) (f, h)) (@Functor.onMorphisms _ _ C^.tensor (V, Y) (W, Z) (g, k)) :=
  @Functor.functoriality (C × C) C C^.tensor (U, X) (V, Y) (W, Z) (f, h) (g, k)

namespace notations
  infix `⊗`:70 := λ {C : MonoidalCategory} (X Y : C^.Obj),
                    C^.tensorObjects X Y
  infix `⊗`:70 := λ {C : MonoidalCategory} {W X Y Z : C^.Obj}
                     (f : C^.Hom W X) (g : C^.Hom Y Z),
                     C^.tensorMorphisms f g
end notations

-- TODO make this work again
definition tensor_on_left (C: MonoidalCategory.{u v}) (Z: C^.Obj) : Functor.{u v u v} C C :=
  {
    onObjects := λ X, C^.tensorObjects Z X,
    onMorphisms := λ X Y f, C^.tensorMorphisms (C^.identity Z) f,
    identities := begin
                    intros, 
                    -- TODO these next two steps are ridiculous... surely we shouldn't have to do this.
                    assert identities_same : Category.identity.{u v} C = MonoidalCategory.identity C, blast,
                    rewrite identities_same,
                    blast,
                    rewrite Functor.identities (C^.tensor),                
                  end,
    functoriality := sorry
                    --  begin
                    --    blast,
                    --    assert compositions_same : Category.compose C = MonoidalCategory.compose C, blast,
                    --    rewrite compositions_same,
                    --    rewrite C^.interchange,
                    --    exact sorry
                    --  end
  }
  --

/-
-- I don't really understand why the universe annotations are needed in Braiding and in squaredBraiding.
-- My guess is that it is related to
-- https://groups.google.com/d/msg/lean-user/3qzchWkut0g/0QR6_cS8AgAJ
-/

end tqft.categories.monoidal_category
