import bpy
import numpy
from ... base_types import AnimationNode, VectorizedSocket

class DeleteArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_DeleteArrayNode"
    bl_label = "Delete Array"
    errorHandlingType = "EXCEPTION"

    multi = VectorizedSocket.newProperty()

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Index", "obj"), ("Indices", "obj")))
        self.newInput("Integer", "Axis", "axis", value= -1)
        self.newOutput("Array", "SubArray", "subArray")

    def execute(self, array, obj, axis):
        try: return numpy.delete(array, obj, axis)
        except Exception as e: self.raiseErrorMessage(str(e))
