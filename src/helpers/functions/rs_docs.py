import os
import re


docs = open('overview.md', "w+")

for file in os.listdir('.'):
	if file.endswith('.ps1'):
	
		fileName = os.path.basename(file)
		fileBase = os.path.splitext(fileName)[0]
		fileExt = os.path.splitext(fileName)[1]
		
		docs.write('* __%s__ \[[src](https://github.com/chocolatey/chocolatey/blob/master/src/helpers/functions/%s)\]  ' % (fileBase, fileName) + '\n');
	
		with open(file, 'r') as fh:
			data = fh.read()

			# Find Synopsis
			s = re.search('\.SYNOPSIS\n((.|\n)+?)\n*^\.\w+', data, re.MULTILINE)
			if s != None:
				docs.write(s.group(1) + '  \n');

			# Find example
			s = re.search('\.EXAMPLE\n((.|\n)+?)\n*^\.\w+', data, re.MULTILINE)
			if s != None:
				docs.write('```powershell' + '\n');
				docs.write(s.group(1) + '\n');
				docs.write('```' + '\n');

docs.close()