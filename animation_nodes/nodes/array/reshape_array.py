import bpy
import numpy
from bpy.props import *
from ... base_types import AnimationNode, VectorizedSocket

orderTypes = [
    ("C", "C", "C Order", "", 0),
    ("F", "F", "F Order", "", 1),
    ("A", "A", "F if a is Fortran contiguous, C otherwise", "", 2),
]

class ReshapeArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ReshapeArrayNode"
    bl_label = "Reshape Array"
    errorHandlingType = "EXCEPTION"

    order_type = EnumProperty(name = "Order", default = "C",
        items = orderTypes, update = AnimationNode.refresh)
    multi = VectorizedSocket.newProperty()

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Shape", "shape", dict(value = -1)), ("Shape", "shape")))
        self.newOutput("Array", "Array", "newArray")

    def draw(self, layout):
        layout.prop(self, "order_type", text="")

    def execute(self, array, shape):
        try: return numpy.reshape(array, shape, self.order_type)
        except Exception as e: self.raiseErrorMessage(str(e))
