module MyXML
( fileParse
  )where

import Text.Parsec
import Types
-- import Text.Parsec (<|>)
-- import Control.Applicative hiding (<|>)



fileParse::Parsec String () Root
fileParse=do
  _ <- string "<?xml"
  as <- many $ try attParse
  _ <- string "?>"
  spaces
  n <- tagParse
  return $ Root as n

tagParse::Parsec String () Tag
tagParse=choice [tagTagParse, strTagParse]

strTagParse::Parsec String () Tag
strTagParse=do
  xs <- many1 $ (try alphaNum) <|> oneOf " \n" -- anyChar $ try $ char '<' <|> eof
  -- ns <- many $ try tagParse
  return $ TagStr xs

tagTagParse::Parsec String () Tag
tagTagParse=do
  _ <- char '<'
  name <- many1 $ try alphaNum
  as <- many $ attParse
  c <- anyChar
  ns <- tagHelper c
  return $ TagTag name as ns

tagHelper::Char -> Parsec String () [Tag]
tagHelper c
  |c == '/' = closeTag
  |c == '>' = childrenParse
  |otherwise = eFunc

closeTag:: Parsec String () [Tag]
closeTag=do
  char '>'
  return []

childrenParse::Parsec String () [Tag]
childrenParse=do
  ns <- many $ try tagParse
  _ <- closingTag
  return ns

eFunc::Parsec String () [Tag]
eFunc = do
  str <- manyTill anyChar $ try eof
  -- let ns = []
  return $ [TagStr str]

closingTag:: Parsec String () ()
closingTag=do
  _ <- string "</"
  _ <- manyTill alphaNum $ try $ char '>'
  return ()

attParse::Parsec String () Att
attParse=do
  many1 $ try (oneOf " \n")
  x <- manyTill anyChar $ try (string "=\"")
  y <- manyTill anyChar $ try (char '"')
  return $ Att (x ,y)