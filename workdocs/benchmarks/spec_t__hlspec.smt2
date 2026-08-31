(set-logic ALL)


;; Prelude

;; AIR prelude
(declare-sort %%Function%% 0)

(declare-sort FuelId 0)
(declare-sort Fuel 0)
(declare-const zero Fuel)
(declare-fun succ (Fuel) Fuel)
(declare-fun fuel_bool (FuelId) Bool)
(declare-fun fuel_bool_default (FuelId) Bool)
(declare-const fuel_defaults Bool)
(assert
 (=>
  fuel_defaults
  (forall ((id FuelId)) (!
    (= (fuel_bool id) (fuel_bool_default id))
    :pattern ((fuel_bool id))
    :qid prelude_fuel_defaults
))))
(declare-sort Char 0)
(declare-fun char%from_unicode (Int) Char)
(declare-fun char%to_unicode (Char) Int)
(declare-sort StrSlice 0)
(declare-fun str%strslice_is_ascii (StrSlice) Bool)
(declare-fun str%strslice_len (StrSlice) Int)
(declare-fun str%strslice_get_char (StrSlice Int) Char)
(declare-fun str%new_strlit (Int) StrSlice)
(declare-fun str%from_strlit (StrSlice) Int)
(declare-datatypes ((fndef 0)) (((fndef_singleton))))
(declare-sort Poly 0)
(declare-sort Height 0)
(declare-fun I (Int) Poly)
(declare-fun B (Bool) Poly)
(declare-fun F (fndef) Poly)
(declare-fun %I (Poly) Int)
(declare-fun %B (Poly) Bool)
(declare-fun %F (Poly) fndef)
(declare-fun S (StrSlice) Poly)
(declare-fun %S (Poly) StrSlice)
(declare-fun C (Char) Poly)
(declare-fun %C (Poly) Char)
(declare-sort Type 0)
(declare-const BOOL Type)
(declare-const INT Type)
(declare-const NAT Type)
(declare-const STRSLICE Type)
(declare-const CHAR Type)
(declare-fun UINT (Int) Type)
(declare-fun SINT (Int) Type)
(declare-fun CONST_INT (Int) Type)
(declare-sort Dcr 0)
(declare-const $ Dcr)
(declare-fun REF (Dcr) Dcr)
(declare-fun MUT_REF (Dcr) Dcr)
(declare-fun BOX (Dcr) Dcr)
(declare-fun RC (Dcr) Dcr)
(declare-fun ARC (Dcr) Dcr)
(declare-fun GHOST (Dcr) Dcr)
(declare-fun TRACKED (Dcr) Dcr)
(declare-fun NEVER (Dcr) Dcr)
(declare-fun ARRAY (Dcr Type Dcr Type) Type)
(declare-fun SLICE (Dcr Type) Type)
(declare-fun has_type (Poly Type) Bool)
(declare-fun as_type (Poly Type) Poly)
(declare-fun mk_fun (%%Function%%) %%Function%%)
(declare-fun const_int (Type) Int)
(assert
 (forall ((i Int)) (!
   (= i (const_int (CONST_INT i)))
   :pattern ((CONST_INT i))
   :qid prelude_type_id_const_int
)))
(assert
 (forall ((b Bool)) (!
   (has_type (B b) BOOL)
   :pattern ((has_type (B b) BOOL))
   :qid prelude_has_type_bool
)))
(assert
 (forall ((x Poly) (t Type)) (!
   (and
    (has_type (as_type x t) t)
    (=>
     (has_type x t)
     (= x (as_type x t))
   ))
   :pattern ((as_type x t))
   :qid prelude_as_type
)))
(assert
 (forall ((x %%Function%%)) (!
   (= (mk_fun x) x)
   :pattern ((mk_fun x))
   :qid prelude_mk_fun
)))
(assert
 (forall ((x Bool)) (!
   (= x (%B (B x)))
   :pattern ((B x))
   :qid prelude_unbox_box_bool
)))
(assert
 (forall ((x Int)) (!
   (= x (%I (I x)))
   :pattern ((I x))
   :qid prelude_unbox_box_int
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x BOOL)
    (= x (B (%B x)))
   )
   :pattern ((has_type x BOOL))
   :qid prelude_box_unbox_bool
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x INT)
    (= x (I (%I x)))
   )
   :pattern ((has_type x INT))
   :qid prelude_box_unbox_int
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x NAT)
    (= x (I (%I x)))
   )
   :pattern ((has_type x NAT))
   :qid prelude_box_unbox_nat
)))
(assert
 (forall ((bits Int) (x Poly)) (!
   (=>
    (has_type x (UINT bits))
    (= x (I (%I x)))
   )
   :pattern ((has_type x (UINT bits)))
   :qid prelude_box_unbox_uint
)))
(assert
 (forall ((bits Int) (x Poly)) (!
   (=>
    (has_type x (SINT bits))
    (= x (I (%I x)))
   )
   :pattern ((has_type x (SINT bits)))
   :qid prelude_box_unbox_sint
)))
(assert
 (forall ((x Int)) (!
   (= (str%from_strlit (str%new_strlit x)) x)
   :pattern ((str%new_strlit x))
   :qid prelude_strlit_injective
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x STRSLICE)
    (= x (S (%S x)))
   )
   :pattern ((has_type x STRSLICE))
   :qid prelude_box_unbox_strslice
)))
(assert
 (forall ((x StrSlice)) (!
   (= x (%S (S x)))
   :pattern ((S x))
   :qid prelude_unbox_box_strslice
)))
(assert
 (forall ((x StrSlice)) (!
   (has_type (S x) STRSLICE)
   :pattern ((has_type (S x) STRSLICE))
   :qid prelude_has_type_strslice
)))
(declare-fun ext_eq (Bool Type Poly Poly) Bool)
(assert
 (forall ((deep Bool) (t Type) (x Poly) (y Poly)) (!
   (= (= x y) (ext_eq deep t x y))
   :pattern ((ext_eq deep t x y))
   :qid prelude_ext_eq
)))
(declare-const SZ Int)
(assert
 (= SZ 64)
)
(declare-fun uHi (Int) Int)
(declare-fun iLo (Int) Int)
(declare-fun iHi (Int) Int)
(assert
 (= (uHi 8) 256)
)
(assert
 (= (uHi 16) 65536)
)
(assert
 (= (uHi 32) 4294967296)
)
(assert
 (= (uHi 64) 18446744073709551616)
)
(assert
 (= (uHi 128) (+ 1 340282366920938463463374607431768211455))
)
(assert
 (= (iLo 8) (- 128))
)
(assert
 (= (iLo 16) (- 32768))
)
(assert
 (= (iLo 32) (- 2147483648))
)
(assert
 (= (iLo 64) (- 9223372036854775808))
)
(assert
 (= (iLo 128) (- 170141183460469231731687303715884105728))
)
(assert
 (= (iHi 8) 128)
)
(assert
 (= (iHi 16) 32768)
)
(assert
 (= (iHi 32) 2147483648)
)
(assert
 (= (iHi 64) 9223372036854775808)
)
(assert
 (= (iHi 128) 170141183460469231731687303715884105728)
)
(declare-fun nClip (Int) Int)
(declare-fun uClip (Int Int) Int)
(declare-fun iClip (Int Int) Int)
(assert
 (forall ((i Int)) (!
   (and
    (<= 0 (nClip i))
    (=>
     (<= 0 i)
     (= i (nClip i))
   ))
   :pattern ((nClip i))
   :qid prelude_nat_clip
)))
(assert
 (forall ((bits Int) (i Int)) (!
   (and
    (<= 0 (uClip bits i))
    (< (uClip bits i) (uHi bits))
    (=>
     (and
      (<= 0 i)
      (< i (uHi bits))
     )
     (= i (uClip bits i))
   ))
   :pattern ((uClip bits i))
   :qid prelude_u_clip
)))
(assert
 (forall ((bits Int) (i Int)) (!
   (and
    (<= (iLo bits) (iClip bits i))
    (< (iClip bits i) (iHi bits))
    (=>
     (and
      (<= (iLo bits) i)
      (< i (iHi bits))
     )
     (= i (iClip bits i))
   ))
   :pattern ((iClip bits i))
   :qid prelude_i_clip
)))
(declare-fun uInv (Int Int) Bool)
(declare-fun iInv (Int Int) Bool)
(assert
 (forall ((bits Int) (i Int)) (!
   (= (uInv bits i) (and
     (<= 0 i)
     (< i (uHi bits))
   ))
   :pattern ((uInv bits i))
   :qid prelude_u_inv
)))
(assert
 (forall ((bits Int) (i Int)) (!
   (= (iInv bits i) (and
     (<= (iLo bits) i)
     (< i (iHi bits))
   ))
   :pattern ((iInv bits i))
   :qid prelude_i_inv
)))
(assert
 (forall ((x Int)) (!
   (has_type (I x) INT)
   :pattern ((has_type (I x) INT))
   :qid prelude_has_type_int
)))
(assert
 (forall ((x Int)) (!
   (=>
    (<= 0 x)
    (has_type (I x) NAT)
   )
   :pattern ((has_type (I x) NAT))
   :qid prelude_has_type_nat
)))
(assert
 (forall ((bits Int) (x Int)) (!
   (=>
    (uInv bits x)
    (has_type (I x) (UINT bits))
   )
   :pattern ((has_type (I x) (UINT bits)))
   :qid prelude_has_type_uint
)))
(assert
 (forall ((bits Int) (x Int)) (!
   (=>
    (iInv bits x)
    (has_type (I x) (SINT bits))
   )
   :pattern ((has_type (I x) (SINT bits)))
   :qid prelude_has_type_sint
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x NAT)
    (<= 0 (%I x))
   )
   :pattern ((has_type x NAT))
   :qid prelude_unbox_int
)))
(assert
 (forall ((bits Int) (x Poly)) (!
   (=>
    (has_type x (UINT bits))
    (uInv bits (%I x))
   )
   :pattern ((has_type x (UINT bits)))
   :qid prelude_unbox_uint
)))
(assert
 (forall ((bits Int) (x Poly)) (!
   (=>
    (has_type x (SINT bits))
    (iInv bits (%I x))
   )
   :pattern ((has_type x (SINT bits)))
   :qid prelude_unbox_sint
)))
(declare-fun Add (Int Int) Int)
(declare-fun Sub (Int Int) Int)
(declare-fun Mul (Int Int) Int)
(declare-fun EucDiv (Int Int) Int)
(declare-fun EucMod (Int Int) Int)
(assert
 (forall ((x Int) (y Int)) (!
   (= (Add x y) (+ x y))
   :pattern ((Add x y))
   :qid prelude_add
)))
(assert
 (forall ((x Int) (y Int)) (!
   (= (Sub x y) (- x y))
   :pattern ((Sub x y))
   :qid prelude_sub
)))
(assert
 (forall ((x Int) (y Int)) (!
   (= (Mul x y) (* x y))
   :pattern ((Mul x y))
   :qid prelude_mul
)))
(assert
 (forall ((x Int) (y Int)) (!
   (= (EucDiv x y) (div x y))
   :pattern ((EucDiv x y))
   :qid prelude_eucdiv
)))
(assert
 (forall ((x Int) (y Int)) (!
   (= (EucMod x y) (mod x y))
   :pattern ((EucMod x y))
   :qid prelude_eucmod
)))
(assert
 (forall ((x Int) (y Int)) (!
   (=>
    (and
     (<= 0 x)
     (<= 0 y)
    )
    (<= 0 (Mul x y))
   )
   :pattern ((Mul x y))
   :qid prelude_mul_nats
)))
(assert
 (forall ((x Int) (y Int)) (!
   (=>
    (and
     (<= 0 x)
     (< 0 y)
    )
    (and
     (<= 0 (EucDiv x y))
     (<= (EucDiv x y) x)
   ))
   :pattern ((EucDiv x y))
   :qid prelude_div_unsigned_in_bounds
)))
(assert
 (forall ((x Int) (y Int)) (!
   (=>
    (and
     (<= 0 x)
     (< 0 y)
    )
    (and
     (<= 0 (EucMod x y))
     (< (EucMod x y) y)
   ))
   :pattern ((EucMod x y))
   :qid prelude_mod_unsigned_in_bounds
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x CHAR)
    (= x (C (%C x)))
   )
   :pattern ((has_type x CHAR))
   :qid prelude_box_unbox_char
)))
(assert
 (forall ((x Char)) (!
   (= x (%C (C x)))
   :pattern ((C x))
   :qid prelude_unbox_box_char
)))
(assert
 (forall ((x Char)) (!
   (has_type (C x) CHAR)
   :pattern ((has_type (C x) CHAR))
   :qid prelude_has_type_char
)))
(assert
 (forall ((x Int)) (!
   (=>
    (and
     (<= 0 x)
     (< x (uHi 32))
    )
    (= x (char%to_unicode (char%from_unicode x)))
   )
   :pattern ((char%from_unicode x))
   :qid prelude_char_injective
)))
(assert
 (forall ((c Char)) (!
   (and
    (<= 0 (char%to_unicode c))
    (< (char%to_unicode c) (uHi 32))
   )
   :pattern ((char%to_unicode c))
   :qid prelude_to_unicode_bounds
)))
(declare-fun uintxor (Int Poly Poly) Int)
(declare-fun uintand (Int Poly Poly) Int)
(declare-fun uintor (Int Poly Poly) Int)
(declare-fun uintshr (Int Poly Poly) Int)
(declare-fun uintshl (Int Poly Poly) Int)
(declare-fun uintnot (Int Poly) Int)
(declare-fun singular_mod (Int Int) Int)
(assert
 (forall ((x Int) (y Int)) (!
   (=>
    (not (= y 0))
    (= (EucMod x y) (singular_mod x y))
   )
   :pattern ((singular_mod x y))
   :qid prelude_singularmod
)))
(declare-fun closure_req (Type Dcr Type Poly Poly) Bool)
(declare-fun closure_ens (Type Dcr Type Poly Poly Poly) Bool)
(declare-fun height (Poly) Height)
(declare-fun height_lt (Height Height) Bool)
(declare-fun fun_from_recursive_field (Poly) Poly)
(declare-fun check_decrease_int (Int Int Bool) Bool)
(assert
 (forall ((cur Int) (prev Int) (otherwise Bool)) (!
   (= (check_decrease_int cur prev otherwise) (or
     (and
      (<= 0 cur)
      (< cur prev)
     )
     (and
      (= cur prev)
      otherwise
   )))
   :pattern ((check_decrease_int cur prev otherwise))
   :qid prelude_check_decrease_int
)))
(declare-fun check_decrease_height (Poly Poly Bool) Bool)
(assert
 (forall ((cur Poly) (prev Poly) (otherwise Bool)) (!
   (= (check_decrease_height cur prev otherwise) (or
     (height_lt (height cur) (height prev))
     (and
      (= (height cur) (height prev))
      otherwise
   )))
   :pattern ((check_decrease_height cur prev otherwise))
   :qid prelude_check_decrease_height
)))
(declare-fun partial-order (Height Height) Bool)
(assert
 (forall ((x Height)) (partial-order x x))
)
(assert
 (forall ((x Height) (y Height)) (=>
   (and
    (partial-order x y)
    (partial-order y x)
   )
   (= x y)
)))
(assert
 (forall ((x Height) (y Height) (z Height)) (=>
   (and
    (partial-order x y)
    (partial-order y z)
   )
   (partial-order x z)
)))
(assert
 (forall ((x Height) (y Height)) (= (height_lt x y) (and
    (partial-order x y)
    (not (= x y))
))))

;; MODULE 'module spec_t::hlspec'

;; Fuel
(declare-const fuel%vstd!map.impl&%0.spec_index. FuelId)
(declare-const fuel%vstd!map_lib.impl&%0.contains_pair. FuelId)
(declare-const fuel%vstd!seq.impl&%0.spec_index. FuelId)
(declare-const fuel%vstd!set.impl&%0.choose. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_op. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_result. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_Map_vaddr. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_Map_pte. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_Map_result. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_Unmap_result. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr. FuelId)
(declare-const fuel%main!spec_t.hlspec.impl&%0.arrow_Resolve_result. FuelId)
(declare-const fuel%main!spec_t.hlspec.init. FuelId)
(declare-const fuel%main!spec_t.hlspec.mem_domain_from_mappings_contains. FuelId)
(declare-const fuel%main!spec_t.hlspec.mem_domain_from_mappings. FuelId)
(declare-const fuel%main!spec_t.hlspec.step_ReadWrite. FuelId)
(declare-const fuel%main!spec_t.hlspec.step_Map_enabled. FuelId)
(declare-const fuel%main!spec_t.hlspec.step_Map. FuelId)
(declare-const fuel%main!spec_t.hlspec.step_Unmap_enabled. FuelId)
(declare-const fuel%main!spec_t.hlspec.step_Unmap. FuelId)
(declare-const fuel%main!spec_t.hlspec.step_Resolve_enabled. FuelId)
(declare-const fuel%main!spec_t.hlspec.step_Resolve. FuelId)
(declare-const fuel%main!spec_t.hlspec.step_Stutter. FuelId)
(declare-const fuel%main!spec_t.hlspec.next_step. FuelId)
(declare-const fuel%main!spec_t.hlspec.next. FuelId)
(declare-const fuel%main!spec_t.mem.word_index_spec. FuelId)
(declare-const fuel%main!definitions_t.X86_NUM_LAYERS. FuelId)
(declare-const fuel%main!definitions_t.X86_NUM_ENTRIES. FuelId)
(declare-const fuel%main!definitions_t.WORD_SIZE. FuelId)
(declare-const fuel%main!definitions_t.PAGE_SIZE. FuelId)
(declare-const fuel%main!definitions_t.X86_MAX_ENTRY_SIZE. FuelId)
(declare-const fuel%main!definitions_t.PT_BOUND_LOW. FuelId)
(declare-const fuel%main!definitions_t.PT_BOUND_HIGH. FuelId)
(declare-const fuel%main!definitions_t.L3_ENTRY_SIZE. FuelId)
(declare-const fuel%main!definitions_t.L2_ENTRY_SIZE. FuelId)
(declare-const fuel%main!definitions_t.L1_ENTRY_SIZE. FuelId)
(declare-const fuel%main!definitions_t.L0_ENTRY_SIZE. FuelId)
(declare-const fuel%main!definitions_t.entry_base_from_index. FuelId)
(declare-const fuel%main!definitions_t.candidate_mapping_in_bounds. FuelId)
(declare-const fuel%main!definitions_t.candidate_mapping_overlaps_existing_vmem. FuelId)
(declare-const fuel%main!definitions_t.candidate_mapping_overlaps_existing_pmem. FuelId)
(declare-const fuel%main!definitions_t.aligned. FuelId)
(declare-const fuel%main!definitions_t.between. FuelId)
(declare-const fuel%main!definitions_t.impl&%0.is_ErrOverlap. FuelId)
(declare-const fuel%main!definitions_t.impl&%0.is_Ok. FuelId)
(declare-const fuel%main!definitions_t.impl&%1.is_ErrNoSuchMapping. FuelId)
(declare-const fuel%main!definitions_t.impl&%1.is_Ok. FuelId)
(declare-const fuel%main!definitions_t.impl&%7.is_Pagefault. FuelId)
(declare-const fuel%main!definitions_t.impl&%7.is_Value. FuelId)
(declare-const fuel%main!definitions_t.impl&%7.get_Value_0. FuelId)
(declare-const fuel%main!definitions_t.impl&%9.is_Pagefault. FuelId)
(declare-const fuel%main!definitions_t.impl&%9.is_Ok. FuelId)
(declare-const fuel%main!definitions_t.overlap. FuelId)
(declare-const fuel%main!definitions_t.impl&%15.entry_size. FuelId)
(declare-const fuel%main!definitions_t.impl&%15.num_entries. FuelId)
(declare-const fuel%main!definitions_t.impl&%15.upper_vaddr. FuelId)
(declare-const fuel%main!definitions_t.impl&%15.inv. FuelId)
(declare-const fuel%main!definitions_t.impl&%15.entry_size_is_next_layer_size. FuelId)
(declare-const fuel%main!definitions_t.impl&%15.entry_base. FuelId)
(declare-const fuel%main!definitions_t.x86_arch_spec. FuelId)
(assert
 (distinct fuel%vstd!map.impl&%0.spec_index. fuel%vstd!map_lib.impl&%0.contains_pair.
  fuel%vstd!seq.impl&%0.spec_index. fuel%vstd!set.impl&%0.choose. fuel%main!spec_t.hlspec.impl&%0.arrow_op.
  fuel%main!spec_t.hlspec.impl&%0.arrow_result. fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr.
  fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op. fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte.
  fuel%main!spec_t.hlspec.impl&%0.arrow_Map_vaddr. fuel%main!spec_t.hlspec.impl&%0.arrow_Map_pte.
  fuel%main!spec_t.hlspec.impl&%0.arrow_Map_result. fuel%main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr.
  fuel%main!spec_t.hlspec.impl&%0.arrow_Unmap_result. fuel%main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr.
  fuel%main!spec_t.hlspec.impl&%0.arrow_Resolve_result. fuel%main!spec_t.hlspec.init.
  fuel%main!spec_t.hlspec.mem_domain_from_mappings_contains. fuel%main!spec_t.hlspec.mem_domain_from_mappings.
  fuel%main!spec_t.hlspec.step_ReadWrite. fuel%main!spec_t.hlspec.step_Map_enabled.
  fuel%main!spec_t.hlspec.step_Map. fuel%main!spec_t.hlspec.step_Unmap_enabled. fuel%main!spec_t.hlspec.step_Unmap.
  fuel%main!spec_t.hlspec.step_Resolve_enabled. fuel%main!spec_t.hlspec.step_Resolve.
  fuel%main!spec_t.hlspec.step_Stutter. fuel%main!spec_t.hlspec.next_step. fuel%main!spec_t.hlspec.next.
  fuel%main!spec_t.mem.word_index_spec. fuel%main!definitions_t.X86_NUM_LAYERS. fuel%main!definitions_t.X86_NUM_ENTRIES.
  fuel%main!definitions_t.WORD_SIZE. fuel%main!definitions_t.PAGE_SIZE. fuel%main!definitions_t.X86_MAX_ENTRY_SIZE.
  fuel%main!definitions_t.PT_BOUND_LOW. fuel%main!definitions_t.PT_BOUND_HIGH. fuel%main!definitions_t.L3_ENTRY_SIZE.
  fuel%main!definitions_t.L2_ENTRY_SIZE. fuel%main!definitions_t.L1_ENTRY_SIZE. fuel%main!definitions_t.L0_ENTRY_SIZE.
  fuel%main!definitions_t.entry_base_from_index. fuel%main!definitions_t.candidate_mapping_in_bounds.
  fuel%main!definitions_t.candidate_mapping_overlaps_existing_vmem. fuel%main!definitions_t.candidate_mapping_overlaps_existing_pmem.
  fuel%main!definitions_t.aligned. fuel%main!definitions_t.between. fuel%main!definitions_t.impl&%0.is_ErrOverlap.
  fuel%main!definitions_t.impl&%0.is_Ok. fuel%main!definitions_t.impl&%1.is_ErrNoSuchMapping.
  fuel%main!definitions_t.impl&%1.is_Ok. fuel%main!definitions_t.impl&%7.is_Pagefault.
  fuel%main!definitions_t.impl&%7.is_Value. fuel%main!definitions_t.impl&%7.get_Value_0.
  fuel%main!definitions_t.impl&%9.is_Pagefault. fuel%main!definitions_t.impl&%9.is_Ok.
  fuel%main!definitions_t.overlap. fuel%main!definitions_t.impl&%15.entry_size. fuel%main!definitions_t.impl&%15.num_entries.
  fuel%main!definitions_t.impl&%15.upper_vaddr. fuel%main!definitions_t.impl&%15.inv.
  fuel%main!definitions_t.impl&%15.entry_size_is_next_layer_size. fuel%main!definitions_t.impl&%15.entry_base.
  fuel%main!definitions_t.x86_arch_spec.
))

;; Datatypes
(declare-sort vstd!map.Map<nat./nat.>. 0)
(declare-sort vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. 0)
(declare-sort vstd!seq.Seq<main!definitions_t.ArchLayer.>. 0)
(declare-sort vstd!set.Set<nat.>. 0)
(declare-datatypes ((core!option.Option. 0) (main!spec_t.hlspec.AbstractConstants. 0)
  (main!spec_t.hlspec.AbstractVariables. 0) (main!spec_t.hlspec.AbstractStep. 0) (main!definitions_t.MapResult.
   0
  ) (main!definitions_t.UnmapResult. 0) (main!definitions_t.ResolveResult. 0) (main!definitions_t.LoadResult.
   0
  ) (main!definitions_t.StoreResult. 0) (main!definitions_t.RWOp. 0) (main!definitions_t.MemRegion.
   0
  ) (main!definitions_t.Flags. 0) (main!definitions_t.PageTableEntry. 0) (main!definitions_t.ArchLayer.
   0
  ) (main!definitions_t.Arch. 0) (tuple%0. 0) (tuple%2. 0)
 ) (((core!option.Option./None) (core!option.Option./Some (core!option.Option./Some/?0
     Poly
   ))
  ) ((main!spec_t.hlspec.AbstractConstants./AbstractConstants (main!spec_t.hlspec.AbstractConstants./AbstractConstants/?phys_mem_size
     Int
   ))
  ) ((main!spec_t.hlspec.AbstractVariables./AbstractVariables (main!spec_t.hlspec.AbstractVariables./AbstractVariables/?mem
     vstd!map.Map<nat./nat.>.
    ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/?mappings vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.)
   )
  ) ((main!spec_t.hlspec.AbstractStep./ReadWrite (main!spec_t.hlspec.AbstractStep./ReadWrite/?vaddr
     Int
    ) (main!spec_t.hlspec.AbstractStep./ReadWrite/?op main!definitions_t.RWOp.) (main!spec_t.hlspec.AbstractStep./ReadWrite/?pte
     core!option.Option.
    )
   ) (main!spec_t.hlspec.AbstractStep./Map (main!spec_t.hlspec.AbstractStep./Map/?vaddr
     Int
    ) (main!spec_t.hlspec.AbstractStep./Map/?pte main!definitions_t.PageTableEntry.)
    (main!spec_t.hlspec.AbstractStep./Map/?result main!definitions_t.MapResult.)
   ) (main!spec_t.hlspec.AbstractStep./Unmap (main!spec_t.hlspec.AbstractStep./Unmap/?vaddr
     Int
    ) (main!spec_t.hlspec.AbstractStep./Unmap/?result main!definitions_t.UnmapResult.)
   ) (main!spec_t.hlspec.AbstractStep./Resolve (main!spec_t.hlspec.AbstractStep./Resolve/?vaddr
     Int
    ) (main!spec_t.hlspec.AbstractStep./Resolve/?result main!definitions_t.ResolveResult.)
   ) (main!spec_t.hlspec.AbstractStep./Stutter)
  ) ((main!definitions_t.MapResult./ErrOverlap) (main!definitions_t.MapResult./Ok))
  ((main!definitions_t.UnmapResult./ErrNoSuchMapping) (main!definitions_t.UnmapResult./Ok))
  ((main!definitions_t.ResolveResult./ErrUnmapped) (main!definitions_t.ResolveResult./Ok
    (main!definitions_t.ResolveResult./Ok/?0 Int) (main!definitions_t.ResolveResult./Ok/?1
     main!definitions_t.PageTableEntry.
   ))
  ) ((main!definitions_t.LoadResult./Pagefault) (main!definitions_t.LoadResult./Value
    (main!definitions_t.LoadResult./Value/?0 Int)
   )
  ) ((main!definitions_t.StoreResult./Pagefault) (main!definitions_t.StoreResult./Ok))
  ((main!definitions_t.RWOp./Store (main!definitions_t.RWOp./Store/?new_value Int) (main!definitions_t.RWOp./Store/?result
     main!definitions_t.StoreResult.
    )
   ) (main!definitions_t.RWOp./Load (main!definitions_t.RWOp./Load/?is_exec Bool) (main!definitions_t.RWOp./Load/?result
     main!definitions_t.LoadResult.
   ))
  ) ((main!definitions_t.MemRegion./MemRegion (main!definitions_t.MemRegion./MemRegion/?base
     Int
    ) (main!definitions_t.MemRegion./MemRegion/?size Int)
   )
  ) ((main!definitions_t.Flags./Flags (main!definitions_t.Flags./Flags/?is_writable Bool)
    (main!definitions_t.Flags./Flags/?is_supervisor Bool) (main!definitions_t.Flags./Flags/?disable_execute
     Bool
   ))
  ) ((main!definitions_t.PageTableEntry./PageTableEntry (main!definitions_t.PageTableEntry./PageTableEntry/?frame
     main!definitions_t.MemRegion.
    ) (main!definitions_t.PageTableEntry./PageTableEntry/?flags main!definitions_t.Flags.)
   )
  ) ((main!definitions_t.ArchLayer./ArchLayer (main!definitions_t.ArchLayer./ArchLayer/?entry_size
     Int
    ) (main!definitions_t.ArchLayer./ArchLayer/?num_entries Int)
   )
  ) ((main!definitions_t.Arch./Arch (main!definitions_t.Arch./Arch/?layers vstd!seq.Seq<main!definitions_t.ArchLayer.>.)))
  ((tuple%0./tuple%0)) ((tuple%2./tuple%2 (tuple%2./tuple%2/?0 Poly) (tuple%2./tuple%2/?1
     Poly
)))))
(declare-fun core!option.Option./Some/0 (core!option.Option.) Poly)
(declare-fun main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size
 (main!spec_t.hlspec.AbstractConstants.) Int
)
(declare-fun main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (main!spec_t.hlspec.AbstractVariables.)
 vstd!map.Map<nat./nat.>.
)
(declare-fun main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (main!spec_t.hlspec.AbstractVariables.)
 vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
)
(declare-fun main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr (main!spec_t.hlspec.AbstractStep.)
 Int
)
(declare-fun main!spec_t.hlspec.AbstractStep./ReadWrite/op (main!spec_t.hlspec.AbstractStep.)
 main!definitions_t.RWOp.
)
(declare-fun main!spec_t.hlspec.AbstractStep./ReadWrite/pte (main!spec_t.hlspec.AbstractStep.)
 core!option.Option.
)
(declare-fun main!spec_t.hlspec.AbstractStep./Map/vaddr (main!spec_t.hlspec.AbstractStep.)
 Int
)
(declare-fun main!spec_t.hlspec.AbstractStep./Map/pte (main!spec_t.hlspec.AbstractStep.)
 main!definitions_t.PageTableEntry.
)
(declare-fun main!spec_t.hlspec.AbstractStep./Map/result (main!spec_t.hlspec.AbstractStep.)
 main!definitions_t.MapResult.
)
(declare-fun main!spec_t.hlspec.AbstractStep./Unmap/vaddr (main!spec_t.hlspec.AbstractStep.)
 Int
)
(declare-fun main!spec_t.hlspec.AbstractStep./Unmap/result (main!spec_t.hlspec.AbstractStep.)
 main!definitions_t.UnmapResult.
)
(declare-fun main!spec_t.hlspec.AbstractStep./Resolve/vaddr (main!spec_t.hlspec.AbstractStep.)
 Int
)
(declare-fun main!spec_t.hlspec.AbstractStep./Resolve/result (main!spec_t.hlspec.AbstractStep.)
 main!definitions_t.ResolveResult.
)
(declare-fun main!definitions_t.ResolveResult./Ok/0 (main!definitions_t.ResolveResult.)
 Int
)
(declare-fun main!definitions_t.ResolveResult./Ok/1 (main!definitions_t.ResolveResult.)
 main!definitions_t.PageTableEntry.
)
(declare-fun main!definitions_t.LoadResult./Value/0 (main!definitions_t.LoadResult.)
 Int
)
(declare-fun main!definitions_t.RWOp./Store/new_value (main!definitions_t.RWOp.) Int)
(declare-fun main!definitions_t.RWOp./Store/result (main!definitions_t.RWOp.) main!definitions_t.StoreResult.)
(declare-fun main!definitions_t.RWOp./Load/is_exec (main!definitions_t.RWOp.) Bool)
(declare-fun main!definitions_t.RWOp./Load/result (main!definitions_t.RWOp.) main!definitions_t.LoadResult.)
(declare-fun main!definitions_t.MemRegion./MemRegion/base (main!definitions_t.MemRegion.)
 Int
)
(declare-fun main!definitions_t.MemRegion./MemRegion/size (main!definitions_t.MemRegion.)
 Int
)
(declare-fun main!definitions_t.Flags./Flags/is_writable (main!definitions_t.Flags.)
 Bool
)
(declare-fun main!definitions_t.Flags./Flags/is_supervisor (main!definitions_t.Flags.)
 Bool
)
(declare-fun main!definitions_t.Flags./Flags/disable_execute (main!definitions_t.Flags.)
 Bool
)
(declare-fun main!definitions_t.PageTableEntry./PageTableEntry/frame (main!definitions_t.PageTableEntry.)
 main!definitions_t.MemRegion.
)
(declare-fun main!definitions_t.PageTableEntry./PageTableEntry/flags (main!definitions_t.PageTableEntry.)
 main!definitions_t.Flags.
)
(declare-fun main!definitions_t.ArchLayer./ArchLayer/entry_size (main!definitions_t.ArchLayer.)
 Int
)
(declare-fun main!definitions_t.ArchLayer./ArchLayer/num_entries (main!definitions_t.ArchLayer.)
 Int
)
(declare-fun main!definitions_t.Arch./Arch/layers (main!definitions_t.Arch.) vstd!seq.Seq<main!definitions_t.ArchLayer.>.)
(declare-fun tuple%2./tuple%2/0 (tuple%2.) Poly)
(declare-fun tuple%2./tuple%2/1 (tuple%2.) Poly)
(declare-fun TYPE%fun%1. (Dcr Type Dcr Type) Type)
(declare-fun TYPE%core!option.Option. (Dcr Type) Type)
(declare-fun TYPE%vstd!map.Map. (Dcr Type Dcr Type) Type)
(declare-fun TYPE%vstd!seq.Seq. (Dcr Type) Type)
(declare-fun TYPE%vstd!set.Set. (Dcr Type) Type)
(declare-const TYPE%main!spec_t.hlspec.AbstractConstants. Type)
(declare-const TYPE%main!spec_t.hlspec.AbstractVariables. Type)
(declare-const TYPE%main!spec_t.hlspec.AbstractStep. Type)
(declare-const TYPE%main!definitions_t.MapResult. Type)
(declare-const TYPE%main!definitions_t.UnmapResult. Type)
(declare-const TYPE%main!definitions_t.ResolveResult. Type)
(declare-const TYPE%main!definitions_t.LoadResult. Type)
(declare-const TYPE%main!definitions_t.StoreResult. Type)
(declare-const TYPE%main!definitions_t.RWOp. Type)
(declare-const TYPE%main!definitions_t.MemRegion. Type)
(declare-const TYPE%main!definitions_t.Flags. Type)
(declare-const TYPE%main!definitions_t.PageTableEntry. Type)
(declare-const TYPE%main!definitions_t.ArchLayer. Type)
(declare-const TYPE%main!definitions_t.Arch. Type)
(declare-const TYPE%tuple%0. Type)
(declare-fun TYPE%tuple%2. (Dcr Type Dcr Type) Type)
(declare-fun Poly%fun%1. (%%Function%%) Poly)
(declare-fun %Poly%fun%1. (Poly) %%Function%%)
(declare-fun Poly%vstd!map.Map<nat./nat.>. (vstd!map.Map<nat./nat.>.) Poly)
(declare-fun %Poly%vstd!map.Map<nat./nat.>. (Poly) vstd!map.Map<nat./nat.>.)
(declare-fun Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.)
 Poly
)
(declare-fun %Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (Poly) vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.)
(declare-fun Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. (vstd!seq.Seq<main!definitions_t.ArchLayer.>.)
 Poly
)
(declare-fun %Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. (Poly) vstd!seq.Seq<main!definitions_t.ArchLayer.>.)
(declare-fun Poly%vstd!set.Set<nat.>. (vstd!set.Set<nat.>.) Poly)
(declare-fun %Poly%vstd!set.Set<nat.>. (Poly) vstd!set.Set<nat.>.)
(declare-fun Poly%core!option.Option. (core!option.Option.) Poly)
(declare-fun %Poly%core!option.Option. (Poly) core!option.Option.)
(declare-fun Poly%main!spec_t.hlspec.AbstractConstants. (main!spec_t.hlspec.AbstractConstants.)
 Poly
)
(declare-fun %Poly%main!spec_t.hlspec.AbstractConstants. (Poly) main!spec_t.hlspec.AbstractConstants.)
(declare-fun Poly%main!spec_t.hlspec.AbstractVariables. (main!spec_t.hlspec.AbstractVariables.)
 Poly
)
(declare-fun %Poly%main!spec_t.hlspec.AbstractVariables. (Poly) main!spec_t.hlspec.AbstractVariables.)
(declare-fun Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep.)
 Poly
)
(declare-fun %Poly%main!spec_t.hlspec.AbstractStep. (Poly) main!spec_t.hlspec.AbstractStep.)
(declare-fun Poly%main!definitions_t.MapResult. (main!definitions_t.MapResult.) Poly)
(declare-fun %Poly%main!definitions_t.MapResult. (Poly) main!definitions_t.MapResult.)
(declare-fun Poly%main!definitions_t.UnmapResult. (main!definitions_t.UnmapResult.)
 Poly
)
(declare-fun %Poly%main!definitions_t.UnmapResult. (Poly) main!definitions_t.UnmapResult.)
(declare-fun Poly%main!definitions_t.ResolveResult. (main!definitions_t.ResolveResult.)
 Poly
)
(declare-fun %Poly%main!definitions_t.ResolveResult. (Poly) main!definitions_t.ResolveResult.)
(declare-fun Poly%main!definitions_t.LoadResult. (main!definitions_t.LoadResult.)
 Poly
)
(declare-fun %Poly%main!definitions_t.LoadResult. (Poly) main!definitions_t.LoadResult.)
(declare-fun Poly%main!definitions_t.StoreResult. (main!definitions_t.StoreResult.)
 Poly
)
(declare-fun %Poly%main!definitions_t.StoreResult. (Poly) main!definitions_t.StoreResult.)
(declare-fun Poly%main!definitions_t.RWOp. (main!definitions_t.RWOp.) Poly)
(declare-fun %Poly%main!definitions_t.RWOp. (Poly) main!definitions_t.RWOp.)
(declare-fun Poly%main!definitions_t.MemRegion. (main!definitions_t.MemRegion.) Poly)
(declare-fun %Poly%main!definitions_t.MemRegion. (Poly) main!definitions_t.MemRegion.)
(declare-fun Poly%main!definitions_t.Flags. (main!definitions_t.Flags.) Poly)
(declare-fun %Poly%main!definitions_t.Flags. (Poly) main!definitions_t.Flags.)
(declare-fun Poly%main!definitions_t.PageTableEntry. (main!definitions_t.PageTableEntry.)
 Poly
)
(declare-fun %Poly%main!definitions_t.PageTableEntry. (Poly) main!definitions_t.PageTableEntry.)
(declare-fun Poly%main!definitions_t.ArchLayer. (main!definitions_t.ArchLayer.) Poly)
(declare-fun %Poly%main!definitions_t.ArchLayer. (Poly) main!definitions_t.ArchLayer.)
(declare-fun Poly%main!definitions_t.Arch. (main!definitions_t.Arch.) Poly)
(declare-fun %Poly%main!definitions_t.Arch. (Poly) main!definitions_t.Arch.)
(declare-fun Poly%tuple%0. (tuple%0.) Poly)
(declare-fun %Poly%tuple%0. (Poly) tuple%0.)
(declare-fun Poly%tuple%2. (tuple%2.) Poly)
(declare-fun %Poly%tuple%2. (Poly) tuple%2.)
(assert
 (forall ((x %%Function%%)) (!
   (= x (%Poly%fun%1. (Poly%fun%1. x)))
   :pattern ((Poly%fun%1. x))
   :qid internal_crate__fun__1_box_axiom_definition
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (x Poly)) (!
   (=>
    (has_type x (TYPE%fun%1. T%0&. T%0& T%1&. T%1&))
    (= x (Poly%fun%1. (%Poly%fun%1. x)))
   )
   :pattern ((has_type x (TYPE%fun%1. T%0&. T%0& T%1&. T%1&)))
   :qid internal_crate__fun__1_unbox_axiom_definition
)))
(declare-fun %%apply%%0 (%%Function%% Poly) Poly)
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (x %%Function%%)) (!
   (=>
    (forall ((T%0 Poly)) (!
      (=>
       (has_type T%0 T%0&)
       (has_type (%%apply%%0 x T%0) T%1&)
      )
      :pattern ((has_type (%%apply%%0 x T%0) T%1&))
      :qid internal_crate__fun__1_constructor_inner_definition
    ))
    (has_type (Poly%fun%1. (mk_fun x)) (TYPE%fun%1. T%0&. T%0& T%1&. T%1&))
   )
   :pattern ((has_type (Poly%fun%1. (mk_fun x)) (TYPE%fun%1. T%0&. T%0& T%1&. T%1&)))
   :qid internal_crate__fun__1_constructor_definition
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (T%0 Poly) (x %%Function%%))
  (!
   (=>
    (and
     (has_type (Poly%fun%1. x) (TYPE%fun%1. T%0&. T%0& T%1&. T%1&))
     (has_type T%0 T%0&)
    )
    (has_type (%%apply%%0 x T%0) T%1&)
   )
   :pattern ((%%apply%%0 x T%0) (has_type (Poly%fun%1. x) (TYPE%fun%1. T%0&. T%0& T%1&.
      T%1&
   )))
   :qid internal_crate__fun__1_apply_definition
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (T%0 Poly) (x %%Function%%))
  (!
   (=>
    (and
     (has_type (Poly%fun%1. x) (TYPE%fun%1. T%0&. T%0& T%1&. T%1&))
     (has_type T%0 T%0&)
    )
    (height_lt (height (%%apply%%0 x T%0)) (height (fun_from_recursive_field (Poly%fun%1.
        (mk_fun x)
   )))))
   :pattern ((height (%%apply%%0 x T%0)) (has_type (Poly%fun%1. x) (TYPE%fun%1. T%0&. T%0&
      T%1&. T%1&
   )))
   :qid internal_crate__fun__1_height_apply_definition
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (deep Bool) (x Poly) (y Poly))
  (!
   (=>
    (and
     (has_type x (TYPE%fun%1. T%0&. T%0& T%1&. T%1&))
     (has_type y (TYPE%fun%1. T%0&. T%0& T%1&. T%1&))
     (forall ((T%0 Poly)) (!
       (=>
        (has_type T%0 T%0&)
        (ext_eq deep T%1& (%%apply%%0 (%Poly%fun%1. x) T%0) (%%apply%%0 (%Poly%fun%1. y) T%0))
       )
       :pattern ((ext_eq deep T%1& (%%apply%%0 (%Poly%fun%1. x) T%0) (%%apply%%0 (%Poly%fun%1.
           y
          ) T%0
       )))
       :qid internal_crate__fun__1_inner_ext_equal_definition
    )))
    (ext_eq deep (TYPE%fun%1. T%0&. T%0& T%1&. T%1&) x y)
   )
   :pattern ((ext_eq deep (TYPE%fun%1. T%0&. T%0& T%1&. T%1&) x y))
   :qid internal_crate__fun__1_ext_equal_definition
)))
(assert
 (forall ((x vstd!map.Map<nat./nat.>.)) (!
   (= x (%Poly%vstd!map.Map<nat./nat.>. (Poly%vstd!map.Map<nat./nat.>. x)))
   :pattern ((Poly%vstd!map.Map<nat./nat.>. x))
   :qid internal_vstd__map__Map<nat./nat.>_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x (TYPE%vstd!map.Map. $ NAT $ NAT))
    (= x (Poly%vstd!map.Map<nat./nat.>. (%Poly%vstd!map.Map<nat./nat.>. x)))
   )
   :pattern ((has_type x (TYPE%vstd!map.Map. $ NAT $ NAT)))
   :qid internal_vstd__map__Map<nat./nat.>_unbox_axiom_definition
)))
(assert
 (forall ((x vstd!map.Map<nat./nat.>.)) (!
   (has_type (Poly%vstd!map.Map<nat./nat.>. x) (TYPE%vstd!map.Map. $ NAT $ NAT))
   :pattern ((has_type (Poly%vstd!map.Map<nat./nat.>. x) (TYPE%vstd!map.Map. $ NAT $ NAT)))
   :qid internal_vstd__map__Map<nat./nat.>_has_type_always_definition
)))
(assert
 (forall ((x vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.)) (!
   (= x (%Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
      x
   )))
   :pattern ((Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. x))
   :qid internal_vstd__map__Map<nat./main!definitions_t.PageTableEntry.>_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x (TYPE%vstd!map.Map. $ NAT $ TYPE%main!definitions_t.PageTableEntry.))
    (= x (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (%Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
       x
   ))))
   :pattern ((has_type x (TYPE%vstd!map.Map. $ NAT $ TYPE%main!definitions_t.PageTableEntry.)))
   :qid internal_vstd__map__Map<nat./main!definitions_t.PageTableEntry.>_unbox_axiom_definition
)))
(assert
 (forall ((x vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.)) (!
   (has_type (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. x) (TYPE%vstd!map.Map.
     $ NAT $ TYPE%main!definitions_t.PageTableEntry.
   ))
   :pattern ((has_type (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. x)
     (TYPE%vstd!map.Map. $ NAT $ TYPE%main!definitions_t.PageTableEntry.)
   ))
   :qid internal_vstd__map__Map<nat./main!definitions_t.PageTableEntry.>_has_type_always_definition
)))
(assert
 (forall ((x vstd!seq.Seq<main!definitions_t.ArchLayer.>.)) (!
   (= x (%Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
      x
   )))
   :pattern ((Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. x))
   :qid internal_vstd__seq__Seq<main!definitions_t.ArchLayer.>_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x (TYPE%vstd!seq.Seq. $ TYPE%main!definitions_t.ArchLayer.))
    (= x (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. (%Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
       x
   ))))
   :pattern ((has_type x (TYPE%vstd!seq.Seq. $ TYPE%main!definitions_t.ArchLayer.)))
   :qid internal_vstd__seq__Seq<main!definitions_t.ArchLayer.>_unbox_axiom_definition
)))
(assert
 (forall ((x vstd!seq.Seq<main!definitions_t.ArchLayer.>.)) (!
   (has_type (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. x) (TYPE%vstd!seq.Seq.
     $ TYPE%main!definitions_t.ArchLayer.
   ))
   :pattern ((has_type (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. x) (TYPE%vstd!seq.Seq.
      $ TYPE%main!definitions_t.ArchLayer.
   )))
   :qid internal_vstd__seq__Seq<main!definitions_t.ArchLayer.>_has_type_always_definition
)))
(assert
 (forall ((x vstd!set.Set<nat.>.)) (!
   (= x (%Poly%vstd!set.Set<nat.>. (Poly%vstd!set.Set<nat.>. x)))
   :pattern ((Poly%vstd!set.Set<nat.>. x))
   :qid internal_vstd__set__Set<nat.>_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x (TYPE%vstd!set.Set. $ NAT))
    (= x (Poly%vstd!set.Set<nat.>. (%Poly%vstd!set.Set<nat.>. x)))
   )
   :pattern ((has_type x (TYPE%vstd!set.Set. $ NAT)))
   :qid internal_vstd__set__Set<nat.>_unbox_axiom_definition
)))
(assert
 (forall ((x vstd!set.Set<nat.>.)) (!
   (has_type (Poly%vstd!set.Set<nat.>. x) (TYPE%vstd!set.Set. $ NAT))
   :pattern ((has_type (Poly%vstd!set.Set<nat.>. x) (TYPE%vstd!set.Set. $ NAT)))
   :qid internal_vstd__set__Set<nat.>_has_type_always_definition
)))
(assert
 (forall ((x core!option.Option.)) (!
   (= x (%Poly%core!option.Option. (Poly%core!option.Option. x)))
   :pattern ((Poly%core!option.Option. x))
   :qid internal_core__option__Option_box_axiom_definition
)))
(assert
 (forall ((V&. Dcr) (V& Type) (x Poly)) (!
   (=>
    (has_type x (TYPE%core!option.Option. V&. V&))
    (= x (Poly%core!option.Option. (%Poly%core!option.Option. x)))
   )
   :pattern ((has_type x (TYPE%core!option.Option. V&. V&)))
   :qid internal_core__option__Option_unbox_axiom_definition
)))
(assert
 (forall ((V&. Dcr) (V& Type)) (!
   (has_type (Poly%core!option.Option. core!option.Option./None) (TYPE%core!option.Option.
     V&. V&
   ))
   :pattern ((has_type (Poly%core!option.Option. core!option.Option./None) (TYPE%core!option.Option.
      V&. V&
   )))
   :qid internal_core!option.Option./None_constructor_definition
)))
(assert
 (forall ((V&. Dcr) (V& Type) (_0! Poly)) (!
   (=>
    (has_type _0! V&)
    (has_type (Poly%core!option.Option. (core!option.Option./Some _0!)) (TYPE%core!option.Option.
      V&. V&
   )))
   :pattern ((has_type (Poly%core!option.Option. (core!option.Option./Some _0!)) (TYPE%core!option.Option.
      V&. V&
   )))
   :qid internal_core!option.Option./Some_constructor_definition
)))
(assert
 (forall ((x core!option.Option.)) (!
   (= (core!option.Option./Some/0 x) (core!option.Option./Some/?0 x))
   :pattern ((core!option.Option./Some/0 x))
   :qid internal_core!option.Option./Some/0_accessor_definition
)))
(assert
 (forall ((V&. Dcr) (V& Type) (x Poly)) (!
   (=>
    (has_type x (TYPE%core!option.Option. V&. V&))
    (has_type (core!option.Option./Some/0 (%Poly%core!option.Option. x)) V&)
   )
   :pattern ((core!option.Option./Some/0 (%Poly%core!option.Option. x)) (has_type x (TYPE%core!option.Option.
      V&. V&
   )))
   :qid internal_core!option.Option./Some/0_invariant_definition
)))
(assert
 (forall ((x core!option.Option.)) (!
   (=>
    (is-core!option.Option./Some x)
    (height_lt (height (core!option.Option./Some/0 x)) (height (Poly%core!option.Option.
       x
   ))))
   :pattern ((height (core!option.Option./Some/0 x)))
   :qid prelude_datatype_height_core!option.Option./Some/0
)))
(assert
 (forall ((V&. Dcr) (V& Type) (deep Bool) (x Poly) (y Poly)) (!
   (=>
    (and
     (has_type x (TYPE%core!option.Option. V&. V&))
     (has_type y (TYPE%core!option.Option. V&. V&))
     (is-core!option.Option./None (%Poly%core!option.Option. x))
     (is-core!option.Option./None (%Poly%core!option.Option. y))
    )
    (ext_eq deep (TYPE%core!option.Option. V&. V&) x y)
   )
   :pattern ((ext_eq deep (TYPE%core!option.Option. V&. V&) x y))
   :qid internal_core!option.Option./None_ext_equal_definition
)))
(assert
 (forall ((V&. Dcr) (V& Type) (deep Bool) (x Poly) (y Poly)) (!
   (=>
    (and
     (has_type x (TYPE%core!option.Option. V&. V&))
     (has_type y (TYPE%core!option.Option. V&. V&))
     (is-core!option.Option./Some (%Poly%core!option.Option. x))
     (is-core!option.Option./Some (%Poly%core!option.Option. y))
     (ext_eq deep V& (core!option.Option./Some/0 (%Poly%core!option.Option. x)) (core!option.Option./Some/0
       (%Poly%core!option.Option. y)
    )))
    (ext_eq deep (TYPE%core!option.Option. V&. V&) x y)
   )
   :pattern ((ext_eq deep (TYPE%core!option.Option. V&. V&) x y))
   :qid internal_core!option.Option./Some_ext_equal_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractConstants.)) (!
   (= x (%Poly%main!spec_t.hlspec.AbstractConstants. (Poly%main!spec_t.hlspec.AbstractConstants.
      x
   )))
   :pattern ((Poly%main!spec_t.hlspec.AbstractConstants. x))
   :qid internal_main__spec_t__hlspec__AbstractConstants_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractConstants.)
    (= x (Poly%main!spec_t.hlspec.AbstractConstants. (%Poly%main!spec_t.hlspec.AbstractConstants.
       x
   ))))
   :pattern ((has_type x TYPE%main!spec_t.hlspec.AbstractConstants.))
   :qid internal_main__spec_t__hlspec__AbstractConstants_unbox_axiom_definition
)))
(assert
 (forall ((_phys_mem_size! Int)) (!
   (=>
    (<= 0 _phys_mem_size!)
    (has_type (Poly%main!spec_t.hlspec.AbstractConstants. (main!spec_t.hlspec.AbstractConstants./AbstractConstants
       _phys_mem_size!
      )
     ) TYPE%main!spec_t.hlspec.AbstractConstants.
   ))
   :pattern ((has_type (Poly%main!spec_t.hlspec.AbstractConstants. (main!spec_t.hlspec.AbstractConstants./AbstractConstants
       _phys_mem_size!
      )
     ) TYPE%main!spec_t.hlspec.AbstractConstants.
   ))
   :qid internal_main!spec_t.hlspec.AbstractConstants./AbstractConstants_constructor_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractConstants.)) (!
   (= (main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size x) (main!spec_t.hlspec.AbstractConstants./AbstractConstants/?phys_mem_size
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size x))
   :qid internal_main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractConstants.)
    (<= 0 (main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size (%Poly%main!spec_t.hlspec.AbstractConstants.
       x
   ))))
   :pattern ((main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size (%Poly%main!spec_t.hlspec.AbstractConstants.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractConstants.)
   )
   :qid internal_main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size_invariant_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractVariables.)) (!
   (= x (%Poly%main!spec_t.hlspec.AbstractVariables. (Poly%main!spec_t.hlspec.AbstractVariables.
      x
   )))
   :pattern ((Poly%main!spec_t.hlspec.AbstractVariables. x))
   :qid internal_main__spec_t__hlspec__AbstractVariables_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractVariables.)
    (= x (Poly%main!spec_t.hlspec.AbstractVariables. (%Poly%main!spec_t.hlspec.AbstractVariables.
       x
   ))))
   :pattern ((has_type x TYPE%main!spec_t.hlspec.AbstractVariables.))
   :qid internal_main__spec_t__hlspec__AbstractVariables_unbox_axiom_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractVariables.)) (!
   (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem x) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/?mem
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem x))
   :qid internal_main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem_accessor_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractVariables.)) (!
   (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings x) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/?mappings
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings x))
   :qid internal_main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings_accessor_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractVariables.)) (!
   (has_type (Poly%main!spec_t.hlspec.AbstractVariables. x) TYPE%main!spec_t.hlspec.AbstractVariables.)
   :pattern ((has_type (Poly%main!spec_t.hlspec.AbstractVariables. x) TYPE%main!spec_t.hlspec.AbstractVariables.))
   :qid internal_main__spec_t__hlspec__AbstractVariables_has_type_always_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= x (%Poly%main!spec_t.hlspec.AbstractStep. (Poly%main!spec_t.hlspec.AbstractStep.
      x
   )))
   :pattern ((Poly%main!spec_t.hlspec.AbstractStep. x))
   :qid internal_main__spec_t__hlspec__AbstractStep_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (= x (Poly%main!spec_t.hlspec.AbstractStep. (%Poly%main!spec_t.hlspec.AbstractStep.
       x
   ))))
   :pattern ((has_type x TYPE%main!spec_t.hlspec.AbstractStep.))
   :qid internal_main__spec_t__hlspec__AbstractStep_unbox_axiom_definition
)))
(assert
 (forall ((_vaddr! Int) (_op! main!definitions_t.RWOp.) (_pte! core!option.Option.))
  (!
   (=>
    (and
     (<= 0 _vaddr!)
     (has_type (Poly%main!definitions_t.RWOp. _op!) TYPE%main!definitions_t.RWOp.)
     (has_type (Poly%core!option.Option. _pte!) (TYPE%core!option.Option. $ (TYPE%tuple%2.
        $ NAT $ TYPE%main!definitions_t.PageTableEntry.
    ))))
    (has_type (Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep./ReadWrite
       _vaddr! _op! _pte!
      )
     ) TYPE%main!spec_t.hlspec.AbstractStep.
   ))
   :pattern ((has_type (Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep./ReadWrite
       _vaddr! _op! _pte!
      )
     ) TYPE%main!spec_t.hlspec.AbstractStep.
   ))
   :qid internal_main!spec_t.hlspec.AbstractStep./ReadWrite_constructor_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr x) (main!spec_t.hlspec.AbstractStep./ReadWrite/?vaddr
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr x))
   :qid internal_main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (<= 0 (main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
       x
   ))))
   :pattern ((main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
   )
   :qid internal_main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr_invariant_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./ReadWrite/op x) (main!spec_t.hlspec.AbstractStep./ReadWrite/?op
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./ReadWrite/op x))
   :qid internal_main!spec_t.hlspec.AbstractStep./ReadWrite/op_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%main!definitions_t.RWOp. (main!spec_t.hlspec.AbstractStep./ReadWrite/op
       (%Poly%main!spec_t.hlspec.AbstractStep. x)
      )
     ) TYPE%main!definitions_t.RWOp.
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./ReadWrite/op (%Poly%main!spec_t.hlspec.AbstractStep.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
   )
   :qid internal_main!spec_t.hlspec.AbstractStep./ReadWrite/op_invariant_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./ReadWrite/pte x) (main!spec_t.hlspec.AbstractStep./ReadWrite/?pte
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./ReadWrite/pte x))
   :qid internal_main!spec_t.hlspec.AbstractStep./ReadWrite/pte_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%core!option.Option. (main!spec_t.hlspec.AbstractStep./ReadWrite/pte
       (%Poly%main!spec_t.hlspec.AbstractStep. x)
      )
     ) (TYPE%core!option.Option. $ (TYPE%tuple%2. $ NAT $ TYPE%main!definitions_t.PageTableEntry.))
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./ReadWrite/pte (%Poly%main!spec_t.hlspec.AbstractStep.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
   )
   :qid internal_main!spec_t.hlspec.AbstractStep./ReadWrite/pte_invariant_definition
)))
(assert
 (forall ((_vaddr! Int) (_pte! main!definitions_t.PageTableEntry.) (_result! main!definitions_t.MapResult.))
  (!
   (=>
    (and
     (<= 0 _vaddr!)
     (has_type (Poly%main!definitions_t.PageTableEntry. _pte!) TYPE%main!definitions_t.PageTableEntry.)
    )
    (has_type (Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep./Map
       _vaddr! _pte! _result!
      )
     ) TYPE%main!spec_t.hlspec.AbstractStep.
   ))
   :pattern ((has_type (Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep./Map
       _vaddr! _pte! _result!
      )
     ) TYPE%main!spec_t.hlspec.AbstractStep.
   ))
   :qid internal_main!spec_t.hlspec.AbstractStep./Map_constructor_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./Map/vaddr x) (main!spec_t.hlspec.AbstractStep./Map/?vaddr
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Map/vaddr x))
   :qid internal_main!spec_t.hlspec.AbstractStep./Map/vaddr_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (<= 0 (main!spec_t.hlspec.AbstractStep./Map/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
       x
   ))))
   :pattern ((main!spec_t.hlspec.AbstractStep./Map/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
   )
   :qid internal_main!spec_t.hlspec.AbstractStep./Map/vaddr_invariant_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./Map/pte x) (main!spec_t.hlspec.AbstractStep./Map/?pte
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Map/pte x))
   :qid internal_main!spec_t.hlspec.AbstractStep./Map/pte_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%main!definitions_t.PageTableEntry. (main!spec_t.hlspec.AbstractStep./Map/pte
       (%Poly%main!spec_t.hlspec.AbstractStep. x)
      )
     ) TYPE%main!definitions_t.PageTableEntry.
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Map/pte (%Poly%main!spec_t.hlspec.AbstractStep.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
   )
   :qid internal_main!spec_t.hlspec.AbstractStep./Map/pte_invariant_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./Map/result x) (main!spec_t.hlspec.AbstractStep./Map/?result
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Map/result x))
   :qid internal_main!spec_t.hlspec.AbstractStep./Map/result_accessor_definition
)))
(assert
 (forall ((_vaddr! Int) (_result! main!definitions_t.UnmapResult.)) (!
   (=>
    (<= 0 _vaddr!)
    (has_type (Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep./Unmap
       _vaddr! _result!
      )
     ) TYPE%main!spec_t.hlspec.AbstractStep.
   ))
   :pattern ((has_type (Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep./Unmap
       _vaddr! _result!
      )
     ) TYPE%main!spec_t.hlspec.AbstractStep.
   ))
   :qid internal_main!spec_t.hlspec.AbstractStep./Unmap_constructor_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./Unmap/vaddr x) (main!spec_t.hlspec.AbstractStep./Unmap/?vaddr
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Unmap/vaddr x))
   :qid internal_main!spec_t.hlspec.AbstractStep./Unmap/vaddr_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (<= 0 (main!spec_t.hlspec.AbstractStep./Unmap/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
       x
   ))))
   :pattern ((main!spec_t.hlspec.AbstractStep./Unmap/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
   )
   :qid internal_main!spec_t.hlspec.AbstractStep./Unmap/vaddr_invariant_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./Unmap/result x) (main!spec_t.hlspec.AbstractStep./Unmap/?result
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Unmap/result x))
   :qid internal_main!spec_t.hlspec.AbstractStep./Unmap/result_accessor_definition
)))
(assert
 (forall ((_vaddr! Int) (_result! main!definitions_t.ResolveResult.)) (!
   (=>
    (and
     (<= 0 _vaddr!)
     (has_type (Poly%main!definitions_t.ResolveResult. _result!) TYPE%main!definitions_t.ResolveResult.)
    )
    (has_type (Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep./Resolve
       _vaddr! _result!
      )
     ) TYPE%main!spec_t.hlspec.AbstractStep.
   ))
   :pattern ((has_type (Poly%main!spec_t.hlspec.AbstractStep. (main!spec_t.hlspec.AbstractStep./Resolve
       _vaddr! _result!
      )
     ) TYPE%main!spec_t.hlspec.AbstractStep.
   ))
   :qid internal_main!spec_t.hlspec.AbstractStep./Resolve_constructor_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./Resolve/vaddr x) (main!spec_t.hlspec.AbstractStep./Resolve/?vaddr
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Resolve/vaddr x))
   :qid internal_main!spec_t.hlspec.AbstractStep./Resolve/vaddr_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (<= 0 (main!spec_t.hlspec.AbstractStep./Resolve/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
       x
   ))))
   :pattern ((main!spec_t.hlspec.AbstractStep./Resolve/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
   )
   :qid internal_main!spec_t.hlspec.AbstractStep./Resolve/vaddr_invariant_definition
)))
(assert
 (forall ((x main!spec_t.hlspec.AbstractStep.)) (!
   (= (main!spec_t.hlspec.AbstractStep./Resolve/result x) (main!spec_t.hlspec.AbstractStep./Resolve/?result
     x
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Resolve/result x))
   :qid internal_main!spec_t.hlspec.AbstractStep./Resolve/result_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%main!definitions_t.ResolveResult. (main!spec_t.hlspec.AbstractStep./Resolve/result
       (%Poly%main!spec_t.hlspec.AbstractStep. x)
      )
     ) TYPE%main!definitions_t.ResolveResult.
   ))
   :pattern ((main!spec_t.hlspec.AbstractStep./Resolve/result (%Poly%main!spec_t.hlspec.AbstractStep.
      x
     )
    ) (has_type x TYPE%main!spec_t.hlspec.AbstractStep.)
   )
   :qid internal_main!spec_t.hlspec.AbstractStep./Resolve/result_invariant_definition
)))
(assert
 (has_type (Poly%main!spec_t.hlspec.AbstractStep. main!spec_t.hlspec.AbstractStep./Stutter)
  TYPE%main!spec_t.hlspec.AbstractStep.
))
(assert
 (forall ((x main!definitions_t.MapResult.)) (!
   (= x (%Poly%main!definitions_t.MapResult. (Poly%main!definitions_t.MapResult. x)))
   :pattern ((Poly%main!definitions_t.MapResult. x))
   :qid internal_main__definitions_t__MapResult_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.MapResult.)
    (= x (Poly%main!definitions_t.MapResult. (%Poly%main!definitions_t.MapResult. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.MapResult.))
   :qid internal_main__definitions_t__MapResult_unbox_axiom_definition
)))
(assert
 (forall ((x main!definitions_t.MapResult.)) (!
   (has_type (Poly%main!definitions_t.MapResult. x) TYPE%main!definitions_t.MapResult.)
   :pattern ((has_type (Poly%main!definitions_t.MapResult. x) TYPE%main!definitions_t.MapResult.))
   :qid internal_main__definitions_t__MapResult_has_type_always_definition
)))
(assert
 (forall ((x main!definitions_t.UnmapResult.)) (!
   (= x (%Poly%main!definitions_t.UnmapResult. (Poly%main!definitions_t.UnmapResult. x)))
   :pattern ((Poly%main!definitions_t.UnmapResult. x))
   :qid internal_main__definitions_t__UnmapResult_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.UnmapResult.)
    (= x (Poly%main!definitions_t.UnmapResult. (%Poly%main!definitions_t.UnmapResult. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.UnmapResult.))
   :qid internal_main__definitions_t__UnmapResult_unbox_axiom_definition
)))
(assert
 (forall ((x main!definitions_t.UnmapResult.)) (!
   (has_type (Poly%main!definitions_t.UnmapResult. x) TYPE%main!definitions_t.UnmapResult.)
   :pattern ((has_type (Poly%main!definitions_t.UnmapResult. x) TYPE%main!definitions_t.UnmapResult.))
   :qid internal_main__definitions_t__UnmapResult_has_type_always_definition
)))
(assert
 (forall ((x main!definitions_t.ResolveResult.)) (!
   (= x (%Poly%main!definitions_t.ResolveResult. (Poly%main!definitions_t.ResolveResult.
      x
   )))
   :pattern ((Poly%main!definitions_t.ResolveResult. x))
   :qid internal_main__definitions_t__ResolveResult_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.ResolveResult.)
    (= x (Poly%main!definitions_t.ResolveResult. (%Poly%main!definitions_t.ResolveResult.
       x
   ))))
   :pattern ((has_type x TYPE%main!definitions_t.ResolveResult.))
   :qid internal_main__definitions_t__ResolveResult_unbox_axiom_definition
)))
(assert
 (has_type (Poly%main!definitions_t.ResolveResult. main!definitions_t.ResolveResult./ErrUnmapped)
  TYPE%main!definitions_t.ResolveResult.
))
(assert
 (forall ((_0! Int) (_1! main!definitions_t.PageTableEntry.)) (!
   (=>
    (and
     (<= 0 _0!)
     (has_type (Poly%main!definitions_t.PageTableEntry. _1!) TYPE%main!definitions_t.PageTableEntry.)
    )
    (has_type (Poly%main!definitions_t.ResolveResult. (main!definitions_t.ResolveResult./Ok
       _0! _1!
      )
     ) TYPE%main!definitions_t.ResolveResult.
   ))
   :pattern ((has_type (Poly%main!definitions_t.ResolveResult. (main!definitions_t.ResolveResult./Ok
       _0! _1!
      )
     ) TYPE%main!definitions_t.ResolveResult.
   ))
   :qid internal_main!definitions_t.ResolveResult./Ok_constructor_definition
)))
(assert
 (forall ((x main!definitions_t.ResolveResult.)) (!
   (= (main!definitions_t.ResolveResult./Ok/0 x) (main!definitions_t.ResolveResult./Ok/?0
     x
   ))
   :pattern ((main!definitions_t.ResolveResult./Ok/0 x))
   :qid internal_main!definitions_t.ResolveResult./Ok/0_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.ResolveResult.)
    (<= 0 (main!definitions_t.ResolveResult./Ok/0 (%Poly%main!definitions_t.ResolveResult.
       x
   ))))
   :pattern ((main!definitions_t.ResolveResult./Ok/0 (%Poly%main!definitions_t.ResolveResult.
      x
     )
    ) (has_type x TYPE%main!definitions_t.ResolveResult.)
   )
   :qid internal_main!definitions_t.ResolveResult./Ok/0_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.ResolveResult.)) (!
   (= (main!definitions_t.ResolveResult./Ok/1 x) (main!definitions_t.ResolveResult./Ok/?1
     x
   ))
   :pattern ((main!definitions_t.ResolveResult./Ok/1 x))
   :qid internal_main!definitions_t.ResolveResult./Ok/1_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.ResolveResult.)
    (has_type (Poly%main!definitions_t.PageTableEntry. (main!definitions_t.ResolveResult./Ok/1
       (%Poly%main!definitions_t.ResolveResult. x)
      )
     ) TYPE%main!definitions_t.PageTableEntry.
   ))
   :pattern ((main!definitions_t.ResolveResult./Ok/1 (%Poly%main!definitions_t.ResolveResult.
      x
     )
    ) (has_type x TYPE%main!definitions_t.ResolveResult.)
   )
   :qid internal_main!definitions_t.ResolveResult./Ok/1_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.LoadResult.)) (!
   (= x (%Poly%main!definitions_t.LoadResult. (Poly%main!definitions_t.LoadResult. x)))
   :pattern ((Poly%main!definitions_t.LoadResult. x))
   :qid internal_main__definitions_t__LoadResult_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.LoadResult.)
    (= x (Poly%main!definitions_t.LoadResult. (%Poly%main!definitions_t.LoadResult. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.LoadResult.))
   :qid internal_main__definitions_t__LoadResult_unbox_axiom_definition
)))
(assert
 (has_type (Poly%main!definitions_t.LoadResult. main!definitions_t.LoadResult./Pagefault)
  TYPE%main!definitions_t.LoadResult.
))
(assert
 (forall ((_0! Int)) (!
   (=>
    (<= 0 _0!)
    (has_type (Poly%main!definitions_t.LoadResult. (main!definitions_t.LoadResult./Value
       _0!
      )
     ) TYPE%main!definitions_t.LoadResult.
   ))
   :pattern ((has_type (Poly%main!definitions_t.LoadResult. (main!definitions_t.LoadResult./Value
       _0!
      )
     ) TYPE%main!definitions_t.LoadResult.
   ))
   :qid internal_main!definitions_t.LoadResult./Value_constructor_definition
)))
(assert
 (forall ((x main!definitions_t.LoadResult.)) (!
   (= (main!definitions_t.LoadResult./Value/0 x) (main!definitions_t.LoadResult./Value/?0
     x
   ))
   :pattern ((main!definitions_t.LoadResult./Value/0 x))
   :qid internal_main!definitions_t.LoadResult./Value/0_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.LoadResult.)
    (<= 0 (main!definitions_t.LoadResult./Value/0 (%Poly%main!definitions_t.LoadResult.
       x
   ))))
   :pattern ((main!definitions_t.LoadResult./Value/0 (%Poly%main!definitions_t.LoadResult.
      x
     )
    ) (has_type x TYPE%main!definitions_t.LoadResult.)
   )
   :qid internal_main!definitions_t.LoadResult./Value/0_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.StoreResult.)) (!
   (= x (%Poly%main!definitions_t.StoreResult. (Poly%main!definitions_t.StoreResult. x)))
   :pattern ((Poly%main!definitions_t.StoreResult. x))
   :qid internal_main__definitions_t__StoreResult_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.StoreResult.)
    (= x (Poly%main!definitions_t.StoreResult. (%Poly%main!definitions_t.StoreResult. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.StoreResult.))
   :qid internal_main__definitions_t__StoreResult_unbox_axiom_definition
)))
(assert
 (forall ((x main!definitions_t.StoreResult.)) (!
   (has_type (Poly%main!definitions_t.StoreResult. x) TYPE%main!definitions_t.StoreResult.)
   :pattern ((has_type (Poly%main!definitions_t.StoreResult. x) TYPE%main!definitions_t.StoreResult.))
   :qid internal_main__definitions_t__StoreResult_has_type_always_definition
)))
(assert
 (forall ((x main!definitions_t.RWOp.)) (!
   (= x (%Poly%main!definitions_t.RWOp. (Poly%main!definitions_t.RWOp. x)))
   :pattern ((Poly%main!definitions_t.RWOp. x))
   :qid internal_main__definitions_t__RWOp_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.RWOp.)
    (= x (Poly%main!definitions_t.RWOp. (%Poly%main!definitions_t.RWOp. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.RWOp.))
   :qid internal_main__definitions_t__RWOp_unbox_axiom_definition
)))
(assert
 (forall ((_new_value! Int) (_result! main!definitions_t.StoreResult.)) (!
   (=>
    (<= 0 _new_value!)
    (has_type (Poly%main!definitions_t.RWOp. (main!definitions_t.RWOp./Store _new_value!
       _result!
      )
     ) TYPE%main!definitions_t.RWOp.
   ))
   :pattern ((has_type (Poly%main!definitions_t.RWOp. (main!definitions_t.RWOp./Store _new_value!
       _result!
      )
     ) TYPE%main!definitions_t.RWOp.
   ))
   :qid internal_main!definitions_t.RWOp./Store_constructor_definition
)))
(assert
 (forall ((x main!definitions_t.RWOp.)) (!
   (= (main!definitions_t.RWOp./Store/new_value x) (main!definitions_t.RWOp./Store/?new_value
     x
   ))
   :pattern ((main!definitions_t.RWOp./Store/new_value x))
   :qid internal_main!definitions_t.RWOp./Store/new_value_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.RWOp.)
    (<= 0 (main!definitions_t.RWOp./Store/new_value (%Poly%main!definitions_t.RWOp. x)))
   )
   :pattern ((main!definitions_t.RWOp./Store/new_value (%Poly%main!definitions_t.RWOp.
      x
     )
    ) (has_type x TYPE%main!definitions_t.RWOp.)
   )
   :qid internal_main!definitions_t.RWOp./Store/new_value_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.RWOp.)) (!
   (= (main!definitions_t.RWOp./Store/result x) (main!definitions_t.RWOp./Store/?result
     x
   ))
   :pattern ((main!definitions_t.RWOp./Store/result x))
   :qid internal_main!definitions_t.RWOp./Store/result_accessor_definition
)))
(assert
 (forall ((_is_exec! Bool) (_result! main!definitions_t.LoadResult.)) (!
   (=>
    (has_type (Poly%main!definitions_t.LoadResult. _result!) TYPE%main!definitions_t.LoadResult.)
    (has_type (Poly%main!definitions_t.RWOp. (main!definitions_t.RWOp./Load _is_exec! _result!))
     TYPE%main!definitions_t.RWOp.
   ))
   :pattern ((has_type (Poly%main!definitions_t.RWOp. (main!definitions_t.RWOp./Load _is_exec!
       _result!
      )
     ) TYPE%main!definitions_t.RWOp.
   ))
   :qid internal_main!definitions_t.RWOp./Load_constructor_definition
)))
(assert
 (forall ((x main!definitions_t.RWOp.)) (!
   (= (main!definitions_t.RWOp./Load/is_exec x) (main!definitions_t.RWOp./Load/?is_exec
     x
   ))
   :pattern ((main!definitions_t.RWOp./Load/is_exec x))
   :qid internal_main!definitions_t.RWOp./Load/is_exec_accessor_definition
)))
(assert
 (forall ((x main!definitions_t.RWOp.)) (!
   (= (main!definitions_t.RWOp./Load/result x) (main!definitions_t.RWOp./Load/?result
     x
   ))
   :pattern ((main!definitions_t.RWOp./Load/result x))
   :qid internal_main!definitions_t.RWOp./Load/result_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.RWOp.)
    (has_type (Poly%main!definitions_t.LoadResult. (main!definitions_t.RWOp./Load/result
       (%Poly%main!definitions_t.RWOp. x)
      )
     ) TYPE%main!definitions_t.LoadResult.
   ))
   :pattern ((main!definitions_t.RWOp./Load/result (%Poly%main!definitions_t.RWOp. x))
    (has_type x TYPE%main!definitions_t.RWOp.)
   )
   :qid internal_main!definitions_t.RWOp./Load/result_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.MemRegion.)) (!
   (= x (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. x)))
   :pattern ((Poly%main!definitions_t.MemRegion. x))
   :qid internal_main__definitions_t__MemRegion_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.MemRegion.)
    (= x (Poly%main!definitions_t.MemRegion. (%Poly%main!definitions_t.MemRegion. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.MemRegion.))
   :qid internal_main__definitions_t__MemRegion_unbox_axiom_definition
)))
(assert
 (forall ((_base! Int) (_size! Int)) (!
   (=>
    (and
     (<= 0 _base!)
     (<= 0 _size!)
    )
    (has_type (Poly%main!definitions_t.MemRegion. (main!definitions_t.MemRegion./MemRegion
       _base! _size!
      )
     ) TYPE%main!definitions_t.MemRegion.
   ))
   :pattern ((has_type (Poly%main!definitions_t.MemRegion. (main!definitions_t.MemRegion./MemRegion
       _base! _size!
      )
     ) TYPE%main!definitions_t.MemRegion.
   ))
   :qid internal_main!definitions_t.MemRegion./MemRegion_constructor_definition
)))
(assert
 (forall ((x main!definitions_t.MemRegion.)) (!
   (= (main!definitions_t.MemRegion./MemRegion/base x) (main!definitions_t.MemRegion./MemRegion/?base
     x
   ))
   :pattern ((main!definitions_t.MemRegion./MemRegion/base x))
   :qid internal_main!definitions_t.MemRegion./MemRegion/base_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.MemRegion.)
    (<= 0 (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
       x
   ))))
   :pattern ((main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
      x
     )
    ) (has_type x TYPE%main!definitions_t.MemRegion.)
   )
   :qid internal_main!definitions_t.MemRegion./MemRegion/base_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.MemRegion.)) (!
   (= (main!definitions_t.MemRegion./MemRegion/size x) (main!definitions_t.MemRegion./MemRegion/?size
     x
   ))
   :pattern ((main!definitions_t.MemRegion./MemRegion/size x))
   :qid internal_main!definitions_t.MemRegion./MemRegion/size_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.MemRegion.)
    (<= 0 (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
       x
   ))))
   :pattern ((main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
      x
     )
    ) (has_type x TYPE%main!definitions_t.MemRegion.)
   )
   :qid internal_main!definitions_t.MemRegion./MemRegion/size_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.Flags.)) (!
   (= x (%Poly%main!definitions_t.Flags. (Poly%main!definitions_t.Flags. x)))
   :pattern ((Poly%main!definitions_t.Flags. x))
   :qid internal_main__definitions_t__Flags_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.Flags.)
    (= x (Poly%main!definitions_t.Flags. (%Poly%main!definitions_t.Flags. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.Flags.))
   :qid internal_main__definitions_t__Flags_unbox_axiom_definition
)))
(assert
 (forall ((x main!definitions_t.Flags.)) (!
   (= (main!definitions_t.Flags./Flags/is_writable x) (main!definitions_t.Flags./Flags/?is_writable
     x
   ))
   :pattern ((main!definitions_t.Flags./Flags/is_writable x))
   :qid internal_main!definitions_t.Flags./Flags/is_writable_accessor_definition
)))
(assert
 (forall ((x main!definitions_t.Flags.)) (!
   (= (main!definitions_t.Flags./Flags/is_supervisor x) (main!definitions_t.Flags./Flags/?is_supervisor
     x
   ))
   :pattern ((main!definitions_t.Flags./Flags/is_supervisor x))
   :qid internal_main!definitions_t.Flags./Flags/is_supervisor_accessor_definition
)))
(assert
 (forall ((x main!definitions_t.Flags.)) (!
   (= (main!definitions_t.Flags./Flags/disable_execute x) (main!definitions_t.Flags./Flags/?disable_execute
     x
   ))
   :pattern ((main!definitions_t.Flags./Flags/disable_execute x))
   :qid internal_main!definitions_t.Flags./Flags/disable_execute_accessor_definition
)))
(assert
 (forall ((x main!definitions_t.Flags.)) (!
   (has_type (Poly%main!definitions_t.Flags. x) TYPE%main!definitions_t.Flags.)
   :pattern ((has_type (Poly%main!definitions_t.Flags. x) TYPE%main!definitions_t.Flags.))
   :qid internal_main__definitions_t__Flags_has_type_always_definition
)))
(assert
 (forall ((x main!definitions_t.PageTableEntry.)) (!
   (= x (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
      x
   )))
   :pattern ((Poly%main!definitions_t.PageTableEntry. x))
   :qid internal_main__definitions_t__PageTableEntry_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.PageTableEntry.)
    (= x (Poly%main!definitions_t.PageTableEntry. (%Poly%main!definitions_t.PageTableEntry.
       x
   ))))
   :pattern ((has_type x TYPE%main!definitions_t.PageTableEntry.))
   :qid internal_main__definitions_t__PageTableEntry_unbox_axiom_definition
)))
(assert
 (forall ((_frame! main!definitions_t.MemRegion.) (_flags! main!definitions_t.Flags.))
  (!
   (=>
    (has_type (Poly%main!definitions_t.MemRegion. _frame!) TYPE%main!definitions_t.MemRegion.)
    (has_type (Poly%main!definitions_t.PageTableEntry. (main!definitions_t.PageTableEntry./PageTableEntry
       _frame! _flags!
      )
     ) TYPE%main!definitions_t.PageTableEntry.
   ))
   :pattern ((has_type (Poly%main!definitions_t.PageTableEntry. (main!definitions_t.PageTableEntry./PageTableEntry
       _frame! _flags!
      )
     ) TYPE%main!definitions_t.PageTableEntry.
   ))
   :qid internal_main!definitions_t.PageTableEntry./PageTableEntry_constructor_definition
)))
(assert
 (forall ((x main!definitions_t.PageTableEntry.)) (!
   (= (main!definitions_t.PageTableEntry./PageTableEntry/frame x) (main!definitions_t.PageTableEntry./PageTableEntry/?frame
     x
   ))
   :pattern ((main!definitions_t.PageTableEntry./PageTableEntry/frame x))
   :qid internal_main!definitions_t.PageTableEntry./PageTableEntry/frame_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.PageTableEntry.)
    (has_type (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
       (%Poly%main!definitions_t.PageTableEntry. x)
      )
     ) TYPE%main!definitions_t.MemRegion.
   ))
   :pattern ((main!definitions_t.PageTableEntry./PageTableEntry/frame (%Poly%main!definitions_t.PageTableEntry.
      x
     )
    ) (has_type x TYPE%main!definitions_t.PageTableEntry.)
   )
   :qid internal_main!definitions_t.PageTableEntry./PageTableEntry/frame_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.PageTableEntry.)) (!
   (= (main!definitions_t.PageTableEntry./PageTableEntry/flags x) (main!definitions_t.PageTableEntry./PageTableEntry/?flags
     x
   ))
   :pattern ((main!definitions_t.PageTableEntry./PageTableEntry/flags x))
   :qid internal_main!definitions_t.PageTableEntry./PageTableEntry/flags_accessor_definition
)))
(assert
 (forall ((x main!definitions_t.ArchLayer.)) (!
   (= x (%Poly%main!definitions_t.ArchLayer. (Poly%main!definitions_t.ArchLayer. x)))
   :pattern ((Poly%main!definitions_t.ArchLayer. x))
   :qid internal_main__definitions_t__ArchLayer_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.ArchLayer.)
    (= x (Poly%main!definitions_t.ArchLayer. (%Poly%main!definitions_t.ArchLayer. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.ArchLayer.))
   :qid internal_main__definitions_t__ArchLayer_unbox_axiom_definition
)))
(assert
 (forall ((_entry_size! Int) (_num_entries! Int)) (!
   (=>
    (and
     (<= 0 _entry_size!)
     (<= 0 _num_entries!)
    )
    (has_type (Poly%main!definitions_t.ArchLayer. (main!definitions_t.ArchLayer./ArchLayer
       _entry_size! _num_entries!
      )
     ) TYPE%main!definitions_t.ArchLayer.
   ))
   :pattern ((has_type (Poly%main!definitions_t.ArchLayer. (main!definitions_t.ArchLayer./ArchLayer
       _entry_size! _num_entries!
      )
     ) TYPE%main!definitions_t.ArchLayer.
   ))
   :qid internal_main!definitions_t.ArchLayer./ArchLayer_constructor_definition
)))
(assert
 (forall ((x main!definitions_t.ArchLayer.)) (!
   (= (main!definitions_t.ArchLayer./ArchLayer/entry_size x) (main!definitions_t.ArchLayer./ArchLayer/?entry_size
     x
   ))
   :pattern ((main!definitions_t.ArchLayer./ArchLayer/entry_size x))
   :qid internal_main!definitions_t.ArchLayer./ArchLayer/entry_size_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.ArchLayer.)
    (<= 0 (main!definitions_t.ArchLayer./ArchLayer/entry_size (%Poly%main!definitions_t.ArchLayer.
       x
   ))))
   :pattern ((main!definitions_t.ArchLayer./ArchLayer/entry_size (%Poly%main!definitions_t.ArchLayer.
      x
     )
    ) (has_type x TYPE%main!definitions_t.ArchLayer.)
   )
   :qid internal_main!definitions_t.ArchLayer./ArchLayer/entry_size_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.ArchLayer.)) (!
   (= (main!definitions_t.ArchLayer./ArchLayer/num_entries x) (main!definitions_t.ArchLayer./ArchLayer/?num_entries
     x
   ))
   :pattern ((main!definitions_t.ArchLayer./ArchLayer/num_entries x))
   :qid internal_main!definitions_t.ArchLayer./ArchLayer/num_entries_accessor_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.ArchLayer.)
    (<= 0 (main!definitions_t.ArchLayer./ArchLayer/num_entries (%Poly%main!definitions_t.ArchLayer.
       x
   ))))
   :pattern ((main!definitions_t.ArchLayer./ArchLayer/num_entries (%Poly%main!definitions_t.ArchLayer.
      x
     )
    ) (has_type x TYPE%main!definitions_t.ArchLayer.)
   )
   :qid internal_main!definitions_t.ArchLayer./ArchLayer/num_entries_invariant_definition
)))
(assert
 (forall ((x main!definitions_t.Arch.)) (!
   (= x (%Poly%main!definitions_t.Arch. (Poly%main!definitions_t.Arch. x)))
   :pattern ((Poly%main!definitions_t.Arch. x))
   :qid internal_main__definitions_t__Arch_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%main!definitions_t.Arch.)
    (= x (Poly%main!definitions_t.Arch. (%Poly%main!definitions_t.Arch. x)))
   )
   :pattern ((has_type x TYPE%main!definitions_t.Arch.))
   :qid internal_main__definitions_t__Arch_unbox_axiom_definition
)))
(assert
 (forall ((x main!definitions_t.Arch.)) (!
   (= (main!definitions_t.Arch./Arch/layers x) (main!definitions_t.Arch./Arch/?layers
     x
   ))
   :pattern ((main!definitions_t.Arch./Arch/layers x))
   :qid internal_main!definitions_t.Arch./Arch/layers_accessor_definition
)))
(assert
 (forall ((x main!definitions_t.Arch.)) (!
   (has_type (Poly%main!definitions_t.Arch. x) TYPE%main!definitions_t.Arch.)
   :pattern ((has_type (Poly%main!definitions_t.Arch. x) TYPE%main!definitions_t.Arch.))
   :qid internal_main__definitions_t__Arch_has_type_always_definition
)))
(assert
 (forall ((x tuple%0.)) (!
   (= x (%Poly%tuple%0. (Poly%tuple%0. x)))
   :pattern ((Poly%tuple%0. x))
   :qid internal_crate__tuple__0_box_axiom_definition
)))
(assert
 (forall ((x Poly)) (!
   (=>
    (has_type x TYPE%tuple%0.)
    (= x (Poly%tuple%0. (%Poly%tuple%0. x)))
   )
   :pattern ((has_type x TYPE%tuple%0.))
   :qid internal_crate__tuple__0_unbox_axiom_definition
)))
(assert
 (forall ((x tuple%0.)) (!
   (has_type (Poly%tuple%0. x) TYPE%tuple%0.)
   :pattern ((has_type (Poly%tuple%0. x) TYPE%tuple%0.))
   :qid internal_crate__tuple__0_has_type_always_definition
)))
(assert
 (forall ((x tuple%2.)) (!
   (= x (%Poly%tuple%2. (Poly%tuple%2. x)))
   :pattern ((Poly%tuple%2. x))
   :qid internal_crate__tuple__2_box_axiom_definition
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (x Poly)) (!
   (=>
    (has_type x (TYPE%tuple%2. T%0&. T%0& T%1&. T%1&))
    (= x (Poly%tuple%2. (%Poly%tuple%2. x)))
   )
   :pattern ((has_type x (TYPE%tuple%2. T%0&. T%0& T%1&. T%1&)))
   :qid internal_crate__tuple__2_unbox_axiom_definition
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (_0! Poly) (_1! Poly)) (!
   (=>
    (and
     (has_type _0! T%0&)
     (has_type _1! T%1&)
    )
    (has_type (Poly%tuple%2. (tuple%2./tuple%2 _0! _1!)) (TYPE%tuple%2. T%0&. T%0& T%1&.
      T%1&
   )))
   :pattern ((has_type (Poly%tuple%2. (tuple%2./tuple%2 _0! _1!)) (TYPE%tuple%2. T%0&.
      T%0& T%1&. T%1&
   )))
   :qid internal_tuple__2./tuple__2_constructor_definition
)))
(assert
 (forall ((x tuple%2.)) (!
   (= (tuple%2./tuple%2/0 x) (tuple%2./tuple%2/?0 x))
   :pattern ((tuple%2./tuple%2/0 x))
   :qid internal_tuple__2./tuple__2/0_accessor_definition
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (x Poly)) (!
   (=>
    (has_type x (TYPE%tuple%2. T%0&. T%0& T%1&. T%1&))
    (has_type (tuple%2./tuple%2/0 (%Poly%tuple%2. x)) T%0&)
   )
   :pattern ((tuple%2./tuple%2/0 (%Poly%tuple%2. x)) (has_type x (TYPE%tuple%2. T%0&. T%0&
      T%1&. T%1&
   )))
   :qid internal_tuple__2./tuple__2/0_invariant_definition
)))
(assert
 (forall ((x tuple%2.)) (!
   (= (tuple%2./tuple%2/1 x) (tuple%2./tuple%2/?1 x))
   :pattern ((tuple%2./tuple%2/1 x))
   :qid internal_tuple__2./tuple__2/1_accessor_definition
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (x Poly)) (!
   (=>
    (has_type x (TYPE%tuple%2. T%0&. T%0& T%1&. T%1&))
    (has_type (tuple%2./tuple%2/1 (%Poly%tuple%2. x)) T%1&)
   )
   :pattern ((tuple%2./tuple%2/1 (%Poly%tuple%2. x)) (has_type x (TYPE%tuple%2. T%0&. T%0&
      T%1&. T%1&
   )))
   :qid internal_tuple__2./tuple__2/1_invariant_definition
)))
(assert
 (forall ((x tuple%2.)) (!
   (=>
    (is-tuple%2./tuple%2 x)
    (height_lt (height (tuple%2./tuple%2/0 x)) (height (Poly%tuple%2. x)))
   )
   :pattern ((height (tuple%2./tuple%2/0 x)))
   :qid prelude_datatype_height_tuple%2./tuple%2/0
)))
(assert
 (forall ((x tuple%2.)) (!
   (=>
    (is-tuple%2./tuple%2 x)
    (height_lt (height (tuple%2./tuple%2/1 x)) (height (Poly%tuple%2. x)))
   )
   :pattern ((height (tuple%2./tuple%2/1 x)))
   :qid prelude_datatype_height_tuple%2./tuple%2/1
)))
(assert
 (forall ((T%0&. Dcr) (T%0& Type) (T%1&. Dcr) (T%1& Type) (deep Bool) (x Poly) (y Poly))
  (!
   (=>
    (and
     (has_type x (TYPE%tuple%2. T%0&. T%0& T%1&. T%1&))
     (has_type y (TYPE%tuple%2. T%0&. T%0& T%1&. T%1&))
     (ext_eq deep T%0& (tuple%2./tuple%2/0 (%Poly%tuple%2. x)) (tuple%2./tuple%2/0 (%Poly%tuple%2.
        y
     )))
     (ext_eq deep T%1& (tuple%2./tuple%2/1 (%Poly%tuple%2. x)) (tuple%2./tuple%2/1 (%Poly%tuple%2.
        y
    ))))
    (ext_eq deep (TYPE%tuple%2. T%0&. T%0& T%1&. T%1&) x y)
   )
   :pattern ((ext_eq deep (TYPE%tuple%2. T%0&. T%0& T%1&. T%1&) x y))
   :qid internal_tuple__2./tuple__2_ext_equal_definition
)))

;; Function-Decl vstd::map::impl&%0::empty
(declare-fun vstd!map.impl&%0.empty.? (Dcr Type Dcr Type) Poly)

;; Function-Decl vstd::map::impl&%0::dom
(declare-fun vstd!map.impl&%0.dom.? (Dcr Type Dcr Type Poly) Poly)

;; Function-Decl vstd::map::impl&%0::index
(declare-fun vstd!map.impl&%0.index.? (Dcr Type Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::map::impl&%0::spec_index
(declare-fun vstd!map.impl&%0.spec_index.? (Dcr Type Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::map::impl&%0::insert
(declare-fun vstd!map.impl&%0.insert.? (Dcr Type Dcr Type Poly Poly Poly) Poly)

;; Function-Decl vstd::map::impl&%0::remove
(declare-fun vstd!map.impl&%0.remove.? (Dcr Type Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::map_lib::impl&%0::contains_pair
(declare-fun vstd!map_lib.impl&%0.contains_pair.? (Dcr Type Dcr Type Poly Poly Poly)
 Bool
)

;; Function-Decl vstd::seq::Seq::empty
(declare-fun vstd!seq.Seq.empty.? (Dcr Type) Poly)

;; Function-Decl vstd::seq::Seq::new
(declare-fun vstd!seq.Seq.new.? (Dcr Type Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::seq::Seq::len
(declare-fun vstd!seq.Seq.len.? (Dcr Type Poly) Int)

;; Function-Decl vstd::seq::Seq::index
(declare-fun vstd!seq.Seq.index.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::seq::impl&%0::spec_index
(declare-fun vstd!seq.impl&%0.spec_index.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::seq::Seq::push
(declare-fun vstd!seq.Seq.push.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::seq::Seq::update
(declare-fun vstd!seq.Seq.update.? (Dcr Type Poly Poly Poly) Poly)

;; Function-Decl vstd::seq::Seq::subrange
(declare-fun vstd!seq.Seq.subrange.? (Dcr Type Poly Poly Poly) Poly)

;; Function-Decl vstd::seq::Seq::add
(declare-fun vstd!seq.Seq.add.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::set::impl&%0::empty
(declare-fun vstd!set.impl&%0.empty.? (Dcr Type) Poly)

;; Function-Decl vstd::set::impl&%0::new
(declare-fun vstd!set.impl&%0.new.? (Dcr Type Dcr Type Poly) Poly)

;; Function-Decl vstd::set::impl&%0::contains
(declare-fun vstd!set.impl&%0.contains.? (Dcr Type Poly Poly) Bool)

;; Function-Decl vstd::set::impl&%0::insert
(declare-fun vstd!set.impl&%0.insert.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::set::impl&%0::remove
(declare-fun vstd!set.impl&%0.remove.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::set::impl&%0::union
(declare-fun vstd!set.impl&%0.union.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::set::impl&%0::intersect
(declare-fun vstd!set.impl&%0.intersect.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::set::impl&%0::difference
(declare-fun vstd!set.impl&%0.difference.? (Dcr Type Poly Poly) Poly)

;; Function-Decl vstd::set::impl&%0::complement
(declare-fun vstd!set.impl&%0.complement.? (Dcr Type Poly) Poly)

;; Function-Decl vstd::set::impl&%0::finite
(declare-fun vstd!set.impl&%0.finite.? (Dcr Type Poly) Bool)

;; Function-Decl vstd::set::impl&%0::len
(declare-fun vstd!set.impl&%0.len.? (Dcr Type Poly) Int)

;; Function-Decl vstd::set::impl&%0::choose
(declare-fun vstd!set.impl&%0.choose.? (Dcr Type Poly) Poly)

;; Function-Decl vstd::set::impl&%0::mk_map
(declare-fun vstd!set.impl&%0.mk_map.? (Dcr Type Dcr Type Dcr Type Poly Poly) Poly)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_op
(declare-fun main!spec_t.hlspec.impl&%0.arrow_op.? (Poly) main!definitions_t.RWOp.)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_result
(declare-fun main!spec_t.hlspec.impl&%0.arrow_result.? (Poly) main!definitions_t.ResolveResult.)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_ReadWrite_vaddr
(declare-fun main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr.? (Poly) Int)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_ReadWrite_op
(declare-fun main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op.? (Poly) main!definitions_t.RWOp.)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_ReadWrite_pte
(declare-fun main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte.? (Poly) core!option.Option.)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_Map_vaddr
(declare-fun main!spec_t.hlspec.impl&%0.arrow_Map_vaddr.? (Poly) Int)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_Map_pte
(declare-fun main!spec_t.hlspec.impl&%0.arrow_Map_pte.? (Poly) main!definitions_t.PageTableEntry.)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_Map_result
(declare-fun main!spec_t.hlspec.impl&%0.arrow_Map_result.? (Poly) main!definitions_t.MapResult.)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_Unmap_vaddr
(declare-fun main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr.? (Poly) Int)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_Unmap_result
(declare-fun main!spec_t.hlspec.impl&%0.arrow_Unmap_result.? (Poly) main!definitions_t.UnmapResult.)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_Resolve_vaddr
(declare-fun main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr.? (Poly) Int)

;; Function-Decl main::spec_t::hlspec::AbstractStep::arrow_Resolve_result
(declare-fun main!spec_t.hlspec.impl&%0.arrow_Resolve_result.? (Poly) main!definitions_t.ResolveResult.)

;; Function-Decl main::spec_t::hlspec::init
(declare-fun main!spec_t.hlspec.init.? (Poly) Bool)

;; Function-Decl main::spec_t::hlspec::mem_domain_from_mappings_contains
(declare-fun main!spec_t.hlspec.mem_domain_from_mappings_contains.? (Poly Poly Poly)
 Bool
)

;; Function-Decl main::spec_t::hlspec::mem_domain_from_mappings
(declare-fun main!spec_t.hlspec.mem_domain_from_mappings.? (Poly Poly) vstd!set.Set<nat.>.)

;; Function-Decl main::spec_t::hlspec::step_ReadWrite
(declare-fun main!spec_t.hlspec.step_ReadWrite.? (Poly Poly Poly Poly Poly Poly) Bool)

;; Function-Decl main::spec_t::hlspec::step_Map_enabled
(declare-fun main!spec_t.hlspec.step_Map_enabled.? (Poly Poly Poly) Bool)

;; Function-Decl main::spec_t::hlspec::step_Map
(declare-fun main!spec_t.hlspec.step_Map.? (Poly Poly Poly Poly Poly Poly) Bool)

;; Function-Decl main::spec_t::hlspec::step_Unmap_enabled
(declare-fun main!spec_t.hlspec.step_Unmap_enabled.? (Poly) Bool)

;; Function-Decl main::spec_t::hlspec::step_Unmap
(declare-fun main!spec_t.hlspec.step_Unmap.? (Poly Poly Poly Poly Poly) Bool)

;; Function-Decl main::spec_t::hlspec::step_Resolve_enabled
(declare-fun main!spec_t.hlspec.step_Resolve_enabled.? (Poly) Bool)

;; Function-Decl main::spec_t::hlspec::step_Resolve
(declare-fun main!spec_t.hlspec.step_Resolve.? (Poly Poly Poly Poly Poly) Bool)

;; Function-Decl main::spec_t::hlspec::step_Stutter
(declare-fun main!spec_t.hlspec.step_Stutter.? (Poly Poly Poly) Bool)

;; Function-Decl main::spec_t::hlspec::next_step
(declare-fun main!spec_t.hlspec.next_step.? (Poly Poly Poly Poly) Bool)

;; Function-Decl main::spec_t::hlspec::next
(declare-fun main!spec_t.hlspec.next.? (Poly Poly Poly) Bool)

;; Function-Decl main::spec_t::mem::word_index_spec
(declare-fun main!spec_t.mem.word_index_spec.? (Poly) Int)

;; Function-Decl main::definitions_t::X86_NUM_LAYERS
(declare-fun main!definitions_t.X86_NUM_LAYERS.? () Int)

;; Function-Decl main::definitions_t::X86_NUM_ENTRIES
(declare-fun main!definitions_t.X86_NUM_ENTRIES.? () Int)

;; Function-Decl main::definitions_t::WORD_SIZE
(declare-fun main!definitions_t.WORD_SIZE.? () Int)

;; Function-Decl main::definitions_t::PAGE_SIZE
(declare-fun main!definitions_t.PAGE_SIZE.? () Int)

;; Function-Decl main::definitions_t::X86_MAX_ENTRY_SIZE
(declare-fun main!definitions_t.X86_MAX_ENTRY_SIZE.? () Int)

;; Function-Decl main::definitions_t::PT_BOUND_LOW
(declare-fun main!definitions_t.PT_BOUND_LOW.? () Int)

;; Function-Decl main::definitions_t::PT_BOUND_HIGH
(declare-fun main!definitions_t.PT_BOUND_HIGH.? () Int)

;; Function-Decl main::definitions_t::L3_ENTRY_SIZE
(declare-fun main!definitions_t.L3_ENTRY_SIZE.? () Int)

;; Function-Decl main::definitions_t::L2_ENTRY_SIZE
(declare-fun main!definitions_t.L2_ENTRY_SIZE.? () Int)

;; Function-Decl main::definitions_t::L1_ENTRY_SIZE
(declare-fun main!definitions_t.L1_ENTRY_SIZE.? () Int)

;; Function-Decl main::definitions_t::L0_ENTRY_SIZE
(declare-fun main!definitions_t.L0_ENTRY_SIZE.? () Int)

;; Function-Decl main::definitions_t::entry_base_from_index
(declare-fun main!definitions_t.entry_base_from_index.? (Poly Poly Poly) Int)

;; Function-Decl main::definitions_t::candidate_mapping_in_bounds
(declare-fun main!definitions_t.candidate_mapping_in_bounds.? (Poly Poly) Bool)

;; Function-Decl main::definitions_t::candidate_mapping_overlaps_existing_vmem
(declare-fun main!definitions_t.candidate_mapping_overlaps_existing_vmem.? (Poly Poly
  Poly
 ) Bool
)

;; Function-Decl main::definitions_t::candidate_mapping_overlaps_existing_pmem
(declare-fun main!definitions_t.candidate_mapping_overlaps_existing_pmem.? (Poly Poly
  Poly
 ) Bool
)

;; Function-Decl main::definitions_t::aligned
(declare-fun main!definitions_t.aligned.? (Poly Poly) Bool)

;; Function-Decl main::definitions_t::between
(declare-fun main!definitions_t.between.? (Poly Poly Poly) Bool)

;; Function-Decl main::definitions_t::MapResult::is_ErrOverlap
(declare-fun main!definitions_t.impl&%0.is_ErrOverlap.? (Poly) Bool)

;; Function-Decl main::definitions_t::MapResult::is_Ok
(declare-fun main!definitions_t.impl&%0.is_Ok.? (Poly) Bool)

;; Function-Decl main::definitions_t::UnmapResult::is_ErrNoSuchMapping
(declare-fun main!definitions_t.impl&%1.is_ErrNoSuchMapping.? (Poly) Bool)

;; Function-Decl main::definitions_t::UnmapResult::is_Ok
(declare-fun main!definitions_t.impl&%1.is_Ok.? (Poly) Bool)

;; Function-Decl main::definitions_t::LoadResult::is_Pagefault
(declare-fun main!definitions_t.impl&%7.is_Pagefault.? (Poly) Bool)

;; Function-Decl main::definitions_t::LoadResult::is_Value
(declare-fun main!definitions_t.impl&%7.is_Value.? (Poly) Bool)

;; Function-Decl main::definitions_t::LoadResult::get_Value_0
(declare-fun main!definitions_t.impl&%7.get_Value_0.? (Poly) Int)

;; Function-Decl main::definitions_t::StoreResult::is_Pagefault
(declare-fun main!definitions_t.impl&%9.is_Pagefault.? (Poly) Bool)

;; Function-Decl main::definitions_t::StoreResult::is_Ok
(declare-fun main!definitions_t.impl&%9.is_Ok.? (Poly) Bool)

;; Function-Decl main::definitions_t::overlap
(declare-fun main!definitions_t.overlap.? (Poly Poly) Bool)

;; Function-Decl main::definitions_t::Arch::entry_size
(declare-fun main!definitions_t.impl&%15.entry_size.? (Poly Poly) Int)

;; Function-Decl main::definitions_t::Arch::num_entries
(declare-fun main!definitions_t.impl&%15.num_entries.? (Poly Poly) Int)

;; Function-Decl main::definitions_t::Arch::upper_vaddr
(declare-fun main!definitions_t.impl&%15.upper_vaddr.? (Poly Poly Poly) Int)

;; Function-Decl main::definitions_t::Arch::inv
(declare-fun main!definitions_t.impl&%15.inv.? (Poly) Bool)

;; Function-Decl main::definitions_t::Arch::entry_size_is_next_layer_size
(declare-fun main!definitions_t.impl&%15.entry_size_is_next_layer_size.? (Poly Poly)
 Bool
)

;; Function-Decl main::definitions_t::Arch::entry_base
(declare-fun main!definitions_t.impl&%15.entry_base.? (Poly Poly Poly Poly) Int)

;; Function-Decl main::definitions_t::x86_arch_spec
(declare-fun main!definitions_t.x86_arch_spec.? () main!definitions_t.Arch.)

;; Function-Axioms vstd::seq::Seq::len
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly)) (!
   (=>
    (has_type self! (TYPE%vstd!seq.Seq. A&. A&))
    (<= 0 (vstd!seq.Seq.len.? A&. A& self!))
   )
   :pattern ((vstd!seq.Seq.len.? A&. A& self!))
   :qid internal_vstd!seq.Seq.len.?_pre_post_definition
)))

;; Function-Specs vstd::seq::Seq::index
(declare-fun req%vstd!seq.Seq.index. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%0 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (i! Poly)) (!
   (= (req%vstd!seq.Seq.index. A&. A& self! i!) (=>
     %%global_location_label%%0
     (and
      (<= 0 (%I i!))
      (< (%I i!) (vstd!seq.Seq.len.? A&. A& self!))
   )))
   :pattern ((req%vstd!seq.Seq.index. A&. A& self! i!))
   :qid internal_req__vstd!seq.Seq.index._definition
)))

;; Function-Axioms vstd::seq::Seq::index
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i! INT)
    )
    (has_type (vstd!seq.Seq.index.? A&. A& self! i!) A&)
   )
   :pattern ((vstd!seq.Seq.index.? A&. A& self! i!))
   :qid internal_vstd!seq.Seq.index.?_pre_post_definition
)))

;; Function-Axioms vstd::seq::Seq::empty
(assert
 (forall ((A&. Dcr) (A& Type)) (!
   (has_type (vstd!seq.Seq.empty.? A&. A&) (TYPE%vstd!seq.Seq. A&. A&))
   :pattern ((vstd!seq.Seq.empty.? A&. A&))
   :qid internal_vstd!seq.Seq.empty.?_pre_post_definition
)))

;; Function-Axioms vstd::seq::Seq::push
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type a! A&)
    )
    (has_type (vstd!seq.Seq.push.? A&. A& self! a!) (TYPE%vstd!seq.Seq. A&. A&))
   )
   :pattern ((vstd!seq.Seq.push.? A&. A& self! a!))
   :qid internal_vstd!seq.Seq.push.?_pre_post_definition
)))

;; Function-Specs vstd::seq::impl&%0::spec_index
(declare-fun req%vstd!seq.impl&%0.spec_index. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%1 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (i! Poly)) (!
   (= (req%vstd!seq.impl&%0.spec_index. A&. A& self! i!) (=>
     %%global_location_label%%1
     (and
      (<= 0 (%I i!))
      (< (%I i!) (vstd!seq.Seq.len.? A&. A& self!))
   )))
   :pattern ((req%vstd!seq.impl&%0.spec_index. A&. A& self! i!))
   :qid internal_req__vstd!seq.impl&__0.spec_index._definition
)))

;; Function-Axioms vstd::seq::impl&%0::spec_index
(assert
 (fuel_bool_default fuel%vstd!seq.impl&%0.spec_index.)
)
(assert
 (=>
  (fuel_bool fuel%vstd!seq.impl&%0.spec_index.)
  (forall ((A&. Dcr) (A& Type) (self! Poly) (i! Poly)) (!
    (= (vstd!seq.impl&%0.spec_index.? A&. A& self! i!) (vstd!seq.Seq.index.? A&. A& self!
      i!
    ))
    :pattern ((vstd!seq.impl&%0.spec_index.? A&. A& self! i!))
    :qid internal_vstd!seq.impl&__0.spec_index.?_definition
))))
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i! INT)
    )
    (has_type (vstd!seq.impl&%0.spec_index.? A&. A& self! i!) A&)
   )
   :pattern ((vstd!seq.impl&%0.spec_index.? A&. A& self! i!))
   :qid internal_vstd!seq.impl&__0.spec_index.?_pre_post_definition
)))

;; Function-Specs vstd::seq::Seq::subrange
(declare-fun req%vstd!seq.Seq.subrange. (Dcr Type Poly Poly Poly) Bool)
(declare-const %%global_location_label%%2 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (start_inclusive! Poly) (end_exclusive! Poly))
  (!
   (= (req%vstd!seq.Seq.subrange. A&. A& self! start_inclusive! end_exclusive!) (=>
     %%global_location_label%%2
     (and
      (and
       (<= 0 (%I start_inclusive!))
       (<= (%I start_inclusive!) (%I end_exclusive!))
      )
      (<= (%I end_exclusive!) (vstd!seq.Seq.len.? A&. A& self!))
   )))
   :pattern ((req%vstd!seq.Seq.subrange. A&. A& self! start_inclusive! end_exclusive!))
   :qid internal_req__vstd!seq.Seq.subrange._definition
)))

;; Function-Axioms vstd::seq::Seq::subrange
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (start_inclusive! Poly) (end_exclusive! Poly))
  (!
   (=>
    (and
     (has_type self! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type start_inclusive! INT)
     (has_type end_exclusive! INT)
    )
    (has_type (vstd!seq.Seq.subrange.? A&. A& self! start_inclusive! end_exclusive!) (
      TYPE%vstd!seq.Seq. A&. A&
   )))
   :pattern ((vstd!seq.Seq.subrange.? A&. A& self! start_inclusive! end_exclusive!))
   :qid internal_vstd!seq.Seq.subrange.?_pre_post_definition
)))

;; Function-Axioms vstd::seq::Seq::add
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (rhs! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type rhs! (TYPE%vstd!seq.Seq. A&. A&))
    )
    (has_type (vstd!seq.Seq.add.? A&. A& self! rhs!) (TYPE%vstd!seq.Seq. A&. A&))
   )
   :pattern ((vstd!seq.Seq.add.? A&. A& self! rhs!))
   :qid internal_vstd!seq.Seq.add.?_pre_post_definition
)))

;; Function-Specs vstd::seq::Seq::update
(declare-fun req%vstd!seq.Seq.update. (Dcr Type Poly Poly Poly) Bool)
(declare-const %%global_location_label%%3 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (i! Poly) (a! Poly)) (!
   (= (req%vstd!seq.Seq.update. A&. A& self! i! a!) (=>
     %%global_location_label%%3
     (and
      (<= 0 (%I i!))
      (< (%I i!) (vstd!seq.Seq.len.? A&. A& self!))
   )))
   :pattern ((req%vstd!seq.Seq.update. A&. A& self! i! a!))
   :qid internal_req__vstd!seq.Seq.update._definition
)))

;; Function-Axioms vstd::seq::Seq::update
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (i! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i! INT)
     (has_type a! A&)
    )
    (has_type (vstd!seq.Seq.update.? A&. A& self! i! a!) (TYPE%vstd!seq.Seq. A&. A&))
   )
   :pattern ((vstd!seq.Seq.update.? A&. A& self! i! a!))
   :qid internal_vstd!seq.Seq.update.?_pre_post_definition
)))

;; Function-Axioms vstd::map::impl&%0::empty
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type)) (!
   (has_type (vstd!map.impl&%0.empty.? K&. K& V&. V&) (TYPE%vstd!map.Map. K&. K& V&. V&))
   :pattern ((vstd!map.impl&%0.empty.? K&. K& V&. V&))
   :qid internal_vstd!map.impl&__0.empty.?_pre_post_definition
)))

;; Function-Axioms vstd::map::impl&%0::dom
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly)) (!
   (=>
    (has_type self! (TYPE%vstd!map.Map. K&. K& V&. V&))
    (has_type (vstd!map.impl&%0.dom.? K&. K& V&. V& self!) (TYPE%vstd!set.Set. K&. K&))
   )
   :pattern ((vstd!map.impl&%0.dom.? K&. K& V&. V& self!))
   :qid internal_vstd!map.impl&__0.dom.?_pre_post_definition
)))

;; Function-Specs vstd::map::impl&%0::index
(declare-fun req%vstd!map.impl&%0.index. (Dcr Type Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%4 Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly) (key! Poly)) (!
   (= (req%vstd!map.impl&%0.index. K&. K& V&. V& self! key!) (=>
     %%global_location_label%%4
     (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& self!) key!)
   ))
   :pattern ((req%vstd!map.impl&%0.index. K&. K& V&. V& self! key!))
   :qid internal_req__vstd!map.impl&__0.index._definition
)))

;; Function-Axioms vstd::map::impl&%0::index
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly) (key! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
    )
    (has_type (vstd!map.impl&%0.index.? K&. K& V&. V& self! key!) V&)
   )
   :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& self! key!))
   :qid internal_vstd!map.impl&__0.index.?_pre_post_definition
)))

;; Function-Axioms vstd::map::impl&%0::insert
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly) (key! Poly) (value! Poly))
  (!
   (=>
    (and
     (has_type self! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
     (has_type value! V&)
    )
    (has_type (vstd!map.impl&%0.insert.? K&. K& V&. V& self! key! value!) (TYPE%vstd!map.Map.
      K&. K& V&. V&
   )))
   :pattern ((vstd!map.impl&%0.insert.? K&. K& V&. V& self! key! value!))
   :qid internal_vstd!map.impl&__0.insert.?_pre_post_definition
)))

;; Function-Axioms vstd::map::impl&%0::remove
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly) (key! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
    )
    (has_type (vstd!map.impl&%0.remove.? K&. K& V&. V& self! key!) (TYPE%vstd!map.Map.
      K&. K& V&. V&
   )))
   :pattern ((vstd!map.impl&%0.remove.? K&. K& V&. V& self! key!))
   :qid internal_vstd!map.impl&__0.remove.?_pre_post_definition
)))

;; Function-Specs vstd::map::impl&%0::spec_index
(declare-fun req%vstd!map.impl&%0.spec_index. (Dcr Type Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%5 Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly) (key! Poly)) (!
   (= (req%vstd!map.impl&%0.spec_index. K&. K& V&. V& self! key!) (=>
     %%global_location_label%%5
     (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& self!) key!)
   ))
   :pattern ((req%vstd!map.impl&%0.spec_index. K&. K& V&. V& self! key!))
   :qid internal_req__vstd!map.impl&__0.spec_index._definition
)))

;; Function-Axioms vstd::map::impl&%0::spec_index
(assert
 (fuel_bool_default fuel%vstd!map.impl&%0.spec_index.)
)
(assert
 (=>
  (fuel_bool fuel%vstd!map.impl&%0.spec_index.)
  (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly) (key! Poly)) (!
    (= (vstd!map.impl&%0.spec_index.? K&. K& V&. V& self! key!) (vstd!map.impl&%0.index.?
      K&. K& V&. V& self! key!
    ))
    :pattern ((vstd!map.impl&%0.spec_index.? K&. K& V&. V& self! key!))
    :qid internal_vstd!map.impl&__0.spec_index.?_definition
))))
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly) (key! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
    )
    (has_type (vstd!map.impl&%0.spec_index.? K&. K& V&. V& self! key!) V&)
   )
   :pattern ((vstd!map.impl&%0.spec_index.? K&. K& V&. V& self! key!))
   :qid internal_vstd!map.impl&__0.spec_index.?_pre_post_definition
)))

;; Function-Axioms vstd::set::impl&%0::mk_map
(assert
 (forall ((A&. Dcr) (A& Type) (V&. Dcr) (V& Type) (F&. Dcr) (F& Type) (self! Poly) (
    f! Poly
   )
  ) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!set.Set. A&. A&))
     (has_type f! F&)
    )
    (has_type (vstd!set.impl&%0.mk_map.? A&. A& V&. V& F&. F& self! f!) (TYPE%vstd!map.Map.
      A&. A& V&. V&
   )))
   :pattern ((vstd!set.impl&%0.mk_map.? A&. A& V&. V& F&. F& self! f!))
   :qid internal_vstd!set.impl&__0.mk_map.?_pre_post_definition
)))

;; Function-Axioms vstd::set::impl&%0::new
(assert
 (forall ((A&. Dcr) (A& Type) (F&. Dcr) (F& Type) (f! Poly)) (!
   (=>
    (has_type f! F&)
    (has_type (vstd!set.impl&%0.new.? A&. A& F&. F& f!) (TYPE%vstd!set.Set. A&. A&))
   )
   :pattern ((vstd!set.impl&%0.new.? A&. A& F&. F& f!))
   :qid internal_vstd!set.impl&__0.new.?_pre_post_definition
)))

;; Function-Specs vstd::map::axiom_map_index_decreases_finite
(declare-fun req%vstd!map.axiom_map_index_decreases_finite. (Dcr Type Dcr Type Poly
  Poly
 ) Bool
)
(declare-const %%global_location_label%%6 Bool)
(declare-const %%global_location_label%%7 Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly)) (!
   (= (req%vstd!map.axiom_map_index_decreases_finite. K&. K& V&. V& m! key!) (and
     (=>
      %%global_location_label%%6
      (vstd!set.impl&%0.finite.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!))
     )
     (=>
      %%global_location_label%%7
      (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key!)
   )))
   :pattern ((req%vstd!map.axiom_map_index_decreases_finite. K&. K& V&. V& m! key!))
   :qid internal_req__vstd!map.axiom_map_index_decreases_finite._definition
)))
(declare-fun ens%vstd!map.axiom_map_index_decreases_finite. (Dcr Type Dcr Type Poly
  Poly
 ) Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly)) (!
   (= (ens%vstd!map.axiom_map_index_decreases_finite. K&. K& V&. V& m! key!) (height_lt
     (height (vstd!map.impl&%0.index.? K&. K& V&. V& m! key!)) (height m!)
   ))
   :pattern ((ens%vstd!map.axiom_map_index_decreases_finite. K&. K& V&. V& m! key!))
   :qid internal_ens__vstd!map.axiom_map_index_decreases_finite._definition
)))

;; Broadcast vstd::map::axiom_map_index_decreases_finite
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly)) (!
   (=>
    (and
     (has_type m! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
    )
    (=>
     (and
      (vstd!set.impl&%0.finite.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!))
      (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key!)
     )
     (height_lt (height (vstd!map.impl&%0.index.? K&. K& V&. V& m! key!)) (height m!))
   ))
   :pattern ((height (vstd!map.impl&%0.index.? K&. K& V&. V& m! key!)))
   :qid user_vstd__map__axiom_map_index_decreases_finite_0
)))

;; Function-Specs vstd::map::axiom_map_index_decreases_infinite
(declare-fun req%vstd!map.axiom_map_index_decreases_infinite. (Dcr Type Dcr Type Poly
  Poly
 ) Bool
)
(declare-const %%global_location_label%%8 Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly)) (!
   (= (req%vstd!map.axiom_map_index_decreases_infinite. K&. K& V&. V& m! key!) (=>
     %%global_location_label%%8
     (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key!)
   ))
   :pattern ((req%vstd!map.axiom_map_index_decreases_infinite. K&. K& V&. V& m! key!))
   :qid internal_req__vstd!map.axiom_map_index_decreases_infinite._definition
)))
(declare-fun ens%vstd!map.axiom_map_index_decreases_infinite. (Dcr Type Dcr Type Poly
  Poly
 ) Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly)) (!
   (= (ens%vstd!map.axiom_map_index_decreases_infinite. K&. K& V&. V& m! key!) (height_lt
     (height (vstd!map.impl&%0.index.? K&. K& V&. V& m! key!)) (height (fun_from_recursive_field
       m!
   ))))
   :pattern ((ens%vstd!map.axiom_map_index_decreases_infinite. K&. K& V&. V& m! key!))
   :qid internal_ens__vstd!map.axiom_map_index_decreases_infinite._definition
)))

;; Broadcast vstd::map::axiom_map_index_decreases_infinite
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly)) (!
   (=>
    (and
     (has_type m! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
    )
    (=>
     (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key!)
     (height_lt (height (vstd!map.impl&%0.index.? K&. K& V&. V& m! key!)) (height (fun_from_recursive_field
        m!
   )))))
   :pattern ((height (vstd!map.impl&%0.index.? K&. K& V&. V& m! key!)))
   :qid user_vstd__map__axiom_map_index_decreases_infinite_1
)))

;; Function-Axioms vstd::set::impl&%0::empty
(assert
 (forall ((A&. Dcr) (A& Type)) (!
   (has_type (vstd!set.impl&%0.empty.? A&. A&) (TYPE%vstd!set.Set. A&. A&))
   :pattern ((vstd!set.impl&%0.empty.? A&. A&))
   :qid internal_vstd!set.impl&__0.empty.?_pre_post_definition
)))

;; Function-Specs vstd::map::axiom_map_empty
(declare-fun ens%vstd!map.axiom_map_empty. (Dcr Type Dcr Type) Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type)) (!
   (= (ens%vstd!map.axiom_map_empty. K&. K& V&. V&) (= (vstd!map.impl&%0.dom.? K&. K& V&.
      V& (vstd!map.impl&%0.empty.? K&. K& V&. V&)
     ) (vstd!set.impl&%0.empty.? K&. K&)
   ))
   :pattern ((ens%vstd!map.axiom_map_empty. K&. K& V&. V&))
   :qid internal_ens__vstd!map.axiom_map_empty._definition
)))

;; Broadcast vstd::map::axiom_map_empty
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type)) (!
   (= (vstd!map.impl&%0.dom.? K&. K& V&. V& (vstd!map.impl&%0.empty.? K&. K& V&. V&))
    (vstd!set.impl&%0.empty.? K&. K&)
   )
   :pattern ((vstd!map.impl&%0.dom.? K&. K& V&. V& (vstd!map.impl&%0.empty.? K&. K& V&.
      V&
   )))
   :qid user_vstd__map__axiom_map_empty_2
)))

;; Function-Axioms vstd::set::impl&%0::insert
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (has_type (vstd!set.impl&%0.insert.? A&. A& self! a!) (TYPE%vstd!set.Set. A&. A&))
   )
   :pattern ((vstd!set.impl&%0.insert.? A&. A& self! a!))
   :qid internal_vstd!set.impl&__0.insert.?_pre_post_definition
)))

;; Function-Specs vstd::map::axiom_map_insert_domain
(declare-fun ens%vstd!map.axiom_map_insert_domain. (Dcr Type Dcr Type Poly Poly Poly)
 Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly) (value! Poly))
  (!
   (= (ens%vstd!map.axiom_map_insert_domain. K&. K& V&. V& m! key! value!) (= (vstd!map.impl&%0.dom.?
      K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K& V&. V& m! key! value!)
     ) (vstd!set.impl&%0.insert.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key!)
   ))
   :pattern ((ens%vstd!map.axiom_map_insert_domain. K&. K& V&. V& m! key! value!))
   :qid internal_ens__vstd!map.axiom_map_insert_domain._definition
)))

;; Broadcast vstd::map::axiom_map_insert_domain
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly) (value! Poly))
  (!
   (=>
    (and
     (has_type m! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
     (has_type value! V&)
    )
    (= (vstd!map.impl&%0.dom.? K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K& V&. V& m!
       key! value!
      )
     ) (vstd!set.impl&%0.insert.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key!)
   ))
   :pattern ((vstd!map.impl&%0.dom.? K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K& V&.
      V& m! key! value!
   )))
   :qid user_vstd__map__axiom_map_insert_domain_3
)))

;; Function-Specs vstd::map::axiom_map_insert_same
(declare-fun ens%vstd!map.axiom_map_insert_same. (Dcr Type Dcr Type Poly Poly Poly)
 Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly) (value! Poly))
  (!
   (= (ens%vstd!map.axiom_map_insert_same. K&. K& V&. V& m! key! value!) (= (vstd!map.impl&%0.index.?
      K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K& V&. V& m! key! value!) key!
     ) value!
   ))
   :pattern ((ens%vstd!map.axiom_map_insert_same. K&. K& V&. V& m! key! value!))
   :qid internal_ens__vstd!map.axiom_map_insert_same._definition
)))

;; Broadcast vstd::map::axiom_map_insert_same
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly) (value! Poly))
  (!
   (=>
    (and
     (has_type m! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
     (has_type value! V&)
    )
    (= (vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K& V&. V&
       m! key! value!
      ) key!
     ) value!
   ))
   :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K&
      V&. V& m! key! value!
     ) key!
   ))
   :qid user_vstd__map__axiom_map_insert_same_4
)))

;; Function-Specs vstd::map::axiom_map_insert_different
(declare-fun req%vstd!map.axiom_map_insert_different. (Dcr Type Dcr Type Poly Poly
  Poly Poly
 ) Bool
)
(declare-const %%global_location_label%%9 Bool)
(declare-const %%global_location_label%%10 Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key1! Poly) (key2! Poly)
   (value! Poly)
  ) (!
   (= (req%vstd!map.axiom_map_insert_different. K&. K& V&. V& m! key1! key2! value!)
    (and
     (=>
      %%global_location_label%%9
      (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key1!)
     )
     (=>
      %%global_location_label%%10
      (not (= key1! key2!))
   )))
   :pattern ((req%vstd!map.axiom_map_insert_different. K&. K& V&. V& m! key1! key2! value!))
   :qid internal_req__vstd!map.axiom_map_insert_different._definition
)))
(declare-fun ens%vstd!map.axiom_map_insert_different. (Dcr Type Dcr Type Poly Poly
  Poly Poly
 ) Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key1! Poly) (key2! Poly)
   (value! Poly)
  ) (!
   (= (ens%vstd!map.axiom_map_insert_different. K&. K& V&. V& m! key1! key2! value!)
    (= (vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K& V&. V&
       m! key2! value!
      ) key1!
     ) (vstd!map.impl&%0.index.? K&. K& V&. V& m! key1!)
   ))
   :pattern ((ens%vstd!map.axiom_map_insert_different. K&. K& V&. V& m! key1! key2! value!))
   :qid internal_ens__vstd!map.axiom_map_insert_different._definition
)))

;; Broadcast vstd::map::axiom_map_insert_different
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key1! Poly) (key2! Poly)
   (value! Poly)
  ) (!
   (=>
    (and
     (has_type m! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key1! K&)
     (has_type key2! K&)
     (has_type value! V&)
    )
    (=>
     (and
      (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key1!)
      (not (= key1! key2!))
     )
     (= (vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K& V&. V&
        m! key2! value!
       ) key1!
      ) (vstd!map.impl&%0.index.? K&. K& V&. V& m! key1!)
   )))
   :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!map.impl&%0.insert.? K&. K&
      V&. V& m! key2! value!
     ) key1!
   ))
   :qid user_vstd__map__axiom_map_insert_different_5
)))

;; Function-Axioms vstd::set::impl&%0::remove
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (has_type (vstd!set.impl&%0.remove.? A&. A& self! a!) (TYPE%vstd!set.Set. A&. A&))
   )
   :pattern ((vstd!set.impl&%0.remove.? A&. A& self! a!))
   :qid internal_vstd!set.impl&__0.remove.?_pre_post_definition
)))

;; Function-Specs vstd::map::axiom_map_remove_domain
(declare-fun ens%vstd!map.axiom_map_remove_domain. (Dcr Type Dcr Type Poly Poly) Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly)) (!
   (= (ens%vstd!map.axiom_map_remove_domain. K&. K& V&. V& m! key!) (= (vstd!map.impl&%0.dom.?
      K&. K& V&. V& (vstd!map.impl&%0.remove.? K&. K& V&. V& m! key!)
     ) (vstd!set.impl&%0.remove.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key!)
   ))
   :pattern ((ens%vstd!map.axiom_map_remove_domain. K&. K& V&. V& m! key!))
   :qid internal_ens__vstd!map.axiom_map_remove_domain._definition
)))

;; Broadcast vstd::map::axiom_map_remove_domain
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key! Poly)) (!
   (=>
    (and
     (has_type m! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key! K&)
    )
    (= (vstd!map.impl&%0.dom.? K&. K& V&. V& (vstd!map.impl&%0.remove.? K&. K& V&. V& m!
       key!
      )
     ) (vstd!set.impl&%0.remove.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key!)
   ))
   :pattern ((vstd!map.impl&%0.dom.? K&. K& V&. V& (vstd!map.impl&%0.remove.? K&. K& V&.
      V& m! key!
   )))
   :qid user_vstd__map__axiom_map_remove_domain_6
)))

;; Function-Specs vstd::map::axiom_map_remove_different
(declare-fun req%vstd!map.axiom_map_remove_different. (Dcr Type Dcr Type Poly Poly
  Poly
 ) Bool
)
(declare-const %%global_location_label%%11 Bool)
(declare-const %%global_location_label%%12 Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key1! Poly) (key2! Poly))
  (!
   (= (req%vstd!map.axiom_map_remove_different. K&. K& V&. V& m! key1! key2!) (and
     (=>
      %%global_location_label%%11
      (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key1!)
     )
     (=>
      %%global_location_label%%12
      (not (= key1! key2!))
   )))
   :pattern ((req%vstd!map.axiom_map_remove_different. K&. K& V&. V& m! key1! key2!))
   :qid internal_req__vstd!map.axiom_map_remove_different._definition
)))
(declare-fun ens%vstd!map.axiom_map_remove_different. (Dcr Type Dcr Type Poly Poly
  Poly
 ) Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key1! Poly) (key2! Poly))
  (!
   (= (ens%vstd!map.axiom_map_remove_different. K&. K& V&. V& m! key1! key2!) (= (vstd!map.impl&%0.index.?
      K&. K& V&. V& (vstd!map.impl&%0.remove.? K&. K& V&. V& m! key2!) key1!
     ) (vstd!map.impl&%0.index.? K&. K& V&. V& m! key1!)
   ))
   :pattern ((ens%vstd!map.axiom_map_remove_different. K&. K& V&. V& m! key1! key2!))
   :qid internal_ens__vstd!map.axiom_map_remove_different._definition
)))

;; Broadcast vstd::map::axiom_map_remove_different
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m! Poly) (key1! Poly) (key2! Poly))
  (!
   (=>
    (and
     (has_type m! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type key1! K&)
     (has_type key2! K&)
    )
    (=>
     (and
      (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m!) key1!)
      (not (= key1! key2!))
     )
     (= (vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!map.impl&%0.remove.? K&. K& V&. V&
        m! key2!
       ) key1!
      ) (vstd!map.impl&%0.index.? K&. K& V&. V& m! key1!)
   )))
   :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!map.impl&%0.remove.? K&. K&
      V&. V& m! key2!
     ) key1!
   ))
   :qid user_vstd__map__axiom_map_remove_different_7
)))

;; Function-Specs vstd::map::axiom_map_ext_equal
(declare-fun ens%vstd!map.axiom_map_ext_equal. (Dcr Type Dcr Type Poly Poly) Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m1! Poly) (m2! Poly)) (!
   (= (ens%vstd!map.axiom_map_ext_equal. K&. K& V&. V& m1! m2!) (= (ext_eq false (TYPE%vstd!map.Map.
       K&. K& V&. V&
      ) m1! m2!
     ) (and
      (ext_eq false (TYPE%vstd!set.Set. K&. K&) (vstd!map.impl&%0.dom.? K&. K& V&. V& m1!)
       (vstd!map.impl&%0.dom.? K&. K& V&. V& m2!)
      )
      (forall ((k$ Poly)) (!
        (=>
         (has_type k$ K&)
         (=>
          (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m1!) k$)
          (= (vstd!map.impl&%0.index.? K&. K& V&. V& m1! k$) (vstd!map.impl&%0.index.? K&. K&
            V&. V& m2! k$
        ))))
        :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& m1! k$))
        :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& m2! k$))
        :qid user_vstd__map__axiom_map_ext_equal_8
   )))))
   :pattern ((ens%vstd!map.axiom_map_ext_equal. K&. K& V&. V& m1! m2!))
   :qid internal_ens__vstd!map.axiom_map_ext_equal._definition
)))

;; Broadcast vstd::map::axiom_map_ext_equal
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m1! Poly) (m2! Poly)) (!
   (=>
    (and
     (has_type m1! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type m2! (TYPE%vstd!map.Map. K&. K& V&. V&))
    )
    (= (ext_eq false (TYPE%vstd!map.Map. K&. K& V&. V&) m1! m2!) (and
      (ext_eq false (TYPE%vstd!set.Set. K&. K&) (vstd!map.impl&%0.dom.? K&. K& V&. V& m1!)
       (vstd!map.impl&%0.dom.? K&. K& V&. V& m2!)
      )
      (forall ((k$ Poly)) (!
        (=>
         (has_type k$ K&)
         (=>
          (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m1!) k$)
          (= (vstd!map.impl&%0.index.? K&. K& V&. V& m1! k$) (vstd!map.impl&%0.index.? K&. K&
            V&. V& m2! k$
        ))))
        :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& m1! k$))
        :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& m2! k$))
        :qid user_vstd__map__axiom_map_ext_equal_9
   )))))
   :pattern ((ext_eq false (TYPE%vstd!map.Map. K&. K& V&. V&) m1! m2!))
   :qid user_vstd__map__axiom_map_ext_equal_10
)))

;; Function-Specs vstd::map::axiom_map_ext_equal_deep
(declare-fun ens%vstd!map.axiom_map_ext_equal_deep. (Dcr Type Dcr Type Poly Poly)
 Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m1! Poly) (m2! Poly)) (!
   (= (ens%vstd!map.axiom_map_ext_equal_deep. K&. K& V&. V& m1! m2!) (= (ext_eq true (TYPE%vstd!map.Map.
       K&. K& V&. V&
      ) m1! m2!
     ) (and
      (ext_eq true (TYPE%vstd!set.Set. K&. K&) (vstd!map.impl&%0.dom.? K&. K& V&. V& m1!)
       (vstd!map.impl&%0.dom.? K&. K& V&. V& m2!)
      )
      (forall ((k$ Poly)) (!
        (=>
         (has_type k$ K&)
         (=>
          (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m1!) k$)
          (ext_eq true V& (vstd!map.impl&%0.index.? K&. K& V&. V& m1! k$) (vstd!map.impl&%0.index.?
            K&. K& V&. V& m2! k$
        ))))
        :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& m1! k$))
        :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& m2! k$))
        :qid user_vstd__map__axiom_map_ext_equal_deep_11
   )))))
   :pattern ((ens%vstd!map.axiom_map_ext_equal_deep. K&. K& V&. V& m1! m2!))
   :qid internal_ens__vstd!map.axiom_map_ext_equal_deep._definition
)))

;; Broadcast vstd::map::axiom_map_ext_equal_deep
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (m1! Poly) (m2! Poly)) (!
   (=>
    (and
     (has_type m1! (TYPE%vstd!map.Map. K&. K& V&. V&))
     (has_type m2! (TYPE%vstd!map.Map. K&. K& V&. V&))
    )
    (= (ext_eq true (TYPE%vstd!map.Map. K&. K& V&. V&) m1! m2!) (and
      (ext_eq true (TYPE%vstd!set.Set. K&. K&) (vstd!map.impl&%0.dom.? K&. K& V&. V& m1!)
       (vstd!map.impl&%0.dom.? K&. K& V&. V& m2!)
      )
      (forall ((k$ Poly)) (!
        (=>
         (has_type k$ K&)
         (=>
          (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& m1!) k$)
          (ext_eq true V& (vstd!map.impl&%0.index.? K&. K& V&. V& m1! k$) (vstd!map.impl&%0.index.?
            K&. K& V&. V& m2! k$
        ))))
        :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& m1! k$))
        :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& m2! k$))
        :qid user_vstd__map__axiom_map_ext_equal_deep_12
   )))))
   :pattern ((ext_eq true (TYPE%vstd!map.Map. K&. K& V&. V&) m1! m2!))
   :qid user_vstd__map__axiom_map_ext_equal_deep_13
)))

;; Function-Axioms vstd::seq::Seq::new
(assert
 (forall ((A&. Dcr) (A& Type) (impl%1&. Dcr) (impl%1& Type) (len! Poly) (f! Poly))
  (!
   (=>
    (and
     (has_type len! NAT)
     (has_type f! impl%1&)
    )
    (has_type (vstd!seq.Seq.new.? A&. A& impl%1&. impl%1& len! f!) (TYPE%vstd!seq.Seq.
      A&. A&
   )))
   :pattern ((vstd!seq.Seq.new.? A&. A& impl%1&. impl%1& len! f!))
   :qid internal_vstd!seq.Seq.new.?_pre_post_definition
)))

;; Function-Specs vstd::seq::axiom_seq_index_decreases
(declare-fun req%vstd!seq.axiom_seq_index_decreases. (Dcr Type Poly Int) Bool)
(declare-const %%global_location_label%%13 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Int)) (!
   (= (req%vstd!seq.axiom_seq_index_decreases. A&. A& s! i!) (=>
     %%global_location_label%%13
     (and
      (<= 0 i!)
      (< i! (vstd!seq.Seq.len.? A&. A& s!))
   )))
   :pattern ((req%vstd!seq.axiom_seq_index_decreases. A&. A& s! i!))
   :qid internal_req__vstd!seq.axiom_seq_index_decreases._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_index_decreases. (Dcr Type Poly Int) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Int)) (!
   (= (ens%vstd!seq.axiom_seq_index_decreases. A&. A& s! i!) (height_lt (height (vstd!seq.Seq.index.?
       A&. A& s! (I i!)
      )
     ) (height s!)
   ))
   :pattern ((ens%vstd!seq.axiom_seq_index_decreases. A&. A& s! i!))
   :qid internal_ens__vstd!seq.axiom_seq_index_decreases._definition
)))

;; Broadcast vstd::seq::axiom_seq_index_decreases
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i! INT)
    )
    (=>
     (and
      (<= 0 (%I i!))
      (< (%I i!) (vstd!seq.Seq.len.? A&. A& s!))
     )
     (height_lt (height (vstd!seq.Seq.index.? A&. A& s! i!)) (height s!))
   ))
   :pattern ((height (vstd!seq.Seq.index.? A&. A& s! i!)))
   :qid user_vstd__seq__axiom_seq_index_decreases_14
)))

;; Function-Specs vstd::seq::axiom_seq_empty
(declare-fun ens%vstd!seq.axiom_seq_empty. (Dcr Type) Bool)
(assert
 (forall ((A&. Dcr) (A& Type)) (!
   (= (ens%vstd!seq.axiom_seq_empty. A&. A&) (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.empty.?
       A&. A&
      )
     ) 0
   ))
   :pattern ((ens%vstd!seq.axiom_seq_empty. A&. A&))
   :qid internal_ens__vstd!seq.axiom_seq_empty._definition
)))

;; Broadcast vstd::seq::axiom_seq_empty
(assert
 (forall ((A&. Dcr) (A& Type)) (!
   (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.empty.? A&. A&)) 0)
   :pattern ((vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.empty.? A&. A&)))
   :qid user_vstd__seq__axiom_seq_empty_15
)))

;; Function-Specs vstd::seq::axiom_seq_new_len
(declare-fun ens%vstd!seq.axiom_seq_new_len. (Dcr Type Int %%Function%%) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (len! Int) (f! %%Function%%)) (!
   (= (ens%vstd!seq.axiom_seq_new_len. A&. A& len! f!) (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.new.?
       A&. A& $ (TYPE%fun%1. $ INT A&. A&) (I len!) (Poly%fun%1. f!)
      )
     ) len!
   ))
   :pattern ((ens%vstd!seq.axiom_seq_new_len. A&. A& len! f!))
   :qid internal_ens__vstd!seq.axiom_seq_new_len._definition
)))

;; Broadcast vstd::seq::axiom_seq_new_len
(assert
 (forall ((A&. Dcr) (A& Type) (len! Poly) (f! Poly)) (!
   (=>
    (and
     (has_type len! NAT)
     (has_type f! (TYPE%fun%1. $ INT A&. A&))
    )
    (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.new.? A&. A& $ (TYPE%fun%1. $ INT A&. A&)
       len! f!
      )
     ) (%I len!)
   ))
   :pattern ((vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.new.? A&. A& $ (TYPE%fun%1. $ INT
       A&. A&
      ) len! f!
   )))
   :qid user_vstd__seq__axiom_seq_new_len_16
)))

;; Function-Specs vstd::seq::axiom_seq_new_index
(declare-fun req%vstd!seq.axiom_seq_new_index. (Dcr Type Int %%Function%% Int) Bool)
(declare-const %%global_location_label%%14 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (len! Int) (f! %%Function%%) (i! Int)) (!
   (= (req%vstd!seq.axiom_seq_new_index. A&. A& len! f! i!) (=>
     %%global_location_label%%14
     (and
      (<= 0 i!)
      (< i! len!)
   )))
   :pattern ((req%vstd!seq.axiom_seq_new_index. A&. A& len! f! i!))
   :qid internal_req__vstd!seq.axiom_seq_new_index._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_new_index. (Dcr Type Int %%Function%% Int) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (len! Int) (f! %%Function%%) (i! Int)) (!
   (= (ens%vstd!seq.axiom_seq_new_index. A&. A& len! f! i!) (= (vstd!seq.Seq.index.? A&.
      A& (vstd!seq.Seq.new.? A&. A& $ (TYPE%fun%1. $ INT A&. A&) (I len!) (Poly%fun%1. f!))
      (I i!)
     ) (%%apply%%0 f! (I i!))
   ))
   :pattern ((ens%vstd!seq.axiom_seq_new_index. A&. A& len! f! i!))
   :qid internal_ens__vstd!seq.axiom_seq_new_index._definition
)))

;; Broadcast vstd::seq::axiom_seq_new_index
(assert
 (forall ((A&. Dcr) (A& Type) (len! Poly) (f! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type len! NAT)
     (has_type f! (TYPE%fun%1. $ INT A&. A&))
     (has_type i! INT)
    )
    (=>
     (and
      (<= 0 (%I i!))
      (< (%I i!) (%I len!))
     )
     (= (vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.new.? A&. A& $ (TYPE%fun%1. $ INT A&. A&)
        len! f!
       ) i!
      ) (%%apply%%0 (%Poly%fun%1. f!) i!)
   )))
   :pattern ((vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.new.? A&. A& $ (TYPE%fun%1. $ INT
       A&. A&
      ) len! f!
     ) i!
   ))
   :qid user_vstd__seq__axiom_seq_new_index_17
)))

;; Function-Specs vstd::seq::axiom_seq_push_len
(declare-fun ens%vstd!seq.axiom_seq_push_len. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!seq.axiom_seq_push_len. A&. A& s! a!) (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.push.?
       A&. A& s! a!
      )
     ) (nClip (Add (vstd!seq.Seq.len.? A&. A& s!) 1))
   ))
   :pattern ((ens%vstd!seq.axiom_seq_push_len. A&. A& s! a!))
   :qid internal_ens__vstd!seq.axiom_seq_push_len._definition
)))

;; Broadcast vstd::seq::axiom_seq_push_len
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type a! A&)
    )
    (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.push.? A&. A& s! a!)) (nClip (Add (vstd!seq.Seq.len.?
        A&. A& s!
       ) 1
   ))))
   :pattern ((vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.push.? A&. A& s! a!)))
   :qid user_vstd__seq__axiom_seq_push_len_18
)))

;; Function-Specs vstd::seq::axiom_seq_push_index_same
(declare-fun req%vstd!seq.axiom_seq_push_index_same. (Dcr Type Poly Poly Int) Bool)
(declare-const %%global_location_label%%15 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly) (i! Int)) (!
   (= (req%vstd!seq.axiom_seq_push_index_same. A&. A& s! a! i!) (=>
     %%global_location_label%%15
     (= i! (vstd!seq.Seq.len.? A&. A& s!))
   ))
   :pattern ((req%vstd!seq.axiom_seq_push_index_same. A&. A& s! a! i!))
   :qid internal_req__vstd!seq.axiom_seq_push_index_same._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_push_index_same. (Dcr Type Poly Poly Int) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly) (i! Int)) (!
   (= (ens%vstd!seq.axiom_seq_push_index_same. A&. A& s! a! i!) (= (vstd!seq.Seq.index.?
      A&. A& (vstd!seq.Seq.push.? A&. A& s! a!) (I i!)
     ) a!
   ))
   :pattern ((ens%vstd!seq.axiom_seq_push_index_same. A&. A& s! a! i!))
   :qid internal_ens__vstd!seq.axiom_seq_push_index_same._definition
)))

;; Broadcast vstd::seq::axiom_seq_push_index_same
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type a! A&)
     (has_type i! INT)
    )
    (=>
     (= (%I i!) (vstd!seq.Seq.len.? A&. A& s!))
     (= (vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.push.? A&. A& s! a!) i!) a!)
   ))
   :pattern ((vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.push.? A&. A& s! a!) i!))
   :qid user_vstd__seq__axiom_seq_push_index_same_19
)))

;; Function-Specs vstd::seq::axiom_seq_push_index_different
(declare-fun req%vstd!seq.axiom_seq_push_index_different. (Dcr Type Poly Poly Int)
 Bool
)
(declare-const %%global_location_label%%16 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly) (i! Int)) (!
   (= (req%vstd!seq.axiom_seq_push_index_different. A&. A& s! a! i!) (=>
     %%global_location_label%%16
     (and
      (<= 0 i!)
      (< i! (vstd!seq.Seq.len.? A&. A& s!))
   )))
   :pattern ((req%vstd!seq.axiom_seq_push_index_different. A&. A& s! a! i!))
   :qid internal_req__vstd!seq.axiom_seq_push_index_different._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_push_index_different. (Dcr Type Poly Poly Int)
 Bool
)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly) (i! Int)) (!
   (= (ens%vstd!seq.axiom_seq_push_index_different. A&. A& s! a! i!) (= (vstd!seq.Seq.index.?
      A&. A& (vstd!seq.Seq.push.? A&. A& s! a!) (I i!)
     ) (vstd!seq.Seq.index.? A&. A& s! (I i!))
   ))
   :pattern ((ens%vstd!seq.axiom_seq_push_index_different. A&. A& s! a! i!))
   :qid internal_ens__vstd!seq.axiom_seq_push_index_different._definition
)))

;; Broadcast vstd::seq::axiom_seq_push_index_different
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type a! A&)
     (has_type i! INT)
    )
    (=>
     (and
      (<= 0 (%I i!))
      (< (%I i!) (vstd!seq.Seq.len.? A&. A& s!))
     )
     (= (vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.push.? A&. A& s! a!) i!) (vstd!seq.Seq.index.?
       A&. A& s! i!
   ))))
   :pattern ((vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.push.? A&. A& s! a!) i!))
   :qid user_vstd__seq__axiom_seq_push_index_different_20
)))

;; Function-Specs vstd::seq::axiom_seq_update_len
(declare-fun req%vstd!seq.axiom_seq_update_len. (Dcr Type Poly Int Poly) Bool)
(declare-const %%global_location_label%%17 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Int) (a! Poly)) (!
   (= (req%vstd!seq.axiom_seq_update_len. A&. A& s! i! a!) (=>
     %%global_location_label%%17
     (and
      (<= 0 i!)
      (< i! (vstd!seq.Seq.len.? A&. A& s!))
   )))
   :pattern ((req%vstd!seq.axiom_seq_update_len. A&. A& s! i! a!))
   :qid internal_req__vstd!seq.axiom_seq_update_len._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_update_len. (Dcr Type Poly Int Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Int) (a! Poly)) (!
   (= (ens%vstd!seq.axiom_seq_update_len. A&. A& s! i! a!) (= (vstd!seq.Seq.len.? A&. A&
      (vstd!seq.Seq.update.? A&. A& s! (I i!) a!)
     ) (vstd!seq.Seq.len.? A&. A& s!)
   ))
   :pattern ((ens%vstd!seq.axiom_seq_update_len. A&. A& s! i! a!))
   :qid internal_ens__vstd!seq.axiom_seq_update_len._definition
)))

;; Broadcast vstd::seq::axiom_seq_update_len
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i! INT)
     (has_type a! A&)
    )
    (=>
     (and
      (<= 0 (%I i!))
      (< (%I i!) (vstd!seq.Seq.len.? A&. A& s!))
     )
     (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.update.? A&. A& s! i! a!)) (vstd!seq.Seq.len.?
       A&. A& s!
   ))))
   :pattern ((vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.update.? A&. A& s! i! a!)))
   :qid user_vstd__seq__axiom_seq_update_len_21
)))

;; Function-Specs vstd::seq::axiom_seq_update_same
(declare-fun req%vstd!seq.axiom_seq_update_same. (Dcr Type Poly Int Poly) Bool)
(declare-const %%global_location_label%%18 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Int) (a! Poly)) (!
   (= (req%vstd!seq.axiom_seq_update_same. A&. A& s! i! a!) (=>
     %%global_location_label%%18
     (and
      (<= 0 i!)
      (< i! (vstd!seq.Seq.len.? A&. A& s!))
   )))
   :pattern ((req%vstd!seq.axiom_seq_update_same. A&. A& s! i! a!))
   :qid internal_req__vstd!seq.axiom_seq_update_same._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_update_same. (Dcr Type Poly Int Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Int) (a! Poly)) (!
   (= (ens%vstd!seq.axiom_seq_update_same. A&. A& s! i! a!) (= (vstd!seq.Seq.index.? A&.
      A& (vstd!seq.Seq.update.? A&. A& s! (I i!) a!) (I i!)
     ) a!
   ))
   :pattern ((ens%vstd!seq.axiom_seq_update_same. A&. A& s! i! a!))
   :qid internal_ens__vstd!seq.axiom_seq_update_same._definition
)))

;; Broadcast vstd::seq::axiom_seq_update_same
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i! INT)
     (has_type a! A&)
    )
    (=>
     (and
      (<= 0 (%I i!))
      (< (%I i!) (vstd!seq.Seq.len.? A&. A& s!))
     )
     (= (vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.update.? A&. A& s! i! a!) i!) a!)
   ))
   :pattern ((vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.update.? A&. A& s! i! a!) i!))
   :qid user_vstd__seq__axiom_seq_update_same_22
)))

;; Function-Specs vstd::seq::axiom_seq_update_different
(declare-fun req%vstd!seq.axiom_seq_update_different. (Dcr Type Poly Int Int Poly)
 Bool
)
(declare-const %%global_location_label%%19 Bool)
(declare-const %%global_location_label%%20 Bool)
(declare-const %%global_location_label%%21 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i1! Int) (i2! Int) (a! Poly)) (!
   (= (req%vstd!seq.axiom_seq_update_different. A&. A& s! i1! i2! a!) (and
     (=>
      %%global_location_label%%19
      (and
       (<= 0 i1!)
       (< i1! (vstd!seq.Seq.len.? A&. A& s!))
     ))
     (=>
      %%global_location_label%%20
      (and
       (<= 0 i2!)
       (< i2! (vstd!seq.Seq.len.? A&. A& s!))
     ))
     (=>
      %%global_location_label%%21
      (not (= i1! i2!))
   )))
   :pattern ((req%vstd!seq.axiom_seq_update_different. A&. A& s! i1! i2! a!))
   :qid internal_req__vstd!seq.axiom_seq_update_different._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_update_different. (Dcr Type Poly Int Int Poly)
 Bool
)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i1! Int) (i2! Int) (a! Poly)) (!
   (= (ens%vstd!seq.axiom_seq_update_different. A&. A& s! i1! i2! a!) (= (vstd!seq.Seq.index.?
      A&. A& (vstd!seq.Seq.update.? A&. A& s! (I i2!) a!) (I i1!)
     ) (vstd!seq.Seq.index.? A&. A& s! (I i1!))
   ))
   :pattern ((ens%vstd!seq.axiom_seq_update_different. A&. A& s! i1! i2! a!))
   :qid internal_ens__vstd!seq.axiom_seq_update_different._definition
)))

;; Broadcast vstd::seq::axiom_seq_update_different
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (i1! Poly) (i2! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i1! INT)
     (has_type i2! INT)
     (has_type a! A&)
    )
    (=>
     (and
      (and
       (and
        (<= 0 (%I i1!))
        (< (%I i1!) (vstd!seq.Seq.len.? A&. A& s!))
       )
       (and
        (<= 0 (%I i2!))
        (< (%I i2!) (vstd!seq.Seq.len.? A&. A& s!))
      ))
      (not (= i1! i2!))
     )
     (= (vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.update.? A&. A& s! i2! a!) i1!) (vstd!seq.Seq.index.?
       A&. A& s! i1!
   ))))
   :pattern ((vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.update.? A&. A& s! i2! a!) i1!))
   :qid user_vstd__seq__axiom_seq_update_different_23
)))

;; Function-Specs vstd::seq::axiom_seq_ext_equal
(declare-fun ens%vstd!seq.axiom_seq_ext_equal. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (ens%vstd!seq.axiom_seq_ext_equal. A&. A& s1! s2!) (= (ext_eq false (TYPE%vstd!seq.Seq.
       A&. A&
      ) s1! s2!
     ) (and
      (= (vstd!seq.Seq.len.? A&. A& s1!) (vstd!seq.Seq.len.? A&. A& s2!))
      (forall ((i$ Poly)) (!
        (=>
         (has_type i$ INT)
         (=>
          (and
           (<= 0 (%I i$))
           (< (%I i$) (vstd!seq.Seq.len.? A&. A& s1!))
          )
          (= (vstd!seq.Seq.index.? A&. A& s1! i$) (vstd!seq.Seq.index.? A&. A& s2! i$))
        ))
        :pattern ((vstd!seq.Seq.index.? A&. A& s1! i$))
        :pattern ((vstd!seq.Seq.index.? A&. A& s2! i$))
        :qid user_vstd__seq__axiom_seq_ext_equal_24
   )))))
   :pattern ((ens%vstd!seq.axiom_seq_ext_equal. A&. A& s1! s2!))
   :qid internal_ens__vstd!seq.axiom_seq_ext_equal._definition
)))

;; Broadcast vstd::seq::axiom_seq_ext_equal
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type s2! (TYPE%vstd!seq.Seq. A&. A&))
    )
    (= (ext_eq false (TYPE%vstd!seq.Seq. A&. A&) s1! s2!) (and
      (= (vstd!seq.Seq.len.? A&. A& s1!) (vstd!seq.Seq.len.? A&. A& s2!))
      (forall ((i$ Poly)) (!
        (=>
         (has_type i$ INT)
         (=>
          (and
           (<= 0 (%I i$))
           (< (%I i$) (vstd!seq.Seq.len.? A&. A& s1!))
          )
          (= (vstd!seq.Seq.index.? A&. A& s1! i$) (vstd!seq.Seq.index.? A&. A& s2! i$))
        ))
        :pattern ((vstd!seq.Seq.index.? A&. A& s1! i$))
        :pattern ((vstd!seq.Seq.index.? A&. A& s2! i$))
        :qid user_vstd__seq__axiom_seq_ext_equal_25
   )))))
   :pattern ((ext_eq false (TYPE%vstd!seq.Seq. A&. A&) s1! s2!))
   :qid user_vstd__seq__axiom_seq_ext_equal_26
)))

;; Function-Specs vstd::seq::axiom_seq_ext_equal_deep
(declare-fun ens%vstd!seq.axiom_seq_ext_equal_deep. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (ens%vstd!seq.axiom_seq_ext_equal_deep. A&. A& s1! s2!) (= (ext_eq true (TYPE%vstd!seq.Seq.
       A&. A&
      ) s1! s2!
     ) (and
      (= (vstd!seq.Seq.len.? A&. A& s1!) (vstd!seq.Seq.len.? A&. A& s2!))
      (forall ((i$ Poly)) (!
        (=>
         (has_type i$ INT)
         (=>
          (and
           (<= 0 (%I i$))
           (< (%I i$) (vstd!seq.Seq.len.? A&. A& s1!))
          )
          (ext_eq true A& (vstd!seq.Seq.index.? A&. A& s1! i$) (vstd!seq.Seq.index.? A&. A& s2!
            i$
        ))))
        :pattern ((vstd!seq.Seq.index.? A&. A& s1! i$))
        :pattern ((vstd!seq.Seq.index.? A&. A& s2! i$))
        :qid user_vstd__seq__axiom_seq_ext_equal_deep_27
   )))))
   :pattern ((ens%vstd!seq.axiom_seq_ext_equal_deep. A&. A& s1! s2!))
   :qid internal_ens__vstd!seq.axiom_seq_ext_equal_deep._definition
)))

;; Broadcast vstd::seq::axiom_seq_ext_equal_deep
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type s2! (TYPE%vstd!seq.Seq. A&. A&))
    )
    (= (ext_eq true (TYPE%vstd!seq.Seq. A&. A&) s1! s2!) (and
      (= (vstd!seq.Seq.len.? A&. A& s1!) (vstd!seq.Seq.len.? A&. A& s2!))
      (forall ((i$ Poly)) (!
        (=>
         (has_type i$ INT)
         (=>
          (and
           (<= 0 (%I i$))
           (< (%I i$) (vstd!seq.Seq.len.? A&. A& s1!))
          )
          (ext_eq true A& (vstd!seq.Seq.index.? A&. A& s1! i$) (vstd!seq.Seq.index.? A&. A& s2!
            i$
        ))))
        :pattern ((vstd!seq.Seq.index.? A&. A& s1! i$))
        :pattern ((vstd!seq.Seq.index.? A&. A& s2! i$))
        :qid user_vstd__seq__axiom_seq_ext_equal_deep_28
   )))))
   :pattern ((ext_eq true (TYPE%vstd!seq.Seq. A&. A&) s1! s2!))
   :qid user_vstd__seq__axiom_seq_ext_equal_deep_29
)))

;; Function-Specs vstd::seq::axiom_seq_subrange_len
(declare-fun req%vstd!seq.axiom_seq_subrange_len. (Dcr Type Poly Int Int) Bool)
(declare-const %%global_location_label%%22 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (j! Int) (k! Int)) (!
   (= (req%vstd!seq.axiom_seq_subrange_len. A&. A& s! j! k!) (=>
     %%global_location_label%%22
     (and
      (and
       (<= 0 j!)
       (<= j! k!)
      )
      (<= k! (vstd!seq.Seq.len.? A&. A& s!))
   )))
   :pattern ((req%vstd!seq.axiom_seq_subrange_len. A&. A& s! j! k!))
   :qid internal_req__vstd!seq.axiom_seq_subrange_len._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_subrange_len. (Dcr Type Poly Int Int) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (j! Int) (k! Int)) (!
   (= (ens%vstd!seq.axiom_seq_subrange_len. A&. A& s! j! k!) (= (vstd!seq.Seq.len.? A&.
      A& (vstd!seq.Seq.subrange.? A&. A& s! (I j!) (I k!))
     ) (Sub k! j!)
   ))
   :pattern ((ens%vstd!seq.axiom_seq_subrange_len. A&. A& s! j! k!))
   :qid internal_ens__vstd!seq.axiom_seq_subrange_len._definition
)))

;; Broadcast vstd::seq::axiom_seq_subrange_len
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (j! Poly) (k! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type j! INT)
     (has_type k! INT)
    )
    (=>
     (and
      (and
       (<= 0 (%I j!))
       (<= (%I j!) (%I k!))
      )
      (<= (%I k!) (vstd!seq.Seq.len.? A&. A& s!))
     )
     (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.subrange.? A&. A& s! j! k!)) (Sub (%I k!)
       (%I j!)
   ))))
   :pattern ((vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.subrange.? A&. A& s! j! k!)))
   :qid user_vstd__seq__axiom_seq_subrange_len_30
)))

;; Function-Specs vstd::seq::axiom_seq_subrange_index
(declare-fun req%vstd!seq.axiom_seq_subrange_index. (Dcr Type Poly Int Int Int) Bool)
(declare-const %%global_location_label%%23 Bool)
(declare-const %%global_location_label%%24 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (j! Int) (k! Int) (i! Int)) (!
   (= (req%vstd!seq.axiom_seq_subrange_index. A&. A& s! j! k! i!) (and
     (=>
      %%global_location_label%%23
      (and
       (and
        (<= 0 j!)
        (<= j! k!)
       )
       (<= k! (vstd!seq.Seq.len.? A&. A& s!))
     ))
     (=>
      %%global_location_label%%24
      (and
       (<= 0 i!)
       (< i! (Sub k! j!))
   ))))
   :pattern ((req%vstd!seq.axiom_seq_subrange_index. A&. A& s! j! k! i!))
   :qid internal_req__vstd!seq.axiom_seq_subrange_index._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_subrange_index. (Dcr Type Poly Int Int Int) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (j! Int) (k! Int) (i! Int)) (!
   (= (ens%vstd!seq.axiom_seq_subrange_index. A&. A& s! j! k! i!) (= (vstd!seq.Seq.index.?
      A&. A& (vstd!seq.Seq.subrange.? A&. A& s! (I j!) (I k!)) (I i!)
     ) (vstd!seq.Seq.index.? A&. A& s! (I (Add i! j!)))
   ))
   :pattern ((ens%vstd!seq.axiom_seq_subrange_index. A&. A& s! j! k! i!))
   :qid internal_ens__vstd!seq.axiom_seq_subrange_index._definition
)))

;; Broadcast vstd::seq::axiom_seq_subrange_index
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (j! Poly) (k! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type j! INT)
     (has_type k! INT)
     (has_type i! INT)
    )
    (=>
     (and
      (and
       (and
        (<= 0 (%I j!))
        (<= (%I j!) (%I k!))
       )
       (<= (%I k!) (vstd!seq.Seq.len.? A&. A& s!))
      )
      (and
       (<= 0 (%I i!))
       (< (%I i!) (Sub (%I k!) (%I j!)))
     ))
     (= (vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.subrange.? A&. A& s! j! k!) i!) (vstd!seq.Seq.index.?
       A&. A& s! (I (Add (%I i!) (%I j!)))
   ))))
   :pattern ((vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.subrange.? A&. A& s! j! k!) i!))
   :qid user_vstd__seq__axiom_seq_subrange_index_31
)))

;; Function-Specs vstd::seq::axiom_seq_add_len
(declare-fun ens%vstd!seq.axiom_seq_add_len. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (ens%vstd!seq.axiom_seq_add_len. A&. A& s1! s2!) (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.add.?
       A&. A& s1! s2!
      )
     ) (nClip (Add (vstd!seq.Seq.len.? A&. A& s1!) (vstd!seq.Seq.len.? A&. A& s2!)))
   ))
   :pattern ((ens%vstd!seq.axiom_seq_add_len. A&. A& s1! s2!))
   :qid internal_ens__vstd!seq.axiom_seq_add_len._definition
)))

;; Broadcast vstd::seq::axiom_seq_add_len
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type s2! (TYPE%vstd!seq.Seq. A&. A&))
    )
    (= (vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.add.? A&. A& s1! s2!)) (nClip (Add (vstd!seq.Seq.len.?
        A&. A& s1!
       ) (vstd!seq.Seq.len.? A&. A& s2!)
   ))))
   :pattern ((vstd!seq.Seq.len.? A&. A& (vstd!seq.Seq.add.? A&. A& s1! s2!)))
   :qid user_vstd__seq__axiom_seq_add_len_32
)))

;; Function-Specs vstd::seq::axiom_seq_add_index1
(declare-fun req%vstd!seq.axiom_seq_add_index1. (Dcr Type Poly Poly Int) Bool)
(declare-const %%global_location_label%%25 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (i! Int)) (!
   (= (req%vstd!seq.axiom_seq_add_index1. A&. A& s1! s2! i!) (=>
     %%global_location_label%%25
     (and
      (<= 0 i!)
      (< i! (vstd!seq.Seq.len.? A&. A& s1!))
   )))
   :pattern ((req%vstd!seq.axiom_seq_add_index1. A&. A& s1! s2! i!))
   :qid internal_req__vstd!seq.axiom_seq_add_index1._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_add_index1. (Dcr Type Poly Poly Int) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (i! Int)) (!
   (= (ens%vstd!seq.axiom_seq_add_index1. A&. A& s1! s2! i!) (= (vstd!seq.Seq.index.? A&.
      A& (vstd!seq.Seq.add.? A&. A& s1! s2!) (I i!)
     ) (vstd!seq.Seq.index.? A&. A& s1! (I i!))
   ))
   :pattern ((ens%vstd!seq.axiom_seq_add_index1. A&. A& s1! s2! i!))
   :qid internal_ens__vstd!seq.axiom_seq_add_index1._definition
)))

;; Broadcast vstd::seq::axiom_seq_add_index1
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type s2! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i! INT)
    )
    (=>
     (and
      (<= 0 (%I i!))
      (< (%I i!) (vstd!seq.Seq.len.? A&. A& s1!))
     )
     (= (vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.add.? A&. A& s1! s2!) i!) (vstd!seq.Seq.index.?
       A&. A& s1! i!
   ))))
   :pattern ((vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.add.? A&. A& s1! s2!) i!))
   :qid user_vstd__seq__axiom_seq_add_index1_33
)))

;; Function-Specs vstd::seq::axiom_seq_add_index2
(declare-fun req%vstd!seq.axiom_seq_add_index2. (Dcr Type Poly Poly Int) Bool)
(declare-const %%global_location_label%%26 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (i! Int)) (!
   (= (req%vstd!seq.axiom_seq_add_index2. A&. A& s1! s2! i!) (=>
     %%global_location_label%%26
     (and
      (<= (vstd!seq.Seq.len.? A&. A& s1!) i!)
      (< i! (nClip (Add (vstd!seq.Seq.len.? A&. A& s1!) (vstd!seq.Seq.len.? A&. A& s2!))))
   )))
   :pattern ((req%vstd!seq.axiom_seq_add_index2. A&. A& s1! s2! i!))
   :qid internal_req__vstd!seq.axiom_seq_add_index2._definition
)))
(declare-fun ens%vstd!seq.axiom_seq_add_index2. (Dcr Type Poly Poly Int) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (i! Int)) (!
   (= (ens%vstd!seq.axiom_seq_add_index2. A&. A& s1! s2! i!) (= (vstd!seq.Seq.index.? A&.
      A& (vstd!seq.Seq.add.? A&. A& s1! s2!) (I i!)
     ) (vstd!seq.Seq.index.? A&. A& s2! (I (Sub i! (vstd!seq.Seq.len.? A&. A& s1!))))
   ))
   :pattern ((ens%vstd!seq.axiom_seq_add_index2. A&. A& s1! s2! i!))
   :qid internal_ens__vstd!seq.axiom_seq_add_index2._definition
)))

;; Broadcast vstd::seq::axiom_seq_add_index2
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (i! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type s2! (TYPE%vstd!seq.Seq. A&. A&))
     (has_type i! INT)
    )
    (=>
     (and
      (<= (vstd!seq.Seq.len.? A&. A& s1!) (%I i!))
      (< (%I i!) (nClip (Add (vstd!seq.Seq.len.? A&. A& s1!) (vstd!seq.Seq.len.? A&. A& s2!))))
     )
     (= (vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.add.? A&. A& s1! s2!) i!) (vstd!seq.Seq.index.?
       A&. A& s2! (I (Sub (%I i!) (vstd!seq.Seq.len.? A&. A& s1!)))
   ))))
   :pattern ((vstd!seq.Seq.index.? A&. A& (vstd!seq.Seq.add.? A&. A& s1! s2!) i!))
   :qid user_vstd__seq__axiom_seq_add_index2_34
)))

;; Function-Axioms vstd::set::impl&%0::union
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
    )
    (has_type (vstd!set.impl&%0.union.? A&. A& self! s2!) (TYPE%vstd!set.Set. A&. A&))
   )
   :pattern ((vstd!set.impl&%0.union.? A&. A& self! s2!))
   :qid internal_vstd!set.impl&__0.union.?_pre_post_definition
)))

;; Function-Axioms vstd::set::impl&%0::intersect
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
    )
    (has_type (vstd!set.impl&%0.intersect.? A&. A& self! s2!) (TYPE%vstd!set.Set. A&. A&))
   )
   :pattern ((vstd!set.impl&%0.intersect.? A&. A& self! s2!))
   :qid internal_vstd!set.impl&__0.intersect.?_pre_post_definition
)))

;; Function-Axioms vstd::set::impl&%0::difference
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type self! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
    )
    (has_type (vstd!set.impl&%0.difference.? A&. A& self! s2!) (TYPE%vstd!set.Set. A&.
      A&
   )))
   :pattern ((vstd!set.impl&%0.difference.? A&. A& self! s2!))
   :qid internal_vstd!set.impl&__0.difference.?_pre_post_definition
)))

;; Function-Axioms vstd::set::impl&%0::complement
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly)) (!
   (=>
    (has_type self! (TYPE%vstd!set.Set. A&. A&))
    (has_type (vstd!set.impl&%0.complement.? A&. A& self!) (TYPE%vstd!set.Set. A&. A&))
   )
   :pattern ((vstd!set.impl&%0.complement.? A&. A& self!))
   :qid internal_vstd!set.impl&__0.complement.?_pre_post_definition
)))

;; Function-Axioms vstd::set::impl&%0::len
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly)) (!
   (=>
    (has_type self! (TYPE%vstd!set.Set. A&. A&))
    (<= 0 (vstd!set.impl&%0.len.? A&. A& self!))
   )
   :pattern ((vstd!set.impl&%0.len.? A&. A& self!))
   :qid internal_vstd!set.impl&__0.len.?_pre_post_definition
)))

;; Function-Specs vstd::set::axiom_set_empty
(declare-fun ens%vstd!set.axiom_set_empty. (Dcr Type Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_empty. A&. A& a!) (not (vstd!set.impl&%0.contains.? A&. A&
      (vstd!set.impl&%0.empty.? A&. A&) a!
   )))
   :pattern ((ens%vstd!set.axiom_set_empty. A&. A& a!))
   :qid internal_ens__vstd!set.axiom_set_empty._definition
)))

;; Broadcast vstd::set::axiom_set_empty
(assert
 (forall ((A&. Dcr) (A& Type) (a! Poly)) (!
   (=>
    (has_type a! A&)
    (not (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.empty.? A&. A&) a!))
   )
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.empty.? A&. A&) a!))
   :qid user_vstd__set__axiom_set_empty_35
)))

;; Function-Specs vstd::set::axiom_set_new
(declare-fun ens%vstd!set.axiom_set_new. (Dcr Type %%Function%% Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (f! %%Function%%) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_new. A&. A& f! a!) (= (vstd!set.impl&%0.contains.? A&. A&
      (vstd!set.impl&%0.new.? A&. A& $ (TYPE%fun%1. A&. A& $ BOOL) (Poly%fun%1. f!)) a!
     ) (%B (%%apply%%0 f! a!))
   ))
   :pattern ((ens%vstd!set.axiom_set_new. A&. A& f! a!))
   :qid internal_ens__vstd!set.axiom_set_new._definition
)))

;; Broadcast vstd::set::axiom_set_new
(assert
 (forall ((A&. Dcr) (A& Type) (f! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type f! (TYPE%fun%1. A&. A& $ BOOL))
     (has_type a! A&)
    )
    (= (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.new.? A&. A& $ (TYPE%fun%1.
        A&. A& $ BOOL
       ) f!
      ) a!
     ) (%B (%%apply%%0 (%Poly%fun%1. f!) a!))
   ))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.new.? A&. A& $ (TYPE%fun%1.
       A&. A& $ BOOL
      ) f!
     ) a!
   ))
   :qid user_vstd__set__axiom_set_new_36
)))

;; Function-Specs vstd::set::axiom_set_insert_same
(declare-fun ens%vstd!set.axiom_set_insert_same. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_insert_same. A&. A& s! a!) (vstd!set.impl&%0.contains.?
     A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a!) a!
   ))
   :pattern ((ens%vstd!set.axiom_set_insert_same. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_insert_same._definition
)))

;; Broadcast vstd::set::axiom_set_insert_same
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a!) a!)
   )
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a!)
     a!
   ))
   :qid user_vstd__set__axiom_set_insert_same_37
)))

;; Function-Specs vstd::set::axiom_set_insert_different
(declare-fun req%vstd!set.axiom_set_insert_different. (Dcr Type Poly Poly Poly) Bool)
(declare-const %%global_location_label%%27 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a1! Poly) (a2! Poly)) (!
   (= (req%vstd!set.axiom_set_insert_different. A&. A& s! a1! a2!) (=>
     %%global_location_label%%27
     (not (= a1! a2!))
   ))
   :pattern ((req%vstd!set.axiom_set_insert_different. A&. A& s! a1! a2!))
   :qid internal_req__vstd!set.axiom_set_insert_different._definition
)))
(declare-fun ens%vstd!set.axiom_set_insert_different. (Dcr Type Poly Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a1! Poly) (a2! Poly)) (!
   (= (ens%vstd!set.axiom_set_insert_different. A&. A& s! a1! a2!) (= (vstd!set.impl&%0.contains.?
      A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a2!) a1!
     ) (vstd!set.impl&%0.contains.? A&. A& s! a1!)
   ))
   :pattern ((ens%vstd!set.axiom_set_insert_different. A&. A& s! a1! a2!))
   :qid internal_ens__vstd!set.axiom_set_insert_different._definition
)))

;; Broadcast vstd::set::axiom_set_insert_different
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a1! Poly) (a2! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a1! A&)
     (has_type a2! A&)
    )
    (=>
     (not (= a1! a2!))
     (= (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a2!) a1!)
      (vstd!set.impl&%0.contains.? A&. A& s! a1!)
   )))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a2!)
     a1!
   ))
   :qid user_vstd__set__axiom_set_insert_different_38
)))

;; Function-Specs vstd::set::axiom_set_remove_same
(declare-fun ens%vstd!set.axiom_set_remove_same. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_remove_same. A&. A& s! a!) (not (vstd!set.impl&%0.contains.?
      A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!) a!
   )))
   :pattern ((ens%vstd!set.axiom_set_remove_same. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_remove_same._definition
)))

;; Broadcast vstd::set::axiom_set_remove_same
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (not (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!) a!))
   )
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!)
     a!
   ))
   :qid user_vstd__set__axiom_set_remove_same_39
)))

;; Function-Specs vstd::set::axiom_set_remove_insert
(declare-fun req%vstd!set.axiom_set_remove_insert. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%28 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (req%vstd!set.axiom_set_remove_insert. A&. A& s! a!) (=>
     %%global_location_label%%28
     (vstd!set.impl&%0.contains.? A&. A& s! a!)
   ))
   :pattern ((req%vstd!set.axiom_set_remove_insert. A&. A& s! a!))
   :qid internal_req__vstd!set.axiom_set_remove_insert._definition
)))
(declare-fun ens%vstd!set.axiom_set_remove_insert. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_remove_insert. A&. A& s! a!) (= (vstd!set.impl&%0.insert.?
      A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!) a!
     ) s!
   ))
   :pattern ((ens%vstd!set.axiom_set_remove_insert. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_remove_insert._definition
)))

;; Broadcast vstd::set::axiom_set_remove_insert
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (=>
     (vstd!set.impl&%0.contains.? A&. A& s! a!)
     (= (vstd!set.impl&%0.insert.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!) a!)
      s!
   )))
   :pattern ((vstd!set.impl&%0.remove.? A&. A& s! a!))
   :qid user_vstd__set__axiom_set_remove_insert_40
)))

;; Function-Specs vstd::set::axiom_set_remove_different
(declare-fun req%vstd!set.axiom_set_remove_different. (Dcr Type Poly Poly Poly) Bool)
(declare-const %%global_location_label%%29 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a1! Poly) (a2! Poly)) (!
   (= (req%vstd!set.axiom_set_remove_different. A&. A& s! a1! a2!) (=>
     %%global_location_label%%29
     (not (= a1! a2!))
   ))
   :pattern ((req%vstd!set.axiom_set_remove_different. A&. A& s! a1! a2!))
   :qid internal_req__vstd!set.axiom_set_remove_different._definition
)))
(declare-fun ens%vstd!set.axiom_set_remove_different. (Dcr Type Poly Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a1! Poly) (a2! Poly)) (!
   (= (ens%vstd!set.axiom_set_remove_different. A&. A& s! a1! a2!) (= (vstd!set.impl&%0.contains.?
      A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a2!) a1!
     ) (vstd!set.impl&%0.contains.? A&. A& s! a1!)
   ))
   :pattern ((ens%vstd!set.axiom_set_remove_different. A&. A& s! a1! a2!))
   :qid internal_ens__vstd!set.axiom_set_remove_different._definition
)))

;; Broadcast vstd::set::axiom_set_remove_different
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a1! Poly) (a2! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a1! A&)
     (has_type a2! A&)
    )
    (=>
     (not (= a1! a2!))
     (= (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a2!) a1!)
      (vstd!set.impl&%0.contains.? A&. A& s! a1!)
   )))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a2!)
     a1!
   ))
   :qid user_vstd__set__axiom_set_remove_different_41
)))

;; Function-Specs vstd::set::axiom_set_union
(declare-fun ens%vstd!set.axiom_set_union. (Dcr Type Poly Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_union. A&. A& s1! s2! a!) (= (vstd!set.impl&%0.contains.?
      A&. A& (vstd!set.impl&%0.union.? A&. A& s1! s2!) a!
     ) (or
      (vstd!set.impl&%0.contains.? A&. A& s1! a!)
      (vstd!set.impl&%0.contains.? A&. A& s2! a!)
   )))
   :pattern ((ens%vstd!set.axiom_set_union. A&. A& s1! s2! a!))
   :qid internal_ens__vstd!set.axiom_set_union._definition
)))

;; Broadcast vstd::set::axiom_set_union
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (= (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.union.? A&. A& s1! s2!) a!)
     (or
      (vstd!set.impl&%0.contains.? A&. A& s1! a!)
      (vstd!set.impl&%0.contains.? A&. A& s2! a!)
   )))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.union.? A&. A& s1! s2!)
     a!
   ))
   :qid user_vstd__set__axiom_set_union_42
)))

;; Function-Specs vstd::set::axiom_set_intersect
(declare-fun ens%vstd!set.axiom_set_intersect. (Dcr Type Poly Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_intersect. A&. A& s1! s2! a!) (= (vstd!set.impl&%0.contains.?
      A&. A& (vstd!set.impl&%0.intersect.? A&. A& s1! s2!) a!
     ) (and
      (vstd!set.impl&%0.contains.? A&. A& s1! a!)
      (vstd!set.impl&%0.contains.? A&. A& s2! a!)
   )))
   :pattern ((ens%vstd!set.axiom_set_intersect. A&. A& s1! s2! a!))
   :qid internal_ens__vstd!set.axiom_set_intersect._definition
)))

;; Broadcast vstd::set::axiom_set_intersect
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (= (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.intersect.? A&. A& s1! s2!)
      a!
     ) (and
      (vstd!set.impl&%0.contains.? A&. A& s1! a!)
      (vstd!set.impl&%0.contains.? A&. A& s2! a!)
   )))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.intersect.? A&. A& s1!
      s2!
     ) a!
   ))
   :qid user_vstd__set__axiom_set_intersect_43
)))

;; Function-Specs vstd::set::axiom_set_difference
(declare-fun ens%vstd!set.axiom_set_difference. (Dcr Type Poly Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_difference. A&. A& s1! s2! a!) (= (vstd!set.impl&%0.contains.?
      A&. A& (vstd!set.impl&%0.difference.? A&. A& s1! s2!) a!
     ) (and
      (vstd!set.impl&%0.contains.? A&. A& s1! a!)
      (not (vstd!set.impl&%0.contains.? A&. A& s2! a!))
   )))
   :pattern ((ens%vstd!set.axiom_set_difference. A&. A& s1! s2! a!))
   :qid internal_ens__vstd!set.axiom_set_difference._definition
)))

;; Broadcast vstd::set::axiom_set_difference
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (= (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.difference.? A&. A& s1! s2!)
      a!
     ) (and
      (vstd!set.impl&%0.contains.? A&. A& s1! a!)
      (not (vstd!set.impl&%0.contains.? A&. A& s2! a!))
   )))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.difference.? A&. A&
      s1! s2!
     ) a!
   ))
   :qid user_vstd__set__axiom_set_difference_44
)))

;; Function-Specs vstd::set::axiom_set_complement
(declare-fun ens%vstd!set.axiom_set_complement. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_complement. A&. A& s! a!) (= (vstd!set.impl&%0.contains.?
      A&. A& (vstd!set.impl&%0.complement.? A&. A& s!) a!
     ) (not (vstd!set.impl&%0.contains.? A&. A& s! a!))
   ))
   :pattern ((ens%vstd!set.axiom_set_complement. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_complement._definition
)))

;; Broadcast vstd::set::axiom_set_complement
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (= (vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.complement.? A&. A& s!) a!)
     (not (vstd!set.impl&%0.contains.? A&. A& s! a!))
   ))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& (vstd!set.impl&%0.complement.? A&. A&
      s!
     ) a!
   ))
   :qid user_vstd__set__axiom_set_complement_45
)))

;; Function-Specs vstd::set::axiom_set_ext_equal
(declare-fun ens%vstd!set.axiom_set_ext_equal. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (ens%vstd!set.axiom_set_ext_equal. A&. A& s1! s2!) (= (ext_eq false (TYPE%vstd!set.Set.
       A&. A&
      ) s1! s2!
     ) (forall ((a$ Poly)) (!
       (=>
        (has_type a$ A&)
        (= (vstd!set.impl&%0.contains.? A&. A& s1! a$) (vstd!set.impl&%0.contains.? A&. A&
          s2! a$
       )))
       :pattern ((vstd!set.impl&%0.contains.? A&. A& s1! a$))
       :pattern ((vstd!set.impl&%0.contains.? A&. A& s2! a$))
       :qid user_vstd__set__axiom_set_ext_equal_46
   ))))
   :pattern ((ens%vstd!set.axiom_set_ext_equal. A&. A& s1! s2!))
   :qid internal_ens__vstd!set.axiom_set_ext_equal._definition
)))

;; Broadcast vstd::set::axiom_set_ext_equal
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
    )
    (= (ext_eq false (TYPE%vstd!set.Set. A&. A&) s1! s2!) (forall ((a$ Poly)) (!
       (=>
        (has_type a$ A&)
        (= (vstd!set.impl&%0.contains.? A&. A& s1! a$) (vstd!set.impl&%0.contains.? A&. A&
          s2! a$
       )))
       :pattern ((vstd!set.impl&%0.contains.? A&. A& s1! a$))
       :pattern ((vstd!set.impl&%0.contains.? A&. A& s2! a$))
       :qid user_vstd__set__axiom_set_ext_equal_47
   ))))
   :pattern ((ext_eq false (TYPE%vstd!set.Set. A&. A&) s1! s2!))
   :qid user_vstd__set__axiom_set_ext_equal_48
)))

;; Function-Specs vstd::set::axiom_set_ext_equal_deep
(declare-fun ens%vstd!set.axiom_set_ext_equal_deep. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (ens%vstd!set.axiom_set_ext_equal_deep. A&. A& s1! s2!) (= (ext_eq true (TYPE%vstd!set.Set.
       A&. A&
      ) s1! s2!
     ) (ext_eq false (TYPE%vstd!set.Set. A&. A&) s1! s2!)
   ))
   :pattern ((ens%vstd!set.axiom_set_ext_equal_deep. A&. A& s1! s2!))
   :qid internal_ens__vstd!set.axiom_set_ext_equal_deep._definition
)))

;; Broadcast vstd::set::axiom_set_ext_equal_deep
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
    )
    (= (ext_eq true (TYPE%vstd!set.Set. A&. A&) s1! s2!) (ext_eq false (TYPE%vstd!set.Set.
       A&. A&
      ) s1! s2!
   )))
   :pattern ((ext_eq true (TYPE%vstd!set.Set. A&. A&) s1! s2!))
   :qid user_vstd__set__axiom_set_ext_equal_deep_49
)))

;; Function-Specs vstd::set::axiom_mk_map_domain
(declare-fun ens%vstd!set.axiom_mk_map_domain. (Dcr Type Dcr Type Poly %%Function%%)
 Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (s! Poly) (f! %%Function%%)) (!
   (= (ens%vstd!set.axiom_mk_map_domain. K&. K& V&. V& s! f!) (= (vstd!map.impl&%0.dom.?
      K&. K& V&. V& (vstd!set.impl&%0.mk_map.? K&. K& V&. V& $ (TYPE%fun%1. K&. K& V&. V&)
       s! (Poly%fun%1. f!)
      )
     ) s!
   ))
   :pattern ((ens%vstd!set.axiom_mk_map_domain. K&. K& V&. V& s! f!))
   :qid internal_ens__vstd!set.axiom_mk_map_domain._definition
)))

;; Broadcast vstd::set::axiom_mk_map_domain
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (s! Poly) (f! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. K&. K&))
     (has_type f! (TYPE%fun%1. K&. K& V&. V&))
    )
    (= (vstd!map.impl&%0.dom.? K&. K& V&. V& (vstd!set.impl&%0.mk_map.? K&. K& V&. V& $
       (TYPE%fun%1. K&. K& V&. V&) s! f!
      )
     ) s!
   ))
   :pattern ((vstd!map.impl&%0.dom.? K&. K& V&. V& (vstd!set.impl&%0.mk_map.? K&. K& V&.
      V& $ (TYPE%fun%1. K&. K& V&. V&) s! f!
   )))
   :qid user_vstd__set__axiom_mk_map_domain_50
)))

;; Function-Specs vstd::set::axiom_mk_map_index
(declare-fun req%vstd!set.axiom_mk_map_index. (Dcr Type Dcr Type Poly %%Function%%
  Poly
 ) Bool
)
(declare-const %%global_location_label%%30 Bool)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (s! Poly) (f! %%Function%%) (key! Poly))
  (!
   (= (req%vstd!set.axiom_mk_map_index. K&. K& V&. V& s! f! key!) (=>
     %%global_location_label%%30
     (vstd!set.impl&%0.contains.? K&. K& s! key!)
   ))
   :pattern ((req%vstd!set.axiom_mk_map_index. K&. K& V&. V& s! f! key!))
   :qid internal_req__vstd!set.axiom_mk_map_index._definition
)))
(declare-fun ens%vstd!set.axiom_mk_map_index. (Dcr Type Dcr Type Poly %%Function%%
  Poly
 ) Bool
)
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (s! Poly) (f! %%Function%%) (key! Poly))
  (!
   (= (ens%vstd!set.axiom_mk_map_index. K&. K& V&. V& s! f! key!) (= (vstd!map.impl&%0.index.?
      K&. K& V&. V& (vstd!set.impl&%0.mk_map.? K&. K& V&. V& $ (TYPE%fun%1. K&. K& V&. V&)
       s! (Poly%fun%1. f!)
      ) key!
     ) (%%apply%%0 f! key!)
   ))
   :pattern ((ens%vstd!set.axiom_mk_map_index. K&. K& V&. V& s! f! key!))
   :qid internal_ens__vstd!set.axiom_mk_map_index._definition
)))

;; Broadcast vstd::set::axiom_mk_map_index
(assert
 (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (s! Poly) (f! Poly) (key! Poly))
  (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. K&. K&))
     (has_type f! (TYPE%fun%1. K&. K& V&. V&))
     (has_type key! K&)
    )
    (=>
     (vstd!set.impl&%0.contains.? K&. K& s! key!)
     (= (vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!set.impl&%0.mk_map.? K&. K& V&. V&
        $ (TYPE%fun%1. K&. K& V&. V&) s! f!
       ) key!
      ) (%%apply%%0 (%Poly%fun%1. f!) key!)
   )))
   :pattern ((vstd!map.impl&%0.index.? K&. K& V&. V& (vstd!set.impl&%0.mk_map.? K&. K&
      V&. V& $ (TYPE%fun%1. K&. K& V&. V&) s! f!
     ) key!
   ))
   :qid user_vstd__set__axiom_mk_map_index_51
)))

;; Function-Specs vstd::set::axiom_set_empty_finite
(declare-fun ens%vstd!set.axiom_set_empty_finite. (Dcr Type) Bool)
(assert
 (forall ((A&. Dcr) (A& Type)) (!
   (= (ens%vstd!set.axiom_set_empty_finite. A&. A&) (vstd!set.impl&%0.finite.? A&. A&
     (vstd!set.impl&%0.empty.? A&. A&)
   ))
   :pattern ((ens%vstd!set.axiom_set_empty_finite. A&. A&))
   :qid internal_ens__vstd!set.axiom_set_empty_finite._definition
)))

;; Broadcast vstd::set::axiom_set_empty_finite
(assert
 (forall ((A&. Dcr) (A& Type)) (!
   (vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.empty.? A&. A&))
   :pattern ((vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.empty.? A&. A&)))
   :qid user_vstd__set__axiom_set_empty_finite_52
)))

;; Function-Specs vstd::set::axiom_set_insert_finite
(declare-fun req%vstd!set.axiom_set_insert_finite. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%31 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (req%vstd!set.axiom_set_insert_finite. A&. A& s! a!) (=>
     %%global_location_label%%31
     (vstd!set.impl&%0.finite.? A&. A& s!)
   ))
   :pattern ((req%vstd!set.axiom_set_insert_finite. A&. A& s! a!))
   :qid internal_req__vstd!set.axiom_set_insert_finite._definition
)))
(declare-fun ens%vstd!set.axiom_set_insert_finite. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_insert_finite. A&. A& s! a!) (vstd!set.impl&%0.finite.?
     A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a!)
   ))
   :pattern ((ens%vstd!set.axiom_set_insert_finite. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_insert_finite._definition
)))

;; Broadcast vstd::set::axiom_set_insert_finite
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (=>
     (vstd!set.impl&%0.finite.? A&. A& s!)
     (vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a!))
   ))
   :pattern ((vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a!)))
   :qid user_vstd__set__axiom_set_insert_finite_53
)))

;; Function-Specs vstd::set::axiom_set_remove_finite
(declare-fun req%vstd!set.axiom_set_remove_finite. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%32 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (req%vstd!set.axiom_set_remove_finite. A&. A& s! a!) (=>
     %%global_location_label%%32
     (vstd!set.impl&%0.finite.? A&. A& s!)
   ))
   :pattern ((req%vstd!set.axiom_set_remove_finite. A&. A& s! a!))
   :qid internal_req__vstd!set.axiom_set_remove_finite._definition
)))
(declare-fun ens%vstd!set.axiom_set_remove_finite. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_remove_finite. A&. A& s! a!) (vstd!set.impl&%0.finite.?
     A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!)
   ))
   :pattern ((ens%vstd!set.axiom_set_remove_finite. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_remove_finite._definition
)))

;; Broadcast vstd::set::axiom_set_remove_finite
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (=>
     (vstd!set.impl&%0.finite.? A&. A& s!)
     (vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!))
   ))
   :pattern ((vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!)))
   :qid user_vstd__set__axiom_set_remove_finite_54
)))

;; Function-Specs vstd::set::axiom_set_union_finite
(declare-fun req%vstd!set.axiom_set_union_finite. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%33 Bool)
(declare-const %%global_location_label%%34 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (req%vstd!set.axiom_set_union_finite. A&. A& s1! s2!) (and
     (=>
      %%global_location_label%%33
      (vstd!set.impl&%0.finite.? A&. A& s1!)
     )
     (=>
      %%global_location_label%%34
      (vstd!set.impl&%0.finite.? A&. A& s2!)
   )))
   :pattern ((req%vstd!set.axiom_set_union_finite. A&. A& s1! s2!))
   :qid internal_req__vstd!set.axiom_set_union_finite._definition
)))
(declare-fun ens%vstd!set.axiom_set_union_finite. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (ens%vstd!set.axiom_set_union_finite. A&. A& s1! s2!) (vstd!set.impl&%0.finite.?
     A&. A& (vstd!set.impl&%0.union.? A&. A& s1! s2!)
   ))
   :pattern ((ens%vstd!set.axiom_set_union_finite. A&. A& s1! s2!))
   :qid internal_ens__vstd!set.axiom_set_union_finite._definition
)))

;; Broadcast vstd::set::axiom_set_union_finite
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
    )
    (=>
     (and
      (vstd!set.impl&%0.finite.? A&. A& s1!)
      (vstd!set.impl&%0.finite.? A&. A& s2!)
     )
     (vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.union.? A&. A& s1! s2!))
   ))
   :pattern ((vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.union.? A&. A& s1! s2!)))
   :qid user_vstd__set__axiom_set_union_finite_55
)))

;; Function-Specs vstd::set::axiom_set_intersect_finite
(declare-fun req%vstd!set.axiom_set_intersect_finite. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%35 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (req%vstd!set.axiom_set_intersect_finite. A&. A& s1! s2!) (=>
     %%global_location_label%%35
     (or
      (vstd!set.impl&%0.finite.? A&. A& s1!)
      (vstd!set.impl&%0.finite.? A&. A& s2!)
   )))
   :pattern ((req%vstd!set.axiom_set_intersect_finite. A&. A& s1! s2!))
   :qid internal_req__vstd!set.axiom_set_intersect_finite._definition
)))
(declare-fun ens%vstd!set.axiom_set_intersect_finite. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (ens%vstd!set.axiom_set_intersect_finite. A&. A& s1! s2!) (vstd!set.impl&%0.finite.?
     A&. A& (vstd!set.impl&%0.intersect.? A&. A& s1! s2!)
   ))
   :pattern ((ens%vstd!set.axiom_set_intersect_finite. A&. A& s1! s2!))
   :qid internal_ens__vstd!set.axiom_set_intersect_finite._definition
)))

;; Broadcast vstd::set::axiom_set_intersect_finite
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
    )
    (=>
     (or
      (vstd!set.impl&%0.finite.? A&. A& s1!)
      (vstd!set.impl&%0.finite.? A&. A& s2!)
     )
     (vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.intersect.? A&. A& s1! s2!))
   ))
   :pattern ((vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.intersect.? A&. A& s1!
      s2!
   )))
   :qid user_vstd__set__axiom_set_intersect_finite_56
)))

;; Function-Specs vstd::set::axiom_set_difference_finite
(declare-fun req%vstd!set.axiom_set_difference_finite. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%36 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (req%vstd!set.axiom_set_difference_finite. A&. A& s1! s2!) (=>
     %%global_location_label%%36
     (vstd!set.impl&%0.finite.? A&. A& s1!)
   ))
   :pattern ((req%vstd!set.axiom_set_difference_finite. A&. A& s1! s2!))
   :qid internal_req__vstd!set.axiom_set_difference_finite._definition
)))
(declare-fun ens%vstd!set.axiom_set_difference_finite. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (= (ens%vstd!set.axiom_set_difference_finite. A&. A& s1! s2!) (vstd!set.impl&%0.finite.?
     A&. A& (vstd!set.impl&%0.difference.? A&. A& s1! s2!)
   ))
   :pattern ((ens%vstd!set.axiom_set_difference_finite. A&. A& s1! s2!))
   :qid internal_ens__vstd!set.axiom_set_difference_finite._definition
)))

;; Broadcast vstd::set::axiom_set_difference_finite
(assert
 (forall ((A&. Dcr) (A& Type) (s1! Poly) (s2! Poly)) (!
   (=>
    (and
     (has_type s1! (TYPE%vstd!set.Set. A&. A&))
     (has_type s2! (TYPE%vstd!set.Set. A&. A&))
    )
    (=>
     (vstd!set.impl&%0.finite.? A&. A& s1!)
     (vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.difference.? A&. A& s1! s2!))
   ))
   :pattern ((vstd!set.impl&%0.finite.? A&. A& (vstd!set.impl&%0.difference.? A&. A& s1!
      s2!
   )))
   :qid user_vstd__set__axiom_set_difference_finite_57
)))

;; Function-Axioms vstd::set::impl&%0::choose
(assert
 (fuel_bool_default fuel%vstd!set.impl&%0.choose.)
)
(declare-fun %%choose%%0 (Type Dcr Type Poly Dcr Type Poly) Poly)
(assert
 (forall ((%%hole%%0 Type) (%%hole%%1 Dcr) (%%hole%%2 Type) (%%hole%%3 Poly) (%%hole%%4
    Dcr
   ) (%%hole%%5 Type) (%%hole%%6 Poly)
  ) (!
   (=>
    (exists ((a$ Poly)) (!
      (and
       (has_type a$ %%hole%%0)
       (vstd!set.impl&%0.contains.? %%hole%%1 %%hole%%2 %%hole%%3 a$)
      )
      :pattern ((vstd!set.impl&%0.contains.? %%hole%%4 %%hole%%5 %%hole%%6 a$))
      :qid user_vstd__set__impl&%0__choose_58
    ))
    (exists ((a$ Poly)) (!
      (and
       (and
        (has_type a$ %%hole%%0)
        (vstd!set.impl&%0.contains.? %%hole%%1 %%hole%%2 %%hole%%3 a$)
       )
       (= (%%choose%%0 %%hole%%0 %%hole%%1 %%hole%%2 %%hole%%3 %%hole%%4 %%hole%%5 %%hole%%6)
        a$
      ))
      :pattern ((vstd!set.impl&%0.contains.? %%hole%%4 %%hole%%5 %%hole%%6 a$))
   )))
   :pattern ((%%choose%%0 %%hole%%0 %%hole%%1 %%hole%%2 %%hole%%3 %%hole%%4 %%hole%%5
     %%hole%%6
)))))
(assert
 (=>
  (fuel_bool fuel%vstd!set.impl&%0.choose.)
  (forall ((A&. Dcr) (A& Type) (self! Poly)) (!
    (= (vstd!set.impl&%0.choose.? A&. A& self!) (as_type (%%choose%%0 A& A&. A& self! A&.
       A& self!
      ) A&
    ))
    :pattern ((vstd!set.impl&%0.choose.? A&. A& self!))
    :qid internal_vstd!set.impl&__0.choose.?_definition
))))
(assert
 (forall ((A&. Dcr) (A& Type) (self! Poly)) (!
   (=>
    (has_type self! (TYPE%vstd!set.Set. A&. A&))
    (has_type (vstd!set.impl&%0.choose.? A&. A& self!) A&)
   )
   :pattern ((vstd!set.impl&%0.choose.? A&. A& self!))
   :qid internal_vstd!set.impl&__0.choose.?_pre_post_definition
)))

;; Function-Specs vstd::set::axiom_set_choose_finite
(declare-fun req%vstd!set.axiom_set_choose_finite. (Dcr Type Poly) Bool)
(declare-const %%global_location_label%%37 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly)) (!
   (= (req%vstd!set.axiom_set_choose_finite. A&. A& s!) (=>
     %%global_location_label%%37
     (not (vstd!set.impl&%0.finite.? A&. A& s!))
   ))
   :pattern ((req%vstd!set.axiom_set_choose_finite. A&. A& s!))
   :qid internal_req__vstd!set.axiom_set_choose_finite._definition
)))
(declare-fun ens%vstd!set.axiom_set_choose_finite. (Dcr Type Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly)) (!
   (= (ens%vstd!set.axiom_set_choose_finite. A&. A& s!) (vstd!set.impl&%0.contains.? A&.
     A& s! (vstd!set.impl&%0.choose.? A&. A& s!)
   ))
   :pattern ((ens%vstd!set.axiom_set_choose_finite. A&. A& s!))
   :qid internal_ens__vstd!set.axiom_set_choose_finite._definition
)))

;; Broadcast vstd::set::axiom_set_choose_finite
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly)) (!
   (=>
    (has_type s! (TYPE%vstd!set.Set. A&. A&))
    (=>
     (not (vstd!set.impl&%0.finite.? A&. A& s!))
     (vstd!set.impl&%0.contains.? A&. A& s! (vstd!set.impl&%0.choose.? A&. A& s!))
   ))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& s! (vstd!set.impl&%0.choose.? A&. A& s!)))
   :qid user_vstd__set__axiom_set_choose_finite_59
)))

;; Function-Specs vstd::set::axiom_set_empty_len
(declare-fun ens%vstd!set.axiom_set_empty_len. (Dcr Type) Bool)
(assert
 (forall ((A&. Dcr) (A& Type)) (!
   (= (ens%vstd!set.axiom_set_empty_len. A&. A&) (= (vstd!set.impl&%0.len.? A&. A& (vstd!set.impl&%0.empty.?
       A&. A&
      )
     ) 0
   ))
   :pattern ((ens%vstd!set.axiom_set_empty_len. A&. A&))
   :qid internal_ens__vstd!set.axiom_set_empty_len._definition
)))

;; Broadcast vstd::set::axiom_set_empty_len
(assert
 (forall ((A&. Dcr) (A& Type)) (!
   (= (vstd!set.impl&%0.len.? A&. A& (vstd!set.impl&%0.empty.? A&. A&)) 0)
   :pattern ((vstd!set.impl&%0.len.? A&. A& (vstd!set.impl&%0.empty.? A&. A&)))
   :qid user_vstd__set__axiom_set_empty_len_60
)))

;; Function-Specs vstd::set::axiom_set_insert_len
(declare-fun req%vstd!set.axiom_set_insert_len. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%38 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (req%vstd!set.axiom_set_insert_len. A&. A& s! a!) (=>
     %%global_location_label%%38
     (vstd!set.impl&%0.finite.? A&. A& s!)
   ))
   :pattern ((req%vstd!set.axiom_set_insert_len. A&. A& s! a!))
   :qid internal_req__vstd!set.axiom_set_insert_len._definition
)))
(declare-fun ens%vstd!set.axiom_set_insert_len. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_insert_len. A&. A& s! a!) (= (vstd!set.impl&%0.len.? A&.
      A& (vstd!set.impl&%0.insert.? A&. A& s! a!)
     ) (Add (vstd!set.impl&%0.len.? A&. A& s!) (ite
       (vstd!set.impl&%0.contains.? A&. A& s! a!)
       0
       1
   ))))
   :pattern ((ens%vstd!set.axiom_set_insert_len. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_insert_len._definition
)))

;; Broadcast vstd::set::axiom_set_insert_len
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (=>
     (vstd!set.impl&%0.finite.? A&. A& s!)
     (= (vstd!set.impl&%0.len.? A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a!)) (Add (vstd!set.impl&%0.len.?
        A&. A& s!
       ) (ite
        (vstd!set.impl&%0.contains.? A&. A& s! a!)
        0
        1
   )))))
   :pattern ((vstd!set.impl&%0.len.? A&. A& (vstd!set.impl&%0.insert.? A&. A& s! a!)))
   :qid user_vstd__set__axiom_set_insert_len_61
)))

;; Function-Specs vstd::set::axiom_set_remove_len
(declare-fun req%vstd!set.axiom_set_remove_len. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%39 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (req%vstd!set.axiom_set_remove_len. A&. A& s! a!) (=>
     %%global_location_label%%39
     (vstd!set.impl&%0.finite.? A&. A& s!)
   ))
   :pattern ((req%vstd!set.axiom_set_remove_len. A&. A& s! a!))
   :qid internal_req__vstd!set.axiom_set_remove_len._definition
)))
(declare-fun ens%vstd!set.axiom_set_remove_len. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_remove_len. A&. A& s! a!) (= (vstd!set.impl&%0.len.? A&.
      A& s!
     ) (Add (vstd!set.impl&%0.len.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!)) (ite
       (vstd!set.impl&%0.contains.? A&. A& s! a!)
       1
       0
   ))))
   :pattern ((ens%vstd!set.axiom_set_remove_len. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_remove_len._definition
)))

;; Broadcast vstd::set::axiom_set_remove_len
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (=>
     (vstd!set.impl&%0.finite.? A&. A& s!)
     (= (vstd!set.impl&%0.len.? A&. A& s!) (Add (vstd!set.impl&%0.len.? A&. A& (vstd!set.impl&%0.remove.?
         A&. A& s! a!
        )
       ) (ite
        (vstd!set.impl&%0.contains.? A&. A& s! a!)
        1
        0
   )))))
   :pattern ((vstd!set.impl&%0.len.? A&. A& (vstd!set.impl&%0.remove.? A&. A& s! a!)))
   :qid user_vstd__set__axiom_set_remove_len_62
)))

;; Function-Specs vstd::set::axiom_set_contains_len
(declare-fun req%vstd!set.axiom_set_contains_len. (Dcr Type Poly Poly) Bool)
(declare-const %%global_location_label%%40 Bool)
(declare-const %%global_location_label%%41 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (req%vstd!set.axiom_set_contains_len. A&. A& s! a!) (and
     (=>
      %%global_location_label%%40
      (vstd!set.impl&%0.finite.? A&. A& s!)
     )
     (=>
      %%global_location_label%%41
      (vstd!set.impl&%0.contains.? A&. A& s! a!)
   )))
   :pattern ((req%vstd!set.axiom_set_contains_len. A&. A& s! a!))
   :qid internal_req__vstd!set.axiom_set_contains_len._definition
)))
(declare-fun ens%vstd!set.axiom_set_contains_len. (Dcr Type Poly Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (= (ens%vstd!set.axiom_set_contains_len. A&. A& s! a!) (not (= (vstd!set.impl&%0.len.?
       A&. A& s!
      ) 0
   )))
   :pattern ((ens%vstd!set.axiom_set_contains_len. A&. A& s! a!))
   :qid internal_ens__vstd!set.axiom_set_contains_len._definition
)))

;; Broadcast vstd::set::axiom_set_contains_len
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly) (a! Poly)) (!
   (=>
    (and
     (has_type s! (TYPE%vstd!set.Set. A&. A&))
     (has_type a! A&)
    )
    (=>
     (and
      (vstd!set.impl&%0.finite.? A&. A& s!)
      (vstd!set.impl&%0.contains.? A&. A& s! a!)
     )
     (not (= (vstd!set.impl&%0.len.? A&. A& s!) 0))
   ))
   :pattern ((vstd!set.impl&%0.contains.? A&. A& s! a!) (vstd!set.impl&%0.len.? A&. A&
     s!
   ))
   :qid user_vstd__set__axiom_set_contains_len_63
)))

;; Function-Specs vstd::set::axiom_set_choose_len
(declare-fun req%vstd!set.axiom_set_choose_len. (Dcr Type Poly) Bool)
(declare-const %%global_location_label%%42 Bool)
(declare-const %%global_location_label%%43 Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly)) (!
   (= (req%vstd!set.axiom_set_choose_len. A&. A& s!) (and
     (=>
      %%global_location_label%%42
      (vstd!set.impl&%0.finite.? A&. A& s!)
     )
     (=>
      %%global_location_label%%43
      (not (= (vstd!set.impl&%0.len.? A&. A& s!) 0))
   )))
   :pattern ((req%vstd!set.axiom_set_choose_len. A&. A& s!))
   :qid internal_req__vstd!set.axiom_set_choose_len._definition
)))
(declare-fun ens%vstd!set.axiom_set_choose_len. (Dcr Type Poly) Bool)
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly)) (!
   (= (ens%vstd!set.axiom_set_choose_len. A&. A& s!) (vstd!set.impl&%0.contains.? A&.
     A& s! (vstd!set.impl&%0.choose.? A&. A& s!)
   ))
   :pattern ((ens%vstd!set.axiom_set_choose_len. A&. A& s!))
   :qid internal_ens__vstd!set.axiom_set_choose_len._definition
)))

;; Broadcast vstd::set::axiom_set_choose_len
(assert
 (forall ((A&. Dcr) (A& Type) (s! Poly)) (!
   (=>
    (has_type s! (TYPE%vstd!set.Set. A&. A&))
    (=>
     (and
      (vstd!set.impl&%0.finite.? A&. A& s!)
      (not (= (vstd!set.impl&%0.len.? A&. A& s!) 0))
     )
     (vstd!set.impl&%0.contains.? A&. A& s! (vstd!set.impl&%0.choose.? A&. A& s!))
   ))
   :pattern ((vstd!set.impl&%0.len.? A&. A& s!) (vstd!set.impl&%0.contains.? A&. A& s!
     (vstd!set.impl&%0.choose.? A&. A& s!)
   ))
   :qid user_vstd__set__axiom_set_choose_len_64
)))

;; Function-Axioms main::definitions_t::overlap
(assert
 (fuel_bool_default fuel%main!definitions_t.overlap.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.overlap.)
  (forall ((region1! Poly) (region2! Poly)) (!
    (= (main!definitions_t.overlap.? region1! region2!) (ite
      (<= (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
         region1!
        )
       ) (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
         region2!
      )))
      (< (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
         region2!
        )
       ) (nClip (Add (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
           region1!
          )
         ) (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
           region1!
      )))))
      (< (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
         region1!
        )
       ) (nClip (Add (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
           region2!
          )
         ) (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
           region2!
    )))))))
    :pattern ((main!definitions_t.overlap.? region1! region2!))
    :qid internal_main!definitions_t.overlap.?_definition
))))

;; Function-Axioms main::definitions_t::aligned
(assert
 (fuel_bool_default fuel%main!definitions_t.aligned.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.aligned.)
  (forall ((addr! Poly) (size! Poly)) (!
    (= (main!definitions_t.aligned.? addr! size!) (= (nClip (EucMod (%I addr!) (%I size!)))
      0
    ))
    :pattern ((main!definitions_t.aligned.? addr! size!))
    :qid internal_main!definitions_t.aligned.?_definition
))))

;; Function-Axioms main::definitions_t::PAGE_SIZE
(assert
 (fuel_bool_default fuel%main!definitions_t.PAGE_SIZE.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.PAGE_SIZE.)
  (= main!definitions_t.PAGE_SIZE.? 4096)
))
(assert
 (uInv SZ main!definitions_t.PAGE_SIZE.?)
)

;; Function-Axioms main::definitions_t::X86_NUM_LAYERS
(assert
 (fuel_bool_default fuel%main!definitions_t.X86_NUM_LAYERS.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.X86_NUM_LAYERS.)
  (= main!definitions_t.X86_NUM_LAYERS.? 4)
))
(assert
 (uInv SZ main!definitions_t.X86_NUM_LAYERS.?)
)

;; Function-Specs main::definitions_t::Arch::entry_size
(declare-fun req%main!definitions_t.impl&%15.entry_size. (Poly Poly) Bool)
(declare-const %%global_location_label%%44 Bool)
(assert
 (forall ((self! Poly) (layer! Poly)) (!
   (= (req%main!definitions_t.impl&%15.entry_size. self! layer!) (=>
     %%global_location_label%%44
     (< (%I layer!) (vstd!seq.Seq.len.? $ TYPE%main!definitions_t.ArchLayer. (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
        (main!definitions_t.Arch./Arch/layers (%Poly%main!definitions_t.Arch. self!))
   )))))
   :pattern ((req%main!definitions_t.impl&%15.entry_size. self! layer!))
   :qid internal_req__main!definitions_t.impl&__15.entry_size._definition
)))

;; Function-Axioms main::definitions_t::Arch::entry_size
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%15.entry_size.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%15.entry_size.)
  (forall ((self! Poly) (layer! Poly)) (!
    (= (main!definitions_t.impl&%15.entry_size.? self! layer!) (main!definitions_t.ArchLayer./ArchLayer/entry_size
      (%Poly%main!definitions_t.ArchLayer. (vstd!seq.Seq.index.? $ TYPE%main!definitions_t.ArchLayer.
        (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. (main!definitions_t.Arch./Arch/layers
          (%Poly%main!definitions_t.Arch. self!)
         )
        ) layer!
    ))))
    :pattern ((main!definitions_t.impl&%15.entry_size.? self! layer!))
    :qid internal_main!definitions_t.impl&__15.entry_size.?_definition
))))
(assert
 (forall ((self! Poly) (layer! Poly)) (!
   (=>
    (and
     (has_type self! TYPE%main!definitions_t.Arch.)
     (has_type layer! NAT)
    )
    (<= 0 (main!definitions_t.impl&%15.entry_size.? self! layer!))
   )
   :pattern ((main!definitions_t.impl&%15.entry_size.? self! layer!))
   :qid internal_main!definitions_t.impl&__15.entry_size.?_pre_post_definition
)))

;; Function-Specs main::definitions_t::Arch::num_entries
(declare-fun req%main!definitions_t.impl&%15.num_entries. (Poly Poly) Bool)
(declare-const %%global_location_label%%45 Bool)
(assert
 (forall ((self! Poly) (layer! Poly)) (!
   (= (req%main!definitions_t.impl&%15.num_entries. self! layer!) (=>
     %%global_location_label%%45
     (< (%I layer!) (vstd!seq.Seq.len.? $ TYPE%main!definitions_t.ArchLayer. (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
        (main!definitions_t.Arch./Arch/layers (%Poly%main!definitions_t.Arch. self!))
   )))))
   :pattern ((req%main!definitions_t.impl&%15.num_entries. self! layer!))
   :qid internal_req__main!definitions_t.impl&__15.num_entries._definition
)))

;; Function-Axioms main::definitions_t::Arch::num_entries
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%15.num_entries.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%15.num_entries.)
  (forall ((self! Poly) (layer! Poly)) (!
    (= (main!definitions_t.impl&%15.num_entries.? self! layer!) (main!definitions_t.ArchLayer./ArchLayer/num_entries
      (%Poly%main!definitions_t.ArchLayer. (vstd!seq.Seq.index.? $ TYPE%main!definitions_t.ArchLayer.
        (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. (main!definitions_t.Arch./Arch/layers
          (%Poly%main!definitions_t.Arch. self!)
         )
        ) layer!
    ))))
    :pattern ((main!definitions_t.impl&%15.num_entries.? self! layer!))
    :qid internal_main!definitions_t.impl&__15.num_entries.?_definition
))))
(assert
 (forall ((self! Poly) (layer! Poly)) (!
   (=>
    (and
     (has_type self! TYPE%main!definitions_t.Arch.)
     (has_type layer! NAT)
    )
    (<= 0 (main!definitions_t.impl&%15.num_entries.? self! layer!))
   )
   :pattern ((main!definitions_t.impl&%15.num_entries.? self! layer!))
   :qid internal_main!definitions_t.impl&__15.num_entries.?_pre_post_definition
)))

;; Function-Axioms main::definitions_t::X86_MAX_ENTRY_SIZE
(assert
 (fuel_bool_default fuel%main!definitions_t.X86_MAX_ENTRY_SIZE.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.X86_MAX_ENTRY_SIZE.)
  (= main!definitions_t.X86_MAX_ENTRY_SIZE.? (nClip (Mul (nClip (Mul (nClip (Mul 512 512))
       512
      )
     ) 4096
)))))
(assert
 (<= 0 main!definitions_t.X86_MAX_ENTRY_SIZE.?)
)

;; Function-Axioms main::definitions_t::X86_NUM_ENTRIES
(assert
 (fuel_bool_default fuel%main!definitions_t.X86_NUM_ENTRIES.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.X86_NUM_ENTRIES.)
  (= main!definitions_t.X86_NUM_ENTRIES.? 512)
))
(assert
 (uInv SZ main!definitions_t.X86_NUM_ENTRIES.?)
)

;; Function-Specs main::definitions_t::Arch::entry_size_is_next_layer_size
(declare-fun req%main!definitions_t.impl&%15.entry_size_is_next_layer_size. (Poly Poly)
 Bool
)
(declare-const %%global_location_label%%46 Bool)
(assert
 (forall ((self! Poly) (i! Poly)) (!
   (= (req%main!definitions_t.impl&%15.entry_size_is_next_layer_size. self! i!) (=>
     %%global_location_label%%46
     (< (%I i!) (vstd!seq.Seq.len.? $ TYPE%main!definitions_t.ArchLayer. (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
        (main!definitions_t.Arch./Arch/layers (%Poly%main!definitions_t.Arch. self!))
   )))))
   :pattern ((req%main!definitions_t.impl&%15.entry_size_is_next_layer_size. self! i!))
   :qid internal_req__main!definitions_t.impl&__15.entry_size_is_next_layer_size._definition
)))

;; Function-Axioms main::definitions_t::Arch::entry_size_is_next_layer_size
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%15.entry_size_is_next_layer_size.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%15.entry_size_is_next_layer_size.)
  (forall ((self! Poly) (i! Poly)) (!
    (= (main!definitions_t.impl&%15.entry_size_is_next_layer_size.? self! i!) (=>
      (< (nClip (Add (%I i!) 1)) (vstd!seq.Seq.len.? $ TYPE%main!definitions_t.ArchLayer.
        (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>. (main!definitions_t.Arch./Arch/layers
          (%Poly%main!definitions_t.Arch. self!)
      ))))
      (= (main!definitions_t.impl&%15.entry_size.? self! i!) (nClip (Mul (main!definitions_t.impl&%15.entry_size.?
          self! (I (nClip (Add (%I i!) 1)))
         ) (main!definitions_t.impl&%15.num_entries.? self! (I (nClip (Add (%I i!) 1))))
    )))))
    :pattern ((main!definitions_t.impl&%15.entry_size_is_next_layer_size.? self! i!))
    :qid internal_main!definitions_t.impl&__15.entry_size_is_next_layer_size.?_definition
))))

;; Function-Axioms main::definitions_t::Arch::inv
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%15.inv.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%15.inv.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%15.inv.? self!) (and
      (<= (vstd!seq.Seq.len.? $ TYPE%main!definitions_t.ArchLayer. (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
         (main!definitions_t.Arch./Arch/layers (%Poly%main!definitions_t.Arch. self!))
        )
       ) main!definitions_t.X86_NUM_LAYERS.?
      )
      (forall ((i$ Poly)) (!
        (=>
         (has_type i$ NAT)
         (=>
          (< (%I i$) (vstd!seq.Seq.len.? $ TYPE%main!definitions_t.ArchLayer. (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
             (main!definitions_t.Arch./Arch/layers (%Poly%main!definitions_t.Arch. self!))
          )))
          (and
           (and
            (let
             ((tmp%%$ (main!definitions_t.impl&%15.entry_size.? self! i$)))
             (and
              (< 0 tmp%%$)
              (<= tmp%%$ main!definitions_t.X86_MAX_ENTRY_SIZE.?)
            ))
            (let
             ((tmp%%$ (main!definitions_t.impl&%15.num_entries.? self! i$)))
             (and
              (< 0 tmp%%$)
              (<= tmp%%$ main!definitions_t.X86_NUM_ENTRIES.?)
           )))
           (main!definitions_t.impl&%15.entry_size_is_next_layer_size.? self! i$)
        )))
        :pattern ((main!definitions_t.impl&%15.entry_size.? self! i$))
        :pattern ((main!definitions_t.impl&%15.num_entries.? self! i$))
        :qid user_main__definitions_t__Arch__inv_65
    ))))
    :pattern ((main!definitions_t.impl&%15.inv.? self!))
    :qid internal_main!definitions_t.impl&__15.inv.?_definition
))))

;; Function-Axioms main::definitions_t::entry_base_from_index
(assert
 (fuel_bool_default fuel%main!definitions_t.entry_base_from_index.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.entry_base_from_index.)
  (forall ((base! Poly) (idx! Poly) (entry_size! Poly)) (!
    (= (main!definitions_t.entry_base_from_index.? base! idx! entry_size!) (nClip (Add (
        %I base!
       ) (nClip (Mul (%I idx!) (%I entry_size!)))
    )))
    :pattern ((main!definitions_t.entry_base_from_index.? base! idx! entry_size!))
    :qid internal_main!definitions_t.entry_base_from_index.?_definition
))))
(assert
 (forall ((base! Poly) (idx! Poly) (entry_size! Poly)) (!
   (=>
    (and
     (has_type base! NAT)
     (has_type idx! NAT)
     (has_type entry_size! NAT)
    )
    (<= 0 (main!definitions_t.entry_base_from_index.? base! idx! entry_size!))
   )
   :pattern ((main!definitions_t.entry_base_from_index.? base! idx! entry_size!))
   :qid internal_main!definitions_t.entry_base_from_index.?_pre_post_definition
)))

;; Function-Specs main::definitions_t::Arch::entry_base
(declare-fun req%main!definitions_t.impl&%15.entry_base. (Poly Poly Poly Poly) Bool)
(declare-const %%global_location_label%%47 Bool)
(declare-const %%global_location_label%%48 Bool)
(assert
 (forall ((self! Poly) (layer! Poly) (base! Poly) (idx! Poly)) (!
   (= (req%main!definitions_t.impl&%15.entry_base. self! layer! base! idx!) (and
     (=>
      %%global_location_label%%47
      (main!definitions_t.impl&%15.inv.? self!)
     )
     (=>
      %%global_location_label%%48
      (< (%I layer!) (vstd!seq.Seq.len.? $ TYPE%main!definitions_t.ArchLayer. (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
         (main!definitions_t.Arch./Arch/layers (%Poly%main!definitions_t.Arch. self!))
   ))))))
   :pattern ((req%main!definitions_t.impl&%15.entry_base. self! layer! base! idx!))
   :qid internal_req__main!definitions_t.impl&__15.entry_base._definition
)))

;; Function-Axioms main::definitions_t::Arch::entry_base
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%15.entry_base.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%15.entry_base.)
  (forall ((self! Poly) (layer! Poly) (base! Poly) (idx! Poly)) (!
    (= (main!definitions_t.impl&%15.entry_base.? self! layer! base! idx!) (main!definitions_t.entry_base_from_index.?
      base! idx! (I (main!definitions_t.impl&%15.entry_size.? self! layer!))
    ))
    :pattern ((main!definitions_t.impl&%15.entry_base.? self! layer! base! idx!))
    :qid internal_main!definitions_t.impl&__15.entry_base.?_definition
))))
(assert
 (forall ((self! Poly) (layer! Poly) (base! Poly) (idx! Poly)) (!
   (=>
    (and
     (has_type self! TYPE%main!definitions_t.Arch.)
     (has_type layer! NAT)
     (has_type base! NAT)
     (has_type idx! NAT)
    )
    (<= 0 (main!definitions_t.impl&%15.entry_base.? self! layer! base! idx!))
   )
   :pattern ((main!definitions_t.impl&%15.entry_base.? self! layer! base! idx!))
   :qid internal_main!definitions_t.impl&__15.entry_base.?_pre_post_definition
)))

;; Function-Specs main::definitions_t::Arch::upper_vaddr
(declare-fun req%main!definitions_t.impl&%15.upper_vaddr. (Poly Poly Poly) Bool)
(declare-const %%global_location_label%%49 Bool)
(declare-const %%global_location_label%%50 Bool)
(assert
 (forall ((self! Poly) (layer! Poly) (base! Poly)) (!
   (= (req%main!definitions_t.impl&%15.upper_vaddr. self! layer! base!) (and
     (=>
      %%global_location_label%%49
      (main!definitions_t.impl&%15.inv.? self!)
     )
     (=>
      %%global_location_label%%50
      (< (%I layer!) (vstd!seq.Seq.len.? $ TYPE%main!definitions_t.ArchLayer. (Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
         (main!definitions_t.Arch./Arch/layers (%Poly%main!definitions_t.Arch. self!))
   ))))))
   :pattern ((req%main!definitions_t.impl&%15.upper_vaddr. self! layer! base!))
   :qid internal_req__main!definitions_t.impl&__15.upper_vaddr._definition
)))

;; Function-Axioms main::definitions_t::Arch::upper_vaddr
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%15.upper_vaddr.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%15.upper_vaddr.)
  (forall ((self! Poly) (layer! Poly) (base! Poly)) (!
    (= (main!definitions_t.impl&%15.upper_vaddr.? self! layer! base!) (main!definitions_t.entry_base_from_index.?
      base! (I (main!definitions_t.impl&%15.num_entries.? self! layer!)) (I (main!definitions_t.impl&%15.entry_size.?
        self! layer!
    ))))
    :pattern ((main!definitions_t.impl&%15.upper_vaddr.? self! layer! base!))
    :qid internal_main!definitions_t.impl&__15.upper_vaddr.?_definition
))))
(assert
 (forall ((self! Poly) (layer! Poly) (base! Poly)) (!
   (=>
    (and
     (has_type self! TYPE%main!definitions_t.Arch.)
     (has_type layer! NAT)
     (has_type base! NAT)
    )
    (<= 0 (main!definitions_t.impl&%15.upper_vaddr.? self! layer! base!))
   )
   :pattern ((main!definitions_t.impl&%15.upper_vaddr.? self! layer! base!))
   :qid internal_main!definitions_t.impl&__15.upper_vaddr.?_pre_post_definition
)))

;; Function-Axioms main::definitions_t::L3_ENTRY_SIZE
(assert
 (fuel_bool_default fuel%main!definitions_t.L3_ENTRY_SIZE.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.L3_ENTRY_SIZE.)
  (= main!definitions_t.L3_ENTRY_SIZE.? main!definitions_t.PAGE_SIZE.?)
))
(assert
 (uInv SZ main!definitions_t.L3_ENTRY_SIZE.?)
)

;; Function-Axioms main::definitions_t::L2_ENTRY_SIZE
(assert
 (fuel_bool_default fuel%main!definitions_t.L2_ENTRY_SIZE.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.L2_ENTRY_SIZE.)
  (= main!definitions_t.L2_ENTRY_SIZE.? (uClip SZ (Mul 512 main!definitions_t.L3_ENTRY_SIZE.?)))
))
(assert
 (uInv SZ main!definitions_t.L2_ENTRY_SIZE.?)
)

;; Function-Axioms main::definitions_t::L1_ENTRY_SIZE
(assert
 (fuel_bool_default fuel%main!definitions_t.L1_ENTRY_SIZE.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.L1_ENTRY_SIZE.)
  (= main!definitions_t.L1_ENTRY_SIZE.? (uClip SZ (Mul 512 main!definitions_t.L2_ENTRY_SIZE.?)))
))
(assert
 (uInv SZ main!definitions_t.L1_ENTRY_SIZE.?)
)

;; Function-Axioms main::definitions_t::L0_ENTRY_SIZE
(assert
 (fuel_bool_default fuel%main!definitions_t.L0_ENTRY_SIZE.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.L0_ENTRY_SIZE.)
  (= main!definitions_t.L0_ENTRY_SIZE.? (uClip SZ (Mul 512 main!definitions_t.L1_ENTRY_SIZE.?)))
))
(assert
 (uInv SZ main!definitions_t.L0_ENTRY_SIZE.?)
)

;; Function-Axioms main::definitions_t::x86_arch_spec
(assert
 (fuel_bool_default fuel%main!definitions_t.x86_arch_spec.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.x86_arch_spec.)
  (= main!definitions_t.x86_arch_spec.? (main!definitions_t.Arch./Arch (%Poly%vstd!seq.Seq<main!definitions_t.ArchLayer.>.
     (vstd!seq.Seq.push.? $ TYPE%main!definitions_t.ArchLayer. (vstd!seq.Seq.push.? $ TYPE%main!definitions_t.ArchLayer.
       (vstd!seq.Seq.push.? $ TYPE%main!definitions_t.ArchLayer. (vstd!seq.Seq.push.? $ TYPE%main!definitions_t.ArchLayer.
         (vstd!seq.Seq.empty.? $ TYPE%main!definitions_t.ArchLayer.) (Poly%main!definitions_t.ArchLayer.
          (main!definitions_t.ArchLayer./ArchLayer (%I (I main!definitions_t.L0_ENTRY_SIZE.?))
           (%I (I 512))
         ))
        ) (Poly%main!definitions_t.ArchLayer. (main!definitions_t.ArchLayer./ArchLayer (%I (
            I main!definitions_t.L1_ENTRY_SIZE.?
           )
          ) (%I (I 512))
        ))
       ) (Poly%main!definitions_t.ArchLayer. (main!definitions_t.ArchLayer./ArchLayer (%I (
           I main!definitions_t.L2_ENTRY_SIZE.?
          )
         ) (%I (I 512))
       ))
      ) (Poly%main!definitions_t.ArchLayer. (main!definitions_t.ArchLayer./ArchLayer (%I (
          I main!definitions_t.L3_ENTRY_SIZE.?
         )
        ) (%I (I 512))
))))))))

;; Function-Axioms main::definitions_t::candidate_mapping_in_bounds
(assert
 (fuel_bool_default fuel%main!definitions_t.candidate_mapping_in_bounds.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.candidate_mapping_in_bounds.)
  (forall ((base! Poly) (pte! Poly)) (!
    (= (main!definitions_t.candidate_mapping_in_bounds.? base! pte!) (< (nClip (Add (%I base!)
        (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
          (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
            (%Poly%main!definitions_t.PageTableEntry. pte!)
       )))))
      ) (main!definitions_t.impl&%15.upper_vaddr.? (Poly%main!definitions_t.Arch. main!definitions_t.x86_arch_spec.?)
       (I 0) (I 0)
    )))
    :pattern ((main!definitions_t.candidate_mapping_in_bounds.? base! pte!))
    :qid internal_main!definitions_t.candidate_mapping_in_bounds.?_definition
))))

;; Function-Axioms main::definitions_t::candidate_mapping_overlaps_existing_pmem
(assert
 (fuel_bool_default fuel%main!definitions_t.candidate_mapping_overlaps_existing_pmem.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.candidate_mapping_overlaps_existing_pmem.)
  (forall ((mappings! Poly) (base! Poly) (pte! Poly)) (!
    (= (main!definitions_t.candidate_mapping_overlaps_existing_pmem.? mappings! base! pte!)
     (exists ((b$ Poly)) (!
       (and
        (has_type b$ NAT)
        (and
         (vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
           mappings!
          ) b$
         )
         (main!definitions_t.overlap.? (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
            (%Poly%main!definitions_t.PageTableEntry. pte!)
           )
          ) (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
            (%Poly%main!definitions_t.PageTableEntry. (vstd!map.impl&%0.index.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
              mappings! b$
       )))))))
       :pattern ((vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
          mappings!
         ) b$
       ))
       :qid user_main__definitions_t__candidate_mapping_overlaps_existing_pmem_66
    )))
    :pattern ((main!definitions_t.candidate_mapping_overlaps_existing_pmem.? mappings!
      base! pte!
    ))
    :qid internal_main!definitions_t.candidate_mapping_overlaps_existing_pmem.?_definition
))))

;; Function-Axioms main::definitions_t::candidate_mapping_overlaps_existing_vmem
(assert
 (fuel_bool_default fuel%main!definitions_t.candidate_mapping_overlaps_existing_vmem.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.candidate_mapping_overlaps_existing_vmem.)
  (forall ((mappings! Poly) (base! Poly) (pte! Poly)) (!
    (= (main!definitions_t.candidate_mapping_overlaps_existing_vmem.? mappings! base! pte!)
     (exists ((b$ Poly)) (!
       (and
        (has_type b$ NAT)
        (and
         (vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
           mappings!
          ) b$
         )
         (main!definitions_t.overlap.? (Poly%main!definitions_t.MemRegion. (main!definitions_t.MemRegion./MemRegion
            (%I base!) (%I (I (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
                (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                  (%Poly%main!definitions_t.PageTableEntry. pte!)
           )))))))
          ) (Poly%main!definitions_t.MemRegion. (main!definitions_t.MemRegion./MemRegion (%I b$)
            (%I (I (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
                (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                  (%Poly%main!definitions_t.PageTableEntry. (vstd!map.impl&%0.index.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
                    mappings! b$
       )))))))))))))
       :pattern ((vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
          mappings!
         ) b$
       ))
       :qid user_main__definitions_t__candidate_mapping_overlaps_existing_vmem_67
    )))
    :pattern ((main!definitions_t.candidate_mapping_overlaps_existing_vmem.? mappings!
      base! pte!
    ))
    :qid internal_main!definitions_t.candidate_mapping_overlaps_existing_vmem.?_definition
))))

;; Function-Axioms main::definitions_t::MapResult::is_ErrOverlap
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%0.is_ErrOverlap.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%0.is_ErrOverlap.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%0.is_ErrOverlap.? self!) (is-main!definitions_t.MapResult./ErrOverlap
      (%Poly%main!definitions_t.MapResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%0.is_ErrOverlap.? self!))
    :qid internal_main!definitions_t.impl&__0.is_ErrOverlap.?_definition
))))

;; Function-Axioms main::definitions_t::MapResult::is_Ok
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%0.is_Ok.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%0.is_Ok.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%0.is_Ok.? self!) (is-main!definitions_t.MapResult./Ok
      (%Poly%main!definitions_t.MapResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%0.is_Ok.? self!))
    :qid internal_main!definitions_t.impl&__0.is_Ok.?_definition
))))

;; Function-Axioms main::definitions_t::between
(assert
 (fuel_bool_default fuel%main!definitions_t.between.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.between.)
  (forall ((x! Poly) (a! Poly) (b! Poly)) (!
    (= (main!definitions_t.between.? x! a! b!) (and
      (<= (%I a!) (%I x!))
      (< (%I x!) (%I b!))
    ))
    :pattern ((main!definitions_t.between.? x! a! b!))
    :qid internal_main!definitions_t.between.?_definition
))))

;; Function-Axioms main::definitions_t::PT_BOUND_LOW
(assert
 (fuel_bool_default fuel%main!definitions_t.PT_BOUND_LOW.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.PT_BOUND_LOW.)
  (= main!definitions_t.PT_BOUND_LOW.? 0)
))
(assert
 (<= 0 main!definitions_t.PT_BOUND_LOW.?)
)

;; Function-Axioms main::definitions_t::PT_BOUND_HIGH
(assert
 (fuel_bool_default fuel%main!definitions_t.PT_BOUND_HIGH.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.PT_BOUND_HIGH.)
  (= main!definitions_t.PT_BOUND_HIGH.? (uClip SZ (Mul (uClip SZ (Mul (uClip SZ (Mul (uClip
          SZ (Mul 512 512)
         ) 1024
        )
       ) 1024
      )
     ) 1024
)))))
(assert
 (uInv SZ main!definitions_t.PT_BOUND_HIGH.?)
)

;; Function-Axioms main::definitions_t::UnmapResult::is_Ok
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%1.is_Ok.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%1.is_Ok.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%1.is_Ok.? self!) (is-main!definitions_t.UnmapResult./Ok
      (%Poly%main!definitions_t.UnmapResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%1.is_Ok.? self!))
    :qid internal_main!definitions_t.impl&__1.is_Ok.?_definition
))))

;; Function-Axioms main::definitions_t::UnmapResult::is_ErrNoSuchMapping
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%1.is_ErrNoSuchMapping.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%1.is_ErrNoSuchMapping.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%1.is_ErrNoSuchMapping.? self!) (is-main!definitions_t.UnmapResult./ErrNoSuchMapping
      (%Poly%main!definitions_t.UnmapResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%1.is_ErrNoSuchMapping.? self!))
    :qid internal_main!definitions_t.impl&__1.is_ErrNoSuchMapping.?_definition
))))

;; Function-Axioms vstd::map_lib::impl&%0::contains_pair
(assert
 (fuel_bool_default fuel%vstd!map_lib.impl&%0.contains_pair.)
)
(assert
 (=>
  (fuel_bool fuel%vstd!map_lib.impl&%0.contains_pair.)
  (forall ((K&. Dcr) (K& Type) (V&. Dcr) (V& Type) (self! Poly) (k! Poly) (v! Poly))
   (!
    (= (vstd!map_lib.impl&%0.contains_pair.? K&. K& V&. V& self! k! v!) (and
      (vstd!set.impl&%0.contains.? K&. K& (vstd!map.impl&%0.dom.? K&. K& V&. V& self!) k!)
      (= (vstd!map.impl&%0.index.? K&. K& V&. V& self! k!) v!)
    ))
    :pattern ((vstd!map_lib.impl&%0.contains_pair.? K&. K& V&. V& self! k! v!))
    :qid internal_vstd!map_lib.impl&__0.contains_pair.?_definition
))))

;; Function-Axioms main::definitions_t::WORD_SIZE
(assert
 (fuel_bool_default fuel%main!definitions_t.WORD_SIZE.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.WORD_SIZE.)
  (= main!definitions_t.WORD_SIZE.? 8)
))
(assert
 (uInv SZ main!definitions_t.WORD_SIZE.?)
)

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_op
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_op.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_op.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_op.? self!) (main!spec_t.hlspec.AbstractStep./ReadWrite/op
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_op.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_op.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%main!definitions_t.RWOp. (main!spec_t.hlspec.impl&%0.arrow_op.? self!))
     TYPE%main!definitions_t.RWOp.
   ))
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_op.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_op.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_result
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_result.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_result.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_result.? self!) (main!spec_t.hlspec.AbstractStep./Resolve/result
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_result.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_result.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%main!definitions_t.ResolveResult. (main!spec_t.hlspec.impl&%0.arrow_result.?
       self!
      )
     ) TYPE%main!definitions_t.ResolveResult.
   ))
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_result.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_result.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_ReadWrite_vaddr
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr.? self!) (main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_ReadWrite_vaddr.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (<= 0 (main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr.? self!))
   )
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_ReadWrite_vaddr.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_ReadWrite_vaddr.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_ReadWrite_op
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op.? self!) (main!spec_t.hlspec.AbstractStep./ReadWrite/op
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_ReadWrite_op.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%main!definitions_t.RWOp. (main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op.?
       self!
      )
     ) TYPE%main!definitions_t.RWOp.
   ))
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_ReadWrite_op.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_ReadWrite_op.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_ReadWrite_pte
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte.? self!) (main!spec_t.hlspec.AbstractStep./ReadWrite/pte
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_ReadWrite_pte.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%core!option.Option. (main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte.?
       self!
      )
     ) (TYPE%core!option.Option. $ (TYPE%tuple%2. $ NAT $ TYPE%main!definitions_t.PageTableEntry.))
   ))
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_ReadWrite_pte.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_ReadWrite_pte.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_Map_vaddr
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_Map_vaddr.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_Map_vaddr.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_Map_vaddr.? self!) (main!spec_t.hlspec.AbstractStep./Map/vaddr
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_Map_vaddr.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_Map_vaddr.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (<= 0 (main!spec_t.hlspec.impl&%0.arrow_Map_vaddr.? self!))
   )
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_Map_vaddr.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_Map_vaddr.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_Map_pte
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_Map_pte.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_Map_pte.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_Map_pte.? self!) (main!spec_t.hlspec.AbstractStep./Map/pte
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_Map_pte.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_Map_pte.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%main!definitions_t.PageTableEntry. (main!spec_t.hlspec.impl&%0.arrow_Map_pte.?
       self!
      )
     ) TYPE%main!definitions_t.PageTableEntry.
   ))
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_Map_pte.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_Map_pte.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_Map_result
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_Map_result.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_Map_result.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_Map_result.? self!) (main!spec_t.hlspec.AbstractStep./Map/result
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_Map_result.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_Map_result.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_Unmap_vaddr
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr.? self!) (main!spec_t.hlspec.AbstractStep./Unmap/vaddr
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_Unmap_vaddr.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (<= 0 (main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr.? self!))
   )
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_Unmap_vaddr.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_Unmap_vaddr.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_Unmap_result
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_Unmap_result.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_Unmap_result.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_Unmap_result.? self!) (main!spec_t.hlspec.AbstractStep./Unmap/result
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_Unmap_result.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_Unmap_result.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_Resolve_vaddr
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr.? self!) (main!spec_t.hlspec.AbstractStep./Resolve/vaddr
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_Resolve_vaddr.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (<= 0 (main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr.? self!))
   )
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_Resolve_vaddr.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_Resolve_vaddr.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::AbstractStep::arrow_Resolve_result
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.impl&%0.arrow_Resolve_result.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.impl&%0.arrow_Resolve_result.)
  (forall ((self! Poly)) (!
    (= (main!spec_t.hlspec.impl&%0.arrow_Resolve_result.? self!) (main!spec_t.hlspec.AbstractStep./Resolve/result
      (%Poly%main!spec_t.hlspec.AbstractStep. self!)
    ))
    :pattern ((main!spec_t.hlspec.impl&%0.arrow_Resolve_result.? self!))
    :qid internal_main!spec_t.hlspec.impl&__0.arrow_Resolve_result.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!spec_t.hlspec.AbstractStep.)
    (has_type (Poly%main!definitions_t.ResolveResult. (main!spec_t.hlspec.impl&%0.arrow_Resolve_result.?
       self!
      )
     ) TYPE%main!definitions_t.ResolveResult.
   ))
   :pattern ((main!spec_t.hlspec.impl&%0.arrow_Resolve_result.? self!))
   :qid internal_main!spec_t.hlspec.impl&__0.arrow_Resolve_result.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::init
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.init.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.init.)
  (forall ((s! Poly)) (!
    (= (main!spec_t.hlspec.init.? s!) (and
      (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
         s!
        )
       ) (%Poly%vstd!map.Map<nat./nat.>. (vstd!map.impl&%0.empty.? $ NAT $ NAT))
      )
      (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
         s!
        )
       ) (%Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (vstd!map.impl&%0.empty.?
         $ NAT $ TYPE%main!definitions_t.PageTableEntry.
    )))))
    :pattern ((main!spec_t.hlspec.init.? s!))
    :qid internal_main!spec_t.hlspec.init.?_definition
))))

;; Function-Specs main::spec_t::mem::word_index_spec
(declare-fun req%main!spec_t.mem.word_index_spec. (Poly) Bool)
(declare-const %%global_location_label%%51 Bool)
(assert
 (forall ((addr! Poly)) (!
   (= (req%main!spec_t.mem.word_index_spec. addr!) (=>
     %%global_location_label%%51
     (main!definitions_t.aligned.? addr! (I 8))
   ))
   :pattern ((req%main!spec_t.mem.word_index_spec. addr!))
   :qid internal_req__main!spec_t.mem.word_index_spec._definition
)))

;; Function-Axioms main::spec_t::mem::word_index_spec
(assert
 (fuel_bool_default fuel%main!spec_t.mem.word_index_spec.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.mem.word_index_spec.)
  (forall ((addr! Poly)) (!
    (= (main!spec_t.mem.word_index_spec.? addr!) (nClip (EucDiv (%I addr!) main!definitions_t.WORD_SIZE.?)))
    :pattern ((main!spec_t.mem.word_index_spec.? addr!))
    :qid internal_main!spec_t.mem.word_index_spec.?_definition
))))
(assert
 (forall ((addr! Poly)) (!
   (=>
    (has_type addr! NAT)
    (<= 0 (main!spec_t.mem.word_index_spec.? addr!))
   )
   :pattern ((main!spec_t.mem.word_index_spec.? addr!))
   :qid internal_main!spec_t.mem.word_index_spec.?_pre_post_definition
)))

;; Function-Axioms main::spec_t::hlspec::mem_domain_from_mappings_contains
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.mem_domain_from_mappings_contains.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.mem_domain_from_mappings_contains.)
  (forall ((phys_mem_size! Poly) (word_idx! Poly) (mappings! Poly)) (!
    (= (main!spec_t.hlspec.mem_domain_from_mappings_contains.? phys_mem_size! word_idx!
      mappings!
     ) (let
      ((vaddr$ (nClip (Mul (%I word_idx!) main!definitions_t.WORD_SIZE.?))))
      (exists ((base$ Poly) (pte$ Poly)) (!
        (and
         (and
          (has_type base$ NAT)
          (has_type pte$ TYPE%main!definitions_t.PageTableEntry.)
         )
         (let
          ((paddr$ (nClip (Add (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
                (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                  (%Poly%main!definitions_t.PageTableEntry. pte$)
               )))
              ) (Sub vaddr$ (%I base$))
          ))))
          (let
           ((pmem_idx$ (main!spec_t.mem.word_index_spec.? (I paddr$))))
           (and
            (and
             (vstd!map_lib.impl&%0.contains_pair.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
              mappings! base$ pte$
             )
             (main!definitions_t.between.? (I vaddr$) base$ (I (nClip (Add (%I base$) (main!definitions_t.MemRegion./MemRegion/size
                  (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                     (%Poly%main!definitions_t.PageTableEntry. pte$)
            )))))))))
            (< pmem_idx$ (%I phys_mem_size!))
        ))))
        :pattern ((vstd!map_lib.impl&%0.contains_pair.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
          mappings! base$ pte$
        ))
        :qid user_main__spec_t__hlspec__mem_domain_from_mappings_contains_68
    ))))
    :pattern ((main!spec_t.hlspec.mem_domain_from_mappings_contains.? phys_mem_size! word_idx!
      mappings!
    ))
    :qid internal_main!spec_t.hlspec.mem_domain_from_mappings_contains.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::mem_domain_from_mappings
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.mem_domain_from_mappings.)
)
(declare-fun %%lambda%%0 (Poly Poly) %%Function%%)
(assert
 (forall ((%%hole%%0 Poly) (%%hole%%1 Poly) (word_idx$ Poly)) (!
   (= (%%apply%%0 (%%lambda%%0 %%hole%%0 %%hole%%1) word_idx$) (B (main!spec_t.hlspec.mem_domain_from_mappings_contains.?
      %%hole%%0 word_idx$ %%hole%%1
   )))
   :pattern ((%%apply%%0 (%%lambda%%0 %%hole%%0 %%hole%%1) word_idx$))
)))
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.mem_domain_from_mappings.)
  (forall ((phys_mem_size! Poly) (mappings! Poly)) (!
    (= (main!spec_t.hlspec.mem_domain_from_mappings.? phys_mem_size! mappings!) (%Poly%vstd!set.Set<nat.>.
      (vstd!set.impl&%0.new.? $ NAT $ (TYPE%fun%1. $ NAT $ BOOL) (Poly%fun%1. (mk_fun (%%lambda%%0
          phys_mem_size! mappings!
    ))))))
    :pattern ((main!spec_t.hlspec.mem_domain_from_mappings.? phys_mem_size! mappings!))
    :qid internal_main!spec_t.hlspec.mem_domain_from_mappings.?_definition
))))

;; Function-Axioms main::definitions_t::StoreResult::is_Ok
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%9.is_Ok.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%9.is_Ok.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%9.is_Ok.? self!) (is-main!definitions_t.StoreResult./Ok
      (%Poly%main!definitions_t.StoreResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%9.is_Ok.? self!))
    :qid internal_main!definitions_t.impl&__9.is_Ok.?_definition
))))

;; Function-Axioms main::definitions_t::StoreResult::is_Pagefault
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%9.is_Pagefault.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%9.is_Pagefault.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%9.is_Pagefault.? self!) (is-main!definitions_t.StoreResult./Pagefault
      (%Poly%main!definitions_t.StoreResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%9.is_Pagefault.? self!))
    :qid internal_main!definitions_t.impl&__9.is_Pagefault.?_definition
))))

;; Function-Axioms main::definitions_t::LoadResult::is_Value
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%7.is_Value.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%7.is_Value.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%7.is_Value.? self!) (is-main!definitions_t.LoadResult./Value
      (%Poly%main!definitions_t.LoadResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%7.is_Value.? self!))
    :qid internal_main!definitions_t.impl&__7.is_Value.?_definition
))))

;; Function-Axioms main::definitions_t::LoadResult::get_Value_0
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%7.get_Value_0.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%7.get_Value_0.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%7.get_Value_0.? self!) (main!definitions_t.LoadResult./Value/0
      (%Poly%main!definitions_t.LoadResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%7.get_Value_0.? self!))
    :qid internal_main!definitions_t.impl&__7.get_Value_0.?_definition
))))
(assert
 (forall ((self! Poly)) (!
   (=>
    (has_type self! TYPE%main!definitions_t.LoadResult.)
    (<= 0 (main!definitions_t.impl&%7.get_Value_0.? self!))
   )
   :pattern ((main!definitions_t.impl&%7.get_Value_0.? self!))
   :qid internal_main!definitions_t.impl&__7.get_Value_0.?_pre_post_definition
)))

;; Function-Axioms main::definitions_t::LoadResult::is_Pagefault
(assert
 (fuel_bool_default fuel%main!definitions_t.impl&%7.is_Pagefault.)
)
(assert
 (=>
  (fuel_bool fuel%main!definitions_t.impl&%7.is_Pagefault.)
  (forall ((self! Poly)) (!
    (= (main!definitions_t.impl&%7.is_Pagefault.? self!) (is-main!definitions_t.LoadResult./Pagefault
      (%Poly%main!definitions_t.LoadResult. self!)
    ))
    :pattern ((main!definitions_t.impl&%7.is_Pagefault.? self!))
    :qid internal_main!definitions_t.impl&__7.is_Pagefault.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::step_ReadWrite
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.step_ReadWrite.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.step_ReadWrite.)
  (forall ((c! Poly) (s1! Poly) (s2! Poly) (vaddr! Poly) (op! Poly) (pte! Poly)) (!
    (= (main!spec_t.hlspec.step_ReadWrite.? c! s1! s2! vaddr! op! pte!) (let
      ((vmem_idx$ (main!spec_t.mem.word_index_spec.? vaddr!)))
      (and
       (and
        (main!definitions_t.aligned.? vaddr! (I 8))
        (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
           s2!
          )
         ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
           s1!
       ))))
       (ite
        (is-core!option.Option./Some (%Poly%core!option.Option. pte!))
        (let
         ((base$ (%I (tuple%2./tuple%2/0 (%Poly%tuple%2. (core!option.Option./Some/0 (%Poly%core!option.Option.
                pte!
         )))))))
         (let
          ((pte$ (%Poly%main!definitions_t.PageTableEntry. (tuple%2./tuple%2/1 (%Poly%tuple%2. (
                core!option.Option./Some/0 (%Poly%core!option.Option. pte!)
          ))))))
          (let
           ((paddr$ (nClip (Add (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
                 (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                   (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                     pte$
                )))))
               ) (Sub (%I vaddr!) base$)
           ))))
           (let
            ((pmem_idx$ (main!spec_t.mem.word_index_spec.? (I paddr$))))
            (and
             (and
              (vstd!map_lib.impl&%0.contains_pair.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
               (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings
                 (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
                )
               ) (I base$) (Poly%main!definitions_t.PageTableEntry. pte$)
              )
              (main!definitions_t.between.? vaddr! (I base$) (I (nClip (Add base$ (main!definitions_t.MemRegion./MemRegion/size
                   (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                      (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                        pte$
             )))))))))))
             (ite
              (is-main!definitions_t.RWOp./Store (%Poly%main!definitions_t.RWOp. op!))
              (let
               ((new_value$ (main!definitions_t.RWOp./Store/new_value (%Poly%main!definitions_t.RWOp.
                   op!
               ))))
               (let
                ((result$ (main!definitions_t.RWOp./Store/result (%Poly%main!definitions_t.RWOp. op!))))
                (ite
                 (and
                  (and
                   (< pmem_idx$ (main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size
                     (%Poly%main!spec_t.hlspec.AbstractConstants. c!)
                   ))
                   (not (main!definitions_t.Flags./Flags/is_supervisor (%Poly%main!definitions_t.Flags.
                      (Poly%main!definitions_t.Flags. (main!definitions_t.PageTableEntry./PageTableEntry/flags
                        (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                          pte$
                  ))))))))
                  (main!definitions_t.Flags./Flags/is_writable (%Poly%main!definitions_t.Flags. (Poly%main!definitions_t.Flags.
                     (main!definitions_t.PageTableEntry./PageTableEntry/flags (%Poly%main!definitions_t.PageTableEntry.
                       (Poly%main!definitions_t.PageTableEntry. pte$)
                 ))))))
                 (and
                  (is-main!definitions_t.StoreResult./Ok (%Poly%main!definitions_t.StoreResult. (Poly%main!definitions_t.StoreResult.
                     result$
                  )))
                  (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
                     s2!
                    )
                   ) (%Poly%vstd!map.Map<nat./nat.>. (vstd!map.impl&%0.insert.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>.
                      (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
                        s1!
                      ))
                     ) (I vmem_idx$) (I new_value$)
                 ))))
                 (and
                  (is-main!definitions_t.StoreResult./Pagefault (%Poly%main!definitions_t.StoreResult.
                    (Poly%main!definitions_t.StoreResult. result$)
                  ))
                  (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
                     s2!
                    )
                   ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
                     s1!
              )))))))
              (let
               ((is_exec$ (main!definitions_t.RWOp./Load/is_exec (%Poly%main!definitions_t.RWOp. op!))))
               (let
                ((result$ (main!definitions_t.RWOp./Load/result (%Poly%main!definitions_t.RWOp. op!))))
                (and
                 (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
                    s2!
                   )
                  ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
                    s1!
                 )))
                 (ite
                  (and
                   (and
                    (< pmem_idx$ (main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size
                      (%Poly%main!spec_t.hlspec.AbstractConstants. c!)
                    ))
                    (not (main!definitions_t.Flags./Flags/is_supervisor (%Poly%main!definitions_t.Flags.
                       (Poly%main!definitions_t.Flags. (main!definitions_t.PageTableEntry./PageTableEntry/flags
                         (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                           pte$
                   ))))))))
                   (=>
                    is_exec$
                    (not (main!definitions_t.Flags./Flags/disable_execute (%Poly%main!definitions_t.Flags.
                       (Poly%main!definitions_t.Flags. (main!definitions_t.PageTableEntry./PageTableEntry/flags
                         (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                           pte$
                  )))))))))
                  (and
                   (is-main!definitions_t.LoadResult./Value (%Poly%main!definitions_t.LoadResult. (Poly%main!definitions_t.LoadResult.
                      result$
                   )))
                   (= (main!definitions_t.LoadResult./Value/0 (%Poly%main!definitions_t.LoadResult. (Poly%main!definitions_t.LoadResult.
                       result$
                     ))
                    ) (%I (vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
                        (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
                       )
                      ) (I vmem_idx$)
                  ))))
                  (is-main!definitions_t.LoadResult./Pagefault (%Poly%main!definitions_t.LoadResult.
                    (Poly%main!definitions_t.LoadResult. result$)
        ))))))))))))
        (and
         (and
          (not (vstd!set.impl&%0.contains.? $ NAT (Poly%vstd!set.Set<nat.>. (main!spec_t.hlspec.mem_domain_from_mappings.?
              (I (main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size (%Poly%main!spec_t.hlspec.AbstractConstants.
                 c!
               ))
              ) (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings
                (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
             )))
            ) (I vmem_idx$)
          ))
          (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
             s2!
            )
           ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
             s1!
         ))))
         (ite
          (is-main!definitions_t.RWOp./Store (%Poly%main!definitions_t.RWOp. op!))
          (let
           ((new_value$ (main!definitions_t.RWOp./Store/new_value (%Poly%main!definitions_t.RWOp.
               op!
           ))))
           (let
            ((result$ (main!definitions_t.RWOp./Store/result (%Poly%main!definitions_t.RWOp. op!))))
            (is-main!definitions_t.StoreResult./Pagefault (%Poly%main!definitions_t.StoreResult.
              (Poly%main!definitions_t.StoreResult. result$)
          ))))
          (let
           ((is_exec$ (main!definitions_t.RWOp./Load/is_exec (%Poly%main!definitions_t.RWOp. op!))))
           (let
            ((result$ (main!definitions_t.RWOp./Load/result (%Poly%main!definitions_t.RWOp. op!))))
            (is-main!definitions_t.LoadResult./Pagefault (%Poly%main!definitions_t.LoadResult.
              (Poly%main!definitions_t.LoadResult. result$)
    ))))))))))
    :pattern ((main!spec_t.hlspec.step_ReadWrite.? c! s1! s2! vaddr! op! pte!))
    :qid internal_main!spec_t.hlspec.step_ReadWrite.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::step_Map_enabled
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.step_Map_enabled.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.step_Map_enabled.)
  (forall ((map! Poly) (vaddr! Poly) (pte! Poly)) (!
    (= (main!spec_t.hlspec.step_Map_enabled.? map! vaddr! pte!) (and
      (and
       (and
        (and
         (main!definitions_t.aligned.? vaddr! (I (main!definitions_t.MemRegion./MemRegion/size
            (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
               (%Poly%main!definitions_t.PageTableEntry. pte!)
         ))))))
         (main!definitions_t.aligned.? (I (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
             (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
               (%Poly%main!definitions_t.PageTableEntry. pte!)
           ))))
          ) (I (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
             (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
               (%Poly%main!definitions_t.PageTableEntry. pte!)
        )))))))
        (main!definitions_t.candidate_mapping_in_bounds.? vaddr! pte!)
       )
       (or
        (or
         (= (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
            (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
              (%Poly%main!definitions_t.PageTableEntry. pte!)
           )))
          ) main!definitions_t.L3_ENTRY_SIZE.?
         )
         (= (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
            (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
              (%Poly%main!definitions_t.PageTableEntry. pte!)
           )))
          ) main!definitions_t.L2_ENTRY_SIZE.?
        ))
        (= (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
           (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
             (%Poly%main!definitions_t.PageTableEntry. pte!)
          )))
         ) main!definitions_t.L1_ENTRY_SIZE.?
      )))
      (not (main!definitions_t.candidate_mapping_overlaps_existing_pmem.? map! vaddr! pte!))
    ))
    :pattern ((main!spec_t.hlspec.step_Map_enabled.? map! vaddr! pte!))
    :qid internal_main!spec_t.hlspec.step_Map_enabled.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::step_Map
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.step_Map.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.step_Map.)
  (forall ((c! Poly) (s1! Poly) (s2! Poly) (vaddr! Poly) (pte! Poly) (result! Poly))
   (!
    (= (main!spec_t.hlspec.step_Map.? c! s1! s2! vaddr! pte! result!) (and
      (main!spec_t.hlspec.step_Map_enabled.? (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
        (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
          s1!
        ))
       ) vaddr! pte!
      )
      (ite
       (main!definitions_t.candidate_mapping_overlaps_existing_vmem.? (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
         (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
           s1!
         ))
        ) vaddr! pte!
       )
       (and
        (and
         (is-main!definitions_t.MapResult./ErrOverlap (%Poly%main!definitions_t.MapResult. result!))
         (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
            s2!
           )
          ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
            s1!
        ))))
        (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
           s2!
          )
         ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
           s1!
       ))))
       (and
        (and
         (and
          (is-main!definitions_t.MapResult./Ok (%Poly%main!definitions_t.MapResult. result!))
          (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
             s2!
            )
           ) (%Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (vstd!map.impl&%0.insert.?
             $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
              (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
                s1!
              ))
             ) vaddr! pte!
         ))))
         (forall ((idx$ Poly)) (!
           (=>
            (has_type idx$ NAT)
            (=>
             (vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>.
                (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
                  s1!
               )))
              ) idx$
             )
             (= (vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
                 (%Poly%main!spec_t.hlspec.AbstractVariables. s2!)
                )
               ) idx$
              ) (vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
                 (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
                )
               ) idx$
           ))))
           :pattern ((vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
               (%Poly%main!spec_t.hlspec.AbstractVariables. s2!)
              )
             ) idx$
           ))
           :pattern ((vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
               (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
              )
             ) idx$
           ))
           :qid user_main__spec_t__hlspec__step_Map_69
        )))
        (= (%Poly%vstd!set.Set<nat.>. (vstd!map.impl&%0.dom.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>.
            (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
              s2!
          ))))
         ) (main!spec_t.hlspec.mem_domain_from_mappings.? (I (main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size
            (%Poly%main!spec_t.hlspec.AbstractConstants. c!)
           )
          ) (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings
            (%Poly%main!spec_t.hlspec.AbstractVariables. s2!)
    ))))))))
    :pattern ((main!spec_t.hlspec.step_Map.? c! s1! s2! vaddr! pte! result!))
    :qid internal_main!spec_t.hlspec.step_Map.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::step_Unmap_enabled
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.step_Unmap_enabled.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.step_Unmap_enabled.)
  (forall ((vaddr! Poly)) (!
    (= (main!spec_t.hlspec.step_Unmap_enabled.? vaddr!) (and
      (main!definitions_t.between.? vaddr! (I main!definitions_t.PT_BOUND_LOW.?) (I main!definitions_t.PT_BOUND_HIGH.?))
      (or
       (or
        (main!definitions_t.aligned.? vaddr! (I main!definitions_t.L3_ENTRY_SIZE.?))
        (main!definitions_t.aligned.? vaddr! (I main!definitions_t.L2_ENTRY_SIZE.?))
       )
       (main!definitions_t.aligned.? vaddr! (I main!definitions_t.L1_ENTRY_SIZE.?))
    )))
    :pattern ((main!spec_t.hlspec.step_Unmap_enabled.? vaddr!))
    :qid internal_main!spec_t.hlspec.step_Unmap_enabled.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::step_Unmap
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.step_Unmap.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.step_Unmap.)
  (forall ((c! Poly) (s1! Poly) (s2! Poly) (vaddr! Poly) (result! Poly)) (!
    (= (main!spec_t.hlspec.step_Unmap.? c! s1! s2! vaddr! result!) (and
      (main!spec_t.hlspec.step_Unmap_enabled.? vaddr!)
      (ite
       (vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
         (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings
           (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
         ))
        ) vaddr!
       )
       (and
        (and
         (and
          (is-main!definitions_t.UnmapResult./Ok (%Poly%main!definitions_t.UnmapResult. result!))
          (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
             s2!
            )
           ) (%Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (vstd!map.impl&%0.remove.?
             $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
              (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
                s1!
              ))
             ) vaddr!
         ))))
         (= (%Poly%vstd!set.Set<nat.>. (vstd!map.impl&%0.dom.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>.
             (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
               s2!
           ))))
          ) (main!spec_t.hlspec.mem_domain_from_mappings.? (I (main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size
             (%Poly%main!spec_t.hlspec.AbstractConstants. c!)
            )
           ) (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings
             (%Poly%main!spec_t.hlspec.AbstractVariables. s2!)
        )))))
        (forall ((idx$ Poly)) (!
          (=>
           (has_type idx$ NAT)
           (=>
            (vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>.
               (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
                 s2!
              )))
             ) idx$
            )
            (= (vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
                (%Poly%main!spec_t.hlspec.AbstractVariables. s2!)
               )
              ) idx$
             ) (vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
                (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
               )
              ) idx$
          ))))
          :pattern ((vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
              (%Poly%main!spec_t.hlspec.AbstractVariables. s2!)
             )
            ) idx$
          ))
          :pattern ((vstd!map.impl&%0.index.? $ NAT $ NAT (Poly%vstd!map.Map<nat./nat.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem
              (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
             )
            ) idx$
          ))
          :qid user_main__spec_t__hlspec__step_Unmap_70
       )))
       (and
        (and
         (is-main!definitions_t.UnmapResult./ErrNoSuchMapping (%Poly%main!definitions_t.UnmapResult.
           result!
         ))
         (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
            s2!
           )
          ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings (%Poly%main!spec_t.hlspec.AbstractVariables.
            s1!
        ))))
        (= (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
           s2!
          )
         ) (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mem (%Poly%main!spec_t.hlspec.AbstractVariables.
           s1!
    )))))))
    :pattern ((main!spec_t.hlspec.step_Unmap.? c! s1! s2! vaddr! result!))
    :qid internal_main!spec_t.hlspec.step_Unmap.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::step_Resolve_enabled
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.step_Resolve_enabled.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.step_Resolve_enabled.)
  (forall ((vaddr! Poly)) (!
    (= (main!spec_t.hlspec.step_Resolve_enabled.? vaddr!) (main!definitions_t.aligned.?
      vaddr! (I 8)
    ))
    :pattern ((main!spec_t.hlspec.step_Resolve_enabled.? vaddr!))
    :qid internal_main!spec_t.hlspec.step_Resolve_enabled.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::step_Resolve
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.step_Resolve.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.step_Resolve.)
  (forall ((c! Poly) (s1! Poly) (s2! Poly) (vaddr! Poly) (result! Poly)) (!
    (= (main!spec_t.hlspec.step_Resolve.? c! s1! s2! vaddr! result!) (and
      (and
       (main!spec_t.hlspec.step_Resolve_enabled.? vaddr!)
       (= s2! s1!)
      )
      (ite
       (is-main!definitions_t.ResolveResult./Ok (%Poly%main!definitions_t.ResolveResult. result!))
       (let
        ((base$ (main!definitions_t.ResolveResult./Ok/0 (%Poly%main!definitions_t.ResolveResult.
            result!
        ))))
        (let
         ((pte$ (main!definitions_t.ResolveResult./Ok/1 (%Poly%main!definitions_t.ResolveResult.
             result!
         ))))
         (and
          (vstd!map_lib.impl&%0.contains_pair.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
           (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings
             (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
            )
           ) (I base$) (Poly%main!definitions_t.PageTableEntry. pte$)
          )
          (main!definitions_t.between.? vaddr! (I base$) (I (nClip (Add base$ (main!definitions_t.MemRegion./MemRegion/size
               (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                  (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                    pte$
       )))))))))))))
       (let
        ((vmem_idx$ (main!spec_t.mem.word_index_spec.? vaddr!)))
        (not (vstd!set.impl&%0.contains.? $ NAT (Poly%vstd!set.Set<nat.>. (main!spec_t.hlspec.mem_domain_from_mappings.?
            (I (main!spec_t.hlspec.AbstractConstants./AbstractConstants/phys_mem_size (%Poly%main!spec_t.hlspec.AbstractConstants.
               c!
             ))
            ) (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. (main!spec_t.hlspec.AbstractVariables./AbstractVariables/mappings
              (%Poly%main!spec_t.hlspec.AbstractVariables. s1!)
           )))
          ) (I vmem_idx$)
    ))))))
    :pattern ((main!spec_t.hlspec.step_Resolve.? c! s1! s2! vaddr! result!))
    :qid internal_main!spec_t.hlspec.step_Resolve.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::step_Stutter
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.step_Stutter.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.step_Stutter.)
  (forall ((c! Poly) (s1! Poly) (s2! Poly)) (!
    (= (main!spec_t.hlspec.step_Stutter.? c! s1! s2!) (= s1! s2!))
    :pattern ((main!spec_t.hlspec.step_Stutter.? c! s1! s2!))
    :qid internal_main!spec_t.hlspec.step_Stutter.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::next_step
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.next_step.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.next_step.)
  (forall ((c! Poly) (s1! Poly) (s2! Poly) (step! Poly)) (!
    (= (main!spec_t.hlspec.next_step.? c! s1! s2! step!) (ite
      (is-main!spec_t.hlspec.AbstractStep./ReadWrite (%Poly%main!spec_t.hlspec.AbstractStep.
        step!
      ))
      (let
       ((vaddr$ (main!spec_t.hlspec.AbstractStep./ReadWrite/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
           step!
       ))))
       (let
        ((op$ (main!spec_t.hlspec.AbstractStep./ReadWrite/op (%Poly%main!spec_t.hlspec.AbstractStep.
            step!
        ))))
        (let
         ((pte$ (main!spec_t.hlspec.AbstractStep./ReadWrite/pte (%Poly%main!spec_t.hlspec.AbstractStep.
             step!
         ))))
         (main!spec_t.hlspec.step_ReadWrite.? c! s1! s2! (I vaddr$) (Poly%main!definitions_t.RWOp.
           op$
          ) (Poly%core!option.Option. pte$)
      ))))
      (ite
       (is-main!spec_t.hlspec.AbstractStep./Map (%Poly%main!spec_t.hlspec.AbstractStep. step!))
       (let
        ((vaddr$ (main!spec_t.hlspec.AbstractStep./Map/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
            step!
        ))))
        (let
         ((pte$ (main!spec_t.hlspec.AbstractStep./Map/pte (%Poly%main!spec_t.hlspec.AbstractStep.
             step!
         ))))
         (let
          ((result$ (main!spec_t.hlspec.AbstractStep./Map/result (%Poly%main!spec_t.hlspec.AbstractStep.
              step!
          ))))
          (main!spec_t.hlspec.step_Map.? c! s1! s2! (I vaddr$) (Poly%main!definitions_t.PageTableEntry.
            pte$
           ) (Poly%main!definitions_t.MapResult. result$)
       ))))
       (ite
        (is-main!spec_t.hlspec.AbstractStep./Unmap (%Poly%main!spec_t.hlspec.AbstractStep.
          step!
        ))
        (let
         ((vaddr$ (main!spec_t.hlspec.AbstractStep./Unmap/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
             step!
         ))))
         (let
          ((result$ (main!spec_t.hlspec.AbstractStep./Unmap/result (%Poly%main!spec_t.hlspec.AbstractStep.
              step!
          ))))
          (main!spec_t.hlspec.step_Unmap.? c! s1! s2! (I vaddr$) (Poly%main!definitions_t.UnmapResult.
            result$
        ))))
        (ite
         (is-main!spec_t.hlspec.AbstractStep./Resolve (%Poly%main!spec_t.hlspec.AbstractStep.
           step!
         ))
         (let
          ((vaddr$ (main!spec_t.hlspec.AbstractStep./Resolve/vaddr (%Poly%main!spec_t.hlspec.AbstractStep.
              step!
          ))))
          (let
           ((result$ (main!spec_t.hlspec.AbstractStep./Resolve/result (%Poly%main!spec_t.hlspec.AbstractStep.
               step!
           ))))
           (main!spec_t.hlspec.step_Resolve.? c! s1! s2! (I vaddr$) (Poly%main!definitions_t.ResolveResult.
             result$
         ))))
         (main!spec_t.hlspec.step_Stutter.? c! s1! s2!)
    )))))
    :pattern ((main!spec_t.hlspec.next_step.? c! s1! s2! step!))
    :qid internal_main!spec_t.hlspec.next_step.?_definition
))))

;; Function-Axioms main::spec_t::hlspec::next
(assert
 (fuel_bool_default fuel%main!spec_t.hlspec.next.)
)
(assert
 (=>
  (fuel_bool fuel%main!spec_t.hlspec.next.)
  (forall ((c! Poly) (s1! Poly) (s2! Poly)) (!
    (= (main!spec_t.hlspec.next.? c! s1! s2!) (exists ((step$ Poly)) (!
       (and
        (has_type step$ TYPE%main!spec_t.hlspec.AbstractStep.)
        (main!spec_t.hlspec.next_step.? c! s1! s2! step$)
       )
       :pattern ((main!spec_t.hlspec.next_step.? c! s1! s2! step$))
       :qid user_main__spec_t__hlspec__next_71
    )))
    :pattern ((main!spec_t.hlspec.next.? c! s1! s2!))
    :qid internal_main!spec_t.hlspec.next.?_definition
))))

;; Function-Specs main::spec_t::hlspec::lemma_mem_domain_from_mappings
(declare-fun req%main!spec_t.hlspec.lemma_mem_domain_from_mappings. (Int vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
  Int main!definitions_t.PageTableEntry.
 ) Bool
)
(declare-const %%global_location_label%%52 Bool)
(assert
 (forall ((phys_mem_size! Int) (mappings! vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.)
   (base! Int) (pte! main!definitions_t.PageTableEntry.)
  ) (!
   (= (req%main!spec_t.hlspec.lemma_mem_domain_from_mappings. phys_mem_size! mappings!
     base! pte!
    ) (=>
     %%global_location_label%%52
     (not (vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
        (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
       ) (I base!)
   ))))
   :pattern ((req%main!spec_t.hlspec.lemma_mem_domain_from_mappings. phys_mem_size! mappings!
     base! pte!
   ))
   :qid internal_req__main!spec_t.hlspec.lemma_mem_domain_from_mappings._definition
)))
(declare-fun ens%main!spec_t.hlspec.lemma_mem_domain_from_mappings. (Int vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
  Int main!definitions_t.PageTableEntry.
 ) Bool
)
(assert
 (forall ((phys_mem_size! Int) (mappings! vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.)
   (base! Int) (pte! main!definitions_t.PageTableEntry.)
  ) (!
   (= (ens%main!spec_t.hlspec.lemma_mem_domain_from_mappings. phys_mem_size! mappings!
     base! pte!
    ) (and
     (forall ((word_idx$ Poly)) (!
       (=>
        (has_type word_idx$ NAT)
        (=>
         (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
          (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
         )
         (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
          (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
            mappings!
           ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
       ))))
       :pattern ((main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!)
         word_idx$ (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
          (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!) (I base!)
          (Poly%main!definitions_t.PageTableEntry. pte!)
       )))
       :qid user_main__spec_t__hlspec__lemma_mem_domain_from_mappings_72
     ))
     (forall ((word_idx$ Poly)) (!
       (=>
        (has_type word_idx$ NAT)
        (=>
         (and
          (not (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
            (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
          ))
          (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
           (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
             mappings!
            ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
         )))
         (main!definitions_t.between.? (I (nClip (Mul (%I word_idx$) main!definitions_t.WORD_SIZE.?)))
          (I base!) (I (nClip (Add base! (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
               (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                 (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                   pte!
       ))))))))))))
       :pattern ((main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!)
         word_idx$ (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
          (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!) (I base!)
          (Poly%main!definitions_t.PageTableEntry. pte!)
       )))
       :qid user_main__spec_t__hlspec__lemma_mem_domain_from_mappings_73
   ))))
   :pattern ((ens%main!spec_t.hlspec.lemma_mem_domain_from_mappings. phys_mem_size! mappings!
     base! pte!
   ))
   :qid internal_ens__main!spec_t.hlspec.lemma_mem_domain_from_mappings._definition
)))

;; Function-Def main::spec_t::hlspec::lemma_mem_domain_from_mappings
;; page-table/spec_t/hlspec.rs:65:1: 65:132 (#0)
;;(push)
 (declare-const phys_mem_size! Int)
 (declare-const mappings! vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.)
 (declare-const base! Int)
 (declare-const pte! main!definitions_t.PageTableEntry.)
 (declare-const word_idx@ Poly)
 (declare-const tmp%1 Bool)
 (declare-const vaddr@ Int)
 (declare-const tmp%%@ tuple%2.)
 (declare-const base2@ Int)
 (declare-const pte2@ main!definitions_t.PageTableEntry.)
 (declare-const word_idx$1@ Poly)
 (declare-const tmp%2 Bool)
 (declare-const tmp%3 Bool)
 (declare-const tmp%4 Bool)
 (declare-const tmp%5 Bool)
 (declare-const tmp%6 Bool)
 (declare-const vaddr$1@ Int)
 (declare-const tmp%%$1@ tuple%2.)
 (declare-const base2$1@ Int)
 (declare-const pte2$1@ main!definitions_t.PageTableEntry.)
 (assert
  fuel_defaults
 )
 (assert
  (<= 0 phys_mem_size!)
 )
 (assert
  (<= 0 base!)
 )
 (assert
  (has_type (Poly%main!definitions_t.PageTableEntry. pte!) TYPE%main!definitions_t.PageTableEntry.)
 )
 (assert
  (not (vstd!set.impl&%0.contains.? $ NAT (vstd!map.impl&%0.dom.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
     (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
    ) (I base!)
 )))
 (declare-fun %%choose%%1 (Type Type Int Dcr Type Dcr Type Poly Poly Int Dcr Type Dcr
   Type Poly
  ) Poly
 )
 (assert
  (forall ((%%hole%%0 Type) (%%hole%%1 Type) (%%hole%%2 Int) (%%hole%%3 Dcr) (%%hole%%4
     Type
    ) (%%hole%%5 Dcr) (%%hole%%6 Type) (%%hole%%7 Poly) (%%hole%%8 Poly) (%%hole%%9 Int)
    (%%hole%%10 Dcr) (%%hole%%11 Type) (%%hole%%12 Dcr) (%%hole%%13 Type) (%%hole%%14
     Poly
    )
   ) (!
    (=>
     (exists ((base$ Poly) (pte$ Poly)) (!
       (and
        (has_type base$ %%hole%%0)
        (has_type pte$ %%hole%%1)
        (let
         ((paddr$ (nClip (Add (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
               (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                 (%Poly%main!definitions_t.PageTableEntry. pte$)
              )))
             ) (Sub %%hole%%2 (%I base$))
         ))))
         (let
          ((pmem_idx$ (main!spec_t.mem.word_index_spec.? (I paddr$))))
          (and
           (and
            (vstd!map_lib.impl&%0.contains_pair.? %%hole%%3 %%hole%%4 %%hole%%5 %%hole%%6 %%hole%%7
             base$ pte$
            )
            (main!definitions_t.between.? %%hole%%8 base$ (I (nClip (Add (%I base$) (main!definitions_t.MemRegion./MemRegion/size
                 (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                    (%Poly%main!definitions_t.PageTableEntry. pte$)
           )))))))))
           (< pmem_idx$ %%hole%%9)
       ))))
       :pattern ((vstd!map_lib.impl&%0.contains_pair.? %%hole%%10 %%hole%%11 %%hole%%12 %%hole%%13
         %%hole%%14 base$ pte$
       ))
       :qid user_main__spec_t__hlspec__lemma_mem_domain_from_mappings_76
     ))
     (exists ((base$ Poly) (pte$ Poly)) (!
       (and
        (and
         (has_type base$ %%hole%%0)
         (has_type pte$ %%hole%%1)
         (let
          ((paddr$ (nClip (Add (main!definitions_t.MemRegion./MemRegion/base (%Poly%main!definitions_t.MemRegion.
                (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                  (%Poly%main!definitions_t.PageTableEntry. pte$)
               )))
              ) (Sub %%hole%%2 (%I base$))
          ))))
          (let
           ((pmem_idx$ (main!spec_t.mem.word_index_spec.? (I paddr$))))
           (and
            (and
             (vstd!map_lib.impl&%0.contains_pair.? %%hole%%3 %%hole%%4 %%hole%%5 %%hole%%6 %%hole%%7
              base$ pte$
             )
             (main!definitions_t.between.? %%hole%%8 base$ (I (nClip (Add (%I base$) (main!definitions_t.MemRegion./MemRegion/size
                  (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                     (%Poly%main!definitions_t.PageTableEntry. pte$)
            )))))))))
            (< pmem_idx$ %%hole%%9)
        ))))
        (= (%%choose%%1 %%hole%%0 %%hole%%1 %%hole%%2 %%hole%%3 %%hole%%4 %%hole%%5 %%hole%%6
          %%hole%%7 %%hole%%8 %%hole%%9 %%hole%%10 %%hole%%11 %%hole%%12 %%hole%%13 %%hole%%14
         ) (Poly%tuple%2. (tuple%2./tuple%2 base$ pte$))
       ))
       :pattern ((vstd!map_lib.impl&%0.contains_pair.? %%hole%%10 %%hole%%11 %%hole%%12 %%hole%%13
         %%hole%%14 base$ pte$
    )))))
    :pattern ((%%choose%%1 %%hole%%0 %%hole%%1 %%hole%%2 %%hole%%3 %%hole%%4 %%hole%%5
      %%hole%%6 %%hole%%7 %%hole%%8 %%hole%%9 %%hole%%10 %%hole%%11 %%hole%%12 %%hole%%13
      %%hole%%14
 )))))
 (declare-const %%switch_label%%0 Bool)
 (declare-const %%switch_label%%1 Bool)
 ;; assertion failed
 (declare-const %%location_label%%0 Bool)
 ;; assertion failed
 (declare-const %%location_label%%1 Bool)
 ;; assertion failed
 (declare-const %%location_label%%2 Bool)
 ;; assertion failed
 (declare-const %%location_label%%3 Bool)
 ;; assertion failed
 (declare-const %%location_label%%4 Bool)
 ;; assertion failed
 (declare-const %%location_label%%5 Bool)
 ;; assertion failed
 (declare-const %%location_label%%6 Bool)
 ;; assertion failed
 (declare-const %%location_label%%7 Bool)
 ;; assertion failed
 (declare-const %%location_label%%8 Bool)
 ;; postcondition not satisfied
 (declare-const %%location_label%%9 Bool)
 ;; postcondition not satisfied
 (declare-const %%location_label%%10 Bool)
 (declare-const %%query%% Bool)
 (assert
  (=>
   %%query%%
   (not (and
     (=>
      (has_type word_idx@ NAT)
      (=>
       (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx@
        (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
       )
       (=>
        (= vaddr@ (nClip (Mul (%I word_idx@) main!definitions_t.WORD_SIZE.?)))
        (=>
         (= tmp%%@ (%Poly%tuple%2. (as_type (%%choose%%1 NAT TYPE%main!definitions_t.PageTableEntry.
             vaddr@ $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
              mappings!
             ) (I vaddr@) phys_mem_size! $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
              mappings!
             )
            ) (TYPE%tuple%2. $ NAT $ TYPE%main!definitions_t.PageTableEntry.)
         )))
         (=>
          (= base2@ (%I (tuple%2./tuple%2/0 (%Poly%tuple%2. (Poly%tuple%2. tmp%%@)))))
          (=>
           (= pte2@ (%Poly%main!definitions_t.PageTableEntry. (tuple%2./tuple%2/1 (%Poly%tuple%2.
               (Poly%tuple%2. tmp%%@)
           ))))
           (=>
            (= tmp%1 (vstd!map_lib.impl&%0.contains_pair.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
              (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
                mappings!
               ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
              ) (I base2@) (Poly%main!definitions_t.PageTableEntry. pte2@)
            ))
            (and
             (=>
              %%location_label%%0
              tmp%1
             )
             (=>
              tmp%1
              (=>
               %%location_label%%1
               (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx@
                (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
                  mappings!
                 ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
     ))))))))))))
     (=>
      (forall ((word_idx$ Poly)) (!
        (=>
         (has_type word_idx$ NAT)
         (=>
          (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
           (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
          )
          (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
           (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
             mappings!
            ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
        ))))
        :pattern ((main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!)
          word_idx$ (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
           (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!) (I base!)
           (Poly%main!definitions_t.PageTableEntry. pte!)
        )))
        :qid user_main__spec_t__hlspec__lemma_mem_domain_from_mappings_77
      ))
      (and
       (=>
        (has_type word_idx$1@ NAT)
        (=>
         (and
          (not (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$1@
            (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
          ))
          (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$1@
           (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
             mappings!
            ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
         )))
         (=>
          (= vaddr$1@ (nClip (Mul (%I word_idx$1@) main!definitions_t.WORD_SIZE.?)))
          (=>
           (= tmp%%$1@ (%Poly%tuple%2. (as_type (%%choose%%1 NAT TYPE%main!definitions_t.PageTableEntry.
               vaddr$1@ $ NAT $ TYPE%main!definitions_t.PageTableEntry. (vstd!map.impl&%0.insert.?
                $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
                 mappings!
                ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
               ) (I vaddr$1@) phys_mem_size! $ NAT $ TYPE%main!definitions_t.PageTableEntry. (vstd!map.impl&%0.insert.?
                $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
                 mappings!
                ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
               )
              ) (TYPE%tuple%2. $ NAT $ TYPE%main!definitions_t.PageTableEntry.)
           )))
           (=>
            (= base2$1@ (%I (tuple%2./tuple%2/0 (%Poly%tuple%2. (Poly%tuple%2. tmp%%$1@)))))
            (=>
             (= pte2$1@ (%Poly%main!definitions_t.PageTableEntry. (tuple%2./tuple%2/1 (%Poly%tuple%2.
                 (Poly%tuple%2. tmp%%$1@)
             ))))
             (=>
              (= tmp%2 (vstd!map_lib.impl&%0.contains_pair.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
                (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
                  mappings!
                 ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
                ) (I base2$1@) (Poly%main!definitions_t.PageTableEntry. pte2$1@)
              ))
              (and
               (=>
                %%location_label%%2
                tmp%2
               )
               (=>
                tmp%2
                (=>
                 (= tmp%3 (main!definitions_t.between.? (I vaddr$1@) (I base2$1@) (I (nClip (Add base2$1@
                      (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
                        (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                          (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                            pte2$1@
                 )))))))))))
                 (and
                  (=>
                   %%location_label%%3
                   tmp%3
                  )
                  (=>
                   tmp%3
                   (or
                    (and
                     (=>
                      (not (main!definitions_t.between.? (I vaddr$1@) (I base!) (I (nClip (Add base! (main!definitions_t.MemRegion./MemRegion/size
                            (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                               (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                                 pte!
                      )))))))))))
                      (=>
                       (= tmp%4 (or
                         (not (= base2$1@ base!))
                         (not (= pte2$1@ pte!))
                       ))
                       (and
                        (=>
                         %%location_label%%4
                         tmp%4
                        )
                        (=>
                         tmp%4
                         (or
                          (and
                           (=>
                            (not (= base2$1@ base!))
                            (=>
                             (= tmp%5 (vstd!map_lib.impl&%0.contains_pair.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
                               (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!) (I base2$1@)
                               (Poly%main!definitions_t.PageTableEntry. pte2$1@)
                             ))
                             (and
                              (=>
                               %%location_label%%5
                               tmp%5
                              )
                              (=>
                               tmp%5
                               (=>
                                (= tmp%6 (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!)
                                  word_idx$1@ (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
                                ))
                                (and
                                 (=>
                                  %%location_label%%6
                                  tmp%6
                                 )
                                 (=>
                                  tmp%6
                                  %%switch_label%%1
                           )))))))
                           (=>
                            (not (not (= base2$1@ base!)))
                            %%switch_label%%1
                          ))
                          (and
                           (not %%switch_label%%1)
                           (=>
                            %%location_label%%7
                            false
                     )))))))
                     (=>
                      (not (not (main!definitions_t.between.? (I vaddr$1@) (I base!) (I (nClip (Add base! (main!definitions_t.MemRegion./MemRegion/size
                             (%Poly%main!definitions_t.MemRegion. (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                                (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                                  pte!
                      ))))))))))))
                      %%switch_label%%0
                    ))
                    (and
                     (not %%switch_label%%0)
                     (=>
                      %%location_label%%8
                      (main!definitions_t.between.? (I (nClip (Mul (%I word_idx$1@) main!definitions_t.WORD_SIZE.?)))
                       (I base!) (I (nClip (Add base! (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
                            (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                              (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                                pte!
       )))))))))))))))))))))))))
       (=>
        (forall ((word_idx$ Poly)) (!
          (=>
           (has_type word_idx$ NAT)
           (=>
            (and
             (not (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
               (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
             ))
             (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
              (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
                mappings!
               ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
            )))
            (main!definitions_t.between.? (I (nClip (Mul (%I word_idx$) main!definitions_t.WORD_SIZE.?)))
             (I base!) (I (nClip (Add base! (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
                  (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                    (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                      pte!
          ))))))))))))
          :pattern ((main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!)
            word_idx$ (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
             (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!) (I base!)
             (Poly%main!definitions_t.PageTableEntry. pte!)
          )))
          :qid user_main__spec_t__hlspec__lemma_mem_domain_from_mappings_79
        ))
        (and
         (=>
          %%location_label%%9
          (forall ((word_idx$ Poly)) (!
            (=>
             (has_type word_idx$ NAT)
             (=>
              (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
               (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
              )
              (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
               (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
                 mappings!
                ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
            ))))
            :pattern ((main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!)
              word_idx$ (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
               (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!) (I base!)
               (Poly%main!definitions_t.PageTableEntry. pte!)
            )))
            :qid user_main__spec_t__hlspec__lemma_mem_domain_from_mappings_74
         )))
         (=>
          %%location_label%%10
          (forall ((word_idx$ Poly)) (!
            (=>
             (has_type word_idx$ NAT)
             (=>
              (and
               (not (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
                 (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!)
               ))
               (main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!) word_idx$
                (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry. (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>.
                  mappings!
                 ) (I base!) (Poly%main!definitions_t.PageTableEntry. pte!)
              )))
              (main!definitions_t.between.? (I (nClip (Mul (%I word_idx$) main!definitions_t.WORD_SIZE.?)))
               (I base!) (I (nClip (Add base! (main!definitions_t.MemRegion./MemRegion/size (%Poly%main!definitions_t.MemRegion.
                    (Poly%main!definitions_t.MemRegion. (main!definitions_t.PageTableEntry./PageTableEntry/frame
                      (%Poly%main!definitions_t.PageTableEntry. (Poly%main!definitions_t.PageTableEntry.
                        pte!
            ))))))))))))
            :pattern ((main!spec_t.hlspec.mem_domain_from_mappings_contains.? (I phys_mem_size!)
              word_idx$ (vstd!map.impl&%0.insert.? $ NAT $ TYPE%main!definitions_t.PageTableEntry.
               (Poly%vstd!map.Map<nat./main!definitions_t.PageTableEntry.>. mappings!) (I base!)
               (Poly%main!definitions_t.PageTableEntry. pte!)
            )))
            :qid user_main__spec_t__hlspec__lemma_mem_domain_from_mappings_75
 )))))))))))
 (get-info :version)
 (assert
  %%query%%
 )
 (check-sat)
