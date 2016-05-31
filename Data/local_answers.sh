 #!/bin/bash
export LC_CTYPE=C 
export LANG=C

FNAME="default_answers.json"
LEN=$(cat $FNAME | jsawk 'return this.data.length')
echo "Answers - $LEN"
> L10n.strings
printf '"count"="%d";\n' $LEN >> L10n.strings
for i in `seq 0 $(($LEN-1))`
do
    ANSW=$(cat $FNAME | jsawk "return this.data[$i].text")
    AUTH=$(cat $FNAME | jsawk "return this.data[$i].author")
    
    ANSW=${ANSW//\"/FUCK}
    AUTH=${AUTH//\"/FUCK}
    
    printf '"answer%d"="%s";\n"author%d"="%s";\n' $i "$ANSW" $i "$AUTH" | iconv -f ascii -t utf8//IGNORE >> L10n.strings
    PROGRESS=$(echo "scale=2; $i*100/$LEN" | bc)
    echo -ne " Progress: $PROGRESS\r"
    
done