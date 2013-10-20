import java.awt.image.BufferedImage;
import java.io.*;
import javax.imageio.ImageIO;
import java.util.Random;



// assumes 4 channels

final public class HQImage
{
	private float[] data; 
	private int width, height;
	static float SUBPIXEL_BIAS_R = -0.50f;
	static float SUBPIXEL_BIAS_B = +0.50f;
	void setData(int i, int j, int c, float value)
	{
		data[(j * width + i) * 4 + c] = value;
	}
	
	float getData(int i, int j, int c)
	{
		return data[(j * width + i) * 4 + c];
	}

	float getDataEdgeClamp(int i, int j, int c)
	{
		if (i < 0)
			i = 0;
		if (j < 0)
			j = 0;
		if (i >= width)
			i = width - 1;
		if (j >= height)
			j = height - 1;
		return data[(j * width + i) * 4 + c];
	}
	
	
	public HQImage(String filename) throws IOException
	{
		System.out.print("Read input... ");
		BufferedImage src = ImageIO.read(new File(filename));		
		
		width = src.getWidth();
		height = src.getHeight();
		
		System.out.print("Width is " + width + "x" + height);		

		data = new float[height * width * 4];
		
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				int truc = src.getRGB(i, j);
				float R = ((truc & 0x00ff0000) >> 16) / 255.0f;
				float G = ((truc & 0x0000ff00) >>  8) / 255.0f;
				float B = ((truc & 0x000000ff)      ) / 255.0f;
				float A = ((truc & 0xff000000) >> 24) / 255.0f;				
				setData(i, j, 0, R);
				setData(i, j, 1, G);
				setData(i, j, 2, B);
				setData(i, j, 3, A);
			}
		}
		System.out.println("OK");
	}	
	
	public HQImage(int width, int height)
	{
		this.width = width;
		this.height = height;		
		data = new float[height * width * 4];
	}
	
	public void gammaTransform(float gammaExponent)
	{
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				for (int k = 0; k < 3; ++k)
				{
					setData(i, j, k, (float)Math.pow(getData(i, j, k), gammaExponent));
				}
			}
		}		
	}

	public void convertWhiteToAlpha()
	{
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				float alpha = (getData(i, j, 0) + getData(i, j, 1) + getData(i, j, 2)) / 3.0f;
			//	setData(i, j, 0, 1.0f);
		//		setData(i, j, 1, 1.0f);
	//			setData(i, j, 2, 1.0f);
				setData(i, j, 3, alpha);
 			}
		}
	}
	
	public void sRGBToLinear()
	{	
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				for (int k = 0; k < 3; ++k)
				{
					setData(i, j, k, (float)Utils.sRGBToLinearComponent(getData(i, j, k)));
				}
			}
		}			
	}
	
	public void linearTosRGB()
	{	
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				for (int k = 0; k < 3; ++k)
				{
					setData(i, j, k, (float)Utils.linearTosRGBComponent(getData(i, j, k)));
				}
			}
		}			
	}
	
	public void remap(float a, float b, float c, float d)
	{	
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				for (int k = 0; k < 3; ++k)
				{
					double x = getData(i, j, k);
					double y = c + (d - c) * (x - a)/(b - a);
					setData(i, j, k, (float)y);
				}
				// leave alpha channel untouched
			}
		}			
	}
	
	public double min()
	{	
		double res = 1.0;
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				for (int k = 0; k < 3; ++k)
				{
					double x = getData(i, j, k);
					if (x < res) res = x;					
				}
			}
		}		
		return res;	
	}
	
	public double max()
	{	
		double res = 0.0;
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				for (int k = 0; k < 3; ++k)
				{
					double x = getData(i, j, k);
					if (x > res) res = x;					
				}
			}
		}		
		return res;	
	}
	
	public void normalize()
	{	
		remap((float)min(), (float)max(), 0.0f, 1.0f);
	}
	
	public void clamp(double min, double max)
	{	
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				for (int k = 0; k < 3; ++k)
				{
					double x = getData(i, j, k);
					if (x < min) x = min;
					if (x > max) x = max;
					setData(i, j, k, (float)x);
				}
			}
		}
	}
	
	// use clamping
	private float getValue(int i, int j, int channel)
	{
		if (i < 0) i = 0;
		else if (i >= width) i = width - 1;		
		if (j < 0) j = 0;
		else if (j >= height) j = height - 1;		
		return getData(i, j, channel);
	}
	
	public double bilinearSample(double x, double y, int channel)
	{	
		int bx = (int) Math.floor(x);	
		int by = (int) Math.floor(y);
		double fx = x - bx;
		double fy = y - by;
		assert(fx >= 0);
		assert(fy >= 0);
		assert(fx < 1.0);
		assert(fy < 1.0);
		
		double f = getValue(bx    , by    , channel);
		double g = getValue(bx + 1, by    , channel);
		double j = getValue(bx    , by + 1, channel);
		double k = getValue(bx + 1, by + 1, channel);
		
		double l1 = f + (g - f) * fx;
		double l2 = j + (k - j) * fx;
		double res = l1 + (l2 - l1) * fy;
		return res;
	}
	
	public double bicubicSample(double x, double y, int channel)
	{	
		int bx = (int) Math.floor(x);	
		int by = (int) Math.floor(y);
		double fx = x - bx;
		double fy = y - by;
		assert(fx >= 0);
		assert(fy >= 0);
		assert(fx < 1.0);
		assert(fy < 1.0);
		
		double a = getValue(bx - 1, by - 1, channel);
		double b = getValue(bx    , by - 1, channel);
		double c = getValue(bx + 1, by - 1, channel);
		double d = getValue(bx + 2, by - 1, channel);
		double e = getValue(bx - 1, by    , channel);
		double f = getValue(bx    , by    , channel);
		double g = getValue(bx + 1, by    , channel);
		double h = getValue(bx + 2, by    , channel);
		double i = getValue(bx - 1, by + 1, channel);
		double j = getValue(bx    , by + 1, channel);
		double k = getValue(bx + 1, by + 1, channel);
		double l = getValue(bx + 2, by + 1, channel);
		double m = getValue(bx - 1, by + 2, channel);
		double n = getValue(bx    , by + 2, channel);
		double o = getValue(bx + 1, by + 2, channel);
		double p = getValue(bx + 2, by + 2, channel);
		
		double l1 = Utils.hermite(fx, a, b, c, d);
		double l2 = Utils.hermite(fx, e, f, g, h);
		double l3 = Utils.hermite(fx, i, j, k, l);
		double l4 = Utils.hermite(fx, m, n, o, p);
		double res = Utils.hermite(fy, l1, l2, l3, l4);		
		return res;
	}
	
	public HQImage bicubicResize(int newWidth, int newHeight, boolean LCD)
	{
		HQImage res = new HQImage(newWidth, newHeight);
		
		double sw_dw = (double)width / (double)newWidth;
		double sh_dh = (double)height / (double)newHeight;
		
		double bx = -0.5 + 0.5 * sw_dw;
		double by = -0.5 + 0.5 * sh_dh;
		
		for (int j = 0; j < newHeight; ++j)
		{
			double ty = by + sh_dh * j;
			for (int i = 0; i < newWidth; ++i)
			{
				double tx = bx + sw_dw * i;				
				
				if (LCD )
				{
					res.setData(i, j, 0, (float)bicubicSample(tx + SUBPIXEL_BIAS_R * sw_dw, ty, 0));	
					res.setData(i, j, 1, (float)bicubicSample(tx, ty, 1));	
					res.setData(i, j, 2, (float)bicubicSample(tx + SUBPIXEL_BIAS_B * sw_dw, ty, 2));	
					res.setData(i, j, 3, (float)bicubicSample(tx, ty, 3));		
				}
				else
				{
					res.setData(i, j, 0, (float)bicubicSample(tx, ty, 0));	
					res.setData(i, j, 1, (float)bicubicSample(tx, ty, 1));	
					res.setData(i, j, 2, (float)bicubicSample(tx, ty, 2));	
					res.setData(i, j, 3, (float)bicubicSample(tx, ty, 3));	
				}
			}
		}
		return res;		
	}
	
	public HQImage bilinearResize(int newWidth, int newHeight, boolean LCD)
	{
		HQImage res = new HQImage(newWidth, newHeight);
		
		double sw_dw = (double)width / (double)newWidth;
		double sh_dh = (double)height / (double)newHeight;
		
		double bx = -0.5 + 0.5 * sw_dw;
		double by = -0.5 + 0.5 * sh_dh;
		
		for (int j = 0; j < newHeight; ++j)
		{
			double ty = by + sh_dh * j;
			for (int i = 0; i < newWidth; ++i)
			{
				double tx = bx + sw_dw * i;				
				
				if (LCD )
				{
					res.setData(i, j, 0, (float)bilinearSample(tx + SUBPIXEL_BIAS_R * sw_dw, ty, 0));	
					res.setData(i, j, 1, (float)bilinearSample(tx, ty, 1));	
					res.setData(i, j, 2, (float)bilinearSample(tx + SUBPIXEL_BIAS_B * sw_dw, ty, 2));	
					res.setData(i, j, 3, (float)bilinearSample(tx, ty, 3));		
				}
				else
				{
					res.setData(i, j, 0, (float)bilinearSample(tx, ty, 0));	
					res.setData(i, j, 1, (float)bilinearSample(tx, ty, 1));	
					res.setData(i, j, 2, (float)bilinearSample(tx, ty, 2));	
					res.setData(i, j, 3, (float)bilinearSample(tx, ty, 3));	
				}
			}
		}	
		return res;		
	}
	
	public double lanczosSample(double x, double y, int channel, int taps)
	{
		double result = 0.0;
		
		int bx = (int)Math.round(Math.floor(x));
		int by = (int)Math.round(Math.floor(y));
		double fx = x - bx;
		double fy = y - by;
		
		double totalWeight = 0;
		
		for (int j = -taps; j <= taps+1 ; ++j)
		{
			for (int i = -taps; i <= taps +1; ++i)
			{
				double value = getValue(bx + i, by + j, channel);
				double window = Utils.lanzcosImpulse(i - fx, taps) * Utils.lanzcosImpulse(j - fy, taps);
				
	//			System.out.println("window = " + window);
				totalWeight += window;
				result += window * value;
			}
		}
	//	System.out.println("  weight = " + totalWeight);
		
		return result / totalWeight;
	}	
	
	public HQImage lanczosResize(int newWidth, int newHeight, int taps, boolean LCD)
	{
		System.out.print("Resize from " + width + "x" + height + " to " + newWidth + "x" + newHeight + "...");
		
		HQImage res = new HQImage(newWidth, newHeight);
		
		double sw_dw = (double)width / (double)newWidth;
		double sh_dh = (double)height / (double)newHeight;
		
		double bx = -0.5 + 0.5 * sw_dw;
		double by = -0.5 + 0.5 * sh_dh;
		
		for (int j = 0; j < newHeight; ++j)
		{
			double ty = by + sh_dh * j;
			for (int i = 0; i < newWidth; ++i)
			{
				double tx = bx + sw_dw * i;		
				
				if (LCD )
				{
					res.setData(i, j, 0, (float)lanczosSample(tx + SUBPIXEL_BIAS_R * sw_dw, ty, 0, taps));	
					res.setData(i, j, 1, (float)lanczosSample(tx, ty, 1, taps));	
					res.setData(i, j, 2, (float)lanczosSample(tx + SUBPIXEL_BIAS_B * sw_dw, ty, 2, taps));	
					//res.setData(i, j, 3, (float)lanczosSample(tx, ty, 3, taps));		
				}
				else
				{
					res.setData(i, j, 0, (float)lanczosSample(tx, ty, 0, taps));
					res.setData(i, j, 1, (float)lanczosSample(tx, ty, 1, taps));	
					res.setData(i, j, 2, (float)lanczosSample(tx, ty, 2, taps));	
					//res.setData(i, j, 3, (float)lanczosSample(tx, ty, 3, taps));	
				}				
			}
		}		
		System.out.println("OK");
		return res;		
	}

	public HQImage sharpen(float amount)
	{
		HQImage res = new HQImage(width, height);
		
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				for (int k = 0; k < 4; ++k)
				{					
					double x = getData(i, j, k) * (1 + 8 * amount)
					         - getDataEdgeClamp(i-1, j-1, k) * amount
					         - getDataEdgeClamp(i  , j-1, k) * amount
					         - getDataEdgeClamp(i+1, j-1, k) * amount
					         - getDataEdgeClamp(i-1, j  , k) * amount
					         - getDataEdgeClamp(i+1, j  , k) * amount
					         - getDataEdgeClamp(i-1, j+1, k) * amount
					         - getDataEdgeClamp(i  , j+1, k) * amount
					         - getDataEdgeClamp(i+1, j+1, k) * amount;


					res.setData(i, j, k, (float)x);
				}
			}
		}
		return res;		
	}
	
	// L1 maps to L1, MAX map to 1.0
	// L0 maps to L0, MIN map to 0.0
	
	public void distort(double L0, double MIN, double L1, double MAX)
	{	
		HQImage LFimage = bilinearResize(width / 2, height / 2, false).bilinearResize(width / 4, height / 4, false)
		.lanczosResize(width, height, 4, false);
		double mid = 0.5 * (L0 + L1);
		
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{	
				for (int k = 0; k < 3; ++k)
				{
					double sample = getData(i, j, k);
					double LF = LFimage.getData(i, j, k);
					double HF = sample - LF;
					LF += 0.5 * (LF - mid);
					LF -= 0.2;
					if (LF > L1)
					{
						if (LF > MAX) LF = MAX;
						double x = Utils.map(LF, L1, MAX, 0.0, 1.0);
						x = x + x * x - x * x * x;
						LF = Utils.map(x, 0.0, 1.0, L1, 1.0);
					}
					else if (LF < L0)
					{
						if (LF < L0) LF = MIN;
						double x = Utils.map(LF, L0, MIN, 0.0, 1.0);
						x = x + x * x - x * x * x;
						LF = Utils.map(x, 0.0, 1.0, L0, 0.0);
					}		
					LF -= 0.5 * (mid - LF);
					
					double finalSample = LF + HF;// + HF;//;// + HF * 1.0;// * 2.0;			
					setData(i, j, k, (float)finalSample);
				}
			}
		}		
		
	}	
	
	
	public void stats()
	{
		float minR = 1, minG = 1, minB = 1;
		float maxR = 0, maxG = 0, maxB = 0;
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				float r = getData(i, j, 0);
				float g = getData(i, j, 1);
				float b = getData(i, j, 2);
				if (r < minR) 
				{					
					minR = r;					
				}
				if (r > maxR)
				{					
					maxR = r;					
				}
				if (g < minG)
				{					
					minG = g;
				}
				if (g > maxG)
				{					
					maxG = g;
				}
				if (b < minB)
				{
					minB = b;
				}
				if (b > maxB)
				{
					maxB = b;
				}
			}
		}
		System.out.println("minR = "  + minR + "   maxR = " + maxR);
		System.out.println("minG = "  + minG + "   maxG = " + maxG);
		System.out.println("minB = "  + minB + "   maxB = " + maxB);		
	}

	public void saveToFile(String filename) throws IOException
	{
		BufferedImage dest = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
		Random random = new Random();
		double clipEnergy = 0.0;
		
		
		for (int j = 0; j < height; ++j)
		{
			for (int i = 0; i < width; ++i)
			{
				float fr = getData(i, j, 0);
				float gr = getData(i, j, 1);
				float br = getData(i, j, 2);
				
				int r = (int)Math.round(getData(i, j, 0) * 255.0);
				int g = (int)Math.round(getData(i, j, 1) * 255.0);
				int b = (int)Math.round(getData(i, j, 2) * 255.0);
				int a = (int)Math.round(getData(i, j, 3) * 255.0);

				
				if (r < 0) 
				{
					r = 0;
				}
				if (g < 0) 
				{
					g = 0;
				}
				if (b < 0) 
				{
					b = 0;
				}
				if (a < 0) 
				{
					a = 0;
				}
				
				if (r > 255) 
				{
					r = 255;
				}
				if (g > 255) 
				{
					g = 255;
				}
				if (b > 255) 
				{
					b = 255;
				}
				if (a > 255) 
				{
					a = 255;
				}				
				
				dest.setRGB(i, j, (a << 24) | (r << 16) | (g << 8) | b);
			}
			
		}
		
		File outputFile = new File(filename);
		int i = filename.lastIndexOf('.');
		
		if (i == -1)
		{
			throw new IOException("Can't determine the extension of the output file " + filename);
		}
		
		String format = filename.substring(i+1);
		ImageIO.write(dest, format, outputFile);
	}
	
}
