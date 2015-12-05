javascript:(function() {
	/*
	  A bookmarklet that converts "View Detail" links to "Download Detail"
	  links in lists of 2016 insurance plans on the "New York State of Health"
	  website (https://nystateofhealth.ny.gov/individual/)

	  @author Daniel Convissor <danielc@analysisandsolutions.com>
	  @link https://github.com/convissor/new_york_state_of_health_spreadsheet
	 */

	if ($('form.#resultPage').length) {
		/* List is from a logged in user. */

		if (typeof isEmployee == 'undefined') {
			var isEmployee = false;
		}

		var query = $('form.#resultPage').attr('action').replace(/.*\?/, '');

		var base_url = 'https://nystateofhealth.ny.gov' + GlobalVars.app_url;

		if (isEmployee) {
			base_url += '/employee/search/plans/';
		} else {
			if ($('#isAno').val()) {
				base_url += '/hx_plans/';
			} else {
				base_url += '/prescreen/search/hx_plans/';
			}
		}

		$('tr.productInfo').each(function() {
			var id = $(this).attr('id').replace(/\D/g, '');
			var url = base_url + id + '?' + query;

			/* Display hidden rows. */
			$(this).show();

			/* Replace View Details cell with a download link. */
			$(this).children('td:last').html(
				'<a href="' + url + '" download="' + id + '.html">Download Detail</a>'
			);
		});
	} else {
		/* List is from an anonymous user. */

		/* Convert View Detail regular link to a download link. */
		$('a.planDetails').attr('download', '').html('Download Detail');
	}
})();
