#!/bin/bash

####################################################################################################################
# Description:          Util file containing useful helper methods
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   03-04-2025
####################################################################################################################

# checks if a commit is a merge commit or not
function is_merge() {
    local merges=$(git log --pretty=%P -n 1 $1)
    local num_parents=0

    IFS=' ' read -ra parents <<< $merges

    for parent in "${parents[@]}"; do
        num_parents=$((num_parents + 1))
    done

    if [[ $num_parents > 1 ]]; then
        return 1
    fi
    return 0
}
# quick deploy already validated metadata
function quick_deploy() {

    local deployment_id=$1

    sfdx force source deploy --target-org $ORG_ALIAS --validateddeployrequestid $deployment_id --verbose --api-version $API_VERSION | tee output.txt

    return ${PIPESTATUS[0]}
}

# deploy the metadata after running the specified tests
function deploy() {

    local tests=$1

    echo '*********** Tests to run ***********'
    echo $tests

    if [ ! -z "$tests" ]; then
        # if test classes are selected to run and $tests is not empty
        sfdx project deploy start --target-org $ORG_ALIAS --manifest package/package.xml --test-level RunSpecifiedTests --tests $tests --verbose --api-version $API_VERSION | tee output.txt
    else
        # if no test classes are selected to run and $tests is empty
        sfdx project deploy start --target-org $ORG_ALIAS --manifest package/package.xml --verbose --api-version $API_VERSION | tee output.txt
    fi
    return ${PIPESTATUS[0]}
}

# perform destructive changes and then deploy the metadata after running specified tests
function deploy_with_destructive_changes() {

    local tests=$1

    echo '*********** Tests to run ***********'
    echo $tests

    sfdx project deploy start --target-org $ORG_ALIAS --manifest package/package.xml --test-level RunSpecifiedTests --tests $tests --pre-destructive-changes destructiveChanges/destructiveChanges.xml --verbose --api-version $API_VERSION | tee output.txt

    return ${PIPESTATUS[0]}
}