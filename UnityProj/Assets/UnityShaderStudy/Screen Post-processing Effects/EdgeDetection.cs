using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectionShader;
    private Material edgeDetectionMaterial;
    public Material material {
        get {
            edgeDetectionMaterial = CheckShaderAndCreateMaterial(edgeDetectionShader, edgeDetectionMaterial);
            return edgeDetectionMaterial;
        }
    }

    [Range(0.0f, 1.0f)]
    public float edgesOnly = 1.0f; // 调整边缘线强度。当值为0时，边缘将会叠加在原渲染图像上；当值为1时，则只会显示边缘，不显示原渲染图像。

    public Color edgeColor = Color.black; // 描边颜色

    public Color backgroundColor = Color.white; // 背景色

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null) {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(src, dest, material);
        }
        else {
            Graphics.Blit(src, dest);
        }
    }
}
