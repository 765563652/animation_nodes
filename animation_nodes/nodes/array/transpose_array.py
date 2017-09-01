import bpy
from bpy.props import *
from ... utils.layout import writeText
from ... base_types import AnimationNode

class TransposeArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_TransposeArrayNode"
    bl_label = "Transpose Array"

    errorMessage = StringProperty()

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput("Integer List", "Axis", "axis")
        self.newOutput("Array", "SubArray", "newArray")

    def draw(self, layout):
        if self.errorMessage != "":
            writeText(layout, self.errorMessage, icon = "ERROR", width = 50)

    def getExecutionCode(self, required):
        yield "try:"
        if not "axis" in required:
            yield "    newArray = numpy.transpose(array)"
        else:
            yield "    newArray = numpy.transpose(array, axis)"
        yield "    self.errorMessage = ''"
        yield "except Exception as e:"
        yield "    subArray = array"
        yield "    self.errorMessage = str(e)"
