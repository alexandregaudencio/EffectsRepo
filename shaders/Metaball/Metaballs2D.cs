using UnityEngine;

[RequireComponent(typeof(CircleCollider2D)), ExecuteAlways]
public class Metaballs2D : MonoBehaviour
{
    private new CircleCollider2D collider;
    private void Awake()
    {
        collider = GetComponent<CircleCollider2D>();
    }
    private void Start()
    {
        if (MetaballSystem2D<Metaballs2D>.Get().Contains(this)) return;
        MetaballSystem2D<Metaballs2D>.Add(this);

    }

    public float GetRadius()
    {
        return collider.radius * transform.localScale.magnitude;
    }


    private void OnDestroy()
    {
        if (!MetaballSystem2D<Metaballs2D>.Get().Contains(this)) return;
        MetaballSystem2D<Metaballs2D>.Remove(this);
    }
}
