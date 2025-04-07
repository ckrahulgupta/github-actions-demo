####################################################################################################################
# Description:          Update tesst.config.json based on new Apex class added
# Author:               Rahul Gupta
# Created Date:         13-03-2025
# Last Modified Date:   02-04-2025
####################################################################################################################

import os, subprocess, json, re, csv, time, requests

# constants

ORG_ALIAS 			= os.environ['ORG_ALIAS']
ORG_MY_DOMAIN_URL	= os.environ['ORG_MY_DOMAIN_URL']
AUTH_URL 			= os.environ['AUTH_URL']
API_VERSION 		= os.environ['API_VERSION']
GIT_USER_EMAIL 		= os.environ['GIT_USER_EMAIL']
GIT_USER_NAME 		= os.environ['GIT_USER_NAME']
BASE_BRANCH 		= os.environ['BASE_BRANCH']
WORKSPACE 			= os.environ['GITHUB_WORKSPACE']
MAX_RETRIES			= 10

os.system(f'git config --global --add safe.directory {WORKSPACE}')

os.system(f'sfdx org display --target-org {ORG_ALIAS} --api-version {API_VERSION} --verbose --json > auth.json')

with open('auth.json', 'r') as auth_file:
	auth = json.load(auth_file)
	ACCESS_TOKEN = auth['result']['accessToken']


# fetch all the apex classes in the org, excluding 
# the managed package classes

apex_classes_query_str = '''
	SELECT Id, 
		   Name, 
		   NamespacePrefix 
	FROM ApexClass 
	WHERE NamespacePrefix = null 
	AND (NOT Name LIKE '%Test%')
	ORDER BY CreatedDate ASC
'''

os.system(f'sfdx data query --query "{apex_classes_query_str}" --use-tooling-api --result-format=json --target-org={ORG_ALIAS} --api-version={API_VERSION} > apex-classes.json')


apex_classes_id_str = ''

with open('apex-classes.json', 'r') as apex_classes_json_file:
    apex_classes = json.load(apex_classes_json_file)

    for apex_class in apex_classes['result']['records']:
        apex_classes_id_str += f"'{apex_class['Id']}',"

apex_classes_id_str = apex_classes_id_str.rstrip(',')


# fetch all the dependent apex classes for the apex classes
# fetched from above query

apex_classes_metadata_dependency_query_str = f'''
	SELECT MetadataComponentId, 
		   MetadataComponentName, 
		   MetadataComponentType, 
		   RefMetadataComponentId, 
		   RefMetadataComponentName, 
		   RefMetadataComponentType 
	FROM MetadataComponentDependency 
	WHERE RefMetadataComponentType = 'ApexClass' 
	AND MetadataComponentType = 'ApexClass' 
	AND RefMetadataComponentId IN ({apex_classes_id_str})
	ORDER BY RefMetadataComponentName ASC
'''

def create_bulk_job_for_exporting_dependent_classes():

	endpoint = f'{ORG_MY_DOMAIN_URL}/services/data/v63.0/tooling/jobs/query'

	headers = {
		'Content-Type': 'application/json',
    	'Authorization': f'Bearer {ACCESS_TOKEN}'
	}

	request_body = {
		'operation': "query",
	    'query': apex_classes_metadata_dependency_query_str,
	    'contentType': "CSV"
	}

	response_body = requests.post(endpoint, headers=headers, data=json.dumps(request_body))

	if response_body.status_code == 200:
		return response_body.json()['id']
	else:
		print(f'Failed to create Bulk API job. {response_body.text}')

	return -1


def get_bulk_job_status(job_id):

	endpoint = f'{ORG_MY_DOMAIN_URL}/services/data/v63.0/tooling/jobs/query/{job_id}'

	headers = {
		'Content-Type': 'application/json',
    	'Authorization': f'Bearer {ACCESS_TOKEN}'
	}
 
	response_body = requests.get(endpoint, headers=headers)

	if response_body.status_code == 200:
		return response_body.json()['state']
	else:
		print(f'Failed to get Bulk API job status. {response_body.text}')	

	return -1


def get_bulk_job_result(job_id):

	endpoint = f'{ORG_MY_DOMAIN_URL}/services/data/v63.0/tooling/jobs/query/{job_id}/results'

	headers = {
		'Content-Type': 'application/json',
    	'Authorization': f'Bearer {ACCESS_TOKEN}'
	}

	response_body = requests.get(endpoint, headers=headers)

	if response_body.status_code == 200:
		with open('dependent-apex-classes.csv', 'w+') as dependent_classes_csv_file:
			dependent_classes_csv_file.write(response_body.text)
	else:
		print(f'Failed to get Bulk API job result. {response_body.text}')

	return -1

job_id = create_bulk_job_for_exporting_dependent_classes()


if job_id != -1:
    
	retries = 0
 
	while retries < MAX_RETRIES:

		print(f'Fetching Job Status ... Retry Count Left - {MAX_RETRIES - retries - 1}')
		status = get_bulk_job_status(job_id)

		if status == 'JobComplete':
			break;

		retries = retries + 1
  
		time.sleep(2.5)

	get_bulk_job_result(job_id)


with open('dependent-apex-classes.csv', 'r') as dependent_classes_csv_file:
    # Read the CSV file
    csv_reader = csv.DictReader(dependent_classes_csv_file)
    
    # Convert the rows to a list of dictionaries
    rows = list(csv_reader)

    # Open the output JSON file
    with open('dependent-apex-classes.json', mode='w', encoding='utf-8') as dependent_classes_json_file:
        # Write the list of dictionaries as JSON
        json.dump(rows, dependent_classes_json_file, indent=4)


dependent_apex_classes = {}

with open('dependent-apex-classes.json', 'r') as dependent_classes_json_file:
	dependent_apex_classes = json.load(dependent_classes_json_file)


tests = {}

with open('tests.config.json', 'r+') as tests_json_file:
    tests = json.load(tests_json_file)


# extract the test classes from the dependent apex classes, and
# write them in the tests.config.json.
# Note: Only add or update any new test class that is not present

for dependent_apex_class in dependent_apex_classes:
    dependent_apex_class = dict(dependent_apex_class)

    if dependent_apex_class['RefMetadataComponentName'] in tests:

		# if the apex class is already add in the tests.config.json file,
		# then just update with the new tests (if any)

        if re.search('Test', dependent_apex_class['MetadataComponentName']):
            items = tests[dependent_apex_class['RefMetadataComponentName']]['tests']
            items.append(dependent_apex_class['MetadataComponentName'])
            
            tests[dependent_apex_class['RefMetadataComponentName']]['tests'] = list(set(items))
            tests[dependent_apex_class['RefMetadataComponentName']]['tests'].sort()
   
    else:

		# if the apex class is not present in the tests.config.json file,
		# then add the class and its corresponding tests

        if re.search('Test', dependent_apex_class['MetadataComponentName']):
            tests[dependent_apex_class['RefMetadataComponentName']] = {}
            tests[dependent_apex_class['RefMetadataComponentName']]['tests'] = [dependent_apex_class['MetadataComponentName']]
        


with open('tests.config.json', 'w+') as tests_config_file: 
    json.dump(tests, tests_config_file, indent=4)


# commit and push the tests.config.json to the HEAD

os.system(f'git config --global user.email {GIT_USER_EMAIL}')
os.system(f'git config --global user.name {GIT_USER_NAME}')

os.system('git add tests.config.json')
os.system('git commit -m "build: update tests.config.json"')

result = subprocess.run(
			['git', 'push', 'origin', BASE_BRANCH], 
			capture_output=True, 
			text=True
		)

if 'Everything up-to-date' in result.stderr:
    # assign the step output for "continue" as true
    os.system('echo "continue=true" >> "$GITHUB_OUTPUT"')
else:
    # assign the step output for "continue" as false
    os.system('echo "continue=false" >> "$GITHUB_OUTPUT"')
