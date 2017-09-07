import bpy

from ... utils.layout import writeText
from ... base_types import AnimationNode

class TransposeArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_TransposeArrayNode"
    bl_label = "Transpose Array"
    errorHandlingType = "EXCEPTION"

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput("Integer List", "Axis", "axis")
        self.newOutput("Array", "SubArray", "newArray")

    def getExecutionCode(self, required):
        yield "try:"
        if not "axis" in required:
            yield "    newArray = numpy.transpose(array)"
        else:
            yield "    newArray = numpy.transpose(array, axis)"
        yield "    self.errorMessage = ''"
        yield "except Exception as e:"
        yield "    self.raiseErrorMessage(str(e))"
