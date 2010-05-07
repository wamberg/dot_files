"Make sure the Vim was compiled with +python before loading the script...
if !has("python")
        finish
endif

" Map a keystroke for Visual Mode only (default:F2)
:vmap <f2> :PasteCode<cr>

" Define two commands.. One for just pastebinning alone, and another for
" Gajiming the results
:command -range -nargs=* PasteCode :call PasteMe(<line1>,<line2>,"None")

function! PasteMe(line1,line2,args)
python << EOF
import vim

line1 = vim.eval('a:line1')
line2 = vim.eval('a:line2')
jid = vim.eval('a:args')
format = vim.eval('&ft')

url = PBSend(line1, line2, format)
if not jid == "None":
    gajim_send_url(jid, url)
print "Pasted at %s" % url
EOF
endfunction

python << EOF
import vim
from urllib2 import urlopen

def PBSend(line1, line2, format='text'):
################### BEGIN USER CONFIG ###################
    # Set this to your preferred pastebin
    pastebin = 'http://pastebin.com/api_public.php'
    # Set this to your preferred username
    user = 'wamberg'
#################### END USER CONFIG ####################

    supported_formats = {
        'text' : 'text', 'bash' : 'bash', 'python' : 'python', 'c' : 'c',
        'cpp' : 'cpp', 'html' : 'html4strict', 'java' : 'java',
        'javascript' : 'javascript', 'perl' : 'perl', 'php' : 'php',
        'sql' : 'sql', 'ada' : 'ada', 'apache' : 'apache', 'asm' : 'asm',
        'aspvbs' : 'asp', 'dcl' : 'caddcl', 'lisp' : 'lisp', 'cs' : 'csharp',
        'css' : 'css', 'lua' : 'lua', 'masm' : 'mpasm', 'nsis' : 'nsis',
        'objc' : 'objc', 'ora' : 'oracle8', 'pascal' : 'pascal',
        'basic' : 'qbasic', 'smarty' : 'smarty', 'vb' : 'vb', 'xml' : 'xml',
        'ruby' : 'ruby'
    }

    if not (pastebin[:7] == 'http://'):
        pastebin = 'http://' + pastebin

    code = '\n'.join(vim.current.buffer[int(line1)-1:int(line2)])
    if format in supported_formats.keys():
        data = "paste_format=%s&paste_code=%s&paste_name=%s" % \
                (supported_formats[format], urlencode(code),
                urlencode(user))
    else:
        data = "paste_format=text&paste_code=%s&paste_name=%s" % \
                (urlencode(code), urlencode(user))

    u = urlopen(pastebin, data)
    if u:
        return u.readline()
    else:
        print 'An error occured.'

def urlencode(data):
    out = ""
    for char in data:
        if char.isalnum() or char in ['-','_']:
            out += char
        else:
            char = hex(ord(char))[2:]
            if len(char) == 1:
                char = "0" + char
            out += "%" + char
    return out
EOF

