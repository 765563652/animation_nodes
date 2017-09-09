import bpy
import numpy
from ... base_types import AnimationNode, VectorizedSocket

class RollArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_RollArrayNode"
    bl_label = "Roll Array"
    errorHandlingType = "EXCEPTION"

    multi = VectorizedSocket.newProperty()

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Shift", "shift"), ("Shift", "shift")))
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Axis", "axis"), ("Axis", "axis")))
        self.newOutput("Array", "Array", "Array")

    def execute(self, array, shift, axis):
        try: return numpy.roll(array, shift, axis)
        except Exception as e: self.raiseErrorMessage(str(e))
