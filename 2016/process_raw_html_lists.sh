#! /bin/bash -e

function usage() {
	echo ""
	echo "Usage: process_raw_html_lists.sh"
	echo ""
	echo "Sanitizes and formats 2016 insurance plan list web pages"
	echo "downloaded from the New York State of Health website."
	echo ""
	echo "Processes all .html files in 'raw_html_lists'"
	echo "and puts completed copies in 'clean_html_lists'."
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


# Set and check paths.

this_dir="$(cd "$(dirname "$0")" && pwd)"

src_dir="$this_dir/raw_html_lists";
tmp_dir="$this_dir/tmp_html_lists";
dst_dir="$this_dir/clean_html_lists";
personal_dir="$this_dir/personal_html_lists";

if [[ ! -r "$src_dir" ]] ; then
	error "Not readable: $src_dir" 2
fi

if [[ ! -w "$tmp_dir" ]] ; then
	error "Not writable: $tmp_dir" 3
fi

if [[ ! -w "$dst_dir" ]] ; then
	error "Not writable: $dst_dir" 4
fi

if [[ ! -w "$personal_dir" ]] ; then
	error "Not writable: $personal_dir" 5
fi


# Ensure temporary files are removed no matter what.
trap "rm -f '$tmp_dir'/*.html" EXIT


# Process the files...

cp "$src_dir"/*.html "$tmp_dir"

for file in $(find "$tmp_dir" -name \*.html) ; do
	echo "Processing $file"

	# Add a title.
	title=$(basename "$file")
	title=${title//_/ }
	title=${title//.html/}
	sed "s@<table@<title>$title</title><table@" -i "$file"

	# Add a stylesheet.
	sed "s@<table@<link rel="stylesheet" href="style.css" /><table@" -i "$file"

	# Convert to XHTML and clean file up so PHP can parse it.
	set +e
	tidy -q -f /dev/null -asxhtml -i -w 0 --wrap-attributes 0 -m "$file"
	if [ $? -eq 2 ] ; then
		2&> echo "ERROR calling tidy on $file"
		exit 1
	fi
	set -e

	sed 's@&nbsp;@ @g' -i "$file"

	# Open up all of the plan rows.
	sed -r 's@(class="productbox .*)display: *none;?@\1@' -i "$file"

	# Remove comparison button
	sed '/comparePlansText/d' -i "$file"

	# Remove comparison checkbox cell.
	sed '/<label class="checkbox"/d' -i "$file"

	# Remove row count.
	sed '/quotes_currentNoOfRecords/d' -i "$file"

	# Remove logos.
	sed '/actualIssuerLogo/d' -i "$file"

	# Remove link around plan name.
	sed 's/href="#" class="planDetails/class="planDetails/' -i "$file"

	# Turn rating star images into text.
	sed -r 's@<img.*img_start_rating_([0-9])\.png" />@\1 stars@' -i "$file"
	sed '/0 Star Rating/d' -i "$file"
	sed '/New Plan/d' -i "$file"
	sed '/Quality data not yet available/d' -i "$file"
	sed 's/<div class="planRating">/New Plan, Quality data not yet available/' -i "$file"

	# Clarify deductable data.
	sed '/\/ Person/d' -i "$file"
	sed 's@per group</span> <span class="grayTxt">/ Family@per family@g' -i "$file"
	sed 's/per person not applicable | //g' -i "$file"

	# Create "personal" file with links to plan details.

	# Put plan id in first cell.
#	sed -r 's/  <input class="planId" value="([0-9]+)"/  \1<input class="planId" value="\1"/' -i "$file"
done

cp "$tmp_dir"/*.html "$dst_dir"


# Notes.

# https://nystateofhealth.ny.gov/individual/searchAnonymousPlan/plan/34342?county=New%20York&coverageTier=INDIVIDUAL&entityType=INDIVIDUAL&planYear=2016&youPay=

# https://nystateofhealth.ny.gov/individual/searchAnonymousPlan/plan/34342?county=New%20York&coverageTier=COUPLE_AND_ONE_DEPENDENT&entityType=INDIVIDUAL&planYear=2016&youPay=
