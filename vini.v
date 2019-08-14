/*  -*- Mode: Go; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
module vini

import os

struct IniConfig {
	assign       byte
	comment      byte
	comment_semi byte
}
pub fn new_default_ini_config() IniConfig {
	return IniConfig {
        assign: `=`
		comment: `#`
        comment_semi: `;`
    }

}

//////////////////////////////////////////////////////////////

struct IniValue {
	key   string
	value string
	kind  string
}
struct IniSection {
	title string
mut:
	values map[string]IniValue
}

struct IniResults {
mut:
	sections map[string]IniSection
}

//////////////////////////////////////////////////////////////

struct IniReader  {
	config IniConfig
mut:
	text string
	pos int
	csection string
	output IniResults
}

pub fn (r IniReader) str() string {
	return 'IniReader{ pos: ${r.pos},  csection: "${r.csection}",  config: { assign: ${r.config.assign}, comment: ${r.config.comment},  comment_semi: ${r.config.comment_semi} } }'
}

pub fn new_ini_reader(text string) IniReader {
	return new_ini_reader_with_config(text, new_default_ini_config())
}
pub fn new_ini_reader_with_config(text string, cfg IniConfig) IniReader {
	return IniReader{
		text: text
		config: cfg
		csection: 'global'
	}
}
pub fn parse_ini_file(path string) IniReader? {
	return parse_ini_file_with_config(path, new_default_ini_config())
}
pub fn parse_ini_file_with_config(path string, cfg IniConfig) IniReader? {
	println('parse_ini_file_with_config path: $path ...')
	text := os.read_file(path) or { return error('Could not read file: $path') }
	mut r := new_ini_reader_with_config(text, cfg)
	r.parse()
	return r
}

//////////////////////////////////////////////////////////////

pub fn (r mut IniReader) parse() IniResults {
	r.output = IniResults{}
	mut c := ` `
	for {
		if r.text.len <= r.pos { break }
		c = r.text[ r.pos ]
		//println('len: $r.text.len | pos: ${r.pos:4d} | "$c" ')
		r.pos++
	}
	return r.output
}
