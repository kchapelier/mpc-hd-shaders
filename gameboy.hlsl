static float4 color1 = float4(8.0f / 255.f, 25.f / 255.f, 32.f / 255.f, 1.);
static float4 color2 = float4(50.f / 255.f, 106.f / 255.f, 79.f / 255.f, 1.);
static float4 color3 = float4(137.f / 255.f, 192.f / 255.f, 111.f / 255.f, 1.);
static float4 color4 = float4(223.f / 255.f, 246.f / 255.f, 208.f / 255.f, 1.);

static float PixelSize = 4.f;
static float Desaturation = 0.f;
static float Mix = 1.f;
static float DitheringReduction = 0.2f;

sampler s0 : register(s0);

float4 p0 : register(c0);
float4 p1 : register(c1);

#define width (p0[0])
#define height (p0[1])
#define counter (p0[2])
#define clock (p0[3])
#define one_over_width (p1[0])
#define one_over_height (p1[1])

float4 main(float2 tex : TEXCOORD0) : COLOR
{
	float2 vois = tex * float2(width, height);
	tex = floor(vois / PixelSize) * PixelSize / float2(width, height);
	float4 col = (
		tex2D(s0, tex) +
		tex2D(s0, tex + 0.2f / float2(width, height)) +
		tex2D(s0, tex + float2(0., 0.2f) / float2(width, height)) +
		tex2D(s0, tex + float2(0.2f, 0.) / float2(width, height))
	) * 0.25;

	float luma = pow(dot(col, float3(0.299f, 0.587f, 0.114f)) * 1.3f, 1.5f);

	luma = min(7.0, max(1.0, luma * 7.0f));
	int level = int(ceil(luma));

	float checkDither = (floor(vois.x / PixelSize) + floor(vois.y / PixelSize)) % 2.0;
	float ditherTrigger = luma % 2.0f;
	
	if (ditherTrigger < 1.0f) {
		if (ditherTrigger < DitheringReduction / 2.0f) {
			level -= 1;
		} else if (ditherTrigger > 1.0f - DitheringReduction / 2.0f) {
			level += 1;
		} else {
			level += (1 - int(checkDither) * 2);
		}
	}

	if (level <= 1) col = lerp(col, color1, Mix);
	else if (level <= 3) col = lerp(col, color2, Mix);
	else if (level <= 5) col = lerp(col, color3, Mix);
	else col = lerp(col, color4, Mix);

	col = lerp(col, float4(float(level) / 7., float(level) / 7., float(level) / 7., 1.), Desaturation);

	return col;
}
