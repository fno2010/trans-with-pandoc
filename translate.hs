#!/usr/bin/env runhaskell
-- translate.hs
import System.Environment
import System.IO
import Text.Pandoc.JSON
import Text.Pandoc (readMarkdown, def)

doRead :: String -> Pandoc
doRead = readMarkdown def

doExtract :: Pandoc -> [Block]
doExtract (Pandoc meta blocks) = blocks

doTranslate :: String -> Block -> [Block]
doTranslate "" x = [x]
doTranslate lang cb@(CodeBlock (id, classes, namevals) contents)
  | elem ("trans", lang) namevals        = doExtract $ doRead contents
  | lookup "trans" namevals /= Just lang = [Null]
  | otherwise                            = [cb]
doTranslate lang x = [x]

main :: IO ()
main = do
  args <- getArgs
  case args of
    [lang] -> toJSONFilter $ doTranslate lang
    _      -> do
      putStrLn "Usage: ./translate.hs lang"
      putStrLn "\tlang\t-\ta special language."
      toJSONFilter $ doTranslate ""
