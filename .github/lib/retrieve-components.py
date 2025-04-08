import os, subprocess

ORG_ALIAS 			= os.environ['ORG_ALIAS']
API_VERSION 		= os.environ['API_VERSION']

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
