#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os

extensions = ['sphinx.ext.autodoc', 'sphinx.ext.doctest', 'sphinx.ext.todo',
              'sphinx.ext.viewcode', 'sphinx.ext.extlinks',
              'sphinxcontrib.seqdiag', 'sphinxcontrib.blockdiag']

todo_include_todos = True

templates_path = ['_templates']
html_theme_path = ['_templates']

source_suffix = '.rst'

master_doc = 'index'

project = u'RPG system documentation'

exclude_patterns = ['_build']

pygments_style = 'sphinx'

html_theme = 'blog'

html_add_permalinks = ''

html_short_title = project

html_show_sphinx = False
