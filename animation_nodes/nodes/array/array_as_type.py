import bpy
from bpy.props import *
from ... base_types import AnimationNode
from . array_types import arrayTypes, getArrayType

class ArrayAsTypeNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ArrayAsTypeNode"
    bl_label = "Array As Type"

    array_type = EnumProperty(name = "Data Type", default = "FLOAT32",
        items = arrayTypes, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Array", "Array", "old")
        self.newOutput("Array", "Array", "new")

    def draw(self, layout):
        layout.prop(self, "array_type", text="")

    def getExecutionCode(self, required):
        return "new = old.astype(%s)" % getArrayType(self.array_type)
