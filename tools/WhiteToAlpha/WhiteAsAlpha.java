import java.io.*;

public class WhiteAsAlpha
{
	static void usage()
	{
		System.err.println("Usage: java WhiteAsAlpha <inout-file>");
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

		image.convertWhiteToAlpha();
	
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
