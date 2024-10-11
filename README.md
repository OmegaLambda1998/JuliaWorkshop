# JuliaWorkshop

A collection of data, codes, and slides presented as is, with no promises as to the quality, consistency, or ease of use 😛

## [`Code/Scripts`](Code/Scripts)

Example of reading in, analysing, and writing out data in Julia and python. Meant to highlight the similarities and syntactic differences between the two languages. Also highlights that for "quick and dirty" jobs, Python is often faster

## [`Code/Environments`](Code/Environments)

Basic Julia and Python environments for plotting data. Again highlighting the similarities in syntactic form. Also shows off Julia's in-built package environment.

## [`Code/Optimisation`](Code/Optimisation)

A variety of implementations of the Fibonacci sequence, setup to run until the execution takes longer than a second.

I've also included a memoised fibonacci implemented in Python to provide a comparison. Whilst Python will run into recursion limits at around an input of 1000 - 2000, Julia is able to compile away much of the recursion and can easily reach an input upwards of 40,000 - 50,000

## [`Code/StructsMethodsTypes`](Code/StructsMethodsTypes)

Shows of the power of Multiple Dispatch, allowing independently defined methods of reading and storing lightcurve data to share the same plotting code without changing the plotting source code. Also shows off how implementing additional features after the fact (adding units to the data) can be trivially accomplished.