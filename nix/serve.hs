{-# LANGUAGE OverloadedStrings #-}

-- | Serves the site on localhost for `nix run`: serve DIRECTORY [PORT]
module Main (main) where

import Network.Wai.Application.Static (defaultFileServerSettings, ssMaxAge, staticApp)
import Network.Wai.Handler.Warp (defaultSettings, runSettings, setHost, setPort)
import System.Environment (getArgs)
import WaiAppStatic.Types (MaxAge (NoStore))

main :: IO ()
main = do
  args <- getArgs
  (directory, port) <- case args of
    [directory] -> pure (directory, 8000)
    [directory, port] -> pure (directory, read port)
    _ -> fail "usage: serve DIRECTORY [PORT]"
  putStrLn ("Serving on http://localhost:" <> show port)
  -- no-store, because every file in the Nix store has the same date (1970),
  -- so a browser that caches them never notices a new build.
  runSettings (setHost "127.0.0.1" (setPort port defaultSettings)) $
    staticApp (defaultFileServerSettings directory){ssMaxAge = NoStore}
