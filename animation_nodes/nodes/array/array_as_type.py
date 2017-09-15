import bpy
from bpy.props import *
from . array_types import arrayTypes
from ... base_types import AnimationNode

class ArrayAsTypeNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ArrayAsTypeNode"
    bl_label = "Array As Type"

    array_type = EnumProperty(name = "Data Type", default = "float32",
        items = arrayTypes, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Array", "Array", "old")
        self.newOutput("Array", "Array", "new")

    def draw(self, layout):
        layout.prop(self, "array_type", text="")

    def execute(self, old):
        return old.astype(self.array_type)
