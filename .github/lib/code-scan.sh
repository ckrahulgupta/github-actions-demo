#!/bin/bash

####################################################################################################################
# Description:          Scans the code and generates the report
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   08-11-2024
####################################################################################################################

# updating the HOME to point to root as HOME is pointing to GIT and the extension is loaded at root directory
export HOME=/root

git config --global --add safe.directory $GITHUB_WORKSPACE

files_to_scan=$(git diff --diff-filter=ACM --name-only origin/$BASE_BRANCH force-app/main/default | paste -sd ',' -)

pmd_path='/opt/pmd-bin-7.0.0-rc4'

sfdx scanner rule add --language apex --path $pmd_path/lib/pmd-custom-rules-1.0.0.jar

if [[ -n "$files_to_scan" ]]; then
    # generate the report in HTML
    sfdx scanner run --format html --target $files_to_scan --normalize-severity --category $RULE_CATEGORY --pmdconfig $pmd_path/pmd-ruleset.xml --engine $RULE_ENGINE --preview-pmd7 --outfile Codescan-Report.html

    # generate the report in CSV
    sfdx scanner run --format csv --target $files_to_scan --normalize-severity --category $RULE_CATEGORY --pmdconfig $pmd_path/pmd-ruleset.xml --engine $RULE_ENGINE --preview-pmd7 --outfile Codescan-Report.csv
fi