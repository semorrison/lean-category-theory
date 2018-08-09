-- Copyright (c) 2018 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Scott Morrison

import categories.equivalence
import categories.types

namespace category_theory

universe u

class Concrete (C : Type (u+1)) [large_category C] := 
  (fibre_functor : C ↝ (Type u))
  (faithfulness : Faithful fibre_functor . obviously)

definition FibreFunctor (C : Type (u+1)) [large_category C] [concrete : Concrete C] := concrete.fibre_functor

instance : Concrete (Type u) := 
{ fibre_functor := functor.id _ }

end category_theory