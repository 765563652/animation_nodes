import bpy
from bpy.props import *
from ... base_types import AnimationNode

orderTypes = [
    ("C", "C", "C Order", "", 0),
    ("F", "F", "F Order", "", 1),
    ("A", "A", "F if a is Fortran contiguous, C otherwise", "", 2),
    ("K", "K", "Match the layout of array as closely as possible", "", 3)
]

class EmptyLikeNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_EmptyLikeNode"
    bl_label = "Empty Like"

    order_type = EnumProperty(name = "Order", default = "K",
        items = orderTypes, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput("Boolean", "Subok", "subok")
        self.newOutput("Array", "Empty Array", "emptyArray")

    def draw(self, layout):
        layout.prop(self, "order_type", text="")

    def execute(self, array, subok):
        return numpy.empty_like(array, None, self.order_type, subok)
