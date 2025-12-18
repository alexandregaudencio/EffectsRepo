using UnityEngine;

[RequireComponent(typeof(CircleCollider2D)), ExecuteAlways]
public class ColorfullMetaball2D : MonoBehaviour
{
    private new CircleCollider2D collider;
    [SerializeField, ColorUsage(true, true)] private Color color;
    //public Color color= Color.white;
    private void Awake()
    {
        collider = GetComponent<CircleCollider2D>();
    }
    private void Start()
    {
        if (MetaballSystem2D<ColorfullMetaball2D>.Get().Contains(this)) return;
        MetaballSystem2D<ColorfullMetaball2D>.Add(this);

    }

    public float GetRadius()
    {
        return collider.radius * transform.localScale.magnitude;
    }
    public Color GetColor()
    {
        return color;
    }

    private void OnDestroy()
    {
        if (!MetaballSystem2D<ColorfullMetaball2D>.Get().Contains(this)) return;
        MetaballSystem2D<ColorfullMetaball2D>.Remove(this);
    }
}
