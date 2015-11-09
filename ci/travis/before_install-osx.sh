#!/bin/bash

brew update
brew outdated xctool || brew upgrade xctool
brew install pcre
