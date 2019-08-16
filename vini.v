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
	line int
	col int
	csection string
	output IniResults
}

pub fn (r IniReader) str() string {
	return 'IniReader{ line: ${r.line}, pos: ${r.pos},  csection: "${r.csection}",  config: { assign: ${r.config.assign}, comment: ${r.config.comment},  comment_semi: ${r.config.comment_semi} } }'
}

pub fn new_ini_reader(text string) IniReader {
	return new_ini_reader_with_config(text, new_default_ini_config())
}
pub fn new_ini_reader_with_config(text string, cfg IniConfig) IniReader {
	return IniReader{
		line: 1
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
fn (r mut IniReader) comment_till_end_of_line() string {
	mut c := ` `
	mut cstart := r.pos
	for {
		c = r.text[ r.pos ]
		if c == `\r` || c == `\n` { break }
		r.pos++
	}
	return r.text.substr( cstart, r.pos )
}

fn (r mut IniReader) new_section_name() string {
	mut c := ` `
	r.pos++
	mut cstart := r.pos
	for {
		c = r.text[ r.pos ]
		r.pos++
		if c == `]` { break	}
		if c == `\r` || c == `\n` {
			println('// Warning: incomplete section at line ${r.line} . No `]` found.')
			return ''
		}
	}
	sname := r.text.substr( cstart, r.pos - 1)
	return sname
}

fn (r mut IniReader) skip_line_ends(skipchars int) {
	r.line++
	r.pos += skipchars
	r.col = 0	
}

pub fn (r mut IniReader) parse() IniResults {
	mut c := ` `
	mut n := ` `
	println('len: $r.text.len ')
	for {
		if r.pos >= r.text.len { break }
		c = r.text[ r.pos ]
		n = if r.pos + 1 < r.text.len { r.text[ r.pos + 1 ] }else{` `}
		if c == `\r` && n == `\n` {
			r.skip_line_ends(2)
			continue
		}
		if c == `\n` {
			r.skip_line_ends(1)
			continue
		}
//		println('line: ${r.line:4d} | col: ${r.col:3d} | pos: ${r.pos:4d} | c:"${c.str()}" | n:"${n.str()}" ')
		if c == r.config.comment || c == r.config.comment_semi {
			comment := r.comment_till_end_of_line()
			println( '// Found comment: "$comment" ' )
			continue
		}
		if c == `[`  {
			new_section_name := r.new_section_name()
			if new_section_name != '' {
				println( '// Found new section: "$new_section_name" ')
			}
			continue
		}
		r.pos++
		r.col++
	}
	return r.output
}
