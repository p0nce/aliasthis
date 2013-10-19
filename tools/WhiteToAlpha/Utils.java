
final public class Utils
{
	static public double sRGBToLinearComponent(double c)
	{
		if (c <= 0.04045)
		{
			return c / 12.92;
		}
		else
		{
			return Math.pow((c + 0.055) / 1.055, 2.4);
		}
	}
	
	static public double linearTosRGBComponent(double c)
	{
		if (c <= 0.0031308)
		{
			return c * 12.92;
		}
		else
		{
			return 1.055 * Math.pow(c, 1.0 / 2.4) - 0.055;
		}
	}
	
	static public double lanzcosImpulse(double x, int a)
	{
		if (x == 0.0)
		{
			return 1.0;
		}
		else if ((x < a ) && (x > -a))
		{
			double pix = Math.PI * x;
			return (a * Math.sin(pix) * Math.sin(pix / a)) / (pix * pix);
		}
		else return 0.0;
	}	
	
	// hermite 3 point interpolation
	static public double hermite (double fracPart, double xm1, double x0, double x1, double x2)
	{
		
		double c = (x1 - xm1) * 0.5;		
		double v = x0 - x1;
		double w = c + v;
		double a = w + v + (x2 - x0) * 0.5;
		double b_neg = w + a;		
		return ((((a * fracPart) - b_neg) * fracPart + c) * fracPart + x0);
	}
	
	static public double map(double x, double a, double b, double c, double d)
	{
		double y = c + (d - c) * (x - a)/(b - a);
		return y;	
	}
	
}