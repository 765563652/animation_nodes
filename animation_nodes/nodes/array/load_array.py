import bpy
import numpy
from ... base_types import AnimationNode


class LoadArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_LoadArrayNode"
    bl_label = "Load Array"

    def create(self):
        self.newInput("Text", "Identifier", "identifier")
        self.newInput("Integer", "Index", "index")
        self.newOutput("Array", "Array", "array")

    def execute(self, identifier, index):
        return numpy.load("/tmp/"+identifier+str(index)+".npy")
