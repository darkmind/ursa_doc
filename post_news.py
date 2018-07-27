#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from os import getcwd
from time import strftime, gmtime
from re import match

from argparse import ArgumentParser
from requests import post
from git import Repo

PARSER = ArgumentParser()
PARSER.add_argument('token', metavar='<Telegram Token>', type=str)
ARGS = PARSER.parse_args()

TOKEN = ARGS.token

REPO = Repo(getcwd())
HEADCOMMIT = REPO.head.commit

NEWS = "Автор: {0}\n{1}\n{2}\nИзменения: https://github.com/darkmind/ursa_doc/commit/{3}\n".format(
    HEADCOMMIT.author.name, strftime("%a, %d %b %Y %H:%M", gmtime(HEADCOMMIT.committed_date)),
    HEADCOMMIT.message, HEADCOMMIT.hexsha
)

DOC_MATCH = r'^documentation/'
DOC_CHANGED = []
FILE_CHANGED = []

CHANGED_FILES = [item.a_path for item in HEADCOMMIT.diff('HEAD~1')]
for file_path in CHANGED_FILES:
    if match(DOC_MATCH, file_path):
        changed_file = 'https://darkmind.github.io/ursa_doc/' + file_path.replace('.rst', '.html')
        DOC_CHANGED.append(changed_file)
    else:
        FILE_CHANGED.append(file_path)

if DOC_CHANGED:
    NEWS += "Измененные страницы:\n"
    for file_name in DOC_CHANGED:
        NEWS += file_name + "\n"

if FILE_CHANGED:
    NEWS += "Измененные файлы:\n"
    for file_name in FILE_CHANGED:
        NEWS += file_name + "\n"

METHOD = 'sendMessage'
DATA = {'chat_id': '-305732799', 'text': NEWS}

RESPONSE = post(
    url='https://api.telegram.org/bot{0}/{1}'.format(TOKEN, METHOD),
    data=DATA
).json()
