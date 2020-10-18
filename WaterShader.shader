Shader "Custom/WaterShader"
{
	Properties
	{
		_Color("Color", COLOR) = (0,0,0,0)
		[NoScaleOffset]_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_NoiseMap("Noise Map", 2D) = "white" {}
		_WaveAmplitude("Wave Amplitude", float) = 1
		_WaveSpeed("Wave Speed", float) = 1
			_FoamAmount("FoamAmount", float) = 0.0001

		_Strength("Distort Strength", float) = 1.0

		_FoamColor("Foam Color", COLOR) = (0,0,0,0)

	}

	SubShader
		{
			Tags{"Queue" = "Transparent+1" "RenderType" = "Transparent"}

			//This makes it possible to adjust transparency
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Off



			// Grab the screen behind the object into _BackgroundTexture
			GrabPass
			{
				"_BackgroundTexture"
			}

			Pass
			{


				CGPROGRAM


				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"


				sampler2D _MainTex;
				sampler2D _NoiseMap;
				float _WaveAmplitude;
				float _WaveSpeed;
				float4 _Color;
				float4 _FoamColor;
				float _Strength;
				sampler2D _BackgroundTexture;
				sampler2D _CameraDepthNormalsTexture;
				float _FoamAmount;



				// vertex shader inputs
				struct appdata
				{
					float4 vertex : POSITION; // vertex position
					float2 uv : TEXCOORD0; // texture coordinate
				};


				struct v2f {
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 worldPosition : TEXCOORD1;
					float4 grabPos : TEXCOORD2;
					float3 depth : DEPTH;
					float2 screenuv : TEXCOORD3;

				};





				v2f vert(appdata_base IN) {

					v2f OUT;

					OUT.worldPosition = IN.vertex;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);




					float2 offset = float2(
						tex2Dlod(_NoiseMap, float4(OUT.worldPosition.x, 0, 0, 0)).g,
						tex2Dlod(_NoiseMap, float4(0, OUT.worldPosition.z, 0, 0)).g
					);




					//OUT.vertex.y += sin(_WaveSpeed * _Time.y * offset) * _WaveAmplitude;
					OUT.vertex.y += sin(offset[0] * _WaveSpeed * _Time.y) * _WaveAmplitude;
					OUT.vertex.x += sin(offset[1] * (_WaveSpeed / 2) * _Time.y) * _WaveAmplitude;
					//OUT.vertex.y += sin(OUT.worldPosition.x * _WaveSpeed * _Time.z) * _WaveAmplitude;

					OUT.uv = IN.texcoord;

					OUT.grabPos = ComputeGrabScreenPos(OUT.vertex);
					float noise = tex2Dlod(_NoiseMap, float4(IN.texcoord.xyz, 0)).rgb;
					float3 filt = tex2Dlod(_NoiseMap, float4(IN.texcoord.xyz, 0)).rgb;

					OUT.grabPos.x += cos(noise * _Time.x * _WaveSpeed) * filt * _Strength;
					OUT.grabPos.y += sin(noise * _Time.x * _WaveSpeed) * filt * _Strength;

					OUT.screenuv = ((OUT.vertex.xy / OUT.vertex.w) + 1) / 2;
					OUT.screenuv.y = 1 - OUT.screenuv.y;
					OUT.depth = -mul(UNITY_MATRIX_MV, IN.vertex).z *_ProjectionParams.w;

					return OUT;
				}

				//Fragment shaders run once every pixel
				half4 frag(v2f IN) : SV_Target
				{
					//fixed4 col = tex2D(_MainTex, IN.grabPos);
					//tex2D(_Color, IN.uv);
					//col.a = _Color.a;

						float screenDepth = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture, IN.screenuv).zw);
						float diff = screenDepth - IN.depth;
						float intersect = 0;

						if (diff > 0) intersect = 1 - smoothstep(0, _ProjectionParams.w * _FoamAmount, diff);

						fixed4 intersectColor = fixed4(lerp(fixed3(0,0,0), _FoamColor, pow(intersect, 4)), _FoamColor.a);

						fixed4 col = tex2Dproj(_BackgroundTexture, IN.grabPos) + (intersectColor * _FoamColor.a) + (_Color * _Color.a);

					//return tex2Dproj(_BackgroundTexture, IN.grabPos) + _Color;
					return col;
				}




				ENDCG
			}

		}
		//FallBack "Diffuse"
}
