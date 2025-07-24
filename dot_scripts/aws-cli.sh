get_aws_cred() {
  local file="$HOME/.aws/creds.json"
  local key="$1"

  if [[ -z "$key" ]]; then
    echo "Usage: get_aws_cred <key_path>"
    return 1
  fi

  if [[ ! -f "$file" ]]; then
    echo "Error: $file does not exist." >&2
    return 1
  fi

  jq -e -r ".$key" "$file" 2>/dev/null || {
    echo "Error: Key '$key' not found in $file" >&2
    return 1
  }
}
