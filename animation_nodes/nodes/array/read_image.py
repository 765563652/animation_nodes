import bpy
import numpy
from bpy.props import *
from ... base_types import AnimationNode

pixelFormates = [
    ("RGBA", "RGBA", "", "NONE", 0),
    ("RGB", "RGB", "", "NONE", 1),
    ("BW", "BW", "", "NONE", 2)
]

class ReadImageNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ReadImageNode"
    bl_label = "Read Image"

    pixelFormate = EnumProperty(name = "Pixel Formate", default = "RGB",
                                items = pixelFormates, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Text", "Image Name", "imageName")
        self.newOutput("Array", "Image Buffer", "imageBuffer")

    def draw(self, layout):
        layout.prop(self, "pixelFormate", text = "")

    def getExecutionFunctionName(self):
        return self.pixelFormate

    def RGBA(self, imageName):
        image = bpy.data.images[imageName]
        return numpy.asarray(image.pixels[:]).reshape(image.size[0], image.size[1], 4)

    def RGB(self, imageName):
        image = bpy.data.images[imageName]
        pixels = numpy.asarray(image.pixels[:]).reshape(image.size[0], image.size[1], 4)
        return numpy.delete(pixels, 3, 2)

    def BW(self, imageName):
        image = bpy.data.images[imageName]
        pixels = numpy.asarray(image.pixels[:]).reshape(image.size[0], image.size[1], 4)
        return numpy.delete(pixels, (1, 2, 3), 2)
