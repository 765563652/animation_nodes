import bpy
import numpy
from bpy.props import *
from . array_types import arrayTypes
from ... base_types import AnimationNode, VectorizedSocket

orderTypes = [
    ("C", "C", "C Order", "", 0),
    ("F", "F", "F Order", "", 1),
]

class EmptyArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_EmptyArrayNode"
    bl_label = "Empty Array"

    arrayType = EnumProperty(name = "Data Type", default = "float32",
        items = arrayTypes, update = AnimationNode.refresh)
    orderType = EnumProperty(name = "Order", default = "C",
        items = orderTypes, update = AnimationNode.refresh)
    multi = VectorizedSocket.newProperty()

    def create(self):
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Shape", "shape"), ("Shape", "shape")))
        self.newOutput("Array", "Empty Array", "emptyArray")

    def draw(self, layout):
        layout.prop(self, "orderType", text="")
        layout.prop(self, "arrayType", text="")

    def execute(self, shape):
        return numpy.empty(max(shape, 0) if not hasattr(shape, '__iter__') else [max(e,0) for e in shape], self.arrayType, self.orderType)
