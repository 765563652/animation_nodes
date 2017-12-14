from libc.math cimport sin, cos
from libc.math cimport M_PI as PI
from ... data_structures cimport Vector3DList, EdgeIndicesList, PolygonIndicesList, Mesh

# Vertices
###########################################

def getCylinderMesh():
    print("To Do.")

def vertices(Py_ssize_t radialLoops, Py_ssize_t verticalLoops, Py_ssize_t innerLoops,
             float outerRadius, float innerRadius, float height,
             float startAngle, float endAngle,
             bint mergeStartEnd, bint mergeCenter):

    cdef:
        Py_ssize_t i, j, numVerts, dummyIndex
        Vector3DList vertices
        float outerRadiusCos, outerRadiusSin, innerRadiusCos, innerRadiusSin, iRadius, newCos
        float heightStep = height / max(verticalLoops - 1, 1)
        float innerStep = (outerRadius if mergeCenter else outerRadius - innerRadius) / (innerLoops + 1)
        float angleStep = (2 * PI if mergeStartEnd else endAngle - startAngle) / (radialLoops if mergeStartEnd else radialLoops - 1)
        float iCos = cos(startAngle)
        float iSin = sin(startAngle)
        float eCos = cos(endAngle)
        float eSin = sin(endAngle)
        float stepCos = cos(angleStep)
        float stepSin = sin(angleStep)

    if verticalLoops == 1:
        numVerts = radialLoops * (innerLoops + 1 + (not mergeCenter)) + mergeCenter
        vertices = Vector3DList(length = numVerts, capacity = numVerts)

        for i in range(radialLoops):
            for j in range(innerLoops + 2):
                iRadius = outerRadius - innerStep * j
                dummyIndex = j * radialLoops + i
                vertices.data[dummyIndex].x = iCos * iRadius
                vertices.data[dummyIndex].y = iSin * iRadius
                vertices.data[dummyIndex].z = 0

            newCos = stepCos * iCos - stepSin * iSin
            iSin = stepSin * iCos + stepCos * iSin
            iCos = newCos

        if mergeCenter:
            dummyIndex = numVerts - 1
            vertices.data[dummyIndex].x = 0
            vertices.data[dummyIndex].y = 0
            vertices.data[dummyIndex].z = 0

        return vertices

    if mergeStartEnd:
        if mergeCenter:
            numVerts = radialLoops * (verticalLoops + innerLoops * 2) + 2
        else:
            numVerts = 2 * radialLoops * (verticalLoops + innerLoops)
    else:
        if mergeCenter:
            numVerts = radialLoops * verticalLoops + 2 * (radialLoops + verticalLoops - 2) * innerLoops + verticalLoops
        else:
            numVerts = 2 * (radialLoops * verticalLoops + innerLoops * (radialLoops + verticalLoops - 2))

    vertices = Vector3DList(length = numVerts, capacity = numVerts)

    if not mergeStartEnd:
        for i in range(verticalLoops - 2):
            for j in range(innerLoops):
                iRadius = outerRadius - innerStep * (j + 1)
                if mergeCenter:
                    dummyIndex = radialLoops * (verticalLoops + innerLoops * 2) + i * innerLoops + j
                else:
                    dummyIndex = 2 * radialLoops * (verticalLoops + innerLoops) + i * innerLoops + j
                vertices.data[dummyIndex].x = iCos * iRadius
                vertices.data[dummyIndex].y = iSin * iRadius
                vertices.data[dummyIndex].z = (i + 1) * heightStep
                dummyIndex += innerLoops * (verticalLoops - 2)
                vertices.data[dummyIndex].x = eCos * iRadius
                vertices.data[dummyIndex].y = eSin * iRadius
                vertices.data[dummyIndex].z = (i + 1) * heightStep

    for i in range(radialLoops):
        outerRadiusCos = iCos * outerRadius
        outerRadiusSin = iSin * outerRadius
        innerRadiusCos = iCos * innerRadius
        innerRadiusSin = iSin * innerRadius

        for j in range(innerLoops):
            iRadius = innerRadius * (not mergeCenter) + innerStep * (j + 1)
            dummyIndex = j * radialLoops + i
            vertices.data[dummyIndex].x = iCos * iRadius
            vertices.data[dummyIndex].y = iSin * iRadius
            vertices.data[dummyIndex].z = 0
            iRadius = outerRadius - innerStep * (j + 1)
            dummyIndex += radialLoops * (verticalLoops + innerLoops)
            vertices.data[dummyIndex].x = iCos * iRadius
            vertices.data[dummyIndex].y = iSin * iRadius
            vertices.data[dummyIndex].z = height

        for j in range(verticalLoops):
            dummyIndex = radialLoops * innerLoops + j * radialLoops + i
            vertices.data[dummyIndex].x = outerRadiusCos
            vertices.data[dummyIndex].y = outerRadiusSin
            vertices.data[dummyIndex].z = j * heightStep

            if not mergeCenter:
                dummyIndex += radialLoops * (innerLoops + verticalLoops)
                vertices.data[dummyIndex].x = innerRadiusCos
                vertices.data[dummyIndex].y = innerRadiusSin
                vertices.data[dummyIndex].z = height - j * heightStep

        newCos = stepCos * iCos - stepSin * iSin
        iSin = stepSin * iCos + stepCos * iSin
        iCos = newCos

    if mergeStartEnd:
        if mergeCenter:
            dummyIndex = numVerts - 2
            vertices.data[dummyIndex].x = 0
            vertices.data[dummyIndex].y = 0
            vertices.data[dummyIndex].z = 0
            dummyIndex += 1
            vertices.data[dummyIndex].x = 0
            vertices.data[dummyIndex].y = 0
            vertices.data[dummyIndex].z = height
    else:
        if mergeCenter:
            for i in range(verticalLoops):
                dummyIndex = radialLoops * (verticalLoops + innerLoops * 2) + innerLoops * (verticalLoops - 2) * 2 + i
                vertices.data[dummyIndex].x = 0
                vertices.data[dummyIndex].y = 0
                vertices.data[dummyIndex].z = i * heightStep

    return vertices

def polygons(Py_ssize_t radialLoops, Py_ssize_t verticalLoops, Py_ssize_t innerLoops,
             bint mergeStartEnd, bint mergeCenter):

    cdef:
        PolygonIndicesList polygons
        Py_ssize_t i, j, polygonAmount, indicesAmount, dummyIndex, dummyIndexII

    if mergeStartEnd:
        if mergeCenter:
            polygonAmount = radialLoops * (innerLoops * 2 + verticalLoops + 1)
            indicesAmount = (innerLoops * 2 + verticalLoops - 1) * radialLoops * 4 + radialLoops * 6
        else:
            polygonAmount = 2 * (verticalLoops + innerLoops) * radialLoops
            indicesAmount = polygonAmount * 4
    else:
        if mergeCenter:
            polygonAmount = (innerLoops * 2 + verticalLoops + 1) * (radialLoops - 1) + (innerLoops + 1) * (verticalLoops - 1) * 2
            indicesAmount = ((innerLoops * 2 + verticalLoops - 1) * (radialLoops - 1) + (innerLoops + 1) * (verticalLoops - 1) * 2) * 4 + 6 * (radialLoops - 1)
        else:
            polygonAmount = 2 * (verticalLoops + innerLoops) * (radialLoops - 1) + (innerLoops + 1) * (verticalLoops - 1) * 2
            indicesAmount = polygonAmount * 4

    polygons = PolygonIndicesList(
        indicesAmount = indicesAmount,
        polygonAmount = polygonAmount)

    if mergeStartEnd:
        if mergeCenter:
            for i in range((innerLoops * 2 + verticalLoops - 1) * radialLoops):
                polygons.polyStarts.data[i] = i * 4
                polygons.polyLengths.data[i] = 4

                polygons.indices.data[i * 4 + 0] = 0
                polygons.indices.data[i * 4 + 1] = 1
                polygons.indices.data[i * 4 + 2] = 2
                polygons.indices.data[i * 4 + 3] = 3
            for i in range(radialLoops * 2):
                dummyIndex = (innerLoops * 2 + verticalLoops - 1) * radialLoops * 4
                dummyIndexII = i + (innerLoops * 2 + verticalLoops - 1) * radialLoops
                polygons.polyStarts.data[dummyIndexII] = dummyIndex + i * 3
                polygons.polyLengths.data[dummyIndexII] = 3

                polygons.indices.data[dummyIndex + i * 3 + 0] = 0
                polygons.indices.data[dummyIndex + i * 3 + 1] = 1
                polygons.indices.data[dummyIndex + i * 3 + 2] = 2
        else:
            for i in range(2 * (verticalLoops + innerLoops) * radialLoops):
                polygons.polyStarts.data[i] = i * 4
                polygons.polyLengths.data[i] = 4

                polygons.indices.data[i * 4 + 0] = 0
                polygons.indices.data[i * 4 + 1] = 1
                polygons.indices.data[i * 4 + 2] = 2
                polygons.indices.data[i * 4 + 3] = 3
    else:
        if mergeCenter:
            for i in range(((innerLoops * 2 + verticalLoops - 1) * (radialLoops - 1) + (innerLoops + 1) * (verticalLoops - 1) * 2)):
                polygons.polyStarts.data[i] = i * 4
                polygons.polyLengths.data[i] = 4

                polygons.indices.data[i * 4 + 0] = 0
                polygons.indices.data[i * 4 + 1] = 1
                polygons.indices.data[i * 4 + 2] = 2
                polygons.indices.data[i * 4 + 3] = 3
            for i in range((radialLoops - 1) * 2):
                dummyIndex = ((innerLoops * 2 + verticalLoops - 1) * (radialLoops - 1) + (innerLoops + 1) * (verticalLoops - 1) * 2) * 4
                dummyIndexII = i + ((innerLoops * 2 + verticalLoops - 1) * (radialLoops - 1) + (innerLoops + 1) * (verticalLoops - 1) * 2)
                polygons.polyStarts.data[dummyIndexII] = dummyIndex + i * 3
                polygons.polyLengths.data[dummyIndexII] = 3

                polygons.indices.data[dummyIndex + i * 3 + 0] = 0
                polygons.indices.data[dummyIndex + i * 3 + 1] = 1
                polygons.indices.data[dummyIndex + i * 3 + 2] = 2
        else:
            for i in range(2 * (verticalLoops + innerLoops) * (radialLoops - 1) + (innerLoops + 1) * (verticalLoops - 1) * 2):
                polygons.polyStarts.data[i] = i * 4
                polygons.polyLengths.data[i] = 4

                polygons.indices.data[i * 4 + 0] = 0
                polygons.indices.data[i * 4 + 1] = 1
                polygons.indices.data[i * 4 + 2] = 2
                polygons.indices.data[i * 4 + 3] = 3

    if mergeStartEnd:
        for i in range((verticalLoops + verticalLoops * (not mergeCenter) + 2 * innerLoops - 1) * (radialLoops - 1)):
            dummyIndex = i + i//(radialLoops - 1)
            polygons.polyStarts.data[dummyIndex] = dummyIndex * 4
            polygons.polyLengths.data[dummyIndex] = 4

            i = dummyIndex * 4
            polygons.indices.data[i + 0] = dummyIndex
            polygons.indices.data[i + 1] = dummyIndex + 1
            polygons.indices.data[i + 2] = dummyIndex + radialLoops + 1
            polygons.indices.data[i + 3] = dummyIndex + radialLoops

        for i in range(radialLoops - 1, (verticalLoops + verticalLoops * (not mergeCenter) + 2 * innerLoops - 1) * radialLoops, radialLoops):
            dummyIndex = 4 * i
            polygons.polyStarts.data[i] = dummyIndex
            polygons.polyLengths.data[i] = 4

            polygons.indices.data[dummyIndex + 0] = i
            polygons.indices.data[dummyIndex + 1] = i - radialLoops + 1
            polygons.indices.data[dummyIndex + 2] = i + 1
            polygons.indices.data[dummyIndex + 3] = i + radialLoops
    else:
        for i in range((verticalLoops + verticalLoops * (not mergeCenter) + 2 * innerLoops - 1) * (radialLoops - 1)):
            dummyIndex = i + i//(radialLoops - 1)
            polygons.polyStarts.data[i] = i * 4
            polygons.polyLengths.data[i] = 4

            i *= 4
            polygons.indices.data[i + 0] = dummyIndex
            polygons.indices.data[i + 1] = dummyIndex + 1
            polygons.indices.data[i + 2] = dummyIndex + radialLoops + 1
            polygons.indices.data[i + 3] = dummyIndex + radialLoops

    if mergeCenter:
        for i in range(radialLoops - 1):
            dummyIndex = (2 * innerLoops + verticalLoops - 1) * radialLoops
            dummyIndexII = dummyIndex * 4 + i * 3
            dummyIndex += i
            polygons.polyStarts.data[dummyIndex] = dummyIndexII
            polygons.polyLengths.data[dummyIndex] = 3

            polygons.indices.data[dummyIndexII + 0] = 74
            polygons.indices.data[dummyIndexII + 1] = i + 1
            polygons.indices.data[dummyIndexII + 2] = i

    #
    # if not mergeCenter:
    #     for i in range(radialLoops - 1 * mergeStartEnd):
    #         dummyIndex = (2 * (verticalLoops + innerLoops) - 1) * radialLoops + i
    #         dummyIndexII = dummyIndex * 4
    #         polygons.polyStarts.data[dummyIndex] = dummyIndexII
    #         polygons.polyLengths.data[dummyIndex] = 4
    #
    #         polygons.indices.data[dummyIndexII + 0] = dummyIndex
    #         polygons.indices.data[dummyIndexII + 1] = dummyIndex + 1
    #         polygons.indices.data[dummyIndexII + 2] = i + 1
    #         polygons.indices.data[dummyIndexII + 3] = i


    return polygons
