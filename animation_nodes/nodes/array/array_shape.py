import bpy
from ... base_types import AnimationNode

class ArrayShapeNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ArrayShapeNode"
    bl_label = "Array Shape"

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newOutput("Integer List", "Shape", "shape")

    def getExecutionCode(self, required):
        yield "shape = array.shape"
