float gColorPrimary = float( 1 );
float gColorSecondary = float( 0 );

texture gTexture;

sampler textureSampler = sampler_state
{
	texture = <gTexture>;
};

float4 ColorCorrection_PS ( float2 Tex : TEXCOORD0 ) : COLOR0
{
	float4 Color;
	float4 FinalColor;
	Color = tex2D( textureSampler, Tex.xy );
	
	FinalColor.r = ( Color.r * gColorPrimary ) + ( Color.g * gColorSecondary ) + ( Color.b * gColorSecondary );
	FinalColor.g = ( Color.r * gColorSecondary ) + ( Color.g * gColorPrimary ) + ( Color.b * gColorSecondary );
	FinalColor.b = ( Color.r * gColorSecondary ) + ( Color.g * gColorSecondary ) + ( Color.b * gColorPrimary );
	FinalColor.a = Color.a;
	return FinalColor;
}

technique ColorCorrection
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_2_0 ColorCorrection_PS ( );
	}
}