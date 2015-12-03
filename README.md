# "New York State of Health" Spreadsheets and Help

New York's "Obamacare"
[health insurance exchange website](https://nystateofhealth.ny.gov/individual)
_really_ sucks.  Basic information is missing or hard to find.
This repository is an independent attempt to work around some of
the shortcomings.

# The Horror.  The Inspiration.

Feel free to skip this section and go right to data sections that follow.

But if you're into schadenfreude and/or learning from others' mistakes,
read on...

It's critical to know when the "open enrollment" period is, so you'd imagine
that information would be prominently displayed on the home page.  Nope.
It's nowhere in the homepage's main body or FAQ.  _Some_ of the info is
shown periodically in the tiny "news" scroll at the top of the page.
Even worse, when trying to log in during the 2016 open enrollment period,
a popup is displayed saying the _2015_ open enrollment ended.  Sigh.

Once I'm logged in and have entered my family's information,
the exchange gives me 88 health insurance plans to choose from.
That's a _lot_ of stuff to think about.  I can enter (a sadly limited
set of) search criteria to trim down the number of plans to examine.
Then I click on a plan to view its details.  When I'm ready to
look at the next plan, clicking the "Return to Plan List" takes me
back to the...  GAAAAAHHH!  The list's search criteria and pagination
are lost and I'm back at the first page of all the plans.

As a computer programmer and data lover I kept screaming (mostly) in my mind
"For heaven's sake, give me a spreadsheet!!!"
But the exchange's website doesn't seem to have that option.

So I took it upon myself to make things better.  Welcome to the solution...

## 2016 Open Enrollment Dates

* Starts: November 1
* Deadline for Coverage Starting January 1: December 15
* Ends: January 31
* Medicaid and Child Health Plus: available all year long

## Spreadsheets

* 2016
  * [Westchester County, Family Plans, Unsubsidized](https://github.com/convissor/new_york_state_of_health_spreadsheet/blob/master/2016/data/westchester_family_unsubsidized.csv)

To download a given "spreadsheet," click its link, above, click the
"Raw" button that's right above the data table, then use your browser's
save function to download it.

## How to Extract Data from the "NY State of Health" Website

Here are instructions for the technically savvy on how to glean more
data points from New York's healh insurance exchange website.

* Log in to https://nystateofhealth.ny.gov/individual/
* Go to the "Find a Plan" page (once you've completed
  the process of entering your personal information)
* Scroll down to the plan data
* Note: don't worry about pagination.  The table's HTML contains all of the
  rows but sets `display: none` for "pages" other than the current one.
* Right click on one of the data table's column headers
* Click "Inspect element"
* Scroll up to the `<table>` element, click on it, then right click on it
  * Firefox: pick "Copy Outer HTML"
  * Chrome: pick "Copy"
* Now open your favorite shell
* `cd` into the `new_york_state_of_health_spreadsheet/2016/raw_html_lists` directory
* Paste the data into a file named `<county>_<group>_<subsidy level>.html`
  (eg: `westchester_family_unsubsidized.html`).
  (`xclip -o > filename.html` FTW. :).
* `cd ..`
* `./process_raw_html_lists.sh`

TODO: finish writing steps to download and process the detail files

* `./scrub_raw_html_details.sh`
* `./extract_details.php`

# Independent

This is an independent project.  The State of New York and the various
insurance companies have nothing to do with it.

## Questions?

All questions should be addressed to the health insurance exchange:

* Phone: 855-355-5777
* TTY: 800-662-1220
* https://nystateofhealth.ny.gov/individual

Of course, if you're a computer programmer or an employer thereof,
that's another story! :)  To help out, fork the project and send
in pull requests.  If you need a solid, senior developer,
see my website: http://www.analysisandsolutions.com/

## Donations

Did this data keep you from totally losing your mind?
[Sending a few bucks my way would be so kind.](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=danielc%40analysisandsolutions%2ecom&lc=US&item_name=Donate%3a%20NY%20Health%20Insurance%20Spreadsheets&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)

## Use at Your Own Risk

THIS SOFTWARE AND DATA IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
