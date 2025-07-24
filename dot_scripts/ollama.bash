OLLAMA_RECORD_TEMPLATE=$(cat <<EOF
You are a helpful assistant that transforms records.
The input is a record.
The output is a transformed record. The output should be a valid JSON object.
Your task is to perform the following transformations:
{transformations}
The input is:
{record}
The output is:
EOF
)

OLLAMA_ENDPOINT=http://localhost:11434

ollama_transform_records() {
    local model=$1
    local input_file=$2
    local output_file=$3

    # use jq to loop on each record, and use ollama to transform it
    cat $input_file | jq -c '.[]' | while read -r record; do
        local prompt=$(perl -pe "s/{record}/$record/g" <<< "$OLLAMA_RECORD_TEMPLATE")
        echo $prompt
        echo $record
        # response=$(OLLAMA_ORIGINAL_RECORD="$record" ollama run "$model" -f "$prompt")
        # if [[ -n "$output_file" && -f "$output_file" ]]; then
        #     echo "$response" >> "$output_file"
        # else
        #     echo "$response"
        # fi
    done
}

test_json=$(cat <<EOF
[
    {
        "name": "John Doe",
        "age": 30
    },
    {
        "name": "Jane Roberts",
        "age": 25
    }
]
EOF
)

test_transformations=$(cat <<EOF
- add a new field "gender" by guessing from the name
- add a new field "has_kids_probability" by guessing from the age (0% if age < 18, 70% if age > 65, otherwise interpolate linearly based on the age)
EOF
)

# ollama_transform_records llama3.2 "$test_json" "output.json"

# cat $test_json | jq -c '.[]' | while read -r record; do
#     echo $record
# done

jq -c '.[]' /tmp/test.json | while IFS= read -r record; do
    prompt=$(perl -pe "s/{record}/$record/g; s/{transformations}/$test_transformations/g" <<< "$OLLAMA_RECORD_TEMPLATE")
    # Properly escape the prompt for JSON
    prompt_escaped=$(echo "$prompt" | jq -R -s .)
    echo "--------------------------------"
    curl -s -X POST $OLLAMA_ENDPOINT/api/generate \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"llama3.2\", \"prompt\": $prompt_escaped}" | jq -c '.'
    echo "--------------------------------"
done

# echo jq -c '.[]' | while IFS= read -r record; do
#     echo " === Processing record === "
#     echo $record | jq -c '.'
#     escaped_record=$(echo $record | jq -R -s .)
#     prompt=$(perl -pe "s/{record}/$escaped_record/g; s/{transformations}/$test_transformations/g" <<< "$OLLAMA_RECORD_TEMPLATE")
#     result=$(ollama run llama3.2 "$prompt" --format json)
#     echo $result | jq -c '.'
#     echo " === End of record === "
# done