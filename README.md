# "New York State of Health" Spreadsheets and Help

New York's "Obamacare"
[health insurance exchange website](https://nystateofhealth.ny.gov/individual)
_really_ sucks.  Basic information is missing or hard to find.
This repository is an independent attempt to work around some of
the shortcomings.

# The Horror.  The Inspiration.

Feel free to skip this section and go right to the helpful
[2016 Open Enrollment Dates](#user-content-2016-open-enrollment-dates),
[Got a Family?](#user-content-got-a-family),
[Spredsheets](#user-content-spreadsheets),
or [How to Extract Data](#user-content-how-to-extract-data-from-the-ny-state-of-health-website)
sections that follow.

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

## Got a Family?

If you have kids under the age of 19, chances are you'll be best off
picking two sets of plans.  One plan for the adult(s).  Then selecting
a "Child Health Plus" plan for your little ones.  Child Health Plus
is pretty good, has affordable premiums and, best of all, no copayments
or coinsurance.

This configuration gets set in the "Plan Selection Dashboard."  Instead of
selecting a "Family Plan," select a "Couple Plan" or an "Individual Plan"
for the grown ups, then select a "Child Only Plan" for the young'uns.

If you already started shopping for a "Family Plan," go to the
"Plan Selection Dashboard" and click the "Reset coverage information"
button at the bottom of the page.

## Spreadsheets

* 2016
  * [Westchester County, Family Plan - 2 Kids, Unsubsidized](https://github.com/convissor/new_york_state_of_health_spreadsheet/blob/master/2016/data/westchester_family-2kids_unsubsidized.csv)

To download a given "spreadsheet," click its link, above, click the
"Raw" button that's right above the data table, then use your browser's
save function to download it.

## How to Extract Data from the "NY State of Health" Website

Here are instructions for the technically savvy on how to glean more
data points from New York's health insurance exchange website.

### Install My Bookmarklet

If you haven't done so already, install my bookmarklet.  It _greatly_
simplifies the process of downloading all of the plan detail pages.
What it does is A) removes `display: none` from hidden plan rows so
you can see all the plans at once, and B) converts the "View Detail"
button into a "Download Detail" link.

* Copy the code in [`2016/download-link-bookmarklet.js`](https://raw.githubusercontent.com/convissor/new_york_state_of_health_spreadsheet/master/2016/download-link-bookmarklet.js) to your clipboard
* If you use Chrome:
  * Menu | Bookmarks
  * Ensure "Show bookmarks bar" has a check mark next to it.
    If not, click on that menu option, then open the Bookmarks menu again.
  * Bookmark manager
  * In the "Folders" pane, click on the "Bookmarks bar" entry
  * Right click in the "Organize" pane, pick "Add page..."
  * Put "NYSOH Download Links" in the Name box
  * Hit the `Tab` key
  * Paste the bookmarklet code into the URL box
  * Hit the `Enter` key
* If you use Firefox:
  * Menu | View | Toolbar | Bookmarks Toolbar (put check in box if needed)
  * Menu | Bookmarks | Show All Bookmarks
  * In the left pane, click on the "Bookmarks Toolbar" entry
  * Right click in the right pane, pick "New Bookmark..."
  * Put "NYSOH Download Links" in the Name box
  * Hit the `Tab` key
  * Paste the bookmarklet code into the Location box
  * Hit the `Enter` key

### Download the Plan Detail Pages You Want to Compare

<blockquote>
NOTE: Before getting started, here's what these instructions mean by the term
<strong><code>&lt;sub-directory&gt;</code></strong>.  It's a way to group
the HTML files you download and subsequently process based on the types
of plans you're comparing.  The naming convention is
<code>&lt;county&gt;_&lt;plan-type&gt;_&lt;subsidy-level&gt;</code>
(eg: <code>westchester_family-2kids_unsubsidized.html</code>).
</blockquote>

* Log in to https://nystateofhealth.ny.gov/individual/
* Go to the "Find a Plan" page (once you've completed
  the process of entering your personal information)
* Click on the "NYSOH Download Links" entry in the bookmarks toolbar
* Click the "Download Detail" links for the plans you want to compare
* If you get a Save As dialog box:
  * Save these files in the appropriate
    `new_york_state_of_health_spreadsheet/2016/raw_html_details_login/<sub-directory>`.
  * You'll save a _ton_ of time if you pick "Save File" and the
    "Do this automatically for files like this from now on."  At least that's
    what to do in Firefox.
* Once you're done downloading, open a terminal window
* If necessary: `mv [0-9]*.html <path to>/new_york_state_of_health_spreadsheet/2016/raw_html_details_login/<sub-directory>`
* `cd <path to>/new_york_state_of_health_spreadsheet/2016`
* Make sure you downloaded all the files you expected:
  `ls <sub-directory>/*html | wc -l`
* `./scrub_raw_html_details_login.sh <sub-directory>`
* `./extract_details_login.php <sub-directory>`
* Your can be found in the `data/<sub-directory>.csv` file
* Rejoice!  You can now examine all the data in a spreadsheet or database
  of your choosing!

## Independent

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
