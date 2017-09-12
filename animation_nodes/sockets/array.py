import bpy
import numpy
from bpy.props import *
from .. events import propertyChanged
from . implicit_conversion import registerImplicitConversion
from .. base_types import AnimationNodeSocket, PythonListSocket

class ArraySocket(bpy.types.NodeSocket, AnimationNodeSocket):
    bl_idname = "an_ArraySocket"
    bl_label = "Array Socket"
    dataType = "Array"
    allowedInputTypes = ["All"]
    drawColor = (0.1, 0.5, 0.75, 1)
    storable = True
    comparable = True

    value = FloatProperty(default = 0.0, update = propertyChanged, precision=6)

    def drawProperty(self, layout, text, node):
        layout.prop(self, "value", text = text)

    def getValue(self):
        return numpy.asarray(self.value)

    def setProperty(self, data):
        self.value = data

    def getProperty(self):
        return numpy.asarray(self.value)

    @classmethod
    def getConversionCode(cls, dataType):
        return "numpy.asarray(value) if not hasattr(self, 'asNumpyArray', None) else value.asNumpyArray().reshape(len(value), -1)"

    @classmethod
    def getDefaultValue(cls):
        return numpy.asarray(0.0)

    @classmethod
    def getCopyExpression(cls):
        return "value.copy()"

    @classmethod
    def correctValue(cls, value):
        if isinstance(value, numpy.ndarray):
            return value, 0
        else:
            try: return numpy.asarray(value), 1
            except: return cls.getDefaultValue(), 2

singleTypes = ["Boolean", "Color", "Edge Indices", "Euler", "Float",
               "Integer", "Matrix", "Quaternion", "Vector"]
for t in singleTypes:
    registerImplicitConversion(t, "Array", "numpy.asarray(value)")
registerImplicitConversion("Boolean List", "Array", "value.asNumpyArray()")
registerImplicitConversion("Color List", "Array", "value.asNumpyArray().reshape(-1, 3))")
registerImplicitConversion("Edge Indices List", "Array", "value.asNumpyArray().reshape(-1, 2))")
registerImplicitConversion("Euler List", "Array", "value.asNumpyArray().reshape(-1, 3))")
registerImplicitConversion("Float List", "Array", "value.asNumpyArray()")
registerImplicitConversion("Integer List", "Array", "value.asNumpyArray()")
registerImplicitConversion("Matrix List", "Array", "value.asNumpyArray().reshape(-1, 4, 4)")
registerImplicitConversion("Quaternion List", "Array", "value.asNumpyArray().reshape(-1, 4)")
registerImplicitConversion("Vector List", "Array", "value.asNumpyArray().reshape(-1, 3)")

class ArrayListSocket(bpy.types.NodeSocket, PythonListSocket):
    bl_idname = "an_ArrayListSocket"
    bl_label = "Array List Socket"
    dataType = "Array List"
    baseDataType = "Array"
    allowedInputTypes = ["Array List"]
    drawColor = (0.1, 0.5, 0.75, 0.5)
    storable = True
    comparable = False

    @classmethod
    def getDefaultValue(cls):
        return []

    @classmethod
    def getDefaultValueCode(cls):
        return "[]"

    @classmethod
    def getCopyExpression(cls):
        return "value[:]"
