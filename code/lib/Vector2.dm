/*
	A 2D vector datum with overloaded operators and other common functions.

	Credit to Kaiochao and his Kaiocode lib.
*/

proc
	hypot(x, y)
		if(x || y)
			var t
			x = abs(x)
			y = abs(y)
			if(x <= y)
				t = x
				x = y
			else
				t = y
			t /= x
			return x * sqrt(1 + t * t)
		return 0
var vector2
	Vector2_Zero = new(0, 0)
	Vector2_North = new(0, 1)
	Vector2_South = new(0, -1)
	Vector2_East = new(1, 0)
	Vector2_West = new(-1, 0)
	Vector2_Northeast = new(sqrt(1/2), sqrt(1/2))
	Vector2_Northwest = new(-sqrt(1/2), sqrt(1/2))
	Vector2_Southeast = new(sqrt(1/2), -sqrt(1/2))
	Vector2_Southwest = new(-sqrt(1/2), sqrt(1/2))

vector2
	var
		x
		y

	New(x, y)
		src.x = x
		src.y = y

	proc
		ToRotation(zero_dir = NORTH)
			var
				unit_x = x
				unit_y = y
				magnitude = Magnitude()
			if(magnitude != 1)
				unit_x /= magnitude
				unit_y /= magnitude
			switch(zero_dir)
				if(NORTH)
					return matrix(unit_y, unit_x, 0, -unit_x, unit_y, 0)
				if(EAST)
					return matrix(unit_x, -unit_y, 0, unit_x, unit_y, 0)
				else
					CRASH("Unsupported zero_dir.")

		// Equality checking.
		operator~=(vector2/v)
			return v && x == v.x && y == v.y

		// Vector addition.
		operator+(vector2/v)
			return new/vector2(x + v.x, y + v.y)

		// Vector subtraction and negation.
		operator-(vector2/v)
			return v ? new/vector2(x - v.x, y - v.y) : new/vector2(-x, -y)

		// Vector scaling and dot product.
		operator*(s)
			if(isnum(s))
				return new/vector2(x * s, y * s)
			else if(istype(s, /vector2))
				var vector2/v = s
				return x * v.x + y * v.y

		// Vector inverse scaling.
		operator/(d)
			return new/vector2(x / d, y / d)

		// Dot product, if you don't like the operator form.
		Dot(vector2/v)
			return x * v.x + y * v.y

		// Magnitude (AKA length or size) of the vector.
		Magnitude()
			return hypot(x, y)

		// Square of the magnitude of the vector.
		// Simpler to compute and can be used when comparing magnitudes of vectors.
		SquareMagnitude()
			return x * x + y * y

		// Get a vector in the same direction but with magnitude 1.
		Normalized()
			return src / Magnitude()

		// Get a vector in the same direction but with magnitude m.
		ToMagnitude(m)
			return src * (m / Magnitude())

		// Convert the vector to text with a specified number of significant figures.
		ToText(SigFig = 6)
			return "vector2([num2text(x, SigFig)], [num2text(y, SigFig)])"

		// Get a vector with the same magnitude, rotated by a clockwise angle in degrees.
		Turn(angle)
			var s = sin(angle), c = cos(angle)
			return new/vector2(c * x + s * y, -s * x + c * y)

		// Get the components via index (1, 2) or name ("x", "y").
		operator[](index)
			switch(index)
				if(1, "x")
					return x
				if(2, "y")
					return y
				else
					CRASH("Invalid index.")
