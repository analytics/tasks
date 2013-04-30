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
module Control.Task.Subscription
  ( Subscription(..)
  ) where

import Control.Task.Monad
import Data.Monoid
import Data.Typeable

-- Like in real life, cancelling a subscription may not stop it from sending you stuff immediately!
newtype Subscription = Subscription { cancel :: Task () }
  deriving Typeable

instance Monoid Subscription where
  mempty = Subscription $ return ()
  Subscription a `mappend` Subscription b = Subscription (a |>> b)
