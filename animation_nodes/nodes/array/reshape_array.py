import bpy
from bpy.props import *
from ... utils.layout import writeText
from ... base_types import AnimationNode, VectorizedSocket

orderTypes = [
    ("C", "C", "C Order", "", 0),
    ("F", "F", "F Order", "", 1),
    ("A", "A", "F if a is Fortran contiguous, C otherwise", "", 2),
]

class ReshapeArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ReshapeArrayNode"
    bl_label = "Reshape Array"

    order_type = EnumProperty(name = "Order", default = "C",
        items = orderTypes, update = AnimationNode.refresh)
    multi = VectorizedSocket.newProperty()
    errorMessage = StringProperty()

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Shape", "shape", dict(value = -1)), ("Shape", "shape")))
        self.newOutput("Array", "Array", "newArray")

    def draw(self, layout):
        layout.prop(self, "order_type", text="")
        if self.errorMessage != "":
            writeText(layout, self.errorMessage, icon = "ERROR", width = 50)

    def getExecutionCode(self, required):
        yield "try:"
        yield "    newArray = numpy.reshape(array, shape, %s)" % self.generateOrder(self.order_type)
        yield "    self.errorMessage = ''"
        yield "except Exception as e:"
        yield "    newArray = array"
        yield "    self.errorMessage = str(e)"

    def generateOrder(self, order_type):
        if order_type == "C":
            return "'C'"
        elif order_type == "F":
            return "'F'"
        else:
            return "'A'"
