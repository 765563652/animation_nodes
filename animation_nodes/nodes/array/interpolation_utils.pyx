import numpy
cimport numpy
cimport cython
from cython.parallel import prange
from ... data_structures cimport Vector3DList, DoubleList

cdef inline double bilinearInterpolation(double x, double y, double v00, double v10,
                                                             double v01, double v11) nogil:
    return (v00 * (1 - x) * (1 - y) +
           v10 * x * (1 - y) +
           v01 * (1 - x) * y +
           v11 * x * y)

cdef inline double trilinearInterpolation(double x, double y, double z, double v000, double v100,
                                          double v010, double v001, double v101, double v011,
                                          double v110, double v111) nogil:
    return (v000 * (1 - x) * (1 - y) * (1 - z) +
           v100 * x * (1 - y) * (1 - z) +
           v010 * (1 - x) * y * (1 - z) +
           v001 * (1 - x) * (1 - y) * z +
           v101 * x * (1 - y) * z +
           v011 * (1 - x) * y * z +
           v110 * x * y * (1 - z) +
           v111 * x * y * z)

@cython.boundscheck(False)
@cython.wraparound(False)
def interpolateScalarFieldBilinearly(numpy.ndarray[double, ndim=2, mode="c"] field, Vector3DList points):
    cdef Py_ssize_t i, xLength, yLength, xIndex, yIndex, numPoints
    cdef bint xEdged, yEdged
    cdef double x, y

    numPoints = len(points)
    xLength = field.shape[1] - 1
    yLength = field.shape[0] - 1

    cdef DoubleList values = DoubleList(length = numPoints)

    for i in prange(numPoints, nogil=True, schedule='guided'):
        x, y = points.data[i].x, points.data[i].y
        if x <= 1 and y <= 1 and x >= 0 and y >= 0:
            x *= xLength
            y *= yLength
            xIndex = <int>x
            yIndex = <int>y
            xEdged = xIndex != xLength
            yEdged = yIndex != yLength
            x = x % 1
            y = y % 1
            values.data[i] = bilinearInterpolation(x, y, field[yIndex, xIndex],
                                                         field[yIndex, xIndex + xEdged],
                                                         field[yIndex + yEdged, xIndex],
                                                         field[yIndex + yEdged, xIndex + xEdged])
        else:
            values.data[i] = 0

    return values

@cython.boundscheck(False)
@cython.wraparound(False)
def interpolateVectorFieldBilinearly(numpy.ndarray[double, ndim=3, mode="c"] field, Vector3DList points):
    cdef Py_ssize_t i, xLength, yLength, xIndex, yIndex, numPoints
    cdef bint xEdged, yEdged
    cdef double x, y

    numPoints = len(points)
    xLength = field.shape[1] - 1
    yLength = field.shape[0] - 1

    cdef Vector3DList vectors = Vector3DList(length = numPoints)

    for i in prange(numPoints, nogil=True, schedule='guided'):
        x, y = points.data[i].x, points.data[i].y
        if x <= 1 and y <= 1 and x >= 0 and y >= 0:
            x *= xLength
            y *= yLength
            xIndex = <int>x
            yIndex = <int>y
            xEdged = xIndex != xLength
            yEdged = yIndex != yLength
            x = x % 1
            y = y % 1

            vectors.data[i].x = bilinearInterpolation(x, y, field[yIndex, xIndex, 0],
                                                         field[yIndex, xIndex + xEdged, 0],
                                                         field[yIndex + yEdged, xIndex, 0],
                                                         field[yIndex + yEdged, xIndex + xEdged, 0])
            vectors.data[i].y = bilinearInterpolation(x, y, field[yIndex, xIndex, 1],
                                                         field[yIndex, xIndex + xEdged, 1],
                                                         field[yIndex + yEdged, xIndex, 1],
                                                         field[yIndex + yEdged, xIndex + xEdged, 1])
            vectors.data[i].z = bilinearInterpolation(x, y, field[yIndex, xIndex, 2],
                                                         field[yIndex, xIndex + xEdged, 2],
                                                         field[yIndex + yEdged, xIndex, 2],
                                                         field[yIndex + yEdged, xIndex + xEdged, 2])
        else:
            vectors.data[i].x = 0
            vectors.data[i].y = 0
            vectors.data[i].z = 0

    return vectors

@cython.boundscheck(False)
@cython.wraparound(False)
def interpolateScalarFieldTrilinearly(numpy.ndarray[double, ndim=3, mode="c"] field, Vector3DList points):
    cdef Py_ssize_t i, xLength, yLength, zLength, xIndex, yIndex, zIndex, numPoints
    cdef bint xEdged, yEdged, zEdged
    cdef double x, y, z

    numPoints = len(points)
    xLength = field.shape[2] - 1
    yLength = field.shape[1] - 1
    zLength = field.shape[0] - 1

    cdef DoubleList values = DoubleList(length = numPoints)

    for i in prange(numPoints, nogil=True, schedule='guided'):
        x, y, z = points.data[i].x, points.data[i].y, points.data[i].z
        if x <= 1 and y <= 1 and z <= 1 and x >= 0 and y >= 0 and z >= 0:
            x *= xLength
            y *= yLength
            z *= zLength
            xIndex = <int>x
            yIndex = <int>y
            zIndex = <int>z
            xEdged = xIndex != xLength
            yEdged = yIndex != yLength
            zEdged = zIndex != zLength
            x = x % 1
            y = y % 1
            z = z % 1
            values.data[i] = trilinearInterpolation(x, y, z, field[zIndex, yIndex, xIndex],
                                                    field[zIndex, yIndex, xIndex + xEdged],
                                                    field[zIndex, yIndex + yEdged, xIndex],
                                                    field[zIndex + zEdged, yIndex, xIndex],
                                                    field[zIndex + zEdged, yIndex, xIndex + xEdged],
                                                    field[zIndex + zEdged, yIndex + yEdged, xIndex],
                                                    field[zIndex, yIndex + yEdged, xIndex + xEdged],
                                                    field[zIndex + zEdged, yIndex + yEdged,
                                                                           xIndex + xEdged])
        else:
            values.data[i] = 0

    return values

@cython.boundscheck(False)
@cython.wraparound(False)
def interpolateVectorFieldTrilinearly(numpy.ndarray[double, ndim=4, mode="c"] field, Vector3DList points):
    cdef Py_ssize_t i, xLength, yLength, zLength, xIndex, yIndex, zIndex, numPoints
    cdef bint xEdged, yEdged, zEdged
    cdef double x, y, z

    numPoints = len(points)
    xLength = field.shape[2] - 1
    yLength = field.shape[1] - 1
    zLength = field.shape[0] - 1

    cdef Vector3DList vectors = Vector3DList(length = numPoints)

    for i in prange(numPoints, nogil=True, schedule='guided'):
        x, y, z = points.data[i].x, points.data[i].y, points.data[i].z
        if x <= 1 and y <= 1 and z <= 1 and x >= 0 and y >= 0 and z >= 0:
            x *= xLength
            y *= yLength
            z *= zLength
            xIndex = <int>x
            yIndex = <int>y
            zIndex = <int>z
            xEdged = xIndex != xLength
            yEdged = yIndex != yLength
            zEdged = zIndex != zLength
            x = x % 1
            y = y % 1
            z = z % 1
            vectors.data[i].x = trilinearInterpolation(x, y, z, field[zIndex, yIndex, xIndex, 0],
                                                       field[zIndex, yIndex, xIndex + xEdged, 0],
                                                       field[zIndex, yIndex + yEdged, xIndex, 0],
                                                       field[zIndex + zEdged, yIndex, xIndex, 0],
                                                       field[zIndex + zEdged, yIndex,
                                                                             xIndex + xEdged, 0],
                                                       field[zIndex + zEdged, yIndex + yEdged,
                                                                                      xIndex, 0],
                                                       field[zIndex, yIndex + yEdged,
                                                                             xIndex + xEdged, 0],
                                                       field[zIndex + zEdged, yIndex + yEdged,
                                                                             xIndex + xEdged, 0])

            vectors.data[i].y = trilinearInterpolation(x, y, z, field[zIndex, yIndex, xIndex, 1],
                                                       field[zIndex, yIndex, xIndex + xEdged, 1],
                                                       field[zIndex, yIndex + yEdged, xIndex, 1],
                                                       field[zIndex + zEdged, yIndex, xIndex, 1],
                                                       field[zIndex + zEdged, yIndex,
                                                                             xIndex + xEdged, 1],
                                                       field[zIndex + zEdged, yIndex + yEdged,
                                                                                      xIndex, 1],
                                                       field[zIndex, yIndex + yEdged,
                                                                             xIndex + xEdged, 1],
                                                       field[zIndex + zEdged, yIndex + yEdged,
                                                                             xIndex + xEdged, 1])

            vectors.data[i].z = trilinearInterpolation(x, y, z, field[zIndex, yIndex, xIndex, 2],
                                                       field[zIndex, yIndex, xIndex + xEdged, 2],
                                                       field[zIndex, yIndex + yEdged, xIndex, 2],
                                                       field[zIndex + zEdged, yIndex, xIndex, 2],
                                                       field[zIndex + zEdged, yIndex,
                                                                             xIndex + xEdged, 2],
                                                       field[zIndex + zEdged, yIndex + yEdged,
                                                                                      xIndex, 2],
                                                       field[zIndex, yIndex + yEdged,
                                                                             xIndex + xEdged, 2],
                                                       field[zIndex + zEdged, yIndex + yEdged,
                                                                             xIndex + xEdged, 2])
        else:
            vectors.data[i].x = 0
            vectors.data[i].y = 0
            vectors.data[i].z = 0

    return vectors
