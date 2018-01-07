import bpy
import numpy
from bpy.props import *
from ... base_types import AnimationNode
from . interpolation_utils import (interpolateScalarFieldBilinearly,
                                   interpolateVectorFieldBilinearly,
                                   interpolateScalarFieldTrilinearly,
                                   interpolateVectorFieldTrilinearly)

interpolationTypes = [
    ("2D_SCALAR_FIELD", "2D Scalar Field", "", "NONE", 0),
    ("2D_VECTOR_FIELD", "2D Vector Field", "", "NONE", 1),
    ("3D_SCALAR_FIELD", "3D Scalar Field", "", "NONE", 2),
    ("3D_VECTOR_FIELD", "3D Vector Field", "", "NONE", 3)
]

class InterpolateFieldNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_InterpolateFieldNode"
    bl_label = "Interpolate Field"

    interpolationType = EnumProperty(name = "Interpolation Type", default = "2D_SCALAR_FIELD",
                                     items = interpolationTypes, update = AnimationNode.refresh)

    def create(self):
        self.newInput("Array", "Field", "field")
        self.newInput("Vector List", "Points", "points")
        if self.interpolationType in ("2D_SCALAR_FIELD", "3D_SCALAR_FIELD"):
            self.newOutput("Float List", "Values", "values")
        else:
            self.newOutput("Vector List", "Vectors", "vectors")


    def draw(self, layout):
        layout.prop(self, "interpolationType", text = "")

    def getExecutionFunctionName(self):
        if self.interpolationType == "2D_SCALAR_FIELD":
            return "interpolate2DScalarField"
        elif self.interpolationType == "2D_VECTOR_FIELD":
            return "interpolate2DVectorField"
        elif self.interpolationType == "3D_SCALAR_FIELD":
            return "interpolate3DScalarField"
        elif self.interpolationType == "3D_VECTOR_FIELD":
            return "interpolate3DVectorField"

    def interpolate2DScalarField(self, field, points):
        return interpolateScalarFieldBilinearly(field, points)
    def interpolate2DVectorField(self, field, points):
        return interpolateVectorFieldBilinearly(field, points)
    def interpolate3DScalarField(self, field, points):
        return interpolateScalarFieldTrilinearly(field, points)
    def interpolate3DVectorField(self, field, points):
        return interpolateVectorFieldTrilinearly(field, points)
