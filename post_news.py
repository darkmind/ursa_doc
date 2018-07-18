from requests import post
from sys import argv
from git import Repo
from os import getcwd
from time import strftime, gmtime
from re import match

_, token = argv

repo = Repo(getcwd())
headcommit = repo.head.commit

news = "Автор: {0}\n{1}\n{2}\nИзменения: https://github.com/darkmind/ursa_doc/commit/{3}\n".format(
	headcommit.author.name, strftime("%a, %d %b %Y %H:%M", gmtime(headcommit.committed_date)),
	headcommit.message, headcommit.hexsha
)

doc_match = r'^documentation/'
doc_changed = []
file_changed = []

changedFiles = [ item.a_path for item in headcommit.diff('HEAD~1') ]
for file_path in changedFiles:
    if match( doc_match, file_path ):
        changed_file = 'https://darkmind.github.io/ursa_doc/' + file_path.replace('.rst', '.html')
        doc_changed.append(changed_file)
    else:
        file_changed.append(file_path)

if len(doc_changed) > 0:
    news += "Измененные страницы:\n"
    for file_name in doc_changed:
        news += file_name + "\n"

if len(file_changed) > 0:
    news += "Измененные файлы:\n"
    for file_name in file_changed:
        news += file_name + "\n"

print(news)
exit(0)

method='sendMessage'
data={ 'chat_id': '-305732799', 'text': news }

response = post(
    url='https://api.telegram.org/bot{0}/{1}'.format(token, method),
    data=data
).json()
