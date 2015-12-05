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
	echo "For full instructions, view the source of this script."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "https://github.com/convissor/new_york_state_of_health_spreadsheet"
	echo ""
}

# Full Instructions
#
# * Log in to https://nystateofhealth.ny.gov/individual/
# * Go to the "Find a Plan" page (once you've completed
#   the process of entering your personal information)
# * Scroll down to the plan data
# * Note: don't worry about pagination.  The table's HTML contains all of the
#   rows but sets "display: none" for "pages" other than the current one.
# * Right click on one of the data table's column headers
# * Click "Inspect element"
# * Scroll up to the <table> element, click on it, then right click on it
#   * Firefox: pick "Copy Outer HTML"
#   * Chrome: pick "Copy"
# * Now open your favorite shell
# * `cd` into the "new_york_state_of_health_spreadsheet/2016/raw_html_lists"
#   directory
# * Paste the data into a file named "<county>_<plan-type>_<subsidy-level>.html"
#   (eg: "westchester_family-2kids_unsubsidized.html").
#   (`xclip -o > filename.html` FTW. :).
# * `cd ..`
# * `./process_raw_html_lists.sh`
# * The resulting table will be stored in a directory named
#   "clean_html_lists/<county>_<type>_<subsidy level>"


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

	# Replace comparison checkbox with plan id.
	sed -r 's@<label class="checkbox" for="radioInput([0-9]+)".*</label>@\1@' -i "$file"

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
done

cp "$tmp_dir"/*.html "$dst_dir"
