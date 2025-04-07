#!/bin/bash

####################################################################################################################
# Description:          Deploys components from package.xml
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   08-11-2024
####################################################################################################################

# including utils
source .github/lib/util/util.sh

if [[ $(grep -c '<types>' ./package/package.xml) -gt 0 ]]; then

    # running tests from the specified test classes and performing validation
    # and then deploying
    build_file='deployment-id.txt'

    tests=$TESTS

    if [[ -f $build_file ]]; then
        # try quick deploy first with the validated id
        deployment_id=$(cat $build_file)
        quick_deploy $deployment_id
        exit_code=$?

        if [[ $exit_code != 0 ]]; then
            # if doesn't succeed, then deploy using the traditional method
            deploy "$tests"
            exit_code=$?
        fi
    else 
        deploy "$tests"
        exit_code=$?
    fi

else
    echo -e '*********** NO METADATA TO DEPLOY ***********'
    exit 0
fi

if [[ $exit_code != 0 ]]; then
    set -o pipefail
    exit $exit_code
fi

