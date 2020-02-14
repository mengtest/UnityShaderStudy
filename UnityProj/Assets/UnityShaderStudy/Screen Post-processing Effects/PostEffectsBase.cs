using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    void Start()
    {
        CheckResources();
    }

    // Called when start
    protected void CheckResources()
    {
        bool isSupported = CheckSupport();
        if (!isSupported)
        {
            NotSupported();
        }
    }

    // Called in CheckResources to check support on this platform
    protected bool CheckSupport()
    {
        //现在不需要检测这两项了
        //if (!SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTexture)
        //{
        //    Debug.LogWarning("This platform does not support image effects or render textures.");
        //    return false;
        //}

        return true;
    }

    protected void NotSupported()
    {
        enabled = false;
    }

    // Called when need to create the material used by this effect
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null || !shader.isSupported)
            return null;

        if (material && material.shader == shader)
            return material;
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            return material;
        }
    }
}
