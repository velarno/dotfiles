gcp_proj_list() {
  gcloud projects list --format=json | jq '.[].projectId' | tr -d '"'
}

gcp_proj_sub() {
  if [ -z "$1" ]; then
    echo "Usage: gcp_proj_sub <substring>"
    echo "Example: gcp_proj_sub dev"
    return 1
  fi

  gcloud projects list --format=json | jq --arg sub "$1" '.[] | select(.projectId | contains($sub)) | .projectId' | tr -d '"'
}

gcp_dns_zones_sub() {
  if [ -z "$1" ]; then
    echo "Usage: gcp_dns_zones_sub <substring>"
    echo "Example: gcp_dns_zones_sub arnov"
    return 1
  fi

  gcloud dns managed-zones list --format=json | jq --arg sub "$1" '.[] | select(.name | contains($sub)) | .name' | tr -d '"'
}

gcp_dns_create_a_record() {
  if [ $# -lt 3 ]; then
    echo "Usage: gcp_dns_create_a_record <zone> <domain> <ip_address>"
    echo "Example: gcp_dns_create_a_record arnovdev nas.storage.arnov.dev. 45.23.133.12"
    return 1
  fi

  local zone="$1"
  local domain="$2"
  local ip_address="$3"

  gcloud dns --project=kluster-arnov-dev-init record-sets create "$domain" \
    --zone="$zone" \
    --type="A" \
    --ttl="300" \
    --rrdatas="$ip_address"
}