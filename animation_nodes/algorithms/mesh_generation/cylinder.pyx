from libc.math cimport sin, cos
from libc.math cimport M_PI as PI
from ... data_structures.meshes.validate import createValidEdgesList
from ... data_structures cimport (Vector3DList, EdgeIndicesList, PolygonIndicesList, Mesh,
                                  VirtualDoubleList, VirtualLongList, VirtualBooleanList)

def getCylinderMesh(Py_ssize_t radialLoops, Py_ssize_t verticalLoops, Py_ssize_t innerLoops,
             float outerRadius, float innerRadius, float height,
             float startAngle, float endAngle,
             bint mergeStartEnd, bint mergeCenter):

    cdef PolygonIndicesList polygonsIndices = polygons(radialLoops, verticalLoops, innerLoops,
                                                mergeStartEnd, mergeCenter)

    return Mesh(vertices(radialLoops, verticalLoops, innerLoops, outerRadius, innerRadius,
                     height, startAngle, endAngle, mergeStartEnd, mergeCenter),
                     createValidEdgesList(polygons = polygonsIndices), polygonsIndices,
                     skipValidation = True)

def getCylinderMeshList(Py_ssize_t amount,
                        VirtualLongList radialLoops,
                        VirtualLongList verticalLoops,
                        VirtualLongList innerLoops,
                        VirtualDoubleList outerRadius,
                        VirtualDoubleList innerRadius,
                        VirtualDoubleList height,
                        VirtualDoubleList startAngle,
                        VirtualDoubleList endAngle,
                        VirtualBooleanList mergeStartEnd,
                        VirtualBooleanList mergeCenter):

    cdef list meshes = []
    cdef Py_ssize_t i
    cdef PolygonIndicesList polygonsIndices
    for i in range(amount):
        polygonsIndices = polygons(radialLoops.get(i), verticalLoops.get(i), innerLoops.get(i),
                                   mergeStartEnd.get(i), mergeCenter.get(i))
        meshes.append(Mesh(vertices(radialLoops.get(i), verticalLoops.get(i), innerLoops.get(i),
                                    outerRadius.get(i), innerRadius.get(i), height.get(i),
                                    startAngle.get(i), endAngle.get(i), mergeStartEnd.get(i),
                                    mergeCenter.get(i)), createValidEdgesList(polygons = polygonsIndices),
                                    polygonsIndices, skipValidation = True))

    return meshes

def vertices(Py_ssize_t radialLoops, Py_ssize_t verticalLoops, Py_ssize_t innerLoops,
             float outerRadius, float innerRadius, float height,
             float startAngle, float endAngle,
             bint mergeStartEnd, bint mergeCenter):

    radialLoops = max(radialLoops, 3)
    verticalLoops = max(verticalLoops, 1)
    innerLoops = max(innerLoops, 0)

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

    # Guard Condition For Circles
    if verticalLoops == 1:
        numVerts = radialLoops * (innerLoops + 1 + (not mergeCenter)) + mergeCenter
        vertices = Vector3DList(length = numVerts, capacity = numVerts)

        for i in range(radialLoops):
            for j in range(innerLoops + 1 + (not mergeCenter)):
                iRadius = outerRadius - innerStep * j
                dummyIndex = j * radialLoops + i
                vertices.data[dummyIndex].x = iCos * iRadius
                vertices.data[dummyIndex].y = iSin * iRadius
                vertices.data[dummyIndex].z = height

            newCos = stepCos * iCos - stepSin * iSin
            iSin = stepSin * iCos + stepCos * iSin
            iCos = newCos

        if mergeCenter:
            dummyIndex = numVerts - 1
            vertices.data[dummyIndex].x = 0
            vertices.data[dummyIndex].y = 0
            vertices.data[dummyIndex].z = height

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
                iRadius = innerRadius * (not mergeCenter) + innerStep * (j + 1)
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

    radialLoops = max(radialLoops, 3)
    verticalLoops = max(verticalLoops, 1)
    innerLoops = max(innerLoops, 0)
    
    cdef:
        PolygonIndicesList polygons
        Py_ssize_t i, polygonAmount, indicesAmount, dummyIndex, dummyIndexII, dummyIndexIII

    # Guard Condition For Circles
    if verticalLoops == 1:
        polygonAmount = (radialLoops - 1 * (not mergeStartEnd)) * (innerLoops + 1)
        if mergeCenter:
            indicesAmount = (radialLoops - 1 * (not mergeStartEnd)) * (innerLoops * 4 + 3)
        else:
            indicesAmount = (innerLoops + 1) * (radialLoops - 1 * (not mergeStartEnd)) * 4
        polygons = PolygonIndicesList(
            indicesAmount = indicesAmount,
            polygonAmount = polygonAmount)

        # Main Surface
        if mergeStartEnd:
            for i in range((radialLoops - 1) * (innerLoops + 1 * (not mergeCenter))):
                dummyIndex = i + i//(radialLoops - 1)
                dummyIndexII = dummyIndex * 4
                polygons.polyStarts.data[dummyIndex] = dummyIndexII
                polygons.polyLengths.data[dummyIndex] = 4

                polygons.indices.data[dummyIndexII + 0] = dummyIndex
                polygons.indices.data[dummyIndexII + 1] = dummyIndex + 1
                polygons.indices.data[dummyIndexII + 2] = dummyIndex + radialLoops + 1
                polygons.indices.data[dummyIndexII + 3] = dummyIndex + radialLoops
            for i in range(innerLoops + 1 * (not mergeCenter)):
                dummyIndex = i * radialLoops + radialLoops - 1
                dummyIndexII = 4 * dummyIndex
                polygons.polyStarts.data[dummyIndex] = dummyIndexII
                polygons.polyLengths.data[dummyIndex] = 4

                polygons.indices.data[dummyIndexII + 0] = dummyIndex
                polygons.indices.data[dummyIndexII + 1] = dummyIndex - radialLoops + 1
                polygons.indices.data[dummyIndexII + 2] = dummyIndex + 1
                polygons.indices.data[dummyIndexII + 3] = dummyIndex + radialLoops
        else:
            for i in range((radialLoops - 1) * (innerLoops + 1 * (not mergeCenter))):
                dummyIndex = i + i//(radialLoops - 1)
                dummyIndexII = i * 4
                polygons.polyStarts.data[i] = dummyIndexII
                polygons.polyLengths.data[i] = 4

                polygons.indices.data[dummyIndexII + 0] = dummyIndex
                polygons.indices.data[dummyIndexII + 1] = dummyIndex + 1
                polygons.indices.data[dummyIndexII + 2] = dummyIndex + radialLoops + 1
                polygons.indices.data[dummyIndexII + 3] = dummyIndex + radialLoops

        if mergeCenter:
            polygonAmount = innerLoops * (radialLoops - 1 * (not mergeStartEnd))
            indicesAmount = polygonAmount * 4
            dummyIndex = radialLoops * innerLoops
            dummyIndexII = dummyIndex + radialLoops
            for i in range(radialLoops - 1):
                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 3

                polygons.indices.data[indicesAmount + 0] = dummyIndex
                polygons.indices.data[indicesAmount + 1] = dummyIndex + 1
                polygons.indices.data[indicesAmount + 2] = dummyIndexII

                dummyIndex += 1
                polygonAmount += 1
                indicesAmount += 3

            if mergeStartEnd:
                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 3

                polygons.indices.data[indicesAmount + 0] = dummyIndexII - 1
                polygons.indices.data[indicesAmount + 1] = dummyIndexII - radialLoops
                polygons.indices.data[indicesAmount + 2] = dummyIndexII

        return polygons



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

    # Main Surface
    if mergeStartEnd:
        for i in range((verticalLoops + verticalLoops * (not mergeCenter) + 2 * innerLoops - 1) * (radialLoops - 1)):
            dummyIndex = i + i//(radialLoops - 1)
            dummyIndexII = dummyIndex * 4
            polygons.polyStarts.data[dummyIndex] = dummyIndexII
            polygons.polyLengths.data[dummyIndex] = 4

            polygons.indices.data[dummyIndexII + 0] = dummyIndex
            polygons.indices.data[dummyIndexII + 1] = dummyIndex + 1
            polygons.indices.data[dummyIndexII + 2] = dummyIndex + radialLoops + 1
            polygons.indices.data[dummyIndexII + 3] = dummyIndex + radialLoops

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
            dummyIndexII = i * 4
            polygons.polyStarts.data[i] = dummyIndexII
            polygons.polyLengths.data[i] = 4

            polygons.indices.data[dummyIndexII + 0] = dummyIndex
            polygons.indices.data[dummyIndexII + 1] = dummyIndex + 1
            polygons.indices.data[dummyIndexII + 2] = dummyIndex + radialLoops + 1
            polygons.indices.data[dummyIndexII + 3] = dummyIndex + radialLoops

    # Triangle Fan
    if mergeCenter:
        polygonAmount = (2 * innerLoops + verticalLoops - 1) * (radialLoops - 1 * (not mergeStartEnd)) + (innerLoops + 1) * (verticalLoops - 1) * 2 * (not mergeStartEnd)

        if mergeStartEnd:
            dummyIndex = polygonAmount + radialLoops - 1
            dummyIndexII = polygonAmount * 4 + (radialLoops - 1) * 3
            dummyIndexIII = radialLoops * (verticalLoops + innerLoops * 2)
            polygons.polyStarts.data[dummyIndex] = dummyIndexII
            polygons.polyLengths.data[dummyIndex] = 3

            polygons.indices.data[dummyIndexII + 0] = dummyIndexIII
            polygons.indices.data[dummyIndexII + 1] = 0
            polygons.indices.data[dummyIndexII + 2] = radialLoops - 1


            dummyIndex += radialLoops
            dummyIndexII += radialLoops * 3
            polygons.polyStarts.data[dummyIndex] = dummyIndexII
            polygons.polyLengths.data[dummyIndex] = 3

            polygons.indices.data[dummyIndexII + 0] = dummyIndexIII + 1
            polygons.indices.data[dummyIndexII + 1] = dummyIndexIII - 1
            polygons.indices.data[dummyIndexII + 2] = dummyIndexIII - radialLoops
        else:
            dummyIndexIII = radialLoops * verticalLoops + (2 * (radialLoops + verticalLoops) - 4) * innerLoops

        for i in range(radialLoops - 1):
            dummyIndex = polygonAmount + i
            dummyIndexII = polygonAmount * 4 + i * 3
            polygons.polyStarts.data[dummyIndex] = dummyIndexII
            polygons.polyLengths.data[dummyIndex] = 3

            polygons.indices.data[dummyIndexII + 0] = dummyIndexIII
            polygons.indices.data[dummyIndexII + 1] = i + 1
            polygons.indices.data[dummyIndexII + 2] = i

            dummyIndex += radialLoops - 1 * (not mergeStartEnd)
            dummyIndexII = polygonAmount * 4 + (radialLoops - 1 * (not mergeStartEnd)) * 3 + i * 3
            polygons.polyStarts.data[dummyIndex] = dummyIndexII
            polygons.polyLengths.data[dummyIndex] = 3

            dummyIndex = radialLoops * (2 * innerLoops + verticalLoops - 1) + i
            polygons.indices.data[dummyIndexII + 0] = dummyIndex
            polygons.indices.data[dummyIndexII + 1] = dummyIndex + 1
            polygons.indices.data[dummyIndexII + 2] = dummyIndexIII + 1 if mergeStartEnd else dummyIndexIII + verticalLoops - 1

    # Connecting Loop For Hollow Cylinder
    else:
        polygonAmount = (2 * (verticalLoops + innerLoops) - 1)
        dummyIndexIII = polygonAmount * radialLoops
        polygonAmount *= (radialLoops - 1 * (not mergeStartEnd))
        for i in range(radialLoops - 1):
            dummyIndex = polygonAmount + i
            dummyIndexII = dummyIndex * 4
            polygons.polyStarts.data[dummyIndex] = dummyIndexII
            polygons.polyLengths.data[dummyIndex] = 4

            dummyIndex = dummyIndexIII + i
            polygons.indices.data[dummyIndexII + 0] = dummyIndex
            polygons.indices.data[dummyIndexII + 1] = dummyIndex + 1
            polygons.indices.data[dummyIndexII + 2] = i + 1
            polygons.indices.data[dummyIndexII + 3] = i

        if mergeStartEnd:
            dummyIndex = dummyIndexIII + radialLoops - 1
            dummyIndexII = dummyIndex * 4
            polygons.polyStarts.data[dummyIndex] = dummyIndexII
            polygons.polyLengths.data[dummyIndex] = 4

            polygons.indices.data[dummyIndexII + 0] = dummyIndex
            polygons.indices.data[dummyIndexII + 1] = polygonAmount
            polygons.indices.data[dummyIndexII + 2] = 0
            polygons.indices.data[dummyIndexII + 3] = radialLoops - 1

    # Start And End Polygons
    if not mergeStartEnd:
        if mergeCenter:
            polygonAmount = (verticalLoops + 2 * innerLoops - 1) * (radialLoops - 1)
            indicesAmount = polygonAmount * 4
            dummyIndex = (verticalLoops + 2 * innerLoops) * radialLoops
        else:
            polygonAmount = 2 * (verticalLoops + innerLoops)
            dummyIndex = polygonAmount * radialLoops
            polygonAmount *= (radialLoops - 1)
            indicesAmount = polygonAmount * 4

        # Grid Polygons
        if verticalLoops > 2 and innerLoops:
            for i in range((verticalLoops - 3) * (innerLoops - 1)):
                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                dummyIndexII = dummyIndex + i + i//(innerLoops - 1)
                polygons.indices.data[indicesAmount + 0] = dummyIndexII
                polygons.indices.data[indicesAmount + 1] = dummyIndexII + 1
                polygons.indices.data[indicesAmount + 2] = dummyIndexII + innerLoops + 1
                polygons.indices.data[indicesAmount + 3] = dummyIndexII + innerLoops

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                dummyIndexII += (verticalLoops - 2) * innerLoops
                polygons.indices.data[indicesAmount + 0] = dummyIndexII + innerLoops
                polygons.indices.data[indicesAmount + 1] = dummyIndexII + innerLoops + 1
                polygons.indices.data[indicesAmount + 2] = dummyIndexII + 1
                polygons.indices.data[indicesAmount + 3] = dummyIndexII

                polygonAmount += 1
                indicesAmount += 4

            dummyIndexII = dummyIndex + innerLoops * (verticalLoops - 3)
            dummyIndexIII = innerLoops * (verticalLoops - 2)

            for i in range(innerLoops - 1):
                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = i * radialLoops
                polygons.indices.data[indicesAmount + 1] = (i + 1) * radialLoops
                polygons.indices.data[indicesAmount + 2] = dummyIndex + i + 1
                polygons.indices.data[indicesAmount + 3] = dummyIndex + i

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = dummyIndexII + i
                polygons.indices.data[indicesAmount + 1] = dummyIndexII + i + 1
                polygons.indices.data[indicesAmount + 2] = (innerLoops * 2 + verticalLoops - 2 - i) * radialLoops
                polygons.indices.data[indicesAmount + 3] = (innerLoops * 2 + verticalLoops - 1 - i) * radialLoops

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = dummyIndex + dummyIndexIII + i
                polygons.indices.data[indicesAmount + 1] = dummyIndex + dummyIndexIII + i + 1
                polygons.indices.data[indicesAmount + 2] = (i + 2) * radialLoops - 1
                polygons.indices.data[indicesAmount + 3] = (i + 1) * radialLoops - 1

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = (innerLoops * 2 + verticalLoops - i) * radialLoops - 1
                polygons.indices.data[indicesAmount + 1] = (innerLoops * 2 + verticalLoops - 1 - i) * radialLoops - 1
                polygons.indices.data[indicesAmount + 2] = dummyIndexII + dummyIndexIII + i + 1
                polygons.indices.data[indicesAmount + 3] = dummyIndexII + dummyIndexIII + i

                polygonAmount += 1
                indicesAmount += 4
            for i in range(verticalLoops - 3):
                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = dummyIndex + innerLoops * (1 + i) - 1
                polygons.indices.data[indicesAmount + 1] = (innerLoops + 1 + i) * radialLoops
                polygons.indices.data[indicesAmount + 2] = (innerLoops + 2 + i) * radialLoops
                polygons.indices.data[indicesAmount + 3] = dummyIndex + innerLoops * (2 + i) - 1

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = dummyIndex + innerLoops * (2 + i) - 1 + dummyIndexIII
                polygons.indices.data[indicesAmount + 1] = (innerLoops + 3 + i) * radialLoops - 1
                polygons.indices.data[indicesAmount + 2] = (innerLoops + 2 + i) * radialLoops - 1
                polygons.indices.data[indicesAmount + 3] = dummyIndex + innerLoops * (1 + i) - 1 + dummyIndexIII

                polygonAmount += 1
                indicesAmount += 4

            if mergeCenter:
                dummyIndexII = dummyIndex + dummyIndexIII * 2
                for i in range(verticalLoops - 3):
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = dummyIndexII + 1 + i
                    polygons.indices.data[indicesAmount + 1] = dummyIndex + innerLoops * i
                    polygons.indices.data[indicesAmount + 2] = dummyIndex + innerLoops * (i + 1)
                    polygons.indices.data[indicesAmount + 3] = dummyIndexII + 2 + i

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = dummyIndexII + 2 + i
                    polygons.indices.data[indicesAmount + 1] = dummyIndex + dummyIndexIII + innerLoops * (i + 1)
                    polygons.indices.data[indicesAmount + 2] = dummyIndex + dummyIndexIII + innerLoops * i
                    polygons.indices.data[indicesAmount + 3] = dummyIndexII + 1 + i

                    polygonAmount += 1
                    indicesAmount += 4

                # Merged Singular Polygons
                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = dummyIndexII
                polygons.indices.data[indicesAmount + 1] = 0
                polygons.indices.data[indicesAmount + 2] = dummyIndex
                polygons.indices.data[indicesAmount + 3] = dummyIndexII + 1

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = dummyIndexII + 1
                polygons.indices.data[indicesAmount + 1] = dummyIndex + dummyIndexIII
                polygons.indices.data[indicesAmount + 2] = radialLoops - 1
                polygons.indices.data[indicesAmount + 3] = dummyIndexII

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = dummyIndexII + verticalLoops - 2
                polygons.indices.data[indicesAmount + 1] = dummyIndex + innerLoops * (verticalLoops - 3)
                polygons.indices.data[indicesAmount + 2] = (innerLoops * 2 + verticalLoops - 1) * radialLoops
                polygons.indices.data[indicesAmount + 3] = dummyIndexII + verticalLoops - 1

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = dummyIndexII + verticalLoops - 1
                polygons.indices.data[indicesAmount + 1] = (innerLoops * 2 + verticalLoops) * radialLoops - 1
                polygons.indices.data[indicesAmount + 2] = dummyIndex + innerLoops * (verticalLoops - 3) + dummyIndexIII
                polygons.indices.data[indicesAmount + 3] = dummyIndexII + verticalLoops - 2

                polygonAmount += 1
                indicesAmount += 4
            else:
                for i in range(verticalLoops - 3):
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = (2 * (verticalLoops + innerLoops) - 2 - i) * radialLoops
                    polygons.indices.data[indicesAmount + 1] = dummyIndex + innerLoops * i
                    polygons.indices.data[indicesAmount + 2] = dummyIndex + innerLoops * (i + 1)
                    polygons.indices.data[indicesAmount + 3] = (2 * (verticalLoops + innerLoops) - 3 - i) * radialLoops

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = (2 * (verticalLoops + innerLoops) - 3 - i) * radialLoops + radialLoops - 1
                    polygons.indices.data[indicesAmount + 1] = dummyIndex + dummyIndexIII + innerLoops * (i + 1)
                    polygons.indices.data[indicesAmount + 2] = dummyIndex + dummyIndexIII + innerLoops * i
                    polygons.indices.data[indicesAmount + 3] = (2 * (verticalLoops + innerLoops) - 1 - i) * radialLoops - 1

                    polygonAmount += 1
                    indicesAmount += 4

                # Non-merged Singular Polygons
                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = (innerLoops * 2 + verticalLoops + 1) * radialLoops
                polygons.indices.data[indicesAmount + 1] = dummyIndex + innerLoops * (verticalLoops - 3)
                polygons.indices.data[indicesAmount + 2] = (innerLoops * 2 + verticalLoops - 1) * radialLoops
                polygons.indices.data[indicesAmount + 3] = (innerLoops * 2 + verticalLoops) * radialLoops

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = (innerLoops * 2 + verticalLoops + 1) * radialLoops - 1
                polygons.indices.data[indicesAmount + 1] = (innerLoops * 2 + verticalLoops) * radialLoops - 1
                polygons.indices.data[indicesAmount + 2] = dummyIndex + innerLoops * (verticalLoops - 3) + dummyIndexIII
                polygons.indices.data[indicesAmount + 3] = (innerLoops * 2 + verticalLoops + 2) * radialLoops - 1

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = (2 * (innerLoops + verticalLoops) - 1) * radialLoops
                polygons.indices.data[indicesAmount + 1] = 0
                polygons.indices.data[indicesAmount + 2] = dummyIndex
                polygons.indices.data[indicesAmount + 3] = (2 * (innerLoops + verticalLoops) - 2) * radialLoops

                polygonAmount += 1
                indicesAmount += 4

                polygons.polyStarts.data[polygonAmount] = indicesAmount
                polygons.polyLengths.data[polygonAmount] = 4

                polygons.indices.data[indicesAmount + 0] = (2 * (innerLoops + verticalLoops) - 1) * radialLoops - 1
                polygons.indices.data[indicesAmount + 1] = dummyIndex + dummyIndexIII
                polygons.indices.data[indicesAmount + 2] = radialLoops - 1
                polygons.indices.data[indicesAmount + 3] = 2 * (innerLoops + verticalLoops) * radialLoops - 1

                polygonAmount += 1
                indicesAmount += 4

            # Singular Polygons
            polygons.polyStarts.data[polygonAmount] = indicesAmount
            polygons.polyLengths.data[polygonAmount] = 4

            polygons.indices.data[indicesAmount + 0] = dummyIndex + dummyIndexIII - 1
            polygons.indices.data[indicesAmount + 1] = (innerLoops + verticalLoops - 2) * radialLoops
            polygons.indices.data[indicesAmount + 2] = (innerLoops + verticalLoops - 1) * radialLoops
            polygons.indices.data[indicesAmount + 3] = (innerLoops + verticalLoops) * radialLoops

            polygonAmount += 1
            indicesAmount += 4

            polygons.polyStarts.data[polygonAmount] = indicesAmount
            polygons.polyLengths.data[polygonAmount] = 4

            polygons.indices.data[indicesAmount + 0] = (innerLoops - 1) * radialLoops
            polygons.indices.data[indicesAmount + 1] = innerLoops * radialLoops
            polygons.indices.data[indicesAmount + 2] = (innerLoops + 1) * radialLoops
            polygons.indices.data[indicesAmount + 3] = dummyIndex + innerLoops - 1

            polygonAmount += 1
            indicesAmount += 4

            polygons.polyStarts.data[polygonAmount] = indicesAmount
            polygons.polyLengths.data[polygonAmount] = 4

            polygons.indices.data[indicesAmount + 0] = (innerLoops + verticalLoops + 1) * radialLoops - 1
            polygons.indices.data[indicesAmount + 1] = (innerLoops + verticalLoops) * radialLoops - 1
            polygons.indices.data[indicesAmount + 2] = (innerLoops + verticalLoops - 1) * radialLoops - 1
            polygons.indices.data[indicesAmount + 3] = dummyIndex + dummyIndexIII * 2 - 1

            polygonAmount += 1
            indicesAmount += 4

            polygons.polyStarts.data[polygonAmount] = indicesAmount
            polygons.polyLengths.data[polygonAmount] = 4

            polygons.indices.data[indicesAmount + 0] = dummyIndex + dummyIndexIII + innerLoops - 1
            polygons.indices.data[indicesAmount + 1] = (innerLoops + 2) * radialLoops - 1
            polygons.indices.data[indicesAmount + 2] = (innerLoops + 1) * radialLoops - 1
            polygons.indices.data[indicesAmount + 3] = (innerLoops) * radialLoops - 1

            polygonAmount += 1
            indicesAmount += 4

            return polygons

        # Singular or Double Polygons
        if verticalLoops == 2:
            if not innerLoops:
                if mergeCenter:
                    dummyIndexII = radialLoops * 2
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = 0
                    polygons.indices.data[indicesAmount + 1] = radialLoops
                    polygons.indices.data[indicesAmount + 2] = dummyIndexII + 1
                    polygons.indices.data[indicesAmount + 3] = dummyIndexII

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = dummyIndexII
                    polygons.indices.data[indicesAmount + 1] = dummyIndexII + 1
                    polygons.indices.data[indicesAmount + 2] = dummyIndexII - 1
                    polygons.indices.data[indicesAmount + 3] = radialLoops - 1
                else:
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = 0
                    polygons.indices.data[indicesAmount + 1] = radialLoops
                    polygons.indices.data[indicesAmount + 2] = radialLoops * 2 + 1 * mergeCenter
                    polygons.indices.data[indicesAmount + 3] = radialLoops * 3

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = radialLoops * 4 - 1
                    polygons.indices.data[indicesAmount + 1] = radialLoops * 3 - 1
                    polygons.indices.data[indicesAmount + 2] = radialLoops * 2 - 1
                    polygons.indices.data[indicesAmount + 3] = radialLoops - 1

                return polygons
            else:
                for i in range(innerLoops):
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = i * radialLoops
                    polygons.indices.data[indicesAmount + 1] = (i + 1) * radialLoops
                    polygons.indices.data[indicesAmount + 2] = (innerLoops * 2 - i) * radialLoops
                    polygons.indices.data[indicesAmount + 3] = (innerLoops * 2 + 1 - i) * radialLoops

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = (innerLoops * 2 + 2 - i) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 1] = (innerLoops * 2 - i + 1) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 2] = (i + 2) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 3] = (i + 1) * radialLoops - 1

                    polygonAmount += 1
                    indicesAmount += 4

                if mergeCenter:
                    dummyIndexII = (innerLoops + 1) * radialLoops * 2
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = dummyIndexII
                    polygons.indices.data[indicesAmount + 1] = 0
                    polygons.indices.data[indicesAmount + 2] = (innerLoops * 2 + 1) * radialLoops
                    polygons.indices.data[indicesAmount + 3] = dummyIndexII + 1

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = dummyIndexII + 1
                    polygons.indices.data[indicesAmount + 1] = (innerLoops * 2 + 2) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 2] = radialLoops - 1
                    polygons.indices.data[indicesAmount + 3] = dummyIndexII

                    return polygons
                else:
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = (innerLoops * 2 + 3) * radialLoops
                    polygons.indices.data[indicesAmount + 1] = 0
                    polygons.indices.data[indicesAmount + 2] = (innerLoops * 2 + 1) * radialLoops
                    polygons.indices.data[indicesAmount + 3] = (innerLoops * 2 + 2) * radialLoops

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = (innerLoops * 2 + 3) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 1] = (innerLoops * 2 + 2) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 2] = radialLoops - 1
                    polygons.indices.data[indicesAmount + 3] = (innerLoops * 2 + 4) * radialLoops - 1

                    return polygons
        else:
            if mergeCenter:
                for i in range(verticalLoops - 1):
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = i * radialLoops
                    polygons.indices.data[indicesAmount + 1] = (i + 1) * radialLoops
                    polygons.indices.data[indicesAmount + 2] = radialLoops * verticalLoops + 1 + i
                    polygons.indices.data[indicesAmount + 3] = radialLoops * verticalLoops + i

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = radialLoops * verticalLoops + i
                    polygons.indices.data[indicesAmount + 1] = radialLoops * verticalLoops + 1 + i
                    polygons.indices.data[indicesAmount + 2] = (i + 2) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 3] = (i + 1) * radialLoops - 1

                    polygonAmount += 1
                    indicesAmount += 4

                return polygons
            else:
                for i in range(verticalLoops - 1):
                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = i * radialLoops
                    polygons.indices.data[indicesAmount + 1] = (i + 1) * radialLoops
                    polygons.indices.data[indicesAmount + 2] = (verticalLoops * 2 - 2 - i) * radialLoops
                    polygons.indices.data[indicesAmount + 3] = (verticalLoops * 2 - 1 - i) * radialLoops

                    polygonAmount += 1
                    indicesAmount += 4

                    polygons.polyStarts.data[polygonAmount] = indicesAmount
                    polygons.polyLengths.data[polygonAmount] = 4

                    polygons.indices.data[indicesAmount + 0] = (verticalLoops * 2 - i) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 1] = (verticalLoops * 2 - 1 - i) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 2] = (i + 2) * radialLoops - 1
                    polygons.indices.data[indicesAmount + 3] = (i + 1) * radialLoops - 1

                    polygonAmount += 1
                    indicesAmount += 4

                return polygons
    return polygons
