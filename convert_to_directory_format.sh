#!/bin/bash
# This is the setup script used to generate the words and concepts directories

while IFS= read line; do
  while IFS= read line2; do
    while IFS= read line3; do
      if [[ ${arr[@]} =~ $line3 ]]; then
        continue
      else
        echo "$line"
        printf "%s\n" "words/$(echo $line3 | sed 's/\.//g')"
      fi
    done< <(echo $line2 | tr ' ' '\n');
  done< <(echo "$line" | cut -d $'\t' -f3  | sed -re 's/\[.*?\]//g;s/\s(adj|Adj|adv|Adv|[nNvV]|Phr)\.//g;s/&c\.\.?\s?//g;s/"//g;s/ \. //g;s/ , /, /g;s/\(.*?\)//g' | tr ',' '\n');
done< <(cut -d $'\t' -f 1,2,3 lua/cmp_rogets_thesaurus/rogets_thesaurus.tsv | awk -F $'\t' '{printf "%s\t%s\t%s\n", $2, $1, $3} ')
while IFS= read line; do
  bash -x -c "$line"
done< <(cut -d $'\t' -f 1,2,3 ./rogets_thesaurus.tsv | sed -e "s/\"/\\\"/g;s/\&/\\\&/g;s/'/\\'/g" | sed -r 's/^\#([0-9]+[abcd]?)\./\1/g' | awk -F $'\t' '{printf "echo \"%s\" >> concepts/%s\n", $3, $1}' | sed 's/echo " /echo "/g')
