import numpy as np


def fib_memo(n):
    known = np.zeros(n)

    def memoize(k):
        if known[k] != 0:
            pass
        elif k == 1 or k == 2:
            known[k] = 1
        else:
            known[k] = memoize(k - 1) + memoize(k - 2)
        return known[k]

    return memoize(n - 1)


print(fib_memo(2000))
