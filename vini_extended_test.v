//-*- Mode: Go; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-
import spytheman.vini

fn test_extended_1() {
	println('hello from test_extended_1')
	assert true
}

fn test_new_ini_reader() {
	x := vini.new_ini_reader('')
	dump(x)
}
