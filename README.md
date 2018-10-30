# Projet
**ATTENTION** This is a protoype, working only with texts with texts encoded in TEI with verses encoded with `l`.  

On the fly modernisation of 17th French and assessment of the graphic system (archaisms vs modernisms)

# Credits
Simon Gabay (Université de Neuchâtel)  
Benoît Sagot (INRIA)

# Corpus
We provide a draft of our edition of Racine's *Andromaque* (non-modernised 1668 edition)

# Manual

## Using the rules

Basic rules are provided in `scripta17.rules`. Rules can be deleted, added or changed the following way:  
1. First column: source (17th c. spelling)  
2. Second column: target (modernised version)  
3. Third column: type of rule, *i.e.*  
    * `A` for *archaism*  
    * `M` for *modernism*  
    * `N` for *neutral*  

## Command lines

To process a text:

cat `<FILE_TO_PROCESS> | perl scipta17.pl <PATH_TO_LEXICON.mlex> <PATH_TO_RULES>`  

To save the results, add `> <NAME.xml>`  

In practice, with the provided files:

cat `Andromaque_1668.xml | perl scipta17.pl lefff-3.4.mlex scripta17.rules > result.xml`  


## Analysing results

## In the xml code
A modernised word is encoded with `w`. The non-modernised spelling are kept in `@source` and the rules applied for the modernisation is provided in `@label`.

Exemple: `<w source="voſtre" label="A">vôtre</w>`

## In the terminal
Basic statistics are provided at the end after the text has been processed:
1. Amount of modernised words  
2. Breakdown of modernisms and archaisms identified in the text  
3. Percentage of words modernised  
4. Amount of rules applied per word modernised  
5. Amount of rules applied per word  
6. Balance between modernisms and archaisms  

# Literature

To know more about the Leff:
```
@inproceedings{sagot:inria-00521242,
  TITLE = {{The Lefff, a freely available and large-coverage morphological and syntactic lexicon for French}},
  AUTHOR = {Sagot, Beno{\^i}t},
  URL = {https://hal.inria.fr/inria-00521242},
  BOOKTITLE = {{7th international conference on Language Resources and Evaluation (LREC 2010)}},
  ADDRESS = {Valletta, Malta},
  YEAR = {2010},
  MONTH = May,
  PDF = {https://hal.inria.fr/inria-00521242/file/lrec10lefff.pdf},
  HAL_ID = {inria-00521242},
  HAL_VERSION = {v1},
}
```

# Licence

For the Lefff, cf.http://alpage.inria.fr/~sagot   
For the script CC-BY  


<a rel="license" href="https://creativecommons.org/licenses/by-nc-nd/2.0"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/2.0/88x31.png" /></a><br />