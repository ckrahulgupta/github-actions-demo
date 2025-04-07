#!/bin/bash

####################################################################################################################
# Description:          Validates components from package.xml
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   03-04-2025
####################################################################################################################

tests=$TESTS

echo '*********** Tests to run ***********'
echo $tests

# running tests from the specified test classes and performing validation
if [[ $(grep -c '<types>' ./package/package.xml) -gt 0 ]]; then
    
    if [ ! -z "$tests" ]; then
        # if test classes are selected to run and $tests is not empty
        sfdx project deploy start --target-org $ORG_ALIAS --manifest package/package.xml --test-level RunSpecifiedTests --tests $tests --verbose --dry-run --api-version $API_VERSION --coverage-formatters html | tee ./output.txt | grep 'Deploy ID:' | awk '/^Deploy ID:/ {print $3}' | cat > deployment-id.txt
    else
        # if no test classes are selected to run and $tests is empty
        sfdx project deploy start --target-org $ORG_ALIAS --manifest package/package.xml --verbose --dry-run --api-version $API_VERSION --coverage-formatters html | tee ./output.txt | grep 'Deploy ID:' | awk '/^Deploy ID:/ {print $3}' | cat > deployment-id.txt
    fi

else
    echo -e '*********** No metadata to validate ***********'
    exit 0
fi

exit_code=${PIPESTATUS[0]}

if [[ $exit_code != 0 ]]; then
    exit $exit_code
fi 
set -o pipefail