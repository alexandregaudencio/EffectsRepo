using System.Collections.Generic;

public static class MetaballSystem2D<T> where T : class
{
    private static List<T> metaballs;

    static MetaballSystem2D()
    {
        metaballs = new List<T>();
    }

    public static void Add(T metaball)
    {
        metaballs.Add(metaball);
    }

    public static List<T> Get()
    {
        return metaballs;
    }

    public static void Remove(T metaball)
    {
        metaballs.Remove(metaball);
    }
}
