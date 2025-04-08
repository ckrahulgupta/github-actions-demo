import os, subprocess

# constants
ORG_ALIAS 			= os.environ['ORG_ALIAS']
API_VERSION 		= os.environ['API_VERSION']
# GIT_USER_EMAIL 		= os.environ['GIT_USER_EMAIL']
# GIT_USER_NAME 		= os.environ['GIT_USER_NAME']
GIT_USER_EMAIL 		= 'ckrahulgupta@users.noreply.github.com'
GIT_USER_NAME 		= 'GithubActions'
BASE_BRANCH 		= os.environ['BASE_BRANCH']
WORKSPACE 			= os.environ['GITHUB_WORKSPACE']

# mark the directory as safe
os.system(f'git config --global --add safe.directory {WORKSPACE}')

# set the git username and email
os.system(f'git config --global user.email {GIT_USER_EMAIL}')
os.system(f'git config --global user.name {GIT_USER_NAME}')

# stage and commit the changes
os.system('git add force-app/main/default')
os.system(f'git commit -m "backup: sync all components from {BASE_BRANCH} org to {BASE_BRANCH} backup branch"')

# push the changes to remote
result = subprocess.run(
			['git', 'push', 'origin', BASE_BRANCH], 
			capture_output=True, 
			text=True
		)

print(result.stdout)
print(result.stderr)

if result.returncode == 0:
    print('******* Successfully pushed to remote *******')
else:
    print('******* Failed to push to remote *******')