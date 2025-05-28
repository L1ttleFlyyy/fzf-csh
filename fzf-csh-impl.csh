#!/usr/bin/env csh

# fzf-csh: C shell (csh) history support for fzf
#
# home page: https://github.com/graahnul-grom/fzf-csh
# copyright (c) 2022 dmn <graahnul.grom@ya.ru>
# license: BSD2CLAUSE
# fzf home page: https://github.com/junegunn/fzf
#

if ( $#argv != 2 ) then
    exit 1
endif

set HIST_MODE = 0
set FILE_MODE = 0
set DIR_MODE = 0 #TODO: support dir search and ALT-C mode

switch ($2) 
    case "file":
        set FILE_MODE = 1
        breaksw
    case "hist":
        set HIST_MODE = 1
        breaksw
    case "dir":
        set DIR_MODE = 1
        breaksw
    default:
        exit 1
        breaksw
endsw

set FILE_CMD = $1
set KEY_AUX = "^X^F^G^H^I^J"

touch $FILE_CMD >& /dev/null
if ( $? != 0 ) then
    echo "fzf-csh: unable to write to ${FILE_CMD}."
    unset FILE_CMD
    unset KEY_AUX
    unset FILE_MODE
    unset HIST_MODE
    unset DIR_MODE
    exit 1
endif

if ( $DIR_MODE == 1 ) then
    printf "cd " >! $FILE_CMD
else
    printf "bindkey -s %s " $KEY_AUX >! $FILE_CMD
endif

set TMP_FZF_CMD = ""
set TMP_FZF_OPT = ""

if ( $FILE_MODE == 1 ) then
    set TMP_FZF_CMD = "fzf"
    set TMP_FZF_OPT = ""
    if ( $?FZF_CTRL_T_COMMAND ) then
        set TMP_FZF_CMD = "${FZF_CTRL_T_COMMAND} | fzf"
    endif
    if ( $?FZF_CTRL_T_OPTS ) then
        set TMP_FZF_OPT = "${TMP_FZF_OPT} ${FZF_CTRL_T_OPTS}"
    endif
endif

if ( $HIST_MODE == 1 ) then
    set TMP_FZF_CMD = "history -h | tac | fzf"
    set TMP_FZF_OPT = "--scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line +m"
    if ( $?FZF_CTRL_R_OPTS ) then
        set TMP_FZF_OPT = "${TMP_FZF_OPT} ${FZF_CTRL_R_OPTS}"
    endif
endif

if ( $DIR_MODE == 1 ) then
    set TMP_FZF_CMD = "find . -type d | fzf"
    set TMP_FZF_OPT = ""
    if ( $?FZF_ALT_C_COMMAND ) then
        set TMP_FZF_CMD = "${FZF_ALT_C_COMMAND} | fzf"
    endif
    if ( $?FZF_ALT_C_OPTS ) then
        set TMP_FZF_OPT = "${TMP_FZF_OPT} ${FZF_ALT_C_OPTS}"
    endif
endif

unset FILE_MODE
unset HIST_MODE
unset DIR_MODE

eval "${TMP_FZF_CMD} ${TMP_FZF_OPT}" | \
    sed -E -e 's,\\,\\\\\\\\,g' \
         -e 's, ,\\ ,g'       \
         -e "s,',\\',g"       \
         -e 's,",\\",g'       \
         -e 's,\$,\\$,g'      \
         -e 's,#,\\#,g'       \
         -e 's,`,\\`,g'       \
         -e 's,&,\\&,g'       \
         -e 's,\(,\\(,g'      \
         -e 's,\),\\),g'      \
         -e 's,~,\\~,g'       \
         -e 's,\[,\\[,g'      \
         -e 's,],\\],g'       \
         -e 's,\{,\\{,g'      \
         -e 's,\},\\},g'      \
         -e 's,<,\\<,g'       \
         -e 's,>,\\>,g'       \
         -e 's,\;,\\;,g'      \
         -e 's,\|,\\|,g'      \
         -e 's,\?,\\?,g'      \
         -e 's,\^,\\^,g'      \
    >> $FILE_CMD

if ( $? != 0 ) then
    echo bindkey \"${KEY_AUX}\" backward-char >! $FILE_CMD
endif

unset FILE_CMD
unset KEY_AUX
unset TMP_FZF_CMD
unset TMP_FZF_OPT
