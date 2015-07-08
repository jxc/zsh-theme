# ----------------------------------------------------------------------------
# shared dirty string for all VCS prompt segments
# ----------------------------------------------------------------------------
function dirty_str {
    echo "[dirty]"
}

# ----------------------------------------------------------------------------
# checks if current directory is part of an svn repo
# stolen from: https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/svn-fast-info/svn-fast-info.plugin.zsh
# ----------------------------------------------------------------------------
function in_svn() {
  if $(svn info >/dev/null 2>&1); then
    return 0
  fi
  return 1
}

# ----------------------------------------------------------------------------
# svn prompt
# adapted from: http://zanshin.net/2012/03/09/wordy-nerdy-zsh-prompt/
# ----------------------------------------------------------------------------
function svn_prompt_info {
    # Set up defaults
    local svn_branch=""
    local svn_repository=""
    local svn_version=""
    local svn_change=""

    if in_svn; then
        # query svn info and parse the results
        svn_branch=`svn info | grep '^URL:' | egrep -o '((tags|branches)/[^/]+|trunk).*' | sed -E -e 's/^(branches|tags)\///g'`
        svn_repository=`svn info | grep '^Repository Root:' | egrep -o '(http|https|file|svn|svn+ssh)/[^/]+' | egrep -o '[^/]+$'`
        svn_version=`svnversion -n`
        
        # this is the slowest test of the bunch
        change_count=`svn status | grep "?\|\!\|M\|A" | wc -l`
        if [ "$change_count" != "       0" ]; then
            svn_change="$ZSH_THEME_GIT_PROMPT_DIRTY"
        else
            svn_change="$ZSH_THEME_GIT_PROMPT_CLEAN"
        fi
        
        # show the results
        echo "%{$fg[blue]%}$ZSH_THEME_SVN_PROMPT_PREFIX$svn_repository/$svn_branch @ $svn_version%{$reset_color%}%{$fg[yellow]%}$svn_change$ZSH_THEME_SVN_PROMPT_SUFFIX"
        
    fi
}

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"
PROMPT=$'%{$fg_bold[green]%}%*  %{$fg[cyan]%}${PWD/#$HOME/~}%b  %{$fg_bold[blue]%}$(git_prompt_info)$(svn_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}\n%{$fg[black]%}: %{$fg[magenta]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}%{$fg[yellow]%}%m %{$reset_color%}%{$fg[cyan]%}$%{$fg[black]%}; %{$reset_color%}'

ZSH_THEME_VCS_PROMPT_PREFIX=":(%{$fg[red]%}"
ZSH_THEME_VCS_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_VCS_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}$(dirty_str)%{$reset_color%}"
ZSH_THEME_VCS_PROMPT_CLEAN="%{$fg[blue]%})"

ZSH_THEME_GIT_PROMPT_PREFIX="git$ZSH_THEME_VCS_PROMPT_PREFIX"
ZSH_THEME_GIT_PROMPT_SUFFIX="$ZSH_THEME_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$ZSH_THEME_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$ZSH_THEME_VCS_PROMPT_CLEAN"

ZSH_THEME_SVN_PROMPT_PREFIX="svn$ZSH_THEME_VCS_PROMPT_PREFIX"
ZSH_THEME_SVN_PROMPT_SUFFIX="$ZSH_THEME_VCS_PROMPT_SUFFIX"
ZSH_THEME_SVN_PROMPT_DIRTY="$ZSH_THEME_VCS_PROMPT_DIRTY"
ZSH_THEME_SVN_PROMPT_CLEAN="$ZSH_THEME_VCS_PROMPT_CLEAN"

# Update current prompt every second (to refresh the current time)
TMOUT=1
TRAPALRM() {
    zle reset-prompt
}
