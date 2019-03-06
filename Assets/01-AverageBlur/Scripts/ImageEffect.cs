using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AverageBlur : MonoBehaviour
{
    public Material mat;
    
    [Range(1,5)]
    public float radius = 1;


    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(mat != null)
        {
            mat.SetFloat("_Radius", radius);
            Graphics.Blit(src, dest, mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
