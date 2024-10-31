#!/usr/bin/env bash

if [[ -z $TENSORFLOWS ]]; then
    TENSORFLOWS="2.7 2.8 2.13"
fi

[ -f results.txt ] && rm results.txt
for tf in $TENSORFLOWS; do
    pip install tensorflow=="$tf"
    {
        echo "Using tensorflow == $tf"
        python /script/"$SCRIPT"
        echo -e "\n"
    } >>results.txt
done
