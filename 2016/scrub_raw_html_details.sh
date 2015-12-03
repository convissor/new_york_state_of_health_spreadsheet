#! /bin/bash -e

function usage() {
	echo ""
	echo "Usage: scrub_raw_html_details.sh <sub-directory>"
	echo ""
	echo "Sanitizes and formats 2016 insurance plan detail web pages"
	echo "downloaded from the New York State of Health website."
	echo ""
	echo "Processes all .html files in 'raw_html_details/<sub-directory>'"
	echo "and puts completed copies in 'clean_html_details/<sub-directory>'."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "https://github.com/convissor/new_york_state_of_health_spreadsheet"
	echo ""
}

function error() {
	echo "ERROR: $1" >&2

	if [ "$2" -ne 0 ] ; then
		exit $2
	fi
}


# Parse input.
while getopts "h" OPTION ; do
	case $OPTION in
		h|?)
			usage
			exit
			;;
	esac
done

if [ -z "$1" ] ; then
	error "<sub-directory> parameter is required" 0
	usage
	exit 1
fi

sub_dir=$1


# Set and check paths.

this_dir="$(cd "$(dirname "$0")" && pwd)"

src_dir="$this_dir/raw_html_details/$sub_dir";
tmp_dir="$this_dir/tmp_html_details";
dst_parent_dir="$this_dir/clean_html_details";
dst_dir="$dst_parent_dir/$sub_dir";

if [[ ! -r "$src_dir" ]] ; then
	error "Not readable: $src_dir" 2
fi

if [[ ! -w "$tmp_dir" ]] ; then
	error "Not writable: $tmp_dir" 3
fi

if [[ ! -w "$dst_dir" ]] ; then
	if [[ -d "$dst_dir" ]] ; then
		error "Not writable: $dst_dir" 5
	elif [[ ! -w "$dst_parent_dir" ]] ; then
		error "Not writable: $dst_parent_dir" 4
	fi

	mkdir "$dst_dir"
fi


# Ensure temporary files are removed no matter what.
trap "rm -f tmp_html_details/*.html" EXIT


cp "$src_dir"/*.html "$tmp_dir"

for file in $(find "$tmp_dir" -name \*.html) ; do
	echo "Processing $file"

	# These paths generally contain sensitve data.
	sed 's@"/individual/prescreen.*"@""@' -i $file

	# Blank out personal data.
	sed -r 's@"(a[0-9]*_applicantId|a[0-9]*_dob|CSRFToken|cookieName|formUID|eId|enrlGrpId|mIds|zip)" value=".*"@"\1" value=""@' -i $file

	# Delete names.
	sed "s@Logged in as .*<@Logged in as XYZ<@" -i $file
	sed '/<li style="word-wrap:break-word;">/d' -i $file

	# Open up all of the treatment type comparisons.
	sed 's@class="comparePlanDiv" style="display:none;"@class="comparePlanDiv" style=""@' -i $file

	# Various cleanups to get tidy to work.
	sed 's@<header @<div @' -i $file
	sed 's@</header>@</div>@' -i $file

	sed -r 's@<form (.*)/>@<form \1>@' -i $file

	sed 's@<footer @<div @' -i $file
	sed 's@</footer>@</div>@' -i $file

	sed 's@nav>@div>@' -i $file

	# Convert to XHTML and clean file up so PHP can parse it.
	set +e
	tidy -q -f /dev/null -asxhtml -i -w 0 --wrap-attributes 0 -m $file
	if [ $? -eq 2 ] ; then
		2&> echo "ERROR calling tidy on $file"
		exit 1
	fi
	set -e

	sed 's@&nbsp;@ @g' -i $file
done

cp "$tmp_dir"/*.html "$dst_dir"
