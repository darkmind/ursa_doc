from requests import post
from sys import argv
from git import Repo
from os import getcwd
from time import strftime, gmtime

_, token = argv

repo = Repo(getcwd())
headcommit = repo.head.commit

new=headcommit.author.name + "\n" + \
    strftime("%a, %d %b %Y %H:%M", gmtime(headcommit.committed_date)) + \
    "\n" + headcommit.message
method='sendMessage'
data={ 'chat_id': '-305732799', 'text': new }

response = post(
    url='https://api.telegram.org/bot{0}/{1}'.format(token, method),
    data=data
).json()
