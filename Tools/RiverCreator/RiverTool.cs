using UnityEngine;
using System.Collections.Generic;


namespace RiverCreator
{


    [ExecuteAlways]
    [RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
    public class RiverTool : MonoBehaviour
    {
        public List<Vector3> points = new List<Vector3>();

        public float width = 5f;
        public Material riverMaterial;

        Mesh mesh;

        void OnValidate()
        {
            GenerateMesh();
        }

        public void GenerateMesh()
        {
            if (points.Count < 2)
                return;

            if (mesh == null)
            {
                mesh = new Mesh();
                GetComponent<MeshFilter>().sharedMesh = mesh;
            }

            GetComponent<MeshRenderer>().sharedMaterial = riverMaterial;

            List<Vector3> vertices = new List<Vector3>();
            List<int> triangles = new List<int>();

            for (int i = 0; i < points.Count; i++)
            {
                Vector3 forward = Vector3.zero;

                if (i < points.Count - 1)
                    forward = (points[i + 1] - points[i]).normalized;
                else
                    forward = (points[i] - points[i - 1]).normalized;

                Vector3 right = Vector3.Cross(Vector3.up, forward) * width * 0.5f;

                vertices.Add(points[i] - right);
                vertices.Add(points[i] + right);

                if (i < points.Count - 1)
                {
                    int index = i * 2;

                    triangles.Add(index);
                    triangles.Add(index + 2);
                    triangles.Add(index + 1);

                    triangles.Add(index + 1);
                    triangles.Add(index + 2);
                    triangles.Add(index + 3);
                }
            }

            mesh.Clear();
            mesh.SetVertices(vertices);
            mesh.SetTriangles(triangles, 0);
            mesh.RecalculateNormals();
        }
        
        
    }
}