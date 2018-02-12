#!/usr/bin/bash

function trim_spaces {
    sed 's/  */ /g' | sed 's/ ;/;/g' | sed 's/; /;/g' | sed 's/^ //' | sed 's/ $//'
}

function show_valid {
    egrep '^[a-zA-Z]+;[^;]+;[^;]+;[^;]*$'
}

function show_invalid {
    egrep -v '^[a-zA-Z]+;[^;]+;[^;]+;[^;]*$'
}


TEMP_FILE=`mktemp XXXXXX`

cat "$1" | # ./basic_split_to_valid_and_invalid.sh
    tail -n +33 | head -n -55 | # skip
    egrep -v "[^][a-żA-Ż;,. -/0-9'{}()<>]" |
    egrep -v "ñ" |
    tr ';' ',' | tr '\t' ';' | cut -d ';' -f1,2 | trim_spaces | sed 's/^[^;]*;/\L&\E&/' | # make three columns
    egrep -v 'vulg\.' |
    egrep -v 'Rsv\.' |
    egrep -v 'coll\.' |
    egrep -v 'fig\.' |
    egrep -v 'also fig\.' |
    egrep -v 'hum\.' |
    egrep -v 'pej\.' |
    egrep -v 'spv\.' |
    egrep -v 'sl\.' |
    egrep -v 'Scot\.' |
    egrep -v 'Aus\.' |
    egrep -v 'NZ' |
    egrep -v 'Can\.' |
    egrep -v 'Irish' |
    egrep -v 'Ind\.' |
    egrep -v 'S\.Afr\.' |
    egrep -v 'ugs\.' |
    egrep -v 'dated' |
    egrep -v 'obs\.' |
    egrep -v 'archaic' |
    egrep -v 'literary' |
    egrep -v 'regional' |
    egrep -v 'nonstandard' |
    awk '/\[/{print $0, ";2"}/^[^[]*$/{print $0, ";1"}' |
    sed 's/{[^{}]*}//g' | sed 's/([^()]*)//g' | sed 's/\[[^][]*\]//g' | # skip brackets
    sed 's/<[^<>]*>//g' | sed 's/{[^{}]*}//g' | sed 's/([^()]*)//g' |
    sed 's/\[[^][]*\]//g' | sed 's/<[^<>]*>//g' |
    egrep -v '(\(|\)|\[|\]|<|>|{|})' |
    trim_spaces |
    egrep '^[^;]+;[^;]+;[^;]+;[^;]*$' > "$TEMP_FILE"

VALID_FILE=`mktemp XXXXXX`
INVALID_FILE=`mktemp XXXXXX`

cat "$TEMP_FILE" | show_valid > "$VALID_FILE"
cat "$TEMP_FILE" | show_invalid > "$INVALID_FILE"

cat "$INVALID_FILE" | egrep '^sich [a-zA-Z]*;' | sed 's/^sich //g' >> "$VALID_FILE"
cat "$INVALID_FILE" | egrep -v '^sich [a-zA-Z]*;' > "$TEMP_FILE"
cat "$TEMP_FILE" > "$INVALID_FILE"

cat "$INVALID_FILE" | grep '^etw\. [a-zA-Z]*;' | sed 's/etw\.//g' | trim_spaces | sed 's/ sth.$//' >> "$VALID_FILE"
cat "$INVALID_FILE" | grep -v '^etw\. [a-zA-Z]*;' > "$TEMP_FILE"
cat "$TEMP_FILE" > "$INVALID_FILE"

cat "$INVALID_FILE" | grep '^jd\. [a-zA-Z]*;' | sed 's/jd\.//g' | trim_spaces | sed 's/sb\. //' >> "$VALID_FILE"
cat "$INVALID_FILE" | grep -v '^jd\. [a-zA-Z]*;' > "$TEMP_FILE"
cat "$TEMP_FILE" > "$INVALID_FILE"

cat "$INVALID_FILE" | grep '^jdn\. [a-zA-Z]*;' | sed 's/jdn\.//g' | trim_spaces | sed 's/ sb\.$//' >> "$VALID_FILE"
cat "$INVALID_FILE" | grep -v '^jdn\. [a-zA-Z]*;' > "$TEMP_FILE"
cat "$TEMP_FILE" > "$INVALID_FILE"

cat "$INVALID_FILE" | grep '^jdm\. [a-zA-Z]*;' | sed 's/jdm\.//g' | trim_spaces | sed 's/ sb\.$//' >> "$VALID_FILE"
cat "$INVALID_FILE" | grep -v '^jdm\. [a-zA-Z]*;' > "$TEMP_FILE"
cat "$TEMP_FILE" > "$INVALID_FILE"

cat "$INVALID_FILE" | awk '
BEGIN { FS=";" }
{ gsub("[a-zA-Z]*\./[a-zA-Z]*\.", "", $1);
  gsub("[a-zA-Z]*\./[a-zA-Z]*\.", "", $2);
  gsub("[a-zA-Z]*\./[a-zA-Z]*\.$", "", $3);
  print $1, ";", $2, ";", $3 }
' | sed 's/sich //g' | sed 's/etw\. //g' | sed 's/jd\. //g' | sed 's/jdm\. //g' | sed 's/jdn\. //g' |
    trim_spaces > "$TEMP_FILE"

cat "$TEMP_FILE" | show_invalid  > "$INVALID_FILE"
cat "$TEMP_FILE" | show_valid >> "$VALID_FILE"

cat "$VALID_FILE" | awk 'BEGIN{FS=";"}{print $4, ";", $1, ";", $2, ";", $3}' | trim_spaces | sort -n | cut -d ';' -f2,3,4 > "$TEMP_FILE"
cat "$TEMP_FILE" > "$VALID_FILE"

cat "$VALID_FILE" | ./merge_same.kts - > "$TEMP_FILE"
echo "german;english" > dictionary.txt
cat "$TEMP_FILE" >> dictionary.txt

rm $TEMP_FILE $VALID_FILE $INVALID_FILE
