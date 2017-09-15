import bpy
from ... base_types import AnimationNode

class NumberOfBytesNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_NumberOfBytesNode"
    bl_label = "Number Of Bytes"

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newOutput("Integer", "Number Of Bytes", "n")

    def execute(self, array):
        return array.nbytes
