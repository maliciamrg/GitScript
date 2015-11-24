#!/bin/bash 
# A simple script to backup an organization's GitHub repositories.
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters (repertoire des git)"
	exit 0
fi

source ./github_auth.cfg
GHBU_ORG=$(eval echo ${GHBU_ORG})                                  # the GitHub organization whose repos will be backed up
                                                                     # (if you're backing up a user's repos instead, this should be your GitHub username)
GHBU_UNAME=$(eval echo ${GHBU_UNAME})                               # the username of a GitHub account (to use with the GitHub API)
GHBU_PASSWD=$(eval echo ${GHBU_PASSWD})                             # the password for that account 

GHBU_BACKUP_DIR=${GHBU_BACKUP_DIR-"$1"}                  # where to place the backup files
GHBU_GITHOST=${GHBU_GITHOST-"github.com"}                            # the GitHub hostname (see comments)
GHBU_PRUNE_OLD=${GHBU_PRUNE_OLD-true}                                # when `true`, old backups will be deleted
GHBU_PRUNE_AFTER_N_DAYS=${GHBU_PRUNE_AFTER_N_DAYS-3}                 # the min age (in days) of backup files to delete
GHBU_SILENT=${GHBU_SILENT-false}                                     # when `true`, only show error messages 
GHBU_API=${GHBU_API-"https://api.github.com"}                        # base URI for the GitHub API
#GHBU_GIT_CLONE_CMD="git clone --quiet --mirror git@${GHBU_GITHOST}:" # base command to use to clone GitHub repos
GHBU_GIT_CLONE_CMD="git clone --quiet git@${GHBU_GITHOST}:" # base command to use to clone GitHub repos

TSTAMP=`date "+%Y%m%d-%H%M"`

# The function `check` will exit the script if the given command fails.
function check {
  "$@"
  status=$?
  if [ $status -ne 0 ]; then
    echo "ERROR: Encountered error (${status}) while running the following:" >&2
    echo "           $@"  >&2
    echo "       (at line ${BASH_LINENO[0]} of file $0.)"  >&2
    echo "       Aborting." >&2
    exit $status
  fi
}

# The function `tgz` will create a gzipped tar archive of the specified file ($1) and then remove the original
function tgz {
   check tar zcf $1.tar.gz $1 && check rm -rf $1
}

$GHBU_SILENT || (echo "" && echo "=== INITIALIZING ===" && echo "")

$GHBU_SILENT || echo "Using git directory $GHBU_BACKUP_DIR"
check mkdir -p $GHBU_BACKUP_DIR

$GHBU_SILENT || echo -n "Fetching list of repositories for ${GHBU_ORG}..."

#REPOLIST=`check curl --silent -u $GHBU_UNAME:$GHBU_PASSWD ${GHBU_API}/orgs/${GHBU_ORG}/repos -q | check grep "\"name\"" | check awk -F': "' '{print $2}' | check sed -e 's/",//g'`
# NOTE: if you're backing up a *user's* repos, not an organizations, use this instead:
REPOLIST=`check curl --silent -u $GHBU_UNAME:$GHBU_PASSWD ${GHBU_API}/user/repos -q | check grep "\"name\"" | check awk -F': "' '{print $2}' | check sed -e 's/",//g'`

$GHBU_SILENT || echo "found `echo $REPOLIST | wc -w` repositories."


$GHBU_SILENT || (echo "" && echo "=== CLONNING ALL ===" && echo "")

for REPO in $REPOLIST; do
	if [ -d "$1/${REPO}/.git" ]; then
		$GHBU_SILENT || echo "Already exist ${GHBU_ORG}/${REPO}"
	else 
		$GHBU_SILENT || echo "Clonning ${GHBU_ORG}/${REPO}"
		check ${GHBU_GIT_CLONE_CMD}${GHBU_ORG}/${REPO}.git #${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}-${TSTAMP}.git && tgz ${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}-${TSTAMP}.git
	fi;
#   $GHBU_SILENT || echo "Backing up ${GHBU_ORG}/${REPO}.wiki (if any)"
#   ${GHBU_GIT_CLONE_CMD}${GHBU_ORG}/${REPO}.wiki.git ${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}.wiki-${TSTAMP}.git 2>/dev/null && tgz ${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}.wiki-${TSTAMP}.git

#   $GHBU_SILENT || echo "Backing up ${GHBU_ORG}/${REPO} issues"
#   check curl --silent -u $GHBU_UNAME:$GHBU_PASSWD ${GHBU_API}/repos/${GHBU_ORG}/${REPO}/issues -q > ${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}.issues-${TSTAMP} && tgz ${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}.issues-${TSTAMP}
done

#if $GHBU_PRUNE_OLD; then
#  $GHBU_SILENT || (echo "" && echo "=== PRUNING ===" && echo "")
#  $GHBU_SILENT || echo "Pruning backup files ${GHBU_PRUNE_AFTER_N_DAYS} days old or older."
#  $GHBU_SILENT || echo "Found `find $GHBU_BACKUP_DIR -name '*.tar.gz' -mtime +$GHBU_PRUNE_AFTER_N_DAYS | wc -l` files to prune."
#  find $GHBU_BACKUP_DIR -name '*.tar.gz' -mtime +$GHBU_PRUNE_AFTER_N_DAYS -exec rm -fv {} > /dev/null \; 
#fi

$GHBU_SILENT || (echo "" && echo "=== DONE ===" && echo "")


$GHBU_SILENT || (echo "" && echo "=== MISSING GITHUB ===" && echo "")
for f in $1/*;do
	if [ -d $f ]; then
#		$GHBU_SILENT || echo "GITHUB $f"
		if [ ! -d "$f/.git" ]; then
#			$GHBU_SILENT || echo "$f/.git"
#		else 
			$GHBU_SILENT || echo "Missing GITHUB ${GHBU_ORG}/$f"
		fi;
		if [ ! -d "$f/src" ]; then
			mkdir "$f/src"
			$GHBU_SILENT || echo "Missing GITHUB src : $f"
		fi;
		if [ ! -d "$f/bin" ]; then
			mkdir "$f/bin"
			$GHBU_SILENT || echo "Missing GITHUB bin : $f"
		fi;
		if [ ! -e "$f/.classpath" ]; then
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<classpath>
	<classpathentry kind=\"src\" path=\"\src\"/>
	<classpathentry kind=\"con\" path=\"org.eclipse.jdt.launching.JRE_CONTAINER\"/>
	<classpathentry kind=\"output\" path=\"bin\"/>
</classpath>" > "$f/.classpath"
			$GHBU_SILENT || echo "Missing GITHUB classpath : $f"
		fi;
		if [ ! -e "$f/.project" ]; then
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<projectDescription>
	<name>$(basename $f)</name>
	<comment></comment>
	<projects>
	</projects>
	<buildSpec>
		<buildCommand>
			<name>org.eclipse.jdt.core.javabuilder</name>
			<arguments>
			</arguments>
		</buildCommand>
	</buildSpec>
	<natures>
		<nature>org.eclipse.jdt.core.javanature</nature>
	</natures>
</projectDescription>" > "$f/.project"
			$GHBU_SILENT || echo "Missing GITHUB project : $f"
		fi;
		if [ ! -e "$f/.gitignore" ]; then
echo "" > "$f/.gitignore"
			$GHBU_SILENT || echo "Missing GITHUB gitignore : $f"
		fi;	
		if grep -q "ignore_for_eclipse" "$f/.gitignore"; then
a=a
		else
echo "
# ignore_for_eclipse
/bin/
.classpath
.project
" >> "$f/.gitignore"
			$GHBU_SILENT || echo "Missing GITHUB ignore_for_eclipse : $f"
		fi;	
	fi;
 done;
$GHBU_SILENT || (echo "" && echo "=== DONE ===" && echo "")

$GHBU_SILENT || (echo "GitHub Clonning completed." && echo "")
