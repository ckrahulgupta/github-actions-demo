#!/bin/bash

####################################################################################################################
# Description:          Retrieve components from Salesforce org
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   08-11-2024
####################################################################################################################

# updating the HOME to point to root as HOME is pointing to GIT and the extension is loaded at root directory
export HOME=/root

echo '--->> 1'
git config --global --add safe.directory $GITHUB_WORKSPACE

echo '--->> 2'

sfdx project retrieve start --target-org $ORG_ALIAS --manifest manifest/package.xml --api-version $API_VERSION

echo '--->> 3'
git status
