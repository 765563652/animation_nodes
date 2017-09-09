import bpy
from bpy.props import *
from ... base_types import AnimationNode

operations = [
    ("ADD", "Add", "A+B", "", 0),
    ("SUBTRACT", "Subtract" , "A-B", "", 1),
    ("MULTIPLY", "Multiply", "A*B", "", 2),
    ("DIVIDE", "Divide", "A/B", "", 3),
    ("POWER", "Power", "A**B", "", 4),
    ("MODULO", "Modulo", "A mod B", "", 5),
    ("SQRT", "Square Root", "sqrt(A)", "", 6),
    ("ABS", "Absolute", "abs(A)", "", 7),
    ("SIN", "Sine", "sin(A)", "", 8),
    ("COS", "Cosine", "cos(A)", "", 9),
    ("TAN", "Tangent", "tan(A)", "", 10),
    ("ARCSIN", "ArcSine", "arcsin(A)", "", 11),
    ("ARCCOS", "ArcCosine", "arccos(A)", "", 12),
    ("ARCTAN", "ArcTangent", "arctan(A)", "", 13),
    ("MAX", "Max", "max(A)", "", 14),
    ("MIN", "Min", "min(A)", "", 15),
]

singleInput = [
    "SQRT", "ABS", "SIN", "COS", "TAN", "ARCSIN", "ARCCOS", "ARCTAN"
]

class ArrayMathNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ArrayMathNode"
    bl_label = "Array Math"

    operation = EnumProperty(name = "Operation", default = "MULTIPLY",
        items = operations, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Array", "A", "a")
        if not self.operation in singleInput:
            self.newInput("Array", "B", "b")
        self.newOutput("Array", "Result", "res")

    def draw(self, layout):
        layout.prop(self, "operation", text = "")

    def getExecutionCode(self, required):
        if self.operation == "ADD":
            return "res = numpy.add(a, b)"
        elif self.operation == "SUBTRACT":
            return "res = numpy.subtract(a, b)"
        elif self.operation == "MULTIPLY":
            return "res = numpy.multiply(a, b)"
        elif self.operation == "DIVIDE":
            return "res = numpy.divide(a, b)"
        elif self.operation == "POWER":
            return "res = numpy.power(a, b)"
        elif self.operation == "MODULO":
            return "res = numpy.mod(a, b)"
        elif self.operation == "SQRT":
            return "res = numpy.sqrt(a)"
        elif self.operation == "ABS":
            return "res = numpy.absolute(a)"
        elif self.operation == "SIN":
            return "res = numpy.sin(a)"
        elif self.operation == "COS":
            return "res = numpy.cos(a)"
        elif self.operation == "TAN":
            return "res = numpy.tan(a)"
        elif self.operation == "ARCSIN":
            return "res = numpy.arcsin(a)"
        elif self.operation == "ARCCOS":
            return "res = numpy.arccos(a)"
        elif self.operation == "ARCTAN":
            return "res = numpy.arctan(a)"
        elif self.operation == "MAX":
            return "res = numpy.maximum(a, b)"
        elif self.operation == "MIN":
            return "res = numpy.minimum(a, b)"
