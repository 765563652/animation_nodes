import bpy
from bpy.props import *
from ... base_types import AnimationNode
from . array_types import arrayTypes, getArrayType

stepTypeItems = [
    ("START_STEP", "Start / Step", "", "NONE", 0),
    ("START_STOP", "Start / Stop", "", "NONE", 1)
]

class ArrayRangeNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ArrayRangeNode"
    bl_label = "Array Range"

    arrayType = EnumProperty(name = "Data Type", default = "FLOAT32",
        items = arrayTypes, update = AnimationNode.refresh)
    rangeType = EnumProperty(name = "Range Type", default = "START_STOP",
        items = stepTypeItems, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Float", "Start", "start")
        self.newInput("Float", "Stop", "stop", value = 1)
        if self.rangeType == "START_STEP":
            self.newInput("Float", "Step", "step", value = 1)
        else:
            self.newInput("Integer", "Amount", "amount", value = 5, minValue = 0)
            self.newInput("Boolean", "EndPoint", "endPoint")
        self.newOutput("Array", "Array", "array")
        if self.rangeType == "START_STOP":
            self.newOutput("Float", "Step Size", "stepSize")

    def draw(self, layout):
        layout.prop(self, "arrayType", text = "")
        layout.prop(self, "rangeType", text = "")

    def getExecutionCode(self, required):
        if self.rangeType == "START_STOP":
            return "array, stepSize = numpy.linspace(start, stop, amount, endPoint, True, %s)" % (getArrayType(self.arrayType))
        else:
            return "array = numpy.arange(start, stop, step if step != 0 else 1, %s )" % (getArrayType(self.arrayType))
