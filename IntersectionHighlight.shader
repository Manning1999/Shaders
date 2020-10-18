Shader "Custom/IntersectionHighlight"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,.2)
	}
		SubShader
	{
		Tags{ "Queue" = "Transparent"}
		Pass
		{
			Stencil
			{
				Ref 172
				Comp Always
				Pass Replace
				ZFail Zero
			}

			Blend Zero One
			Cull Front
			ZTest  GEqual
			
			ZWrite Off

		}// end stencil pass
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Stencil
			{
				Ref 172
				Comp Equal
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			float4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				
				//half4 col = tex2D("white", i.uv * _Time.y) * _Color
				return _Color;
			}
			ENDCG
		}//end color pass
	}
}
