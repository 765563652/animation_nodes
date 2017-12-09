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
        for i in range(verticalLoops):
            for j in range(innerLoops):
                iRadius = outerRadius - innerStep * (j + 1)
                if mergeCenter:
                    dummyIndex = radialLoops * (verticalLoops + innerLoops * 2) + i * innerLoops + j
                else:
                    dummyIndex = 2 * radialLoops * (verticalLoops + innerLoops) + i * innerLoops + j
                vertices.data[dummyIndex].x = iCos * iRadius
                vertices.data[dummyIndex].y = iSin * iRadius
                vertices.data[dummyIndex].z = (i + 1) * heightStep

    for i in range(radialLoops):
        outerRadiusCos = iCos * outerRadius
        outerRadiusSin = iSin * outerRadius
        if not mergeCenter:
            innerRadiusCos = iCos * innerRadius
            innerRadiusSin = iSin * innerRadius

        for j in range(verticalLoops):
            dummyIndex = j * radialLoops + i
            vertices.data[dummyIndex].x = outerRadiusCos
            vertices.data[dummyIndex].y = outerRadiusSin
            vertices.data[dummyIndex].z = j * heightStep

            if not mergeCenter:
                dummyIndex = radialLoops * (j + verticalLoops) + i
                vertices.data[dummyIndex].x = innerRadiusCos
                vertices.data[dummyIndex].y = innerRadiusSin
                vertices.data[dummyIndex].z = j * heightStep

        for j in range(innerLoops):
            iRadius = outerRadius - innerStep * (j + 1)
            if mergeCenter:
                dummyIndex = radialLoops * verticalLoops + j * radialLoops + i
            else:
                dummyIndex = 2 * radialLoops * verticalLoops + j * radialLoops + i
            vertices.data[dummyIndex].x = iCos * iRadius
            vertices.data[dummyIndex].y = iSin * iRadius
            vertices.data[dummyIndex].z = 0
            dummyIndex += radialLoops * innerLoops
            vertices.data[dummyIndex].x = iCos * iRadius
            vertices.data[dummyIndex].y = iSin * iRadius
            vertices.data[dummyIndex].z = height

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
        for i in range(verticalLoops):
            for j in range(innerLoops):
                iRadius = outerRadius - innerStep * (j + 1)
                if mergeCenter:
                    dummyIndex = radialLoops * (verticalLoops + innerLoops * 2) + innerLoops * (verticalLoops - 2) + i * innerLoops + j
                else:
                    dummyIndex = 2 * radialLoops * (verticalLoops + innerLoops) + innerLoops * (verticalLoops - 2) + i * innerLoops + j
                vertices.data[dummyIndex].x = eCos * iRadius
                vertices.data[dummyIndex].y = eSin * iRadius
                vertices.data[dummyIndex].z = (i + 1) * heightStep
        if mergeCenter:
            for i in range(verticalLoops):
                dummyIndex = radialLoops * (verticalLoops + innerLoops * 2) + innerLoops * (verticalLoops - 2) * 2 + i
                vertices.data[dummyIndex].x = 0
                vertices.data[dummyIndex].y = 0
                vertices.data[dummyIndex].z = i * heightStep

    return vertices


# Edges
############################################

planeEdges = EdgeIndicesList.fromValues([(0, 2), (1, 3), (0, 1), (2, 3)])

def edges(Py_ssize_t resolution):
    if resolution < 2:
        raise Exception("resolution has to be >= 2")

    cdef:
        EdgeIndicesList edges
        Py_ssize_t i, edgeAmount

    if resolution == 2:
        edges = planeEdges.copy()
    else:
        edges = EdgeIndicesList(length = 3 * resolution)

        for i in range(resolution - 1):
            edges.data[3 * i + 0].v1 = i
            edges.data[3 * i + 0].v2 = i + resolution

            edges.data[3 * i + 1].v1 = i
            edges.data[3 * i + 1].v2 = i + 1

            edges.data[3 * i + 2].v1 = i + resolution
            edges.data[3 * i + 2].v2 = i + resolution + 1

        edges.data[edges.length - 3].v1 = resolution - 1
        edges.data[edges.length - 3].v2 = 2 * resolution - 1

        edges.data[edges.length - 2].v1 = resolution - 1
        edges.data[edges.length - 2].v2 = 0

        edges.data[edges.length - 1].v1 = 2 * resolution - 1
        edges.data[edges.length - 1].v2 = resolution

    return edges


# Polygons
############################################

planePolygons = PolygonIndicesList.fromValues([(0, 1, 3, 2)])

def polygons(Py_ssize_t resolution, bint caps = True):
    if resolution < 2:
        raise Exception("resolution has to be >= 2")

    cdef:
        PolygonIndicesList polygons
        Py_ssize_t i, polygonAmount, indicesAmount

    if resolution == 2:
        polygons = planePolygons.copy()
    else:
        if caps:
            indicesAmount = 6 * resolution
            polygonAmount = resolution + 2
        else:
            indicesAmount = 4 * resolution
            polygonAmount = resolution

        polygons = PolygonIndicesList(
            indicesAmount = indicesAmount,
            polygonAmount = polygonAmount)

        for i in range(resolution - 1):
            polygons.polyStarts.data[i] = 4 * i
            polygons.polyLengths.data[i] = 4

            polygons.indices.data[4 * i + 0] = i
            polygons.indices.data[4 * i + 1] = i + 1
            polygons.indices.data[4 * i + 2] = resolution + i + 1
            polygons.indices.data[4 * i + 3] = resolution + i

        polygons.polyStarts.data[resolution - 1] = 4 * (resolution - 1)
        polygons.polyLengths.data[resolution - 1] = 4
        polygons.indices.data[4 * (resolution - 1) + 0] = resolution - 1
        polygons.indices.data[4 * (resolution - 1) + 1] = 0
        polygons.indices.data[4 * (resolution - 1) + 2] = resolution
        polygons.indices.data[4 * (resolution - 1) + 3] = 2 * resolution - 1

        if caps:
            polygons.polyStarts.data[resolution] = 4 * resolution
            polygons.polyLengths.data[resolution] = resolution
            polygons.polyStarts.data[resolution + 1] = 5 * resolution
            polygons.polyLengths.data[resolution + 1] = resolution

            for i in range(resolution):
                polygons.indices.data[4 * resolution + i] = resolution - i - 1
                polygons.indices.data[5 * resolution + i] = resolution + i
    return polygons
