# =============================================================================
# FILE: deoplete_elm.py
# AUTHOR: Pawel Bogut
# =============================================================================

from .base import Base
from os import path
import re
import subprocess
import json


class Source(Base):

    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'elm'
        self.mark = '[elm]'
        self.filetypes = ['elm']
        self.rank = 1000
        self.input_pattern = r'[^\s\'"]*'
        self.current = vim.current
        self.vim = vim

    def on_init(self, context):
        self.oracle_cmd = 'elm-oracle'

    def get_complete_position(self, context):
        m = re.search(r'[^\s\'"]*$', context['input'])
        if m:
            return m.start()

    def get_complete_query(self, context):
        m = re.search(r'[^\s\'"]*$', context['input'])
        if m:
            return m.group()
        return None

    def gather_candidates(self, context):
        file_path = self.current.buffer.name
        current_path = self.get_project_root(file_path)
        query = self.get_complete_query(context)
        cmd = 'cd {} && {} {} "{}"'.format(current_path, self.oracle_cmd,
                                           file_path, query)
        if not query or query == '':
            return []

        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.read()

        jsonData = str(output.decode('utf-8'))

        if not jsonData or jsonData == '':
            return []

        result = json.loads(jsonData)

        if not result:
            return []

        candidates = []

        for item in result:
            word = self.get_word(item, query)
            candidate = {'word': word,
                         'abbr': word,
                         'kind': item['signature'],
                         'info': item['comment'],
                         'dup': 0}
            candidates.append(candidate)

        return candidates

    def get_word(self, item, query):
        if item['name'].find(query) == 0:
            return item['name']
        else:
            return item['fullName']

    def get_project_root(self, file_path):
        current_path = path.dirname(file_path)
        while current_path != '/' and not path.exists(
            path.join(current_path, 'elm-package.json')
        ):
            current_path = path.dirname(current_path)

        if current_path == '/':
            current_path = path.dirname(file_path)

        return current_path
