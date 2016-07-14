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
from itertools import groupby

# This is the also the order (top to bottom) at which the imports must appear
extras   = ['static']
prefixes = ['java', 'javax', 'org', 'com']


def importSort(x, y):
    lessThan = -1
    greaterThan = 1

    Xwords = x.split()
    Ywords = y.split()

    # Handle imports and static first
    if len(Xwords) > 1:
        # TODO make import modular
        assert( ( Xwords[0] == "import" ) and ( Ywords[0] == "import") )
        for extra in extras:
            if ( Xwords[1] == extra )  == ( Ywords[1] == extra ):
                if Xwords[1] == extra:
                   break
                else:
                    continue
            return lessThan if Xwords[1] == extra else greaterThan

        return importSort(Xwords[-1], Ywords[-1] )

    Xwords = x.split('.')
    Ywords = y.split('.')

    for prefix in prefixes:
        if ( Xwords[0] == prefix)  == ( Ywords[0] == prefix ):
            if Xwords[0] == prefix:
                break
            else:
                continue
        return lessThan if Xwords[0] == prefix else greaterThan

    return str.__eq__( x, y )

def sanitize( lines ):
    # remove duplicates
    lines = list(set(lines))
    # remove strings that are just spaces or empty
    lines = [ x for x in lines if ( x or not x.isspace ) ]
    return lines

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
    # TODO set up templates


def collectImports( lines ):
    parseTemplates()
    lines = sanitize( lines )
    sortedLines = sorted(lines, key=importCompare)
    groupByObject = groupby(sortedLines, importCompare)
    groupedSortedLines  = []
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

python << endpython

lines = collectImports(vim.eval( "lines" ) )
vim.command("'<,'> d")
#vim.command('execute "normal! <,\'> d"')

for line in lines:
    #vim.command("norm i" + line + "\n" )
    vim.command('execute "normal! i' + line + '\<cr>"')

vim.command('execute "normal! dd"')
vim.command('execute "normal! k"')

endpython

    return lines
endfunction

command ImportSort call <sid>start()
xmap e :ImportSort
