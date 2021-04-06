Constants
	var
		global/Constants/_root
		_names[]
		_values[]
		_name_to_value[]
		_value_to_name[]

	New()
		if(type == /Constants) return

		_name_to_value = GetNames()
		_value_to_name = new

		for(var/name in _name_to_value)
			var value = vars[name]
			_name_to_value[name] = value
			_value_to_name["[value]"] = name

	proc
		GetNames()
			if(!_names)
				_names = new
				if(!_root) _root = new
				for(var/v in vars - _root.vars) _names |= v
			return _names

		GetValues()
			if(!_values)
				_values = new
				for(var/name in GetNames()) _values |= vars[name]
			return _values

		ToName(Value)
			return _value_to_name["[Value]"]

		ToValue(Name)
			return _name_to_value[Name]
