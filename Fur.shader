Shader "Unlit/Fur"
{
    Properties
    {
		_Albedo("Albedo", 2D) = "white"{}
		_Color("Color", COLOR) = (0,0,0,0)
        _FurTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
			#include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag




            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
            };

			sampler2D _Albedo;
            sampler2D _FurTex;
            float4 _MainTex_ST;
			fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				fixed4 col = tex2D(_Albedo, i.uv);
                
				return col;
            }
            ENDCG
        }

		Pass
		{

CGPROGRAM
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag




			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			sampler2D _Albedo;
			sampler2D _FurTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);

				o.vertex.xyz -= v.normal.xyz * 0.5;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{

				fixed4 col = _Color;
				col.a = 0.3;

				return col;
			}
			ENDCG
		}
    }
}
