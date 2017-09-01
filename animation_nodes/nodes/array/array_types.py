arrayTypes = [
    ("BOOL", "Boolean", "Boolean (True or False) stored as a byte", "", 0),
    ("INT8", "Integer 8", "Byte (-128 to 127)", "", 1),
    ("INT16", "Integer 16", "Integer (-32768 to 32767)", "", 2),
    ("INT32", "Integer 32", "Integer (-2147483648 to 2147483647)", "", 3),
    ("INT64", "Integer 64", "Integer (-9223372036854775808 to 9223372036854775807)", "", 4),
    ("UINT8", "Unsigned Integer 8", "Unsigned integer (0 to 255)", "", 5),
    ("UINT16", "Unsigned Integer 16", "Unsigned integer (0 to 65535)", "", 6),
    ("UINT32", "Unsigned Integer 32", "Unsigned integer (0 to 4294967295)", "", 7),
    ("UINT64", "Unsigned Integer 64", "Unsigned integer (0 to 18446744073709551615)", "", 8),
    ("FLOAT16", "Float 16", "Half precision float: sign bit, 5 bits exponent, 10 bits mantissa", "", 9),
    ("FLOAT32", "Float 32", "Single precision float: sign bit, 8 bits exponent, 23 bits mantissa", "", 10),
    ("FLOAT64", "Float 64", "Double precision float: sign bit, 11 bits exponent, 52 bits mantissa", "", 11),
    ("COMPLEX64", "Complex 64", "Complex number, represented by two 32-bit floats (real and imaginary components)", "", 12),
    ("COMPLEX128", "Complex 128", "Complex number, represented by two 64-bit floats (real and imaginary components)", "", 13)
]

def getArrayType(array_type):
    if array_type == "BOOL":
        return "numpy.bool_"
    elif array_type == "INT8":
        return "numpy.int8"
    elif array_type == "INT16":
        return "numpy.int16"
    elif array_type == "INT32":
        return "numpy.int32"
    elif array_type == "INT64":
        return "numpy.int64"
    elif array_type == "UINT8":
        return "numpy.uint8"
    elif array_type == "UINT16":
        return "numpy.uint16"
    elif array_type == "UINT32":
        return "numpy.uint32"
    elif array_type == "UINT64":
        return "numpy.uint64"
    elif array_type == "FLOAT16":
        return "numpy.float16"
    elif array_type == "FLOAT32":
        return "numpy.float32"
    elif array_type == "FLOAT64":
        return "numpy.float64"
    elif array_type == "COMPLEX64":
        return "numpy.complex64"
    elif array_type == "COMPLEX128":
        return "numpy.complex128"
