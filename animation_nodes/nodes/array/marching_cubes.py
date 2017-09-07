import bpy
from ... base_types import AnimationNode
from . marching_cubes_utils import marchingCubes

class MarchingCubesNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_MarchingCubesNode"
    bl_label = "Marching Cubes"
    bl_width_default = 160

    def create(self):
        self.newInput("Array", "Field", "field")
        self.newOutput("Vector List", "Triangles", "triangles")

    def execute(self, field):
        return marchingCubes(field)
