#!/bin/bash
#
# file: gitplow-commons.sh
# author: Daniele Bellavista
#
#

get_gitlab_protocol() {
  PROTOCOL=$(git config --get gitplow.gitlab.protocol)
  if [[ -z $PROTOCOL ]]; then
      PROTOCOL=$(git config --global --get gitplow.gitlab.protocol)
  fi

  if [[ -z $PROTOCOL ]]; then
      return 1
  fi
  echo $PROTOCOL
}

get_gitlab_token() {
  PRIVATETOKEN=$(git config --get gitplow.gitlab.token)
  if [[ -z $PRIVATETOKEN ]]; then
      PRIVATETOKEN=$(git config --global --get gitplow.gitlab.token)
  fi

  if [[ -z $PRIVATETOKEN ]]; then
      return 1
  fi
  echo $PRIVATETOKEN
}

get_gitlab_domain() {
  DOMAIN=$(git config --get gitplow.gitlab.domain)
  if [[ -z $DOMAIN ]]; then
      DOMAIN=$(git config --global --get gitplow.gitlab.domain)
  fi

  if [[ -z $DOMAIN ]]; then
      return 1
  fi
  echo $DOMAIN
}

get_gitlab_prid() {
  PRID=$(git config --get gitplow.gitlab.projectid)
  if [[ -z $PRID ]]; then
    return 1
  fi
  echo $PRID
}

i_am_admin() {
  ADMIN=$(git config --get gitplow.gitlab.admin)
  if [[ -z $ADMIN ]]; then
    return 1
  fi
  echo $ADMIN
}

gitflow_is_initialized() {
  $(git flow config >/dev/null 2>&1)
}

gitplow_only_is_initialized() {
  get_gitlab_token > /dev/null \
    && get_gitlab_protocol > /dev/null \
    && get_gitlab_prid > /dev/null \
    && get_gitlab_domain > /dev/null
}

gitplow_is_initialized() {
  gitflow_is_initialized && gitplow_only_is_initialized
}

merge_request() {
    SOURCE=$1
    DEST=$2
    TITLE=$3
    REMOVE=$4
    if [[ -z $REMOVE ]]; then
        REMOVE="false"
    fi

    PROTOCOL=$(get_gitlab_protocol)
    PROJECTID=$(get_gitlab_prid)
    PRIVATETOKEN=$(get_gitlab_token)
    DOMAIN=$(get_gitlab_domain)

    curl --header "Private-Token: $PRIVATETOKEN"\
        -d "source_branch=$SOURCE" \
        -d "target_branch=$DEST" \
        -d "title=$TITLE" \
        -d "allow_collaboration=true" \
        -d "remove_source_branch=$REMOVE" \
        "${PROTOCOL}://${DOMAIN}/api/v4/projects/${PROJECTID}/merge_requests"
}

accept_request() {
    MRID=$1

    PROJECTID=$(get_gitlab_prid)
    PRIVATETOKEN=$(get_gitlab_token)
    DOMAIN=$(get_gitlab_domain)

    curl --header "Private-Token: $PRIVATETOKEN"\
        -X PUT "https://${DOMAIN}/api/v4/projects/${PROJECTID}/merge_requests/${MRID}/merge"
}

pull() {
  echo "Pulling $1"
  git checkout $1
  git pull origin $1
}

approveMergeRequest() {
  local NAME="$1"; shift
  local MR_ID="$1"; shift
  if [[ -z "$MR1_ID" ]]; then
    echo "Missing merge request id"
    return 1
  fi
  set -e
  echo "Accepting request $MR1_ID"
  accept_request $MR1_ID
  echo "Accepting request $MR2_ID"
  accept_request $MR2_ID
  pull "develop"
  pull "master"
  git tag -a $NAME
  git push --tags
}
