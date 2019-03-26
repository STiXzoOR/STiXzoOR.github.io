#!/bin/bash

#set -x

repo_dir=$(dirname $0)
deb_files_dir=$repo_dir/deb_files
debs_dir=$repo_dir/debs
packages=$repo_dir/Packages
zipped_packages=$repo_dir/Packages.bz2

function showOptions() {
	echo "--auto-mode,  Run all commands at once."
    echo "--remove-files,  Remove all cydia files."
    echo "--create-debs,  Create deb files."
    echo "--create-packages,  Package deb files."
    echo "--update-repo,  Upload files to repo."
    echo "--help,  Show this help message."
    echo "Usage: $(basename $0) [Options]"
    echo "Example: $(basename $0) --create-debs"
}

function removeFiles() {
	find "$deb_files_dir" -type f -name '.DS_Store' -delete
	find "$debs_dir" -type f -name '*.deb' -delete
	rm -r "$packages" "$zipped_packages"
}

function createDebs() {
	for folder in "$deb_files_dir"/*; do
		if [[ -d "$folder" ]]; then
			dpkg-deb -bZgzip "$folder" "$debs_dir"
		fi
	done
}

function createPackages() {
	dpkg-scanpackages -m "$debs_dir" 2> /dev/null > "$packages"
	bzip2 -fks "$packages"
}

function updateRepo() {
	read -p "Git commit message: " message
	git add -A
	git commit -m "$message"
	git push -u origin master
}

case "$1" in
	--remove-files)
		removeFiles
	;;
    --create-debs)
		createDebs
    ;;
    --create-packages)
		createPackages
    ;;
    --update-repo)
		updateRepo
    ;;
    --auto-mode)
		$0 --remove-files
		$0 --create-debs
		$0 --create-packages
		$0 --update-repo
	;;
    --help|*)
		showOptions
esac