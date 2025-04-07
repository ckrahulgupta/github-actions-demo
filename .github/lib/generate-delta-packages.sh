#!/bin/bash

####################################################################################################################
# Description:          Evaluates the difference from the 2 branches and generates the package.xml
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   08-11-2024
####################################################################################################################

source .github/lib/util/util.sh

# updating the HOME to point to root as HOME is pointing to GIT and the extension is loaded at root directory
export HOME=/root

git config --global --add safe.directory $GITHUB_WORKSPACE

# generates delta package for rollback
function generate_delta_for_rollback() {
    sfdx sgd source delta --to origin/$BASE_BRANCH~1 --from origin/$BASE_BRANCH --output . --ignore .sgdignore --api-version $API_VERSION
}

# generate the package.xml
if [[ $ROLLBACK == false ]]; then
    sfdx sgd source delta --from origin/$BASE_BRANCH --output . --ignore .sgdignore --api-version $API_VERSION
else
    last_commit=$(git log --pretty=format:'%h' -1)

    is_merge $last_commit
    retval=$?

    if [[ $retval == 0 ]]; then
        echo '*********** CANNOT REVERT - Last commit is not a merge commit ***********'
        set -o pipefail
    fi

    git checkout -- .
    git checkout $BASE_BRANCH~1

    # generate the delta packages for rollback
    generate_delta_for_rollback
fi

# logging the details
echo -e '*********** Generated package.xml for modified components ***********'
cat package/package.xml

echo -e '\n\n*********** Generated destructiveChanges.xml for deleted components ***********'
cat destructiveChanges/destructiveChanges.xml
