#! /usr/bin/env php
<?php

if (!empty($_SERVER['argv'][1])) {
	switch ($_SERVER['argv'][1]) {
		case '-h':
		case '--help':
		case 'help':
			usage();
			break;
	}
}

function usage() {
	echo "Usage: extract_details.php\n";
	echo "\n";
	echo "Pulls data out of insurance plan detail web pages downloaded\n";
	echo "from the New York State of Health website.  Stores the result\n";
	echo "in .csv files in the data directory.\n";
	echo "\n";
	echo "This script processes all .html files in the\n";
	echo "clean_html_details directory.  Those files have been\n";
	echo "processed by scrub_raw_html_details.sh.\n";
	echo "\n";
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>\n";
	echo "https://github.com/convissor/new_york_state_of_health_spreadsheet\n";
	exit;
}

function error($msg, $code) {
	$STDERR = fopen('php://stderr', 'w+');
	fwrite($STDERR, "ERROR: $msg\n");

	if ($code) {
		exit($code);
	}
}


$html_dir = __DIR__ . '/clean_html_details';
$data_dir = __DIR__ . '/data';
$data_file = "$data_dir/output.csv";

if (!is_readable($html_dir)) {
	error("Not readable: $html_dir", __LINE__);
}
if (!is_writable($data_dir)) {
	error("Not writeable: $data_dir", __LINE__);
}

$files = glob($html_dir . '/*.html');
if (!$files) {
	error("No .html files in $html_dir", __LINE__);
}


$all_data = array();

// Put key columns up front.
$all_keys = array(
	'plan_id' => null,
	'plan_name' => null,
	'metal' => null,
	'premium' => null,
	'medical_deductable_person' => null,
	'medical_deductable_family' => null,
	'drug_deductable_person' => null,
	'drug_deductable_family' => null,
	'combined_deductable_person' => null,
	'combined_deductable_family' => null,
	'max_out_of_pocket_person' => null,
	'max_out_of_pocket_family' => null,
	'has_out_of_network' => null,
	'is_hsa' => null,
	'primary_care_visit_to_treat_an_injury_or_illness' => null,
	'specialist_visit' => null,
	'preventive_care_screening_immunization' => null,
);

// Cache all data before generating .csv file in case a plan has a
// different number of columns.

foreach ($files as $file) {
	if (!is_readable($file)) {
		error("Not readable: $file", __LINE__);
	}

	$id = basename($file, '.html');
	$short_file = "clean_html_details/$id.html";

	$data = array('plan_id' => $id);

	echo "Processing $short_file\n";

	try {
		$xml = @new SimpleXMLElement(file_get_contents($file));
	} catch (Exception $e) {
		error("$short_file: " . $e->getMessage(), __LINE__);
	}

	/*
	 * Name.
	 */

	$key = 'plan_name';
	$cell = trim(@$xml->body->div->div[3]->div->div[1]->div->form->table[0]->tr->th[1]);
	if (!$cell) {
		error("$short_file: loading $key cell", __LINE__);
	}
	$data[$key] = $cell;

	/*
	 * Premium, metal.
	 */

	$row = @$xml->body->div->div[3]->div->div[1]->div->form->table[1]->tr[0];
	if ($row === null) {
		error("$short_file: loading premium row", __LINE__);
	}

	$key = 'premium';
	$cell = @$row->td[0];
	if ($cell === null) {
		error("$short_file: loading $key cell", __LINE__);
	}
	$data[$key] = trim($cell->div->span->span) . '.' . trim($cell->div->span->sup);

	$key = 'metal';
	$cell = @$row->td[1];
	if ($cell === null) {
		error("$short_file: loading $key cell", __LINE__);
	}
	$data[$key] = trim($cell->div);

	/*
	 * Deductables.
	 */

	$row = @$xml->body->div->div[3]->div->div[1]->div->form->table[1]->tr[1];
	if ($row === null) {
		error("$short_file: loading deductable row", __LINE__);
	}

	$keys = array('medical', 'drug', 'combined');
	foreach ($keys as $i => $key) {
		$text = trim(@$row->td[$i]->span[1]);

		if ($text == '-') {
			$data[$key . '_deductable_person'] = null;
			$data[$key . '_deductable_family'] = null;
			continue;
		}

		$deductables = explode('|', $text);
		if (!is_array($deductables) || count($deductables) != 2) {
			error("$short_file: loading $key deductable", __LINE__);
		}

		if (preg_match('/(\\d+)/', $deductables[0], $match)) {
			$value = $match[1];
		} else {
			$value = null;
		}
		$data[$key . '_deductable_person'] = $value;

		if (preg_match('/(\\d+)/', $deductables[1], $match)) {
			$value = $match[1];
		} else {
			$value = null;
		}
		$data[$key . '_deductable_family'] = $value;
	}

	/*
	 * Out of pocket, out of network, HSA.
	 */

	$row = @$xml->body->div->div[3]->div->div[1]->div->form->table[1]->tr[2];
	if ($row === null) {
		error("$short_file: loading out of pocket row", __LINE__);
	}

	$key = 'max_out_of_pocket';
	$cell = @$row->td[0];
	if ($cell === null) {
		error("$short_file: loading $key cell", __LINE__);
	}
	$match = preg_split('@[/|]@', $cell);
	if (count($match) != 3) {
		error("$short_file: loading $key cell", __LINE__);
	}
	$subkeys = array(1 => 'person', 2 => 'family');
	foreach ($subkeys as $i => $subkey) {
		if (strpos('not applicable', $match[$i]) !== false) {
			$value = null;
		} else {
			$value = preg_replace('/[^0-9]/', '', $match[$i]);
		}
		$data[$key . '_' . $subkey] = $value;
	}

	$key = 'has_out_of_network';
	$cell = @$row->td[1];
	if ($cell === null) {
		error("$short_file: loading $key cell", __LINE__);
	}
	$data[$key] = trim($cell);

	$key = 'is_hsa';
	$cell = @$row->td[2];
	if ($cell === null) {
		error("$short_file: loading $key cell", __LINE__);
	}
	$data[$key] = trim($cell);

	$benefit_sections = @$xml->body->div->div[3]->div->div[1]->div->form->div[2];
	if ($benefit_sections === null) {
		error("$short_file: loading benefit sections", __LINE__);
	}
	foreach ($benefit_sections as $section) {
		if (!isset($section->table)) {
			continue;
		}

		if (!isset($section->table->tbody->tr)) {
			error("$short_file: benefit section malformed", __LINE__);
		}

		foreach ($section->table->tbody->tr as $i => $benefit) {
			if (!isset($benefit->td)) {
				continue;
			}

			$key = trim(@$benefit->td[0]->div);
			if (!$key) {
				continue;
			}
			$clean_key = preg_replace('/\(.+\)/', '', $key);
			$clean_key = strtolower(trim($clean_key));
			$clean_key = preg_replace('/[^a-z]+/', '_', $clean_key);

			$value = trim(@$benefit->td[1]->div);
			switch ($value) {
				case 'No Charge':
				case '0%':
					$value = '$0';
					break;
				case 'Not Applicable':
					$value = null;
					break;
			}

			$data[$clean_key] = $value;
		}
	}

	$all_data[$id] = $data;
	$all_keys = array_merge($all_keys, array_fill_keys(array_keys($data), null));
}


$fp = @fopen($data_file, 'w+');
if (!$fp) {
	error("Could not open $data_file for writing", __LINE__);
}

if (!@fputcsv($fp, array_keys($all_keys))) {
	error("Problem writing header to $data_file", __LINE__);
}

ksort($all_data);

foreach ($all_data as $id => $data) {
	$out = array();

	foreach ($all_keys as $key => $tmp) {
		if (array_key_exists($key, $data)) {
			$out[$key] = $data[$key];
		} else {
			$out[$key] = null;
		}
	}

	if (!@fputcsv($fp, $out)) {
		error("Problem writing plan $id to $data_file", __LINE__);
	}
}
