import numpy
cimport numpy
from ... data_structures cimport Vector3DList, DoubleList

cdef inline bilinearInterpolation(double x, double y, double v00, double v10, double v01, double v11):
    return (v00 * (1 - x) * (1 - y) +
           v10 * x * (1 - y) +
           v01 * (1 - x) * y +
           v11 * x * y)

cdef inline trilinearInterpolation(double x, double y, double z, double v000, double v100, double v010,
                            double v001, double v101, double v011, double v110, double v111):
    return (v000 * (1 - x) * (1 - y) * (1 - z) +
           v100 * x * (1 - y) * (1 - z) +
           v010 * (1 - x) * y * (1 - z) +
           v001 * (1 - x) * (1 - y) * z +
           v101 * x * (1 - y) * z +
           v011 * (1 - x) * y * z +
           v110 * x * y * (1 - z) +
           v111 * x * y * z)

def interpolateScalarFieldBilinearly(numpy.ndarray[double, ndim=2, mode="c"] field, Vector3DList points):
    cdef Py_ssize_t i, xLength, yLength, xIndex, yIndex
    cdef double x, y, eps
    cdef DoubleList values = DoubleList(length = len(points))

    xLength = field.shape[1] - 1
    yLength = field.shape[0] - 1
    eps = numpy.finfo(numpy.float64).eps

    for i in range(len(points)):
        x, y = points.data[i].x, points.data[i].y
        if x == 1: x -= eps
        if y == 1: y -= eps
        xIndex = <int>(x * xLength)
        yIndex = <int>(y * yLength)
        x = (x * xLength) % 1
        y = (y * yLength) % 1

        if xIndex < xLength and yIndex < yLength and xIndex >= 0 and yIndex >= 0:
            values.data[i] = bilinearInterpolation(x, y, field[yIndex, xIndex],
                                                         field[yIndex, xIndex + 1],
                                                         field[yIndex + 1, xIndex],
                                                         field[yIndex + 1, xIndex + 1])
        else:
            values.data[i] = 0

    return values

def interpolateVectorFieldBilinearly(numpy.ndarray[double, ndim=3, mode="c"] field, Vector3DList points):
    cdef Py_ssize_t i, xLength, yLength, xIndex, yIndex
    cdef double x, y, eps
    cdef Vector3DList vectors = Vector3DList(length = len(points))

    xLength = field.shape[0] - 1
    yLength = field.shape[1] - 1
    eps = numpy.finfo(numpy.float64).eps

    for i in range(len(points)):
        x, y = points.data[i].x, points.data[i].y
        if x == 1: x -= eps
        if y == 1: y -= eps
        xIndex = <int>(x * xLength)
        yIndex = <int>(y * yLength)
        x = (x * xLength) % 1
        y = (y * yLength) % 1

        if xIndex < xLength and yIndex < yLength and xIndex >= 0 and yIndex >= 0:
            vectors.data[i].x = bilinearInterpolation(x, y, field[xIndex, yIndex, 0],
                                                           field[xIndex + 1, yIndex, 0],
                                                           field[xIndex, yIndex + 1, 0],
                                                           field[xIndex + 1, yIndex + 1, 0])
            vectors.data[i].y = bilinearInterpolation(x, y, field[xIndex, yIndex, 1],
                                                           field[xIndex + 1, yIndex, 1],
                                                           field[xIndex, yIndex + 1, 1],
                                                           field[xIndex + 1, yIndex + 1, 1])
            vectors.data[i].z = bilinearInterpolation(x, y, field[xIndex, yIndex, 2],
                                                           field[xIndex + 1, yIndex, 2],
                                                           field[xIndex, yIndex + 1, 2],
                                                           field[xIndex + 1, yIndex + 1, 2])
        else:
            vectors.data[i].x = 0
            vectors.data[i].y = 0
            vectors.data[i].z = 0

    return vectors
