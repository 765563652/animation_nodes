import bpy
from bpy.props import *
from . array_types import arrayTypes, getArrayType
from ... base_types import AnimationNode, VectorizedSocket

orderTypes = [
    ("C", "C", "C Order", "", 0),
    ("F", "F", "F Order", "", 1),
]

class EmptyArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_EmptyArrayNode"
    bl_label = "Empty Array"

    order_type = EnumProperty(name = "Order", default = "C",
        items = orderTypes, update = AnimationNode.refresh)
    array_type = EnumProperty(name = "Data Type", default = "FLOAT32",
        items = arrayTypes, update = AnimationNode.refresh)
    multi = VectorizedSocket.newProperty()

    def create(self):
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Shape", "shape"), ("Shape", "shape")))
        self.newOutput("Array", "Empty Array", "emptyArray")

    def draw(self, layout):
        layout.prop(self, "order_type", text="")
        layout.prop(self, "array_type", text="")

    def getExecutionCode(self, required):
        yield "emptyArray = numpy.empty(max(shape, 0) if not hasattr(shape, '__iter__') else [max(e,0) for e in shape], %s, %s)" % ( getArrayType(self.array_type) , "'C'" if self.order_type == "C" else "'F'")
