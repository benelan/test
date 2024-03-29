#!/bin/bash
# . "$(dirname "$0")/_/husky.sh"

# from https://riptutorial.com/git/example/16164/pre-push

protected_branch='main'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')


if [ $protected_branch = $current_branch ] && [ exec < /dev/tty ]
then
    read -p "You're about to push main, is that what you intended? [y|n] " -n 1 -r < /dev/tty
    echo
    if echo $REPLY | grep -E '^[Yy]$' > /dev/null
    then
        exit 0
    fi
    exit 1
else
    exit_code=1
    conventional_commit_regex='^((build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\(\w+\))?(!)?(: (.*\s*)*))'

    commit_messages=$(git log --format=%B $current_branch --not $protected_branch | tr '\n' ',')

    while [ "$commit_messages" != "$iteration" ]; do
        # extract the substring from start of string up to delimiter.
        iteration=${commit_messages%%,,*}
        # delete this first "element" AND next separator.
        commit_messages=${commit_messages#$iteration,,}
        # match conventional commit regex
        # [[ "$iteration" =~ $conventional_commit_regex ]] && exit_code=0
        if expr "$iteration" : "((build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\(\w+\))?(!)?(: (.*\s*)*))" 1>/dev/null; then
            exit_code=0
        fi
    done
    echo $exit_code
    exit $exit_code
fi
