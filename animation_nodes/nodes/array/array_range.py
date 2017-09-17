import bpy
import numpy
from bpy.props import *
from . array_types import arrayTypes
from ... base_types import AnimationNode

stepTypeItems = [
    ("START_STOP", "Start / Stop", "", "NONE", 0),
    ("START_STEP", "Start / Step", "", "NONE", 1)
]

class ArrayRangeNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ArrayRangeNode"
    bl_label = "Array Range"

    arrayType = EnumProperty(name = "Data Type", default = "float32",
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

    def getExecutionFunctionName(self):
        if self.rangeType == "START_STOP":
            return "start_stop"
        else:
            return "start_step"

    def start_stop(self, start, stop, amount, endPoint):
        return numpy.linspace(start, stop, amount, endPoint, True, self.arrayType)
    def start_step(self, start, stop, step):
        return numpy.arange(start, stop, step if step != 0 else 1, self.arrayType)
