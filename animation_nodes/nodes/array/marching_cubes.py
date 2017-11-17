import bpy
from ... base_types import AnimationNode
from . marching_cubes_utils import getSurfaceMesh

class MarchingCubesNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_MarchingCubesNode"
    bl_label = "Marching Cubes"
    bl_width_default = 160
    errorHandlingType = "EXCEPTION"

    def create(self):
        self.newInput("Array", "Field", "field")
        self.newOutput("Mesh", "Mesh", "mesh")

    def execute(self, field):
        try: return getSurfaceMesh(field)
        except Exception as e: self.raiseErrorMessage(str(e))
