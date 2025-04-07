#!/bin/bash

####################################################################################################################
# Description:          Runs PMD the code and generates the report
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   08-11-2024
####################################################################################################################

# updating the HOME to point to root as HOME is pointing to GIT and the extension is loaded at root directory
export HOME=/root

git config --global --add safe.directory $GITHUB_WORKSPACE

git diff --diff-filter=ACM --name-only origin/$BASE_BRANCH force-app/main/default >> CHANGED_FILES.txt

pmd_path="/opt/pmd-bin-7.0.0-rc4"

# generate the report in HTML
pmd check --file-list CHANGED_FILES.txt --format html --rulesets $pmd_path/pmd-ruleset.xml --aux-classpath $pmd_path/lib/pmd-custom-rules-1.0.0.jar --report-file PMD-Report.html --no-progress --no-fail-on-violation

# generate the report in CSV
pmd check --file-list CHANGED_FILES.txt --format csv --rulesets $pmd_path/pmd-ruleset.xml --aux-classpath $pmd_path/lib/pmd-custom-rules-1.0.0.jar --report-file PMD-Report.csv --no-progress --no-fail-on-violation
