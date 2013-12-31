import java.io.*;

public class WhiteAsAlpha
{
	static void usage()
	{
		System.err.println("Usage: java WhiteAsAlpha <inout-file>");
	}

	static float[] generateGaussianKernel(int size)
	{
		float[] res = new float[size];

		for (int s = 0; s < size; ++s)
			res[s] = 0;
		res[0] = 1;

		for (int s = 1; s < size; ++s)
		{			
			float last = 0;
			for (int i = 0; i < size; ++i)
			{
				float next = last + res[i];
			    last = res[i];
				res[i] = next;
			}
		}
		return res;
	}

	public static void main(String[] args)
	{	
		if (args.length != 1)
		{
			usage();
			return;	
		}
		
		HQImage image;		
		
		try
		{
			image = new HQImage(args[0]);
		} catch (IOException e)
		{
			System.err.println(e.getMessage());
			return;
		}

		int fontWidth = image.width / 16;


		int N = (int)(0.5 + 11.0 * fontWidth / 21.0);
		if ((N % 2) == 0)
			N += 1;

		//image = image.sharpen(0.20f);
        float[] weights = generateGaussianKernel(N);

        float divider = 0;
        for (int i = 0; i < N; ++i)
        	divider += weights[i];

		divider *= 1.3;

		HQImage shadow = image.blur(weights, divider);
		shadow.convertWhiteToAlpha();

		image.convertWhiteToAlpha();

		image = shadow.compose(image);
	
		try
		{
			image.saveToFile(args[0]);			
		} catch(IOException e)
		{
			System.err.println(e.getMessage());
			return;	
		}
	}
	
}
