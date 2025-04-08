import os, subprocess

print('Inside retrieve-components.py ...')

ORG_ALIAS 			= os.environ['ORG_ALIAS']
# ORG_MY_DOMAIN_URL	= os.environ['ORG_MY_DOMAIN_URL']
AUTH_URL 			= os.environ['AUTH_URL']
API_VERSION 		= os.environ['API_VERSION']
# GIT_USER_EMAIL 		= os.environ['GIT_USER_EMAIL']
# GIT_USER_NAME 		= os.environ['GIT_USER_NAME']
# BASE_BRANCH 		= os.environ['BASE_BRANCH']
# WORKSPACE 			= os.environ['GITHUB_WORKSPACE']
MAX_RETRIES			= 10

# retrieve all the components in the branch, based on the package.xml configured
result = subprocess.run(
            ['sfdx', 'project', 'retrieve', 'start', '--target-org', ORG_ALIAS, '--manifest', 'manifest/package.xml', '--api-version', API_VERSION], 
            capture_output=True, 
            text=True
        )

if result.returncode == 0:
    print('******* Successfully retrieved all the components *******')
else:
    print('******* Failed to retrieve all the components *******')


os.system('ls -alRf force-app/main/default')