# anki-helper
A bunch of scripts to generate an import file for anki flash card.

## Usage
You need to write a schema file and specify the routine that anki-helper should follow.

For general purpose you can refer my `my_schema_1.rb`, in which I've added some comments for easily reading.

Generally, a routine will contain four parts, input -> filter -> query dictionary -> generate output.
Firstly, during the input part you'll acquire an array with unfiltered raw word list.
Then you need to pass the raw list through various filters according to your requirements.
Afterwards, you can query each word in specific dictionary. You'd to specify manually under what different conditions you want to query the word in different dicts.
Finally you need output the result. Currently this part has to be done manually yet. I suggest you to follow the code in the demonstrative schema.

You'll now be able to import the output file to Anki. For example, in my demonstration, words are separated into three fields, the word, the syllable and optional pronunciation, and the explanation by `\t` character.
In this way you'd to set the field separator to tab in Anki import interface. Then your fresh flash cards will be available.

### Filters
* ColorDictStarFilter  (colordict_star.rb)
Use this to connect ColorDict with Anki! You should export(by sharing) the history list to a text file in anyway you like.
What this filter does is to bypass all starred words in the history and to omit the others.

Note that this filter will automatically remove the prefix mark.
```ruby
fltr = ColorDictStarFilter.new
word_list = fltr.filter(word_list)
```

* IncrementFilter (increment.rb)
Use this filter if you don't want to omit those words which are previously proceeded.
It will memorize new words bypassed and save them in a file.

```ruby
inc_fltr = IncrementFilter.new()  # optional param: prefix of the history file
word_list = inc_fltr.filter(word_list)
# proceeding words
inc_fltr.produce_increment_file   # save the increment history file
```

### Dictionaries
Currently implemented: Collins Cobuild, WordNet and LazyWorm of stardict format.

Library required: rbstardict.

You probably need to specify the path manually to your stardict dictionary files in `stardict.rb`, line 14.

The interfaces of dictionary are fixed:
* `query_word(word)` return an Entry object, or raise an exception if the word's not found
* `word_exists?(word)` return whether the word exists in the dictionary

An Entry object represent a word query result, which has the following fields:
* word            plain text, required, the query word itself
* pronunciation   plain text or HTML, optional, represent the pronunciation of the word
* syllables       plain text or HTML, optional, a separated word according to its syllables
* explanation     HTML, the body, the explanation of the word
* dict            plain text, required, mark the dict origin of the query

## Anki
* anki: http://ankisrs.net/
* ankidroid: https://code.google.com/p/ankidroid/

## License
See `LICENSE`.
