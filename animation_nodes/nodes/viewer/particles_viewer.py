import bpy
from bgl import *
from bpy.props import *
from ... draw_handler import drawHandler
from ... base_types import AnimationNode
from ... tree_info import getNodesByType
from ... utils.blender_ui import redrawAll
from ... data_structures import Vector3DList
from ... graphics.c_utils import drawColoredVector3DListPoints
from ... graphics.opengl import createDisplayList, drawDisplayList, freeDisplayList

dataByIdentifier = {}

class DrawData:
    def __init__(self, data, displayList):
        self.data = data
        self.displayList = displayList

class ParticlesViewerNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ParticlesViewerNode"
    bl_label = "Particles Viewer"
    errorHandlingType = "EXCEPTION"

    def redrawViewport(self, context):
        redrawAll()

    def create(self):
        self.newInput("Vector List", "Locations", "locations")
        self.newInput("Array", "Colors", "colors")
        self.newInput("Integer", "Size", "size")

    def execute(self, locations, colors, size):
        self.freeDrawingData()
        displayList = None

        if len(locations) == 0 or len(colors.shape) != 2 or len(locations) != colors.shape[0]:
            self.raiseErrorMessage("Shapes are not consistent.")

        displayList = createDisplayList(drawVectors, locations, colors, size)

        if displayList is not None:
            dataByIdentifier[self.identifier] = DrawData(locations, displayList)

    def delete(self):
        self.freeDrawingData()

    def freeDrawingData(self):
        if self.identifier in dataByIdentifier:
            freeDisplayList(dataByIdentifier[self.identifier].displayList)
            del dataByIdentifier[self.identifier]

    def getCurrentData(self):
        if self.identifier in dataByIdentifier:
            return dataByIdentifier[self.identifier].data

def drawVectors(vectors, colors, size):
    glEnable(GL_POINT_SIZE)
    glPointSize(size)

    drawColoredVector3DListPoints(vectors, colors)

    glDisable(GL_POINT_SIZE)

@drawHandler("SpaceView3D", "WINDOW", "POST_VIEW")
def draw():
    for node in getNodesByType("an_ParticlesViewerNode"):
        if node.identifier in dataByIdentifier:
            drawDisplayList(dataByIdentifier[node.identifier].displayList)
