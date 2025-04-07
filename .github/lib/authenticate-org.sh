#!/bin/bash

####################################################################################################################
# Description:          Authenticate the salesforce orgs based on the environment
# Author:               Rahul Gupta
# Created Date:         15-09-2022
# Last Modified Date:   08-11-2024
####################################################################################################################

echo $AUTH_URL >> sfdx_auth_url.txt
sfdx org login sfdx-url --sfdx-url-file sfdx_auth_url.txt --alias $ORG_ALIAS --set-default-dev-hub