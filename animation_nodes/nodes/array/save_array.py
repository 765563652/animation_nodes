import bpy
import numpy
from ... base_types import AnimationNode


class SaveArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_SaveArrayNode"
    bl_label = "Save Array"

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput("Text", "Identifier", "identifier")
        self.newInput("Integer", "Index", "index")
        self.newInput("Boolean", "Wrire", "write")

    def execute(self, array, identifier, index, write):
        if write:
            numpy.save("/tmp/"+identifier+str(index), array)
