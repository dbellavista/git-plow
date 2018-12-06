# Git Plow

Git flow + gitlab merge request

**NOTE**: this is a work in progress, and when it works it works only on basic git/git flow setup. It still need to be used both as a software and as a process.

## Actors

* `master` does `git plow ... approved`
* `developer` does `git plow ... complete`

## Features

* git plow feature start
* ... work
* git plow feature propose
  * publish feature
  * create merge request on develop

Once accepted, both approved and complete commands pull develop and delete branch

## Hotfix / Releases

* git plow hotfix start
* ... work
* git plow hotfix propose
  * publish hotfix
  * create merge request on master

The master approves the request and then

* git plow hotfix finish # Must be done by masters
  * pull master
  * tag master
  * checkout develop
  * merge tag
  * push develop
  * delete hotfix branch

The developer then can

* git plow hotfix finish #
  * pull master
  * pull develop
  * delete hotfix branch
