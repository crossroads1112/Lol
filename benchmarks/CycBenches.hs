{-# LANGUAGE ConstraintKinds, NoImplicitPrelude, RebindableSyntax, FlexibleContexts, RankNTypes,
             DataKinds, TypeOperators, TypeFamilies, PolyKinds, KindSignatures #-}


module CycBenches (cycBenches) where

import Control.Applicative
import Control.Monad.Random

import Crypto.Lol

import Criterion
import Utils

cycBenches :: (MonadRandom rnd) => rnd Benchmark
cycBenches = bgroupRnd "Cyc"
  [bgroupRnd "CRT + *" $ groupC $ wrap2Arg bench_mulPow,
   bgroupRnd "*" $ groupC $ wrap2Arg bench_mul,
   bgroupRnd "crt" $ groupC $ wrap1Arg bench_crt,
   bgroupRnd "crtInv" $ groupC $ wrap1Arg bench_crtInv]
   -- sanity checks
   --bgroupRnd "^2" $ groupC $ wrap1Arg bench_sq,             -- should take same as bench_mul
   --bgroupRnd "id2" $ groupC $ wrap1Arg bench_advisePowPow,] -- should take a few nanoseconds: this is a no-op

-- convert both arguments to CRT basis, then multiply them coefficient-wise
bench_mulPow :: (CElt t r, Fact m) => Cyc t m r -> Cyc t m r -> Benchmarkable
bench_mulPow a b = 
  let a' = advisePow a
      b' = advisePow b
  in nf (a' *) b'

-- no CRT conversion, just coefficient-wise multiplication
bench_mul :: (CElt t r, Fact m) => Cyc t m r -> Cyc t m r -> Benchmarkable
bench_mul a b = 
  let a' = adviseCRT a
      b' = adviseCRT b
  in nf (a *) b

-- convert input from Pow basis to CRT basis
bench_crt :: (CElt t r, Fact m) => Cyc t m r -> Benchmarkable
bench_crt x = let y = advisePow x in nf adviseCRT y

-- convert input from CRT basis to Pow basis
bench_crtInv :: (CElt t r, Fact m) => Cyc t m r -> Benchmarkable
bench_crtInv x = let y = adviseCRT x in nf advisePow y

{-
-- sanity check: this test should take the same amount of time as bench_mul
-- if it takes less, then random element generation is being counted!
bench_sq :: (CElt t r, Fact m) => Cyc t m r -> Benchmarkable
bench_sq a = nf (a *) a

-- sanity check: this should be a no-op
bench_advisePowPow :: (CElt t r, Fact m) => Cyc t m r -> Benchmarkable
bench_advisePowPow x = let y = advisePow x in nf advisePow y
-}


type BasicCtx t m r = (CElt t r, Fact m)

wrap1Arg :: (BasicCtx t m r, MonadRandom rnd) 
  => (Cyc t m r -> Benchmarkable) -> Proxy t -> Proxy '(m,r) -> String -> rnd Benchmark
wrap1Arg f _ _ str = (bench str) <$> (genArgs f)

wrap2Arg :: (BasicCtx t m r, MonadRandom rnd) 
  => (Cyc t m r -> Cyc t m r -> Benchmarkable) -> Proxy t -> Proxy '(m,r) -> String -> rnd Benchmark
wrap2Arg f _ _ str = (bench str) <$> (genArgs f)

groupC :: (MonadRandom rnd) =>
  (forall t m m' r . 
       (BasicCtx t m r) 
       => Proxy t 
          -> Proxy '(m,r)
          -> String
          -> rnd Benchmark)
  -> [rnd Benchmark]
groupC f =
  [--bgroupRnd "Cyc CT" $ groupMR (f (Proxy::Proxy CT))]
   bgroupRnd "Cyc RT" $ groupMR (f (Proxy::Proxy RT))]

data a ** b

type family Zq (a :: k) :: * where
  Zq (a ** b) = (Zq a, Zq b)
  Zq q = (ZqBasic q Int64)


groupMR :: (MonadRandom rnd) =>
  (forall m r . (CElt CT r, CElt RT r, Fact m) => Proxy '(m, r) -> String -> rnd Benchmark) 
  -> [rnd Benchmark]
groupMR f = 
  [f (Proxy::Proxy '(F128, Zq 257)) "F128/Q257",
   f (Proxy::Proxy '(PToF Prime281, Zq 563)) "F281/Q563",
   f (Proxy::Proxy '(F32 * F9, Zq 512)) "F288/Q512",
   f (Proxy::Proxy '(F32 * F9, Zq 577)) "F288/Q577",
   f (Proxy::Proxy '(F32 * F9, Zq (577 ** 1153))) "F288/Q577*1153",
   f (Proxy::Proxy '(F32 * F9, Zq (577 ** 1153 ** 2017))) "F288/Q577*1153*2017",
   f (Proxy::Proxy '(F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593))) "F288/Q577*1153*2017*2593",
   f (Proxy::Proxy '(F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593 ** 3169))) "F288/Q577*1153*2017*2593*3619",
   f (Proxy::Proxy '(F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593 ** 3169 ** 3457))) "F288/Q577*1153*2017*2593*3619*3457",
   f (Proxy::Proxy '(F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593 ** 3169 ** 3457 ** 6337))) "F288/Q577*1153*2017*2593*3619*3457*6337",
   f (Proxy::Proxy '(F32 * F9, Zq (577 ** 1153 ** 2017 ** 2593 ** 3169 ** 3457 ** 6337 ** 7489))) "F288/Q577*1153*2017*2593*3619*3457*6337*7489"]
   f (Proxy::Proxy '(F32 * F9 * F25, Zq 14401)) "F7200/Q14401"]
