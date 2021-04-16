FORMAT=parquet

flowmaps-data risk list | sed 1d |
while read -r line
do
    echo $line
    SOURCE_LAYER=`echo "$line" | python3 -c "import json, sys; d = json.load(sys.stdin); print(d['source_layer'], end='');"`
    TARGET_LAYER=`echo "$line" | python3 -c "import json, sys; d = json.load(sys.stdin); print(d['target_layer'], end='');"`
    EV=`echo "$line" | python3 -c "import json, sys; d = json.load(sys.stdin); print(d['ev'], end='');"`

    DATES=`flowmaps-data risk list-dates --ev $EV`

    mkdir -p data/$SOURCE_LAYER-$TARGET_LAYER-$EV/

    for date in $DATES; do
        echo $date

        FILENAME=data/$SOURCE_LAYER-$TARGET_LAYER-$EV/$date.$SOURCE_LAYER-$TARGET_LAYER-$EV.daily_mobility.$FORMAT

        if [ -f "$FILENAME" ]; then
            echo "skipping $FILENAME (already exists)"
            continue
        fi

        flowmaps-data risk download \
            --date $date \
            --source-layer $SOURCE_LAYER \
            --target-layer $TARGET_LAYER \
            --ev $EV \
            --output-format $FORMAT \
            --output-file $FILENAME
    done
done
