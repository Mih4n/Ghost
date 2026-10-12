// Точка входа: загружает договоры и печатает их количество.
using System;

class Program
{
    static void Main()
    {
        var contracts = Repository.Load("contracts.db");
        Console.WriteLine($"Договоров: {contracts.Count}");
    }
}
