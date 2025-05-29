# fzf-csh: C shell (csh) history support for fzf
#
# home page: https://github.com/graahnul-grom/fzf-csh
# copyright (c) 2022-2023 dmn <graahnul.grom@ya.ru>
# license: BSD2CLAUSE
# fzf home page: https://github.com/junegunn/fzf
#

if ( ! -X "fzf" ) then
    echo "fzf-csh: could not find fzf executable."
    echo "         make sure fzf is installed."
    exit 1
endif

set DIR_OUT = $HOME

if ( $?FZF_CSH_TMP_DIR ) then
    set DIR_OUT = $FZF_CSH_TMP_DIR
endif

test -e $DIR_OUT -a -d $DIR_OUT
if ( $? != 0 ) then
    echo "fzf-csh: ${DIR_OUT} does not exist or not a directory."
    unset DIR_OUT
    exit 1
endif

test -w $DIR_OUT
if ( $? != 0 ) then
    echo "fzf-csh: unable to write to ${DIR_OUT}."
    echo "         make sure the directory is writable, or set the"
    echo '         $FZF_CSH_TMP_DIR environment variable to point'
    echo "         to some writable directory before sourcing the"
    echo "         fzf-csh.csh file."
    unset DIR_OUT
    exit 1
endif


# TODO: randomize FILE_CMD to make sure the script is reentrant
set FILE_CMD = "${DIR_OUT}/fzf-csh-cmd.tmp"
set FILE_IMPL = "fzf-csh-impl.csh"

if ( ! -X $FILE_IMPL ) then
    echo "fzf-csh: could not find ${FILE_IMPL}."
    echo "         make sure it's in the PATH and has executable bit set (chmod +x)."
    unset DIR_OUT
    unset FILE_CMD
    unset FILE_IMPL
    exit 1
endif


set KEY_HISTORY = "^R"
set KEY_HISTORY_AUX = "^X^A^B^C^D^E"
set KEY_AUX = "^X^F^G^H^I^J"

bindkey -c $KEY_HISTORY_AUX "history | ${FILE_IMPL} ${FILE_CMD} hist && source ${FILE_CMD}; \
                             rm -f ${FILE_CMD}"
bindkey -s $KEY_HISTORY "${KEY_HISTORY_AUX}${KEY_AUX}"


set KEY_FILES = "^T"
set KEY_FILES_AUX = "^X^K^L^M^N^O"

bindkey -c $KEY_FILES_AUX "${FILE_IMPL} ${FILE_CMD} file && source ${FILE_CMD}; \
                           rm -f ${FILE_CMD}"
bindkey -s $KEY_FILES "${KEY_FILES_AUX}${KEY_AUX}"

set KEY_DIRS = "^[c"
set KEY_DIRS_AUX = "^X^O^P^Q^R^S"

bindkey -c $KEY_DIRS_AUX "${FILE_IMPL} ${FILE_CMD} dir && source ${FILE_CMD}; \
                           rm -f ${FILE_CMD}"
bindkey -s $KEY_DIRS "${KEY_DIRS_AUX}${KEY_AUX}"

unset DIR_OUT
unset FILE_CMD
unset FILE_IMPL
unset KEY_HISTORY
unset KEY_HISTORY_AUX
unset KEY_FILES
unset KEY_FILES_AUX
unset KEY_DIRS
unset KEY_DIRS_AUX
unset KEY_AUX
