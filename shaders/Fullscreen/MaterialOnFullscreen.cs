using UnityEngine;

public class MaterialOnFullscreen : MonoBehaviour
{
    public Material material;

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (material == null) return;
        Graphics.Blit(src, dst, material);
    }
}
