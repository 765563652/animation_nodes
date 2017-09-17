import bpy
from bpy.props import *
from ... base_types import AnimationNode

conversionTypes = [
    ("Vector", "Vector", "Convert Array To 3D Vector List.", "", 0),
]

class ConvertArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ConvertArrayNode"
    bl_label = "Convert Array"

    conversion_type = EnumProperty(name = "Type", default = "Vector",
        items = conversionTypes, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Array", "Array", "array")
        if self.conversion_type == "Vector":
            self.newOutput("Vector List", "Vectors", "vectors")

    def draw(self, layout):
        layout.prop(self, "conversion_type", text="")

    def getExecutionCode(self, required):
        if self.conversion_type == "Vector":
            yield "vectors = AN.nodes.array.c_utils.arrayTo3DList(array)"
