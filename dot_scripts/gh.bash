#!/bin/bash

# create a repo from current dir, name remote "upstream", private repo, push
gh repo create $1 --source=. --remote=upstream --description=$2 --private --push

# get status of a specific github release tag (found/not_found), helpful to know if release exists
local tag="main"
release_status=$(gh release view $tag > /dev/null 2>&1 && echo "found" || echo "not_found")

# get gist ID based on description substring search, pipe gh output to tail first to remove fancy printing
# TODO: might not work when many gists, test later
local filter_expr="account"
gh gist list --filter $filter_expr | tail | cut -f1 -d $'\t'

# get list of successful github actions runs, only output the latest run from the workflow containing name_substring
local filter_expr="Links"
gh run list -e push -s success --json databaseId,name,url,workflowName,updatedAt | jq --arg name_expr $filter_expr '[.[] | select(.name | test($name_expr))] | sort_by(.updatedAt) | reverse | .[].databaseId' | tail -n 1
# spits out the ID of the latest run only, e.g. 16339064362

# list ids for currently running gh action runs
gh run list --json databaseId,name,url,workflowName,updatedAt -s in_progress --jq '.[].databaseId'

# list all assets in the github release named "main", only get names:
gh release view main --json assets --jq ".assets.[].name"

# list all past artifacts which start with some prefix, here "sqlite-database-", and get latest artifacts first
gh api repos/velarno/openplace/actions/artifacts | jq '.artifacts | map(select(.name | startswith("sqlite-database-"))) | sort_by(.updated_at | fromdateiso8601) | reverse'
