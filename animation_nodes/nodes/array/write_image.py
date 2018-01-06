import bpy
import numpy
from bpy.props import *
from ... base_types import AnimationNode
from . c_utils import arrayToFloatList

pixelFormates = [
    ("RGBA", "RGBA", "", "NONE", 0),
    ("RGB", "RGB", "", "NONE", 1),
    ("BW", "BW", "", "NONE", 2)
]

class WriteImageNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_WriteImageNode"
    bl_label = "Write Image"

    pixelFormate = EnumProperty(name = "Pixel Formate", default = "RGB",
                                items = pixelFormates, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Array", "Image Buffer", "imageBuffer")
        self.newInput("Text", "Image Name", "imageName")

    def draw(self, layout):
        layout.prop(self, "pixelFormate", text = "")

    def getExecutionFunctionName(self):
        return self.pixelFormate

    def RGBA(self, imageBuffer, imageName):
        if imageName in bpy.data.images:
            image = bpy.data.images[imageName]
        else:
            image = bpy.data.images.new(imageName, imageBuffer.shape[0], imageBuffer.shape[1])
        image.generated_width = imageBuffer.shape[0]
        image.generated_height = imageBuffer.shape[1]
        image.pixels = arrayToFloatList(imageBuffer.reshape(-1))

    def RGB(self, imageBuffer, imageName):
        if imageName in bpy.data.images:
            image = bpy.data.images[imageName]
        else:
            image = bpy.data.images.new(imageName, imageBuffer.shape[0], imageBuffer.shape[1])
        image.generated_width = imageBuffer.shape[0]
        image.generated_height = imageBuffer.shape[1]
        image.pixels = arrayToFloatList(numpy.concatenate([imageBuffer,
                                        numpy.ones(imageBuffer.shape[:2]+(1,))], 2).reshape(-1))

    def BW(self, imageName):
        if imageName in bpy.data.images:
            image = bpy.data.images[imageName]
        else:
            image = bpy.data.images.new(imageName, imageBuffer.shape[0], imageBuffer.shape[1])
        image.generated_width = imageBuffer.shape[0]
        image.generated_height = imageBuffer.shape[1]
        image.pixels = arrayToFloatList(numpy.concatenate([imageBuffer, imageBuffer, imageBuffer,
                                        numpy.ones(imageBuffer.shape[:2]+(1,))], 2).reshape(-1))
