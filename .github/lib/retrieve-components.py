import os

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

os.system(f'sfdx project retrieve start --target-org {ORG_ALIAS} --manifest manifest/package.xml --api-version {API_VERSION} | tee output.txt')

os.system('ls -alRf force-app/main/default')