
azrg_list () {
  
  az group list | jq '.[].name' | tr -d '"'

}

azrg_sub () {
  if [ -z "$1" ]; then
    echo "Usage: azg_sub <substring>"
    echo "Example: azg_sub dev"
    return 1
  fi

  az group list | jq --arg sub "$1" '.[] | select(.name | contains($sub)) | .name' | tr -d '"'

}

azacn_sub () {
  if [ -z "$1" ]; then
    echo "Usage: azacn_sub <substring>"
    echo "Example: azacn_sub dev"
    return 1
  fi

  az storage account list | jq --arg sub "$1" '.[] | select(.name | contains($sub)) | .name' | tr -d '"' 
}

azsa_names () {
  local nbNames=${1:-1}
  az storage account list | jq '.[].name' | tr -d '"' | head -n $nbNames
}

azconn_str () {
  # Default values
  local rg_filter="dev"
  local store_config=false
  local ignore_config=false

  # Parse flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --rg-filter)
        rg_filter="$2"
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done

    az storage account show-connection-string \
      --name "$(azsa_names)" \
      --resource-group "$(azrg_sub "$rg_filter")"\
      | jq '.connectionString'
}

azcntr_list () {
  # Default values
  local rg_filter="dev"

  # Parse flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --rg-filter)
        rg_filter="$2"
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done

  az storage container list --connection-string $(azconn_str --rg-filter $rg_filter) | jq '.[].name' | tr -d '"'
}
