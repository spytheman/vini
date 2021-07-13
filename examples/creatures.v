/*  -*- Mode: Go; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
module main
// a minimized maps of objects, containing other maps initialization example

struct Section {
mut:
	description string
	values map[string]string
}

fn (s Section) str() string {
	return 'description: "$s.description" \nvalues: ' + s.values.str()
}
fn (sectionMap map[string]Section) str() string {
	mut res := []string{}
	res << 'map of sections:'
	for k,v in sectionMap {
		res << 'k: $k | v: ' + v.str()
	}
	return res.join('\n')
}

fn main(){
	mut all := map[string]Section
	all['people'] = Section{ description: 'These are people' }
	all['people'].values['John'] = 'Smith'
	all['people'].values['Diana'] = 'Blanca'
	all['animals'] = Section{ description: 'These are animals' }
	all['animals'].values['cat'] = 'Tom'
	all['animals'].values['mouse'] = 'Jerry'
	println('The mouse is named: ' + all['animals'].values['mouse'] )

	println('All creatures:')
	println(all)
}
