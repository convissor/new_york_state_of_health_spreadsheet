#! /bin/bash -e

if [[ $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage: scrub_raw_html_details.sh"
	echo ""
	echo "Sanitizes and formats insurance plan detail files downloaded from"
	echo "the New York State of Health website."
	echo ""
	echo "This script grabs all .html files in the raw_html_details directory,"
	echo "processes them and deposits them in clean_html_details directory."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "https://github.com/convissor/new_york_state_of_health_spreadsheet"
	exit
fi


# Ensure temporary files are removed no matter what.
trap "rm -f tmp_html_details/*.html" EXIT


cp raw_html_details/*.html tmp_html_details

for file in $(find tmp_html_details -name \*.html) ; do
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

cp tmp_html_details/*.html clean_html_details
