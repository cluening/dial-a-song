#!/bin/bash

AST_DATA_DIR=${AST_DATA_DIR:-./}
SOUND_DIR=${SOUND_DIR:-sounds/custom}

declare -A params

# Get the parameters sent by asterisk
while IFS=':' read -r key value && [ -n "${key}" ]; do
    # Get rid of surrounding whitespace
    value=$(echo "$value" | awk '{$1=$1};1')
    params["${key}"]="${value}"
done

# Answer the call.
echo "ANSWER"
read -r _RESPONSE

# debugging
#>&2 echo "Dialed: ${params[agi_extension]}"

# Find a file to play
#to_play=$(ls ${AST_DATA_DIR}/${SOUND_DIR}/external/${params[agi_extension]}-* | shuf -n 1)
to_play=$(find "${AST_DATA_DIR}/${SOUND_DIR}/external" -name "${params[agi_extension]}-*" | shuf -n 1)
if [ -z "$to_play" ]; then
    to_play="${AST_DATA_DIR}/${SOUND_DIR}/builtin/callcouldnotgothrough.mp3"
fi

# debugging
#>&2 echo To play: $to_play

# Tell asterisk to play it
echo "EXEC MP3Player ${to_play}"
read -r _RESPONSE

echo "HANGUP"
read -r _RESPONSE

exit 0
