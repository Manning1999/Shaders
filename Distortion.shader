// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Distortion"
{
    Properties
    {
        _Color ("Color", COLOR) = (0,0,0,0)
		_Strength("Distort Strength", float) = 1.0
		_StrengthFilter("Strength Filter", 2D) = "white" {}
		_Noise("Noise Texture", 2D) = "white" {}
		_Speed("Speed", float) = 1.0

	}
		SubShader
		{
			// Draw ourselves after all opaque geometry
			Tags { "Queue" = "Transparent" }

			ZTest Always


			// Grab the screen behind the object into _BackgroundTexture
			GrabPass
			{
				"_BackgroundTexture"
			}

			// Render the object with the texture generated above, and invert the colors
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"




				// Properties
				float4 _Color;
			sampler2D _Noise;
			sampler2D _StrengthFilter;
			sampler2D _BackgroundTexture;
			float     _Strength;
			float     _Speed;


			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 texCoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 grabPos : TEXCOORD0;
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD1;
			};

			v2f vert(vertexInput v) {

				v2f o;

				// use UnityObjectToClipPos from UnityCG.cginc to calculate 
				// the clip-space of the vertex
				o.pos = UnityObjectToClipPos(v.vertex);

				// use ComputeGrabScreenPos function from UnityCG.cginc
				// to get the correct texture coordinate
				o.grabPos = ComputeGrabScreenPos(o.pos);
				o.uv = v.texCoord;

				float noise = tex2Dlod(_Noise, float4(v.texCoord, 0)).rgb;
				float3 filt = tex2Dlod(_StrengthFilter, float4(v.texCoord, 0)).rgb;

				o.grabPos.x += cos(noise * _Time.x * _Speed) * filt * _Strength;
				o.grabPos.y += sin(noise * _Time.x * _Speed) * filt * _Strength;

				return o;
			}



			half4 frag(v2f i) : SV_Target
			{
				//half4 bgcolor = tex2Dproj(_BackgroundTexture, i.grabPos);
				//fixed4 col = tex2D(bgcolor, i.uv);

				//return 1 - bgcolor;

				return tex2Dproj(_BackgroundTexture, i.grabPos) + _Color;
			}
			ENDCG
		}

	}

}
