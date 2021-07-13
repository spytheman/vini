//-*- Mode: Go; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-
module main

// a minimized maps of objects, containing other maps initialization example

struct Section {
	values map[string]string
}

fn main() {
	mut all := map[string]Section{}
	all['animals'].values['mouse'] = 'Jerry'
	println('The mouse is named: ' + all['animals'].values['mouse'])
	println(all['animals'])
}
