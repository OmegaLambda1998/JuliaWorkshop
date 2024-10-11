module Optimisation

using Chairmarks

#
# Recursive Fibonacci
#

function fibonacci(n)
    if n <= 2
        return 1
    end
    return fibonacci(n - 1) + fibonacci(n - 2)
end

function fibonacci_typed(n::N) where {N<:Integer}
    if n <= N(2)
        return N(1)
    end
    return fibonacci(n - N(1)) + fibonacci(n - N(2))
end



#
# Memoized Fibonacci
#

function fib_memo(n::N) where {N<:Integer}
    if n == 0
        return 1
    end
    known = zeros(N, n)
    function memoize(k)
        if known[k] != 0
            # do nothing
        elseif k == 1 || k == 2
            known[k] = 1
        else
            known[k] = memoize(k - 1) + memoize(k - 2)
        end
        return known[k]
    end
    return memoize(n)
end
#
# Benchmarking, Profiling, etc...
#

function benchmark_function(test_function::Function, init::N; timeout=1, jump=1) where {N<:Integer}
    benchmarks = Dict()
    # Run once to compile
    timed_out = false
    t = 0
    result = 0
    while !timed_out
        if mod(init, 10 * jump) == 0
            @info init, t, result
        end
        @debug "Testing $test_function with input = $init"
        @debug "Testing elapsed time"
        b = @be ($(Ref(test_function)))[]($(Ref(init))[])
        t = Chairmarks.median(b).time
        @debug "Elapsed time = $t"
        timed_out = t > timeout
        if !timed_out
            result = test_function(init)
            @debug "Result = $result"
            benchmarks[init] = (t, result)
            init += N(jump)
        end
    end
    return benchmarks
end

export main
function main()

    test_functions = Dict(
        #"Basic Fibonacci" => (fibonacci, (x -> x)),
        #"BigInt Basic Fibonacci" => (fibonacci, BigInt),
        #"Typed Fibonacci" => (fibonacci_typed, (x -> x)),
        #"BigInt Typed Fibonacci" => (fibonacci_typed, BigInt),
        #"Memoised Fibonacci" => (fib_memo, (x -> x)),
        "BigInt Memoised Fibonacci" => (fib_memo, BigInt),
    )

    results = Dict()

    for name in keys(test_functions)
        test_function, transform = test_functions[name]
        @info "Testing $name"
        results[name] = benchmark_function(test_function, transform(0); jump=1)
        @info maximum(keys(results[name]))
    end
end

function (@main)(ARGS)
    main()
end

end # module Optimisation
