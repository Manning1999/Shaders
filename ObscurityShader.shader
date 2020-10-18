Shader "Custom/ObscurityShader"
{

	Properties{
		_Color("Color", COLOR) = (0, 0, 0, 0)
	}

	SubShader
	{
		Tags{"Queue" = "Transparent+1" "RenderType" = "Transparent"}

		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 _Color;


			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
	}
}