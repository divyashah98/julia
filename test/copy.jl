mainres = ([4, 5, 3],
           [1, 5, 3])
bitres = ([true, true, false],
          [false, true, false])

type Tsk
    t::Task
    f::Function
    function Tsk(x)
        fx() = for i in x produce(i) end
        new(Task(fx), fx)
    end
end
Base.start(itr::Tsk) = (itr.t = Task(itr.f); nothing)
Base.done(itr::Tsk, _) = done(itr.t, _)
Base.next(itr::Tsk, _) = next(itr.t, _)

for (dest, src, bigsrc, res) in [
    ([1, 2, 3], [4, 5], [1, 2, 3, 4, 5], mainres),
    ([1, 2, 3], 4:5, 1:5, mainres),
    ([1, 2, 3], Tsk(4:5), Tsk(1:5), mainres),
    (falses(3), trues(2), trues(5), bitres)]

    @test copy!(copy(dest), src) == res[1]
    @test copy!(copy(dest), 1, src) == res[1]
    @test copy!(copy(dest), 2, src, 2) == res[2]
    @test copy!(copy(dest), 2, src, 2, 1) == res[2]

    @test copy!(copy(dest), 99, src, 99, 0) == dest

    for idx in [0, 4]
        @test_throws BoundsError copy!(dest, idx, src)
        @test_throws BoundsError copy!(dest, idx, src, 1)
        @test_throws BoundsError copy!(dest, idx, src, 1, 1)
        @test_throws BoundsError copy!(dest, 1, src, idx)
        @test_throws BoundsError copy!(dest, 1, src, idx, 1)
    end

    @test_throws BoundsError copy!(dest, 1, src, 1, -1)

    @test_throws BoundsError copy!(dest, bigsrc)

    @test_throws BoundsError copy!(dest, 3, src)
    @test_throws BoundsError copy!(dest, 3, src, 1)
    @test_throws BoundsError copy!(dest, 3, src, 1, 2)

    @test_throws BoundsError copy!(dest, 1, src, 2, 2)
end
