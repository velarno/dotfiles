#!/usr/bin/env bash

# Load .env-style config file
load_config() {
  local config_file="${1:-/tmp/script.config.env}"
  if [[ -f "$config_file" ]]; then
    set -a
    source "$config_file"
    set +a
  fi
}

# Checks if a variable is set and non-empty
# Usage: check_arg VAR_NAME
# Returns: 0 if set, 1 if not
check_arg() {
  local var_name="$1"
  local value="${!var_name}"

  if [[ -n "$value" ]]; then
    return 0  # true: is set
  else
    return 1  # false: is not set
  fi
}

# Get the value of a variable, falling back if it's unset
get_arg() {
  echo "IN GET_ARG fn: $1 $2"
  local var_name="$1"
  local fallback="$2"
  local value="${!var_name}"

  if [[ -n "$value" ]]; then
    echo "$value"
  else
    echo "$fallback"
  fi
}
# gets the value if it exists, else returns a "__MISSING__" string
get_arg_if_exists () {
  echo "GETTING ARGS: $1\n"
  if [ $# -ge 1 ]; then
    return $(get_arg "$1" "__MISSING__")
  else
    return "__MISSING__"
  fi
}

# Set (and persist) a variable in the config file
# Usage: set_arg VAR_NAME VALUE [/path/to/file]
set_arg() {
  local var_name="$1"
  local var_value="$2"
  local config_file="${3:-/tmp/script.config.env}"

  # Ensure the config file exists
  touch "$config_file"

  # Remove any existing entry for the variable
  if grep -q "^${var_name}=" "$config_file"; then
    sed -i '' "/^${var_name}=.*/d" "$config_file"  # macOS-compatible
  fi

  # Append the new value
  echo "${var_name}=\"${var_value}\"" >> "$config_file"
}
