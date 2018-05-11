/*
 * User+Conveniences.swift
 * CoreData Pres Demo
 *
 * Created by François Lamboley on 11/05/2018.
 * Copyright © 2018 François Lamboley. All rights reserved.
 */

import Foundation



extension User {
	
	var fullName: String {
		var res = ""
		if let firstName = firstName {res += firstName}
		if firstName != nil && lastName != nil {res += " "}
		if let lastName = lastName {res += lastName}
		return res
	}
	
}
