#!/bin/bash

####################################################################################################################
# Description:          Checkout to the backup branch
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   08-11-2024
####################################################################################################################

# updating the HOME to point to root as HOME is pointing to GIT and the extension is loaded at root directory
export HOME=/root

# adding safe directory
git config --global --add safe.directory $GITHUB_WORKSPACE

# checkout to the backup branch
git checkout $BACKUP_BRANCH

git status
