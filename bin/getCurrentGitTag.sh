#!/bin/bash
REPO=$1
BRANCH=$(git --git-dir=$REPO/.git --work-tree=$REPO describe --all)
TAG=$(git --git-dir=$REPO/.git --work-tree=$REPO describe --long --always)
ORIGIN=$(git --git-dir=$REPO/.git --work-tree=$REPO config --get remote.origin.url)
UNTRACKED=$(git --git-dir=$REPO/.git --work-tree=$REPO status --porcelain)
if [ "$UNTRACKED" != "" ]; then
    UNTRACKED=" [UnCommited Changes $(date)]"
fi
echo "$ORIGIN ($BRANCH) ($TAG)$UNTRACKED"
