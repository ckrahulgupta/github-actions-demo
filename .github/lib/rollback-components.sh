#!/bin/bash

####################################################################################################################
# Description:          Rollback components from package.xml
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   08-11-2024
####################################################################################################################

source .github/lib/util/util.sh

tests=$TESTS

if [[ -n "$INPUT_TESTS" ]]; then
    tests=$INPUT_TESTS
fi

# running tests from the specified test classes and performing validation
# and then deploying
if [[ ($(grep -c '<types>' ./package/package.xml) -gt 0) && ($(grep -c '<types>' ./destructiveChanges/destructiveChanges.xml) -gt 0) ]]; then
    # if both the package.xml and destructiveChanges.xml contains metadata
    deploy_with_destructive_changes "$tests"
    exit_code=$?


elif [[ $(grep -c '<types>' ./package/package.xml) -gt 0 ]]; then
    # if only the package.xml contains metadata
    deploy "$tests"
    exit_code=$?

else
    echo -e '*********** NO METADATA TO ROLLBACK ***********'
    exit 0
fi


if [[ $exit_code == 0 ]]; then
    # revert the branch

    git config --global --add safe.directory $GITHUB_WORKSPACE

    # set the global configuration for git
    git config --global user.email $GIT_USER_EMAIL
    git config --global user.name $GIT_USER_NAME

    # checkout to the most recent commit
    git checkout -- .
    git checkout $BASE_BRANCH
    
    # get the last comming
    last_commit=$(git log --pretty=format:'%h' -1)

    # revert the commit
    git revert --mainline 1 $last_commit --no-edit

    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        set -o pipefail
        exit 1
    fi

    # push the changes to remote
    git push origin $BASE_BRANCH

    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        set -o pipefail
        exit 1
    fi

    exit $exit_code
fi
set -o pipefail