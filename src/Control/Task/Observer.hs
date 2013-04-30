{-# LANGUAGE DeriveDataTypeable #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett 2013
-- License   :  BSD3
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable
--
--------------------------------------------------------------------
module Control.Task.Observer
  ( Observer(..)
  , foreach
  ) where

import Control.Exception
import Control.Monad.IO.Class
import Control.Task.Monad
import Data.Functor
import Data.Functor.Contravariant
import Data.Monoid
import Data.Typeable

-- $setup
-- >>> :load Control.Task

infixl 1 !

data Observer a = Observer
  { (!) :: a -> Task ()
  , kill :: SomeException -> Task ()
  , complete :: Task ()
  } deriving Typeable

instance Contravariant Observer where
  contramap g (Observer f h c) = Observer (f . g) h c
  {-# INLINE contramap #-}

instance Monoid (Observer a) where
  mempty = Observer (\_ -> return ()) (liftIO . throwIO) (return ())
  {-# INLINE mempty #-}
  p `mappend` q = Observer
    (\a -> do spawn (p ! a); q ! a)
    (\e -> kill p e |>> kill q e)
    (complete p |>> complete q)
  {-# INLINE mappend #-}

-- | Perform an action for each

-- >>> run $  subscribe (observe [1..10]) $ foreach (liftIO . print)
-- 1
-- 2
-- 3
-- 4
-- 5
-- 6
-- 7
-- 8
-- 9
-- 10
foreach :: (a -> Task b) -> Observer a
foreach t = Observer (\a -> () <$ t a) (\_ -> return ()) (return ())
{-# INLINE foreach #-}
