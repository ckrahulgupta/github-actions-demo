####################################################################################################################
# Description:          Validates components from package.xml
# Author:               Rahul Gupta
# Created Date:         23-03-2025
# Last Modified Date:   25-03-2025
####################################################################################################################

import os, json, re
import xml.etree.ElementTree as et


# Parse the XML string into an ElementTree object
root = et.parse('package/package.xml').getroot()

# Define the XML namespace to handle the namespaced elements
namespace = {'ns': 'http://soap.sforce.com/2006/04/metadata'}

apex_classes = []

# Iterate over all 'types' elements in the XML
for types in root.findall('ns:types', namespace):

    # Get the 'name' of the 'types' element
    name = types.find('ns:name', namespace).text
    if name == 'ApexClass' or name == 'ApexTrigger':
    
        # Get all 'members' for each type and print them
        for member in types.findall('ns:members', namespace):
            apex_classes.append(member.text)

tests = {}

with open('tests.config.json', 'r') as tests_json_file:
    tests = json.load(tests_json_file)

tests_to_run = []

for apex_class in apex_classes:
	
    if apex_class in tests:
        if 'priorityTests' in tests[apex_class]:
            tests_to_run = tests_to_run + tests[apex_class]['priorityTests']
        else:
            tests_to_run = tests_to_run + tests[apex_class]['tests']
            
    elif re.search('Test', apex_class):
        tests_to_run.append(apex_class)

tests_str = ' '.join(list(set(tests_to_run)))

with open(os.getenv('GITHUB_ENV'), 'a') as env_file:
    env_file.write(f'TESTS={tests_str}')