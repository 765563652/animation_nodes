import bpy
from ... base_types import AnimationNode, VectorizedSocket

class RandomArrayNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_RandomArrayNode"
    bl_label = "Random Array"

    multi = VectorizedSocket.newProperty()

    def create(self):
        self.newInput(VectorizedSocket("Integer", "multi",
            ("Shape", "shape"), ("Shape", "shape")))
        self.newOutput("Array", "Array", "array")

    def getExecutionCode(self, required):
        yield "shape = max(shape, 0) if not hasattr(shape, '__iter__') else [max(e,0) for e in shape]"
        if self.multi:
            yield "array = numpy.random.rand(*shape)"
        else:
            yield "array = numpy.random.rand(shape)"
