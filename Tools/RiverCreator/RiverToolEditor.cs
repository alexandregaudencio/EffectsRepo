namespace RiverCreator
{
    using UnityEditor;
    using UnityEngine;

    [CustomEditor(typeof(RiverTool))]
    public class RiverToolEditor : Editor
    {
public override void OnInspectorGUI()
{
    DrawDefaultInspector();

    RiverTool river = (RiverTool)target;

    if(GUILayout.Button("Add Point"))
    {
        Undo.RecordObject(river,"Add Point");

        Vector3 pos = Vector3.zero;

        if(river.points.Count > 0)
            pos = river.points[river.points.Count-1] + Vector3.forward * 5;

        river.points.Add(pos);

        river.GenerateMesh();
    }
}
        void OnSceneGUI()
        {
            RiverTool river = (RiverTool)target;

            for(int i=0;i<river.points.Count;i++)
            {
                EditorGUI.BeginChangeCheck();

                Vector3 worldPos = river.transform.TransformPoint(river.points[i]);

                Vector3 newPos = Handles.PositionHandle(worldPos, Quaternion.identity);

                if(EditorGUI.EndChangeCheck())
                {
                    Undo.RecordObject(river,"Move River Point");

                    river.points[i] = river.transform.InverseTransformPoint(newPos);

                    river.GenerateMesh();
                }
            }
        }
    }
}