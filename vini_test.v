//-*- Mode: Go; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-
import spytheman.vini

fn test_default_parser() ? {
	println('')
	r := vini.parse_ini_file('example_ini_files/typed_ini.conf') ?
	println(r)
}

fn test_colon_parser() ? {
	println('')
	r := vini.parse_ini_file('example_ini_files/colon_as_delimiter.conf') ?
	println(r)
}
