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
mut:
	title string
	values map[string]IniValue
}

struct IniResults {
mut:
	sections map[string]IniSection
}

fn (v IniValue) str() string {
	return '$v.key = $v.value # kind: $v.kind'
}
fn (section IniSection) str() string {
	mut res := []string
	res << '[$section.title]'
	for k,v in section.values {	res << v.str()	}
	return res.join('\n')
}
fn (sections map[string]IniSection) str() string {
	mut res := []string
	for k,v in sections {
		res << v.str()
		res << '\n'
	}
	return res.join('\n')
}
fn (results IniResults) str() string {
	return results.sections.str()
}
fn (results mut IniResults) add_section(sname string) {
	if !(sname in results.sections) {
		mut s := IniSection{ title: sname }
		s.values['zz'] = IniValue{ key: 'k', value: 'v', kind: 'comment' }
		results.sections[sname] = s
		println('NEW section with name: "$sname" ')
		println( s )
		println( results.sections[sname] )
	}
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
	return 'IniReader{\n'+
		'line: ${r.line}, pos: ${r.pos},  csection: "${r.csection}",\n' +
		'config: { a: ${r.config.assign}, c: ${r.config.comment},  cs: ${r.config.comment_semi} }\n'+
		'output: ' + r.output.str() + '\n' +
		'}'
}

pub fn new_ini_reader(text string) IniReader {
	return new_ini_reader_with_config(text, new_default_ini_config())
}
pub fn new_ini_reader_with_config(text string, cfg IniConfig) IniReader {
	return IniReader{
		line: 1
		text: text
		config: cfg
		csection: ''
	}
}
pub fn parse_ini_file(path string) ?IniReader {
	return parse_ini_file_with_config(path, new_default_ini_config())
}
pub fn parse_ini_file_with_config(path string, cfg IniConfig) ?IniReader {
	println('parse_ini_file_with_config path: $path ...')
	text := os.read_file(path) or { return error('Could not read file: $path') }
	mut r := new_ini_reader_with_config(text, cfg)
	r.parse()
	return r
}

//////////////////////////////////////////////////////////////
fn (r mut IniReader) skip_line_ends(skipchars int) {
	r.line++
	r.pos += skipchars
	r.col = 0
}

fn (r mut IniReader) handle_new_lines(c byte, n byte) bool {
	if c == `\r` && n == `\n` {
		r.skip_line_ends(2)
		return true
	}
	if c == `\n` {
		r.skip_line_ends(1)
		return true
	}
	return false
}

fn (r mut IniReader) handle_comments(cc byte) bool {
	if cc == r.config.comment || cc == r.config.comment_semi {
		mut c := ` `
		mut cstart := r.pos
		for {
			c = r.text[ r.pos ]
			if c == `\r` || c == `\n` { break }
			r.pos++
		}
		comment := r.text.substr( cstart, r.pos )
		println( '// Found comment: "$comment" ' )
		return true
	}
	return false
}

fn (r mut IniReader) handle_sections(cc byte) bool {
	if cc == `[`  {
		mut c := ` `
		r.pos++
		mut cstart := r.pos
		for {
			c = r.text[ r.pos ]
			r.pos++
			if c == `]` { break	}
			if c == `\r` || c == `\n` {
				println('// Warning: incomplete section at line ${r.line} . No `]` found.')
				return false
			}
		}
		new_section_name := r.text.substr( cstart, r.pos - 1)
		println( '// Found new section: "$new_section_name" ')
		r.csection = new_section_name
		r.output.add_section( r.csection )
		return true
	}
	return false
}

fn (r mut IniReader) peek() byte {
	return if r.pos + 1 < r.text.len { r.text[ r.pos + 1 ] }else{` `}
}

pub fn (r mut IniReader) parse() IniResults {
	mut c := ` `
	mut n := ` `
	println('len: $r.text.len ')
	r.output.add_section('')
	for {
		if r.pos >= r.text.len { break }
		c = r.text[ r.pos ]
		n = r.peek()
		////////////////////////////////////////////////////////////////////////
		if r.handle_new_lines( c, n ) { continue }
		//println('line: ${r.line:4d} | col: ${r.col:3d} | pos: ${r.pos:4d} | c:"${c.str()}"		| n:"${n.str()}" ')
		if r.handle_comments(c) { continue }
		if r.handle_sections(c) { continue }
		// at this point, the text stream is stripped from comments and sections
		r.pos++
		r.col++
	}
	return r.output
}
