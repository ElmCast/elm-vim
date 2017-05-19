# -*- coding: utf-8 -*-

# For debugging, use this command to start neovim:
#
# NVIM_PYTHON_LOG_FILE=nvim.log NVIM_PYTHON_LOG_LEVEL=INFO nvim
#
#
# Please register source before executing any other code, this allow cm_core to
# read basic information about the source without loading the whole module, and
# modules required by this module
from cm import register_source, getLogger, Base

register_source(name='elm-oracle',
                priority=9,
                abbreviation='elm',
                scopes=['elm'],
                cm_refresh_patterns=[r'\.$'],)

import json
import subprocess
from os import path

logger = getLogger(__name__)


class Source(Base):

    def __init__(self, nvim):
        super(Source, self).__init__(nvim)
        self._checked = False

    def cm_refresh(self, info, ctx, *args):

        src = self.get_src(ctx).encode('utf-8')
        typed = ctx['typed']
        startcol = ctx['startcol']
        filepath = ctx['filepath']

        query = typed.lstrip(" \t\'\"")
        args = ['elm-oracle', filepath, query]

        logger.debug("args: %s", args)

        proj_dir = self._project_root(filepath)

        logger.debug("dir: %s", proj_dir)

        proc = subprocess.Popen(args=args,
                                # stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.DEVNULL,
                                cwd=proj_dir)

        result, errs = proc.communicate(src, timeout=30)
        logger.debug("result: %s", result)
        result = json.loads(result.decode('utf-8'))

        if not result:
            return

        matches = []

        for item in result:
            word = item['name']
            menu = item.get('signature', item.get('fullName',''))
            m = { 'word': word, 'menu': menu, 'info': item['comment'] }

            matches.append(m)

        self.complete(info["name"], ctx, startcol, matches)

        return matches

    def _project_root(self, filepath):
        ret = path.dirname(filepath)
        while ret != '/' and not path.exists(path.join(ret, 'elm-package.json')):
            ret = path.dirname(ret)

        if ret == '/':
            return path.dirname(filepath)

        return ret
