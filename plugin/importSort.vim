import com.test.test
import java.test.test
import java.test.test2
import com.google.test1
import com.test.test
import javax.test.test
import custom.test.test

import static test.static.test

python << endpython
import vim
import json
from itertools import groupby

# This is the also the order (top to bottom) at which the imports must appear
keyword  = "import"
split    = "."
extras   = ['static']
prefixes = ['java', 'javax', 'org', 'com']


# A comparator function that determines ordering by a predefined set of prefixes.
def importSort(x, y):
    lessThan = -1
    greaterThan = 1

    Xwords = x.split()
    Ywords = y.split()

    # Handle imports and static first
    if len(Xwords) > 1:
        assert( ( Xwords[0] == keyword ) and ( Ywords[0] == keyword) )
        for extra in extras:
            if ( Xwords[1] == extra )  == ( Ywords[1] == extra ):
                if Xwords[1] == extra:
                   break
                else:
                    continue
            return lessThan if Xwords[1] == extra else greaterThan

        return importSort(Xwords[-1], Ywords[-1] )

    Xwords = x.split( split )
    Ywords = y.split( split )

    for prefix in prefixes:
        if ( Xwords[0] == prefix)  == ( Ywords[0] == prefix ):
            if Xwords[0] == prefix:
                break
            else:
                continue
        return lessThan if Xwords[0] == prefix else greaterThan

    return str.__eq__( x, y )

def sanitize( lines ):
    # Remove duplicates
    lines = list(set(lines))

    # Remove strings that are only spaces, or empty
    lines = [ x for x in lines if ( x or not x.isspace ) ]

    return lines

# A class wrapper so that a custom comparator can be used as a key.
# This is necessary because the python 3 sort function only accepts keys.
class importCompare:
    def __init__(self, obj, *args):
        self.obj = obj
    def __lt__(self, other):
        return importSort(self.obj, other.obj) < 0
    def __gt__(self, other):
        return importSort(self.obj, other.obj) > 0
    def __eq__(self, other):
        return importSort(self.obj, other.obj) == 0
    def __le__(self, other):
        return importSort(self.obj, other.obj) <= 0
    def __ge__(self, other):
        return importSort(self.obj, other.obj) >= 0
    def __ne__(self, other):
        return importSort(self.obj, other.obj) != 0

def parseTemplates():
    pass
    """
    with open(???) as template:
        data = json.load(template)

        keyword = data["import"]
        assert(keyword != None)

        split = data["split"]
        assert( split )

        extras = data["static"]
        assert( extras )

        prefixes = data["prefixes"]
        assert( prefixes )
        """


def collectImports( lines ):
    groupedSortedLines  = []

    parseTemplates()

    lines = sanitize( lines )
    sortedLines = sorted(lines, key=importCompare)
    groupByObject = groupby(sortedLines, importCompare)

    for _, group in groupByObject:
        groupedSortedLines +=  (list(group))
        groupedSortedLines += [""]

    return groupedSortedLines

endpython

function! s:start()
    " http://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
 
    let path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

    let filetype = &filetype

python << endpython

pluginPath = vim.eval("path")
filetype = vim.eval("filetype")

lines = collectImports(vim.eval( "lines" ) )
vim.command("'<,'> d")

for line in lines:
    vim.command('execute "normal! i' + line + '\<cr>"')

vim.command('execute "normal! ddk"')

endpython
endfunction

command ImportSort call <sid>start()
xmap e :<c-u>ImportSort<cr>
