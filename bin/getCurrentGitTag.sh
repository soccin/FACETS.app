#!/bin/bash
REPO=$1
git --git-dir=$REPO/.git --work-tree=$REPO describe --always --long
