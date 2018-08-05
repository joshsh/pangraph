{-# LANGUAGE OverloadedStrings #-}
module Pangraph.GML.Parser where

import Data.Attoparsec.Text
import Data.Text (Text, cons, pack)
import Control.Applicative ((<|>), (<*))
import Data.Map (fromList)

import Prelude (return, Either, String)

import Pangraph.GML.Ast

parseText :: Text -> Either String GML
parseText = parseOnly (gmlParser <* endOfInput)

parseString :: String -> Either String GML
parseString str = parseText (pack str)

gmlParser :: Parser GML
gmlParser = innerListParser

listParser :: Parser GML
listParser = do
    skipSpace
    skip (inClass "[")
    obj <- innerListParser
    skipSpace
    skip (inClass "]")
    skipSpace
    return obj

innerListParser :: Parser GML
innerListParser = do
    entries <- many' listEntryParser
    let map = fromList entries
    return (Object map)

listEntryParser :: Parser (Text, GML)
listEntryParser = do
    skipSpace
    name <- key
    skipMany1 (whitespace)
    value <- valueParser
    return (name, value)
    
key :: Parser Text
key = do
    start <- satisfy (inClass "a-z")
    rest <- takeWhile (inClass "a-zA-Z0-9")
    return (start `cons` rest)

valueParser :: Parser GML
valueParser = stringParser <|> integerParser <|> floatParser <|> listParser

integerParser :: Parser GML
integerParser = do
    i <- signed decimal
    return (Integer i)

floatParser :: Parser GML
floatParser = do
    d <- double
    return (Float d)

stringParser :: Parser GML
stringParser = do 
    let del = inClass "\""
    skip del
    s <- takeTill del
    skip del
    return (String s)
     
whitespace :: Parser ()
whitespace = skip isHorizontalSpace <|> endOfLine

