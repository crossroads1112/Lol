{-|
Module      : Crypto.Lol.Applications.Examples.HomomPRFParams
Description : Parameters for homomorphic PRF.
Copyright   : (c) Eric Crockett, 2011-2017
                  Chris Peikert, 2011-2017
License     : GPL-3
Maintainer  : ecrockett0@email.com
Stability   : experimental
Portability : POSIX

Parameters for homomorphic PRF.
-}

{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE PolyKinds     #-}
{-# LANGUAGE TypeOperators #-}

module Crypto.Lol.Applications.Examples.HomomPRFParams (RngList, Zq, ZQSeq, ZP, ZQ, KSGad, PRFGad, H0, H1, H2, H3, H4, H5) where

import Crypto.Lol
import Crypto.Lol.Types

type H0 = F128
type H1 = F64 * F7
type H2 = F32 * F7 * F13
type H3 = F8 * F5 * F7 * F13
type H4 = F4 * F3 * F5 * F7 * F13
type H5 = F9 * F5 * F7 * F13
type H0' = H0 * F7 * F13
type H1' = H1 * F13
type H2' = H2
type H3' = H3
type H4' = H4
type H5' = H5
type RngList = '[ '(H0,H0'), '(H1,H1'), '(H2,H2'), '(H3,H3'), '(H4,H4'), '(H5,H5') ]

type Zq (q :: k) = ZqBasic q Int64

type ZQ1 = Zq 1520064001
type ZQ2 = (Zq 3144961, ZQ1)
type ZQ3 = (Zq 5241601, ZQ2)
type ZQ4 = (Zq 7338241, ZQ3)
type ZQ5 = (Zq 1522160641, ZQ4)
type ZQ6 = (Zq 1529498881, ZQ5)
type ZQSeq = '[ZQ6, ZQ5, ZQ4, ZQ3, ZQ2, ZQ1]

type ZP = Zq PP16
type ZQ = ZQ5 -- if p=2^k, choose ZQ[k+1]

-- these need not be the same
type KSGad = TrivGad
type PRFGad = TrivGad