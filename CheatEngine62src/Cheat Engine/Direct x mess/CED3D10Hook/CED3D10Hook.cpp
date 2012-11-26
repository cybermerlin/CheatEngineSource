// CED3D10Hook.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

using namespace std;
map<ID3D10Device *, DXMessD3D10Handler *> D3D10devices;

PD3DHookShared shared=NULL;
int insidehook=0;

DXMessD3D10Handler *lastdevice;


//definitions
struct SpriteVertex{
    XMFLOAT3 Pos;
    XMFLOAT2 Tex;
};

struct ConstantBuffer
{	
	XMFLOAT2 translation;	
	XMFLOAT2 scaling;
	FLOAT transparency;		
	FLOAT garbage; //16 byte alignment crap
	FLOAT garbage2;
	FLOAT garbage3;
};


void DXMessD3D10Handler::SetupFontVertexBuffer(int count)
{
	if (currentMaxCharacterCount<count)
	{
		HRESULT hr;
		D3D10_BUFFER_DESC bd2d;


		count+=4; //let's add a bit of overhead
		if (pFontVB)
		{
			pFontVB->Release();
			pFontVB=NULL;
		}

		ZeroMemory( &bd2d, sizeof(bd2d) );
		bd2d.Usage = D3D10_USAGE_DYNAMIC;
		bd2d.ByteWidth = sizeof( SpriteVertex ) * 6 * count; //size of a vertex*verticel per char*charcount
		bd2d.BindFlags = D3D10_BIND_VERTEX_BUFFER;
		bd2d.CPUAccessFlags = D3D10_CPU_ACCESS_WRITE;
	                           
		hr = dev->CreateBuffer( &bd2d, NULL, &pFontVB );

		if (SUCCEEDED(hr))
		{
			currentMaxCharacterCount=count;
		}
	}
}

void DXMessD3D10Handler::DrawString(D3D10_VIEWPORT vp, PTextureData10 pFontTexture, char *s, int strlen)
{
	if (pFontTexture)
	{
		if (strlen==0)
			return;

		SetupFontVertexBuffer(strlen);

		if (currentMaxCharacterCount<strlen) return; //error

		//The following code is mainly ripped from DXUTgui.cpp and modified to support dynamic sized characters
		
		
		float fGlyphSizeY = (pFontTexture->DefinedFontMap->charheight*2) / vp.Height;


		float fRectLeft = 0;
		float fRectTop = 1.0f;

		fRectLeft = fRectLeft * 2.0f - 1.0f;
		fRectTop = fRectTop * 2.0f - 1.0f;

		float fOriginalLeft = fRectLeft;  //0*2.0f-1.0f=-1.0f
		float fTexTop = 0.0f;
		float fTexBottom = 1.0f;


		//fill the FontVB with the sizes and texture coordinates

		SpriteVertex *vertices;

		

		

		if (SUCCEEDED(pFontVB->Map(D3D10_MAP_WRITE_DISCARD, 0, (void **)&vertices)))
		{
			int i,j;			

			for (j=0, i=0; i<strlen; i++)
			{
				if( s[i] == '\n' )
				{
					fRectLeft = fOriginalLeft;
					fRectTop -= fGlyphSizeY;

					continue;
				}
				else
				if ((s[i] < 32) || (s[i] > 127))
					continue;//invalid char


				float fGlyphSizeX = (pFontTexture->DefinedFontMap->charinfo[s[i]-32].charwidth*2) / vp.Width;

				float fCharTexSizeX = pFontTexture->DefinedFontMap->charinfo[s[i]-32].charwidth / (pFontTexture->DefinedFontMap->fullwidth);  //0.010526315f;

				float fRectRight = fRectLeft + fGlyphSizeX;
				float fRectBottom = fRectTop - fGlyphSizeY;
				float fTexLeft = pFontTexture->DefinedFontMap->charinfo[s[i]-32].offset / pFontTexture->DefinedFontMap->fullwidth;				
				float fTexRight = fTexLeft + fCharTexSizeX;
				


				vertices[j*6+0].Pos=XMFLOAT3( fRectLeft, fRectTop, 1.0f );
				vertices[j*6+0].Tex=XMFLOAT2( fTexLeft, fTexTop );
				vertices[j*6+1].Pos=XMFLOAT3( fRectRight, fRectTop, 1.0f );
				vertices[j*6+1].Tex=XMFLOAT2( fTexRight, fTexTop );
				vertices[j*6+2].Pos=XMFLOAT3( fRectLeft, fRectBottom, 1.0f );
				vertices[j*6+2].Tex=XMFLOAT2( fTexLeft, fTexBottom );

				vertices[j*6+3].Pos=XMFLOAT3( fRectRight, fRectTop, 1.0f);
				vertices[j*6+3].Tex=XMFLOAT2( fTexRight, fTexTop  );
				vertices[j*6+4].Pos=XMFLOAT3( fRectRight, fRectBottom,  1.0f);
				vertices[j*6+4].Tex=XMFLOAT2( fTexRight, fTexBottom  );
				vertices[j*6+5].Pos=XMFLOAT3( fRectLeft, fRectBottom,  1.0f);
				vertices[j*6+5].Tex=XMFLOAT2( fTexLeft, fTexBottom );
			
				j++;
				fRectLeft += fGlyphSizeX;
			}




			pFontVB->Unmap();
		}

		

		//then render
		UINT stride = sizeof( SpriteVertex );
		UINT offset = 0;

		dev->IASetVertexBuffers( 0, 1, &pFontVB, &stride, &offset );
		dev->PSSetShaderResources( 0, 1, &pFontTexture->pTexture );

		dev->Draw(6*strlen,0);
	}
}

BOOL DXMessD3D10Handler::UpdateTextures()
{
	//call this each time the resolution changes (when the buffer changes)
	HRESULT hr;
	ID3D10Resource *test;
	ID3D10Texture2D *texturex;
	DXGI_SWAP_CHAIN_DESC desc;
	int i;

	int newTextureCount;


	WaitForSingleObject((HANDLE)(shared->TextureLock), INFINITE);
	
	if (shared->textureCount)
	{
		ZeroMemory(&desc, sizeof(desc));
		hr=swapchain->GetDesc(&desc);
		if (FAILED(hr))
			return hr;

		newTextureCount=shared->textureCount;

		if (shared->textureCount > TextureCount)
		{				
			//update the textures if needed
			if (textures==NULL) //initial alloc
				textures=(TextureData10 *)malloc(sizeof(TextureData10)* shared->textureCount);			
			else //realloc
				textures=(TextureData10 *)realloc(textures, sizeof(TextureData10)* shared->textureCount);		

			//initialize the new entries to NULL
			for (i=TextureCount; i<shared->textureCount; i++)
			{
				textures[i].pTexture=NULL;	
				textures[i].DefinedFontMap=NULL;
			}
		
		}
		

		for (i=0; i<newTextureCount; i++)
		{			
			if (tea[i].AddressOfTexture)
			{	
				if ((tea[i].hasBeenUpdated) || (textures[i].pTexture==NULL))
				{
					if (textures[i].pTexture)
					{
						//already has a texture, so an update. Free the old one	first
						textures[i].pTexture->Release();
						textures[i].pTexture=NULL; //should always happen
					}

					if (textures[i].DefinedFontMap)
					{
						//already has a fontmap. Free the old one
						free(textures[i].DefinedFontMap);
						textures[i].DefinedFontMap=NULL;
					}

					hr=D3DX10CreateTextureFromMemory(dev, (void *)(tea[i].AddressOfTexture), tea[i].size, NULL, NULL, &test, NULL);
					if( FAILED( hr ) )
					{
						OutputDebugStringA("Failure creating a texture");
						return hr;
					}

					
					hr=test->QueryInterface(__uuidof(ID3D10Texture2D), (void **)(&texturex));	


					hr=dev->CreateShaderResourceView(test, NULL, &textures[i].pTexture);
					if( FAILED( hr ) )
						return hr;
			

					test->Release();
					texturex->Release();

					if (tea[i].AddressOfFontmap)
					{
						int j;
						float currentOffset=0;

						textures[i].DefinedFontMap=(PFONTMAP)malloc(sizeof(FONTMAP));
						//now parse the fontmap provided by ce and fill in the gaps						
						
						
						WORD *cefontmap=(WORD *)(tea[i].AddressOfFontmap);											
						textures[i].DefinedFontMap->charheight=(float)cefontmap[0];

						for (j=0; j<96; j++)
						{
							textures[i].DefinedFontMap->charinfo[j].offset=currentOffset;
							textures[i].DefinedFontMap->charinfo[j].charwidth=(float)cefontmap[j+1];

							currentOffset+=cefontmap[j+1];
						}						

						textures[i].DefinedFontMap->fullwidth=currentOffset;
					}

					tea[i].hasBeenUpdated=0;
				}
			}
			else
			{
				//It's NULL (cleanup)
				if (textures[i].pTexture)
				{
					textures[i].pTexture->Release();
					textures[i].pTexture=NULL;					
				}				

				if (textures[i].DefinedFontMap)
				{
					free(textures[i].DefinedFontMap);
					textures[i].DefinedFontMap=NULL;
				}
			}
		}

		TextureCount=newTextureCount;
		

		
	}

	if (shared->texturelistHasUpdate)
		InterlockedExchange((volatile LONG *)&shared->texturelistHasUpdate,0);		

	SetEvent((HANDLE)(shared->TextureLock));

	return TRUE;	

}

DXMessD3D10Handler::~DXMessD3D10Handler()
{
	
	
	if (textures)
	{
		int i;
		for (i=0; i<TextureCount; i++)
		{
			if (textures[i].pTexture)
				textures[i].pTexture->Release();
		}
		free(textures);	
	}

	if (pFontVB)
		pFontVB->Release();

	if (pSpriteVB)
		pSpriteVB->Release();

	if (pPixelShaderNormal)
		pPixelShaderNormal->Release();

	if (pVertexShader)
		pVertexShader->Release();

	if (pVertexLayout)
		pVertexLayout->Release();

	if (pSamplerLinear)
		pSamplerLinear->Release();

	if (pSpriteRasterizer)
		pSpriteRasterizer->Release();

	if (pTransparency)
		pTransparency->Release();

	if (pDepthStencil)
		pDepthStencil->Release();

	if (pRenderTargetView)
		pRenderTargetView->Release();

	if (pDepthStencilView)
		pDepthStencilView->Release();

	if (pConstantBuffer)
		pConstantBuffer->Release();

	if (pWireframeRasterizer)
		pWireframeRasterizer->Release();


	if (pDisabledDepthStencilState)
		pDisabledDepthStencilState->Release();

	if (dev)
	  dev->Release();

	if (swapchain)
	  swapchain->Release();

	
}

DXMessD3D10Handler::DXMessD3D10Handler(ID3D10Device *dev, IDXGISwapChain *sc, PD3DHookShared shared)
{
	HRESULT hr;
	int i;


	pPixelShaderNormal=NULL;
	pVertexShader=NULL;
	pVertexLayout=NULL;

	pSamplerLinear=NULL;
	pSpriteRasterizer=NULL;
	pTransparency=NULL;
	pDepthStencil=NULL;
	pRenderTargetView=NULL;
	pDepthStencilView=NULL;
	pConstantBuffer=NULL;

	pWireframeRasterizer=NULL;
	pDisabledDepthStencilState=NULL;

	pSpriteVB=NULL;
	pFontVB=NULL;
		

	TextureCount=0;
	textures=NULL;

	tea=NULL;



	Valid=FALSE;

	this->shared=shared;
	this->dev=dev;
	this->dev->AddRef();
	this->swapchain=sc;	
	this->swapchain->AddRef();


	//create the shaders
    ID3DBlob* pBlob = NULL;
	ID3DBlob* pErrorBlob = NULL;
	char shaderfile[MAX_PATH];
	sprintf_s(shaderfile,MAX_PATH, "%s%s", shared->CheatEngineDir,"overlay.fx");

	//normal pixel shader
	pBlob = NULL;
	pErrorBlob = NULL;
	hr=D3DX10CompileFromFileA( shaderfile, NULL, NULL, "PSNormal", "ps_4_0", D3DCOMPILE_ENABLE_STRICTNESS, 0, NULL, &pBlob, &pErrorBlob, NULL );

	if (pErrorBlob) 
	{
		OutputDebugStringA((LPCSTR)pErrorBlob->GetBufferPointer());
		pErrorBlob->Release();
	}

	if( FAILED( hr ) )
	{
		OutputDebugStringA("pixelshader compilation failed\n");
		return;
	}

    hr = dev->CreatePixelShader( pBlob->GetBufferPointer(), pBlob->GetBufferSize(), &pPixelShaderNormal );
	pBlob->Release();
	if( FAILED( hr ) )
	{
		OutputDebugStringA("CreatePixelShader failed\n");
		return;
	}

	//vertex shader
	pBlob = NULL;
	pErrorBlob = NULL;

	hr=D3DX10CompileFromFileA( shaderfile, NULL, NULL, "VS", "vs_4_0", D3DCOMPILE_ENABLE_STRICTNESS, 0, NULL, &pBlob, &pErrorBlob, NULL );

	if (pErrorBlob) 
	{
		OutputDebugStringA((LPCSTR)pErrorBlob->GetBufferPointer());
		pErrorBlob->Release();
	}

	if( FAILED( hr ) )
	{
		OutputDebugStringA("vertexshader compilation failed\n");
		return;
	}

    hr = dev->CreateVertexShader( pBlob->GetBufferPointer(), pBlob->GetBufferSize(), &pVertexShader );
	
	if( FAILED( hr ) )
	{
		pBlob->Release();
		OutputDebugStringA("CreatePixelShader failed\n");
		return;
	}

	//and create a input layout
    D3D10_INPUT_ELEMENT_DESC layout[] =
    {
        { "POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D10_INPUT_PER_VERTEX_DATA, 0 },
        { "TEXCOORD", 0, DXGI_FORMAT_R32G32_FLOAT, 0, 12, D3D10_INPUT_PER_VERTEX_DATA, 0 },
    };
    UINT numElements = ARRAYSIZE( layout );

    // Create the input layout
    hr = dev->CreateInputLayout( layout, numElements, pBlob->GetBufferPointer(),
                                          pBlob->GetBufferSize(), &pVertexLayout );

	pBlob->Release();




	//create rectangular vertex buffer for sprites
	SpriteVertex spriteVertices[] ={ 
		{XMFLOAT3( 1.0f,  1.0f, 1.0f), XMFLOAT2( 1.0f, 0.0f ) },
		{XMFLOAT3( 1.0f, -1.0f, 1.0f), XMFLOAT2( 1.0f, 1.0f )},		
		{XMFLOAT3(-1.0f, -1.0f, 1.0f), XMFLOAT2( 0.0f, 1.0f )},
		
		{XMFLOAT3(-1.0f, -1.0f, 1.0f), XMFLOAT2( 0.0f, 1.0f )},
		{XMFLOAT3(-1.0f,  1.0f, 1.0f), XMFLOAT2( 0.0f, 0.0f )},
		{XMFLOAT3( 1.0f,  1.0f, 1.0f), XMFLOAT2( 1.0f, 0.0f )},		
	};

	D3D10_BUFFER_DESC bd2d;
	ZeroMemory( &bd2d, sizeof(bd2d) );
	bd2d.Usage = D3D10_USAGE_DYNAMIC;
	bd2d.ByteWidth = sizeof( SpriteVertex ) * 6;
	bd2d.BindFlags = D3D10_BIND_VERTEX_BUFFER;
	bd2d.CPUAccessFlags = D3D10_CPU_ACCESS_WRITE;

	D3D10_SUBRESOURCE_DATA InitData2d;
	ZeroMemory( &InitData2d, sizeof(InitData2d) );
	InitData2d.pSysMem = spriteVertices;
	hr = dev->CreateBuffer( &bd2d, &InitData2d, &pSpriteVB );
	if( FAILED( hr ) )
	{
		OutputDebugStringA("Vertexbuffer creation failed\n");
		return;
	}



    D3D10_SAMPLER_DESC sampDesc;
    ZeroMemory( &sampDesc, sizeof(sampDesc) );
    sampDesc.Filter = D3D10_FILTER_MIN_MAG_MIP_LINEAR;
    sampDesc.AddressU = D3D10_TEXTURE_ADDRESS_WRAP;
    sampDesc.AddressV = D3D10_TEXTURE_ADDRESS_WRAP;
    sampDesc.AddressW = D3D10_TEXTURE_ADDRESS_WRAP;
    sampDesc.ComparisonFunc = D3D10_COMPARISON_NEVER;
    sampDesc.MinLOD = 0;
    sampDesc.MaxLOD = D3D10_FLOAT32_MAX;
    hr = dev->CreateSamplerState( &sampDesc, &pSamplerLinear );
    if( FAILED( hr ) )
        return;


	//rasterizer
	D3D10_RASTERIZER_DESC rasterizerdesc;
	ZeroMemory(&rasterizerdesc, sizeof(rasterizerdesc));
	
	rasterizerdesc.FillMode = D3D10_FILL_SOLID;
	rasterizerdesc.CullMode = D3D10_CULL_NONE;
	rasterizerdesc.FrontCounterClockwise = false;
	rasterizerdesc.DepthBias = 0;
	rasterizerdesc.DepthBiasClamp = 0.0f;
	rasterizerdesc.DepthClipEnable = false;
	rasterizerdesc.AntialiasedLineEnable = false;
	
	
	rasterizerdesc.MultisampleEnable = false;
	rasterizerdesc.ScissorEnable = false;
	rasterizerdesc.SlopeScaledDepthBias = 0.0f;


	hr=dev->CreateRasterizerState(&rasterizerdesc, &pSpriteRasterizer);
	if( FAILED( hr ) )
        return;

	rasterizerdesc.FillMode = D3D10_FILL_WIREFRAME;
	hr=dev->CreateRasterizerState(&rasterizerdesc, &pWireframeRasterizer);
	if( FAILED( hr ) )
        pWireframeRasterizer=NULL; //no biggie


	D3D10_DEPTH_STENCIL_DESC dsDesc;
	ZeroMemory(&dsDesc, sizeof(dsDesc)); //everything 0, including DepthEnable
	hr= dev->CreateDepthStencilState(&dsDesc, &pDisabledDepthStencilState);
	if( FAILED( hr ) )
		pDisabledDepthStencilState=NULL;


	D3D10_BLEND_DESC blend;	
	ZeroMemory( &blend, sizeof(blend) );

	
	
	blend.BlendEnable[0]		 = true;

	blend.SrcBlend				 = D3D10_BLEND_SRC_ALPHA               ;	
	blend.DestBlend				 = D3D10_BLEND_INV_SRC_ALPHA;
	blend.BlendOp				 = D3D10_BLEND_OP_ADD;
	blend.SrcBlendAlpha			 = D3D10_BLEND_SRC_ALPHA;
	blend.DestBlendAlpha		 = D3D10_BLEND_INV_SRC_ALPHA;
	blend.BlendOpAlpha			 = D3D10_BLEND_OP_ADD;
	blend.RenderTargetWriteMask[0]	 = D3D10_COLOR_WRITE_ENABLE_ALL;



	blend.AlphaToCoverageEnable=false;
	

	for (i=0; i<8; i++)
		blend.RenderTargetWriteMask[i]=D3D10_COLOR_WRITE_ENABLE_ALL;
	
	


	pTransparency=NULL;
	hr=dev->CreateBlendState(&blend, &pTransparency);
	if( FAILED( hr ) )
        return;


	//create a rendertarget
    ID3D10Texture2D* pBackBuffer = NULL;
	hr = sc->GetBuffer( 0, __uuidof( ID3D10Texture2D ), ( LPVOID* )&pBackBuffer );
    if( FAILED( hr ) )
        return;

    hr = dev->CreateRenderTargetView( pBackBuffer, NULL, &pRenderTargetView );
    pBackBuffer->Release();

    if( FAILED( hr ) )
        return;


	DXGI_SWAP_CHAIN_DESC scdesc;
	ZeroMemory(&scdesc,sizeof(scdesc));
	sc->GetDesc(&scdesc);

	
	// Create depth stencil texture
    D3D10_TEXTURE2D_DESC descDepth;
	ZeroMemory( &descDepth, sizeof(descDepth) );
    descDepth.Width = scdesc.BufferDesc.Width;
    descDepth.Height = scdesc.BufferDesc.Height;
    descDepth.MipLevels = 1;
    descDepth.ArraySize = 1;
    descDepth.Format = DXGI_FORMAT_D24_UNORM_S8_UINT;
    descDepth.SampleDesc.Count = 1;
    descDepth.SampleDesc.Quality = 0;
    descDepth.Usage = D3D10_USAGE_DEFAULT;
    descDepth.BindFlags = D3D10_BIND_DEPTH_STENCIL;
    descDepth.CPUAccessFlags = 0;
    descDepth.MiscFlags = 0;
    hr = dev->CreateTexture2D( &descDepth, NULL, &pDepthStencil );
    if( FAILED( hr ) )
        return;

    // Create the depth stencil view
    D3D10_DEPTH_STENCIL_VIEW_DESC descDSV;
	ZeroMemory( &descDSV, sizeof(descDSV) );
    descDSV.Format = descDepth.Format;
    descDSV.ViewDimension = D3D10_DSV_DIMENSION_TEXTURE2D;
    descDSV.Texture2D.MipSlice = 0;
    hr = dev->CreateDepthStencilView( pDepthStencil, &descDSV, &pDepthStencilView );
    if( FAILED( hr ) )
        return;

	//now load the textures
	tea=(PTextureEntry)((uintptr_t)shared+shared->texturelist);
	UpdateTextures();

	// Create the constant buffer
	D3D10_BUFFER_DESC bd;
	ZeroMemory(&bd, sizeof(bd));
 
	bd.Usage = D3D10_USAGE_DEFAULT;
	bd.ByteWidth = sizeof(ConstantBuffer);
	bd.BindFlags = D3D10_BIND_CONSTANT_BUFFER;
	bd.CPUAccessFlags = 0;
    hr = dev->CreateBuffer( &bd, NULL, &pConstantBuffer );
    if( FAILED( hr ) )
        return;

	//create a vertexbuffer to hold the characters
	currentMaxCharacterCount=0;
	SetupFontVertexBuffer(32); //init to 32 chars

	Valid=TRUE;
}


void DXMessD3D10Handler::RenderOverlay()
{
	int i;
	if (Valid)
	{
		//render the overlay
		POINT clientMousepos;
		BOOL hasLock=FALSE;

		clientMousepos.x=-1;
		clientMousepos.y=-1;

		//check if the overlay has an update
		//if so, first update the texture		

		DXGI_SWAP_CHAIN_DESC desc;
		swapchain->GetDesc(&desc);
		shared->lastHwnd=(DWORD)desc.OutputWindow;

		if (shared->texturelistHasUpdate)
			UpdateTextures();

		
		UINT stride = sizeof( SpriteVertex );
		UINT offset = 0;
		float blendFactor[] = {0.0f, 0.0f, 0.0f, 0.0f};

		ID3D10VertexShader *oldvs=NULL;
		ID3D10PixelShader *oldps=NULL;
		ID3D10GeometryShader *oldgs=NULL;

		ID3D10SamplerState *oldPSSampler=NULL;
		ID3D10ShaderResourceView *oldPSShaderResource=NULL;
		ID3D10BlendState *oldBlendState=NULL;
		float oldblendFactor[4];
		UINT oldblendsamplemask;

		ID3D10DepthStencilState *oldDepthStencilState=NULL;
		UINT oldstencilref;

		D3D10_PRIMITIVE_TOPOLOGY oldPrimitiveTopology;

		ID3D10InputLayout *oldInputLayout=NULL;
		ID3D10Buffer *oldIndexBuffer=NULL;
		DXGI_FORMAT oldIndexBufferFormat;
		UINT oldIndexBufferOffset;

		ID3D10Buffer *oldVertexBuffer=NULL;
		UINT oldVertexBufferStrides;
		UINT oldVertexBufferOffset;

		ID3D10RasterizerState *oldRastersizerState=NULL;
		ID3D10RenderTargetView *oldRenderTarget;
		ID3D10DepthStencilView *oldDepthStencilView=NULL;

		ID3D10Buffer *oldConstantBuffersVS=NULL;
		ID3D10Buffer *oldConstantBuffersPS=NULL;

		D3D10_VIEWPORT vp;
		UINT oldviewports=0;
		D3D10_VIEWPORT viewports[D3D10_VIEWPORT_AND_SCISSORRECT_OBJECT_COUNT_PER_PIPELINE];

		//save state
		
		dev->VSGetShader( &oldvs);
		

		dev->VSGetConstantBuffers(0,1, &oldConstantBuffersVS);
		

		dev->GSGetShader(&oldgs);

		dev->PSGetShader( &oldps);
		dev->PSGetSamplers(0,1, &oldPSSampler);
		dev->PSGetShaderResources(0,1, &oldPSShaderResource);
		dev->PSGetConstantBuffers(0,1, &oldConstantBuffersPS);

		
		

		dev->OMGetRenderTargets(1, &oldRenderTarget, &oldDepthStencilView);
		dev->OMGetBlendState( &oldBlendState, oldblendFactor, &oldblendsamplemask);
		dev->OMGetDepthStencilState( &oldDepthStencilState, &oldstencilref);
		
	

		
		dev->IAGetPrimitiveTopology(&oldPrimitiveTopology);
		dev->IAGetInputLayout(&oldInputLayout);
		dev->IAGetIndexBuffer( &oldIndexBuffer, &oldIndexBufferFormat, &oldIndexBufferOffset);
		dev->IAGetVertexBuffers(0,1,&oldVertexBuffer, &oldVertexBufferStrides, &oldVertexBufferOffset);

		

		dev->RSGetState(&oldRastersizerState);

		
		
		dev->RSGetViewports(&oldviewports, NULL);
		dev->RSGetViewports(&oldviewports, viewports);

		

		//change state
		dev->GSSetShader(NULL); //not used
	    dev->VSSetShader(pVertexShader);
		dev->PSSetShader(pPixelShaderNormal);
		dev->PSSetSamplers( 0, 1, &pSamplerLinear );



		

		
		vp.Width = desc.BufferDesc.Width;
		vp.Height = desc.BufferDesc.Height;
		vp.MinDepth = 0.0f;
		vp.MaxDepth = 1.0f;
		vp.TopLeftX = 0;
		vp.TopLeftY = 0;
		dev->RSSetViewports( 1, &vp );
		

		dev->OMSetRenderTargets(1, &pRenderTargetView, NULL); //pDepthStencilView);		
		dev->ClearDepthStencilView( pDepthStencilView, D3D10_CLEAR_DEPTH, 1.0f, 0 );

		dev->OMSetBlendState(pTransparency, blendFactor, 0xffffffff);
		dev->OMSetDepthStencilState(pDisabledDepthStencilState, 0);;

		

		dev->IASetPrimitiveTopology( D3D10_PRIMITIVE_TOPOLOGY_TRIANGLELIST );
		dev->IASetInputLayout( pVertexLayout );
	
//		dev->IASetIndexBuffer( pSpriteIB, DXGI_FORMAT_R16_UINT, 0 );
		dev->IASetIndexBuffer( NULL, DXGI_FORMAT_R16_UINT, 0 );
		

		dev->RSSetState(pSpriteRasterizer);

		
		if (shared->UseCommandlistLock)
			hasLock=WaitForSingleObject((HANDLE)shared->CommandlistLock, INFINITE)==WAIT_OBJECT_0;

		i=0;
		while (shared->RenderCommands[i].Command)
		{
			switch (shared->RenderCommands[i].Command)
			{
				case rcDrawSprite:
				{
					if (shared->RenderCommands[i].sprite.textureid<TextureCount)
					{
					
						XMFLOAT3 position;				

						dev->IASetVertexBuffers( 0, 1, &pSpriteVB, &stride, &offset );
						dev->PSSetShader( pPixelShaderNormal);

						dev->PSSetSamplers( 0, 1, &pSamplerLinear );						
						dev->PSSetShaderResources( 0, 1, &textures[shared->RenderCommands[i].sprite.textureid].pTexture );

						if (shared->RenderCommands[i].x==-1) //center	
						{
							position.x=((float)vp.Width / 2.0f) - ((float)shared->RenderCommands[i].sprite.width / 2.0f);						
						}
						else
						if (shared->RenderCommands[i].x==-2) //mouse
						{
							if (clientMousepos.x==-1)
							{
								//get the mouse position
								GetCursorPos(&clientMousepos);
								ScreenToClient((HWND)shared->lastHwnd, &clientMousepos);	
							}

							position.x=(float)clientMousepos.x-((float)shared->RenderCommands[i].sprite.width / 2.0f); 
						}
						else
							position.x=(float)shared->RenderCommands[i].x;


						if (shared->RenderCommands[i].y==-1) //center
						{
							position.y=((float)vp.Height / 2.0f) - ((float)shared->RenderCommands[i].sprite.height / 2.0f);
						}
						else
						if (shared->RenderCommands[i].y==-2) //mouse
						{
							if (clientMousepos.y==-1)
							{
								//get the mouse position
								GetCursorPos(&clientMousepos);
								ScreenToClient((HWND)shared->lastHwnd, &clientMousepos);	
							}
							position.y=(float)clientMousepos.y-((float)shared->RenderCommands[i].sprite.height / 2.0f);	

						}
						else
							position.y=(float)shared->RenderCommands[i].y;


						//truncate the position to an exact pixel
						position.x=(float)(int)position.x;
						position.y=(float)(int)position.y;

			
						ConstantBuffer cb;					
						cb.transparency=shared->RenderCommands[i].alphablend;

						if (shared->RenderCommands[i].sprite.width==-1)
							cb.scaling.x=(float)vp.Width/(float)vp.Width; //1.0
						else						
							cb.scaling.x=(float)shared->RenderCommands[i].sprite.width/(float)vp.Width;

						cb.scaling.y=(float)shared->RenderCommands[i].sprite.height/(float)vp.Height;
	
						cb.translation.x=-1.0f+((float)((float)position.x * 2)/(float)vp.Width);
						cb.translation.y=-1.0f+((float)((float)position.y * 2)/(float)vp.Height);

						dev->UpdateSubresource( pConstantBuffer, 0, NULL, &cb, 0, 0 );

						dev->VSSetConstantBuffers(0,1, &pConstantBuffer);
						dev->PSSetConstantBuffers(0,1, &pConstantBuffer);


						
						
						dev->Draw(6,0);
					
					}
				
					break;
				}

				case rcDrawFont:
				{
					int tid=shared->RenderCommands[i].font.fontid;							

					if ((tid<TextureCount) && (textures[tid].pTexture))
					{
							
						XMFLOAT3 position;	
						PTextureData10 td;
						char *s;

						if (!hasLock)
							hasLock=WaitForSingleObject((HANDLE)shared->CommandlistLock, INFINITE)==WAIT_OBJECT_0; //fonts demand a lock  (stringpointer)

						position.x=(float)shared->RenderCommands[i].x;
						position.y=(float)shared->RenderCommands[i].y;		

						td=&textures[tid];
						s=(char *)shared->RenderCommands[i].font.addressoftext;

						if (position.x==-1) 
						{
							//horizontal center
							//calculate the width
							float width=0;
							int slen=strlen(s);
							int j;

							for (j=0; j<slen; j++)
							{
								width+=td->DefinedFontMap->charinfo[32-j].charwidth;
							}
							position.x=((float)vp.Width / 2.0f) - ((float)width / 2.0f);
							
						}

						if (position.y==-1)
						{						
							//vertical center						
							position.y=((float)vp.Height / 2.0f) - ((float)td->DefinedFontMap->charheight / 2.0f);
						}

						//truncate the position to an exact pixel
						position.x=(float)(int)position.x;
						position.y=(float)(int)position.y;

					
						dev->PSSetShader( pPixelShaderNormal);
						dev->PSSetSamplers( 0, 1, &pSamplerLinear );						
						

						ConstantBuffer cb;					
						cb.transparency=shared->RenderCommands[i].alphablend;						
						cb.scaling.x=1.0f;
						cb.scaling.y=1.0f;//if you wish a bigger font, use a bigger font, don't scale (ugly)
						
						cb.translation.x=-1.0f;
						cb.translation.y=-1.0f;

						cb.translation.x=-1.0f+((float)((float)position.x * 2)/(float)vp.Width);
						cb.translation.y=-1.0f+((float)((float)position.y * 2)/(float)vp.Height);


						dev->UpdateSubresource( pConstantBuffer, 0, NULL, &cb, 0, 0 );

						dev->VSSetConstantBuffers(0,1, &pConstantBuffer);
						dev->PSSetConstantBuffers(0,1, &pConstantBuffer);

						DrawString(vp, &textures[tid], s,strlen(s));
					}

					
					break;
				}
			}

			i++;				
		}

		if (hasLock) //release the lock if it was obtained
			SetEvent((HANDLE)shared->CommandlistLock);


		//restore
		dev->GSSetShader(oldgs);
		if (oldgs)
			oldgs->Release();

		dev->VSSetShader(oldvs);
		if (oldvs)
			oldvs->Release();

		dev->PSSetShader(oldps);
		if (oldps)
			oldps->Release();

		dev->PSSetSamplers(0, 1, &oldPSSampler);
		if (oldPSSampler)
			oldPSSampler->Release();
			
		dev->PSSetShaderResources(0,1, &oldPSShaderResource);
		if (oldPSShaderResource)
			oldPSShaderResource->Release();

		dev->VSSetConstantBuffers(0,1, &oldConstantBuffersVS);
		if (oldConstantBuffersVS)
			oldConstantBuffersVS->Release();


		dev->PSSetConstantBuffers(0,1, &oldConstantBuffersPS);
		if (oldConstantBuffersPS)
			oldConstantBuffersPS->Release();

		dev->OMSetRenderTargets(1, &oldRenderTarget, oldDepthStencilView);
		if (oldRenderTarget)
			oldRenderTarget->Release();

		if (oldDepthStencilView)
			oldDepthStencilView->Release();

		dev->OMSetBlendState(oldBlendState, oldblendFactor, oldblendsamplemask);
		if (oldBlendState)
			oldBlendState->Release();

		dev->OMSetDepthStencilState(oldDepthStencilState, oldstencilref);
		if (oldDepthStencilState)
			oldDepthStencilState->Release();

		
		dev->IASetPrimitiveTopology(oldPrimitiveTopology);
		dev->IASetInputLayout(oldInputLayout);
		if (oldInputLayout)
			oldInputLayout->Release();

		dev->IASetIndexBuffer(oldIndexBuffer, oldIndexBufferFormat, oldIndexBufferOffset);
		if (oldIndexBuffer)
			oldIndexBuffer->Release();

		dev->IASetVertexBuffers(0,1,&oldVertexBuffer, &oldVertexBufferStrides, &oldVertexBufferOffset);
		if (oldVertexBuffer)
			oldVertexBuffer->Release();

		dev->RSSetState(oldRastersizerState);
		if (oldRastersizerState)
			oldRastersizerState->Release();

		dev->RSSetViewports(oldviewports, viewports);
	}

}

void __stdcall D3D10Hook_SwapChain_ResizeBuffers_imp(IDXGISwapChain *swapchain, ID3D10Device *device, PD3DHookShared s)
{
	//release all buffers
	DXMessD3D10Handler *currentDevice=D3D10devices[device];
	if (currentDevice)
	{
		D3D10devices[device]=NULL;

		device->ClearState();
		delete(currentDevice);
	}

	

}

void __stdcall D3D10Hook_SwapChain_Present_imp(IDXGISwapChain *swapchain, ID3D10Device *device, PD3DHookShared s)
{
	//look up the controller class for this device
	DXMessD3D10Handler *currentDevice=D3D10devices[device];

		

	
	if (currentDevice==NULL)
	{
		currentDevice=new DXMessD3D10Handler(device, swapchain, s);//create a new devicehandler
		D3D10devices[device]=currentDevice;
		shared=s;
	}
	insidehook=1; //tell the draw hooks not to mess with the following draw operations

	lastdevice=currentDevice;

	currentDevice->RenderOverlay();	
	insidehook=0;

}



HRESULT __stdcall D3D10Hook_DrawIndexed_imp(D3D10_DRAWINDEXED_ORIGINAL originalfunction, ID3D10Device *device, UINT IndexCount, UINT StartIndexLocation, INT BaseVertexLocation)	
{	
	if ((shared) && ((shared->wireframe) || (shared->disabledzbuffer) ) && (insidehook==0) )
	{
		//setup for wireframe and/or zbuffer
		HRESULT hr;
		DXMessD3D10Handler *currentDevice=D3D10devices[device];

		if (currentDevice==NULL) //this can happen in some situations when there is a layer inbetween
			currentDevice=lastdevice;			
	

		if (currentDevice)
		{
			ID3D10DepthStencilState *oldDepthStencilState;
			ID3D10RasterizerState *oldRasterizerState;

			currentDevice->dev->OMGetDepthStencilState(&oldDepthStencilState,0);
			currentDevice->dev->RSGetState(&oldRasterizerState);

			if (shared->wireframe)
				currentDevice->dev->RSSetState(currentDevice->pWireframeRasterizer);

			if (shared->disabledzbuffer)
				currentDevice->dev->OMSetDepthStencilState(currentDevice->pDisabledDepthStencilState, 0);;


			hr=originalfunction(device, IndexCount, StartIndexLocation, BaseVertexLocation);
			
			currentDevice->dev->RSSetState(oldRasterizerState);
			currentDevice->dev->OMSetDepthStencilState(oldDepthStencilState, 0);

			return hr;
		}		
	}
	return originalfunction(device, IndexCount, StartIndexLocation, BaseVertexLocation);
}


HRESULT __stdcall D3D10Hook_Draw_imp(D3D10_DRAW_ORIGINAL originalfunction, ID3D10Device *device, UINT VertexCount, UINT StartVertexLocation)
{	
	if ((shared) && ((shared->wireframe) || (shared->disabledzbuffer) ) && (insidehook==0) )
	{
		//setup for wireframe and/or zbuffer
		HRESULT hr;
		DXMessD3D10Handler *currentDevice=D3D10devices[device];

		if (currentDevice==NULL) //this can happen in some situations when there is a layer inbetween
			currentDevice=lastdevice;			


		if (currentDevice)
		{
			ID3D10DepthStencilState *oldDepthStencilState;
			ID3D10RasterizerState *oldRasterizerState;

			currentDevice->dev->OMGetDepthStencilState(&oldDepthStencilState,0);
			currentDevice->dev->RSGetState(&oldRasterizerState);

			if (shared->wireframe)
				currentDevice->dev->RSSetState(currentDevice->pWireframeRasterizer);

			if (shared->disabledzbuffer)
				currentDevice->dev->OMSetDepthStencilState(currentDevice->pDisabledDepthStencilState, 0);;


			hr=originalfunction(device, VertexCount, StartVertexLocation);
			
			currentDevice->dev->RSSetState(oldRasterizerState);
			currentDevice->dev->OMSetDepthStencilState(oldDepthStencilState, 0);

			return hr;
		}		
	}
	return originalfunction(device, VertexCount, StartVertexLocation);
}

HRESULT __stdcall D3D10Hook_DrawIndexedInstanced_imp(D3D10_DRAWINDEXEDINSTANCED_ORIGINAL originalfunction, ID3D10Device *device, UINT IndexCountPerInstance, UINT InstanceCount, UINT StartIndexLocation, INT BaseVertexLocation, UINT StartInstanceLocation)
{	
	if ((shared) && ((shared->wireframe) || (shared->disabledzbuffer) ) && (insidehook==0) )
	{
		//setup for wireframe and/or zbuffer
		HRESULT hr;
		DXMessD3D10Handler *currentDevice=D3D10devices[device];

		if (currentDevice==NULL) //this can happen in some situations when there is a layer inbetween
			currentDevice=lastdevice;	

		if (currentDevice)
		{
			ID3D10DepthStencilState *oldDepthStencilState;
			ID3D10RasterizerState *oldRasterizerState;

			currentDevice->dev->OMGetDepthStencilState(&oldDepthStencilState,0);
			currentDevice->dev->RSGetState(&oldRasterizerState);

			if (shared->wireframe)
				currentDevice->dev->RSSetState(currentDevice->pWireframeRasterizer);

			if (shared->disabledzbuffer)
				currentDevice->dev->OMSetDepthStencilState(currentDevice->pDisabledDepthStencilState, 0);;


			hr=originalfunction(device, IndexCountPerInstance, InstanceCount, StartIndexLocation, BaseVertexLocation, StartInstanceLocation);
			
			currentDevice->dev->RSSetState(oldRasterizerState);
			currentDevice->dev->OMSetDepthStencilState(oldDepthStencilState, 0);

			return hr;
		}		
	}
	return originalfunction(device, IndexCountPerInstance, InstanceCount, StartIndexLocation, BaseVertexLocation, StartInstanceLocation);
}

HRESULT __stdcall D3D10Hook_DrawInstanced_imp(D3D10_DRAWINSTANCED_ORIGINAL originalfunction, ID3D10Device *device, UINT VertexCountPerInstance, UINT InstanceCount, UINT StartVertexLocation, UINT StartInstanceLocation)
{	
	if ((shared) && ((shared->wireframe) || (shared->disabledzbuffer) ) && (insidehook==0) )
	{
		//setup for wireframe and/or zbuffer
		HRESULT hr;
		DXMessD3D10Handler *currentDevice=D3D10devices[device];

		if (currentDevice==NULL) //this can happen in some situations when there is a layer inbetween
			currentDevice=lastdevice;	

		if (currentDevice)
		{
			ID3D10DepthStencilState *oldDepthStencilState;
			ID3D10RasterizerState *oldRasterizerState;

			currentDevice->dev->OMGetDepthStencilState(&oldDepthStencilState,0);
			currentDevice->dev->RSGetState(&oldRasterizerState);

			if (shared->wireframe)
				currentDevice->dev->RSSetState(currentDevice->pWireframeRasterizer);

			if (shared->disabledzbuffer)
				currentDevice->dev->OMSetDepthStencilState(currentDevice->pDisabledDepthStencilState, 0);;


			hr=originalfunction(device, VertexCountPerInstance, InstanceCount, StartVertexLocation, StartInstanceLocation);
			
			currentDevice->dev->RSSetState(oldRasterizerState);
			currentDevice->dev->OMSetDepthStencilState(oldDepthStencilState, 0);

			return hr;
		}		
	}
	return originalfunction(device, VertexCountPerInstance, InstanceCount, StartVertexLocation, StartInstanceLocation);
}

HRESULT __stdcall D3D10Hook_DrawAuto_imp(D3D10_DRAWAUTO_ORIGINAL originalfunction, ID3D10Device *device)
{	
	if ((shared) && ((shared->wireframe) || (shared->disabledzbuffer) ) && (insidehook==0) )
	{
		//setup for wireframe and/or zbuffer
		HRESULT hr;
		DXMessD3D10Handler *currentDevice=D3D10devices[device];

		if (currentDevice==NULL) //this can happen in some situations when there is a layer inbetween
			currentDevice=lastdevice;	

		if (currentDevice)
		{
			ID3D10DepthStencilState *oldDepthStencilState;
			ID3D10RasterizerState *oldRasterizerState;

			currentDevice->dev->OMGetDepthStencilState(&oldDepthStencilState,0);
			currentDevice->dev->RSGetState(&oldRasterizerState);

			if (shared->wireframe)
				currentDevice->dev->RSSetState(currentDevice->pWireframeRasterizer);

			if (shared->disabledzbuffer)
				currentDevice->dev->OMSetDepthStencilState(currentDevice->pDisabledDepthStencilState, 0);;


			hr=originalfunction(device);
			
			currentDevice->dev->RSSetState(oldRasterizerState);
			currentDevice->dev->OMSetDepthStencilState(oldDepthStencilState, 0);

			return hr;
		}		
	}
	HRESULT br;
	br=originalfunction(device);
	return br;
}
