import bpy
from ... base_types import AnimationNode, VectorizedSocket

class ArgPartitionNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ArgPartitionNode"
    bl_label = "ArgPartition"

    multi = VectorizedSocket.newProperty()

    def create(self):
        self.newInput("Array", "Array", "array")
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Kth", "kth"), ("Kth", "kth")))
        self.newInput("Integer", "Axis", "axis", value= -1)
        self.newOutput("Array", "Indices", "indices")

    def execute(self, array, kth, axis):
        return numpy.argpartition(array, kth, axis)
