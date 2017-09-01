import bpy
from bpy.props import *
from ... utils.layout import writeText
from ... base_types import AnimationNode, VectorizedSocket

class DeleteArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_DeleteArrayNode"
    bl_label = "Delete Array"

    multi = VectorizedSocket.newProperty()
    errorMessage = StringProperty()

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Index", "obj"), ("Indices", "obj")))
        self.newInput("Integer", "Axis", "axis", value= -1)
        self.newOutput("Array", "SubArray", "subArray")

    def draw(self, layout):
        if self.errorMessage != "":
            writeText(layout, self.errorMessage, icon = "ERROR", width = 50)

    def getExecutionCode(self, required):
        yield "try:"
        yield "    subArray = numpy.delete(array, obj, axis)"
        yield "    self.errorMessage = ''"
        yield "except Exception as e:"
        yield "    subArray = array"
        yield "    self.errorMessage = str(e)"
